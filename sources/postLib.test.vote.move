//
// done 
// upvote/downvote expert post
//

#[test_only]
module basics::postLib_test_vote
{
    use basics::communityLib;
    use basics::postLib;
    use basics::userLib;
    use basics::i64Lib;
    use sui::test_scenario::{Self, Scenario};

    // TODO: add enum PostType      //import
    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;
    const DOCUMENTATION: u8 = 3;

    const DOWNVOTED_ITEM: u8 = 1;
    const CANCELVOTED_ITEM: u8 = 2;
    const UPVOTED_ITEM: u8 = 3;

    const USER: address = @0xA1;
    const USER1: address = @0xA2;

    fun change_name(scenario: &mut Scenario, post_type: u8) {        // name from tests solidity
        let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
        let communityCollection = &mut community_val;
        let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
        let postCollection = &mut post_val;
        let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
        let userCollection = &mut user_val;
        userLib::create_user(userCollection, test_scenario::ctx(scenario));
        communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
        postLib::create_post_with_type(postCollection, communityCollection, userCollection, post_type, test_scenario::ctx(scenario));

        test_scenario::return_shared(community_val);
        test_scenario::return_shared(post_val);
        test_scenario::return_shared(user_val);
    }

    #[test]
    fun test_upvote_expert_post() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            change_name(scenario, EXPERT_POST);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                true,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                ipfsDoc,
                postTime,
                author,
                rating,
                communityId,
                officialReply,
                bestReply,
                deletedReplyCount,
                isDeleted,
                tags,
                properties,
                historyVotes,
                votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 0);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 0);
            assert!(postTime == 0, 0);
            assert!(author == USER, 0);
            assert!(rating == i64Lib::from(1), 0);
            assert!(communityId == 1, 0);
            assert!(officialReply == 0, 0);
            assert!(bestReply == 0, 0);
            assert!(deletedReplyCount == 0, 0);
            assert!(isDeleted == false, 0);
            assert!(tags == vector<u64>[1, 2], 0);
            assert!(properties == vector<u8>[], 0);
            assert!(historyVotes == vector<u8>[UPVOTED_ITEM], 0);
            assert!(votedUsers == vector<address>[USER1], 0);

            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_cancel_upvote_expert_post() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            change_name(scenario, EXPERT_POST);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                true,
                test_scenario::ctx(scenario)
            );

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                true,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                author,
                rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                historyVotes,
                votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 0);
            assert!(author == USER, 0);
            assert!(rating == i64Lib::from(0), 0);
            assert!(historyVotes == vector<u8>[CANCELVOTED_ITEM], 0);
            assert!(votedUsers == vector<address>[USER1], 0);

            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_upvote_after_cancel_upvote_expert_post() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            change_name(scenario, EXPERT_POST);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                true,
                test_scenario::ctx(scenario)
            );

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                true,
                test_scenario::ctx(scenario)
            );

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                true,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                author,
                rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                historyVotes,
                votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 0);
            assert!(author == USER, 0);
            assert!(rating == i64Lib::from(1), 0);
            assert!(historyVotes == vector<u8>[UPVOTED_ITEM], 0);
            assert!(votedUsers == vector<address>[USER1], 0);

            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_upvote_to_downvote_expert_post() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            change_name(scenario, EXPERT_POST);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                true,
                test_scenario::ctx(scenario)
            );

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                false,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                author,
                rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                historyVotes,
                votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 0);
            assert!(author == USER, 0);
            assert!(rating == i64Lib::neg_from(1), 0);
            assert!(historyVotes == vector<u8>[DOWNVOTED_ITEM], 0);
            assert!(votedUsers == vector<address>[USER1], 0);

            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_upvote_after_cancel_downvote_expert_post() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            change_name(scenario, EXPERT_POST);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                false,
                test_scenario::ctx(scenario)
            );

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                false,
                test_scenario::ctx(scenario)
            );

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                true,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                author,
                rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                historyVotes,
                votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 0);
            assert!(author == USER, 0);
            assert!(rating == i64Lib::from(1), 0);
            assert!(historyVotes == vector<u8>[UPVOTED_ITEM], 0);
            assert!(votedUsers == vector<address>[USER1], 0);

            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_downvote_expert_post() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            change_name(scenario, EXPERT_POST);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                false,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                ipfsDoc,
                postTime,
                author,
                rating,
                communityId,
                officialReply,
                bestReply,
                deletedReplyCount,
                isDeleted,
                tags,
                properties,
                historyVotes,
                votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 0);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 0);
            assert!(postTime == 0, 0);
            assert!(author == USER, 0);
            assert!(rating == i64Lib::neg_from(1), 0);
            assert!(communityId == 1, 0);
            assert!(officialReply == 0, 0);
            assert!(bestReply == 0, 0);
            assert!(deletedReplyCount == 0, 0);
            assert!(isDeleted == false, 0);
            assert!(tags == vector<u64>[1, 2], 0);
            assert!(properties == vector<u8>[], 0);
            assert!(historyVotes == vector<u8>[DOWNVOTED_ITEM], 0);
            assert!(votedUsers == vector<address>[USER1], 0);

            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_cancel_downvote_expert_post() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            change_name(scenario, EXPERT_POST);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                false,
                test_scenario::ctx(scenario)
            );

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                false,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                author,
                rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                historyVotes,
                votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 0);
            assert!(author == USER, 0);
            assert!(rating == i64Lib::from(0), 0);
            assert!(historyVotes == vector<u8>[CANCELVOTED_ITEM], 0);
            assert!(votedUsers == vector<address>[USER1], 0);

            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_downvote_after_cancel_downvote_expert_post() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            change_name(scenario, EXPERT_POST);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                false,
                test_scenario::ctx(scenario)
            );

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                false,
                test_scenario::ctx(scenario)
            );

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                false,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                author,
                rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                historyVotes,
                votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 0);
            assert!(author == USER, 0);
            assert!(rating == i64Lib::neg_from(1), 0);
            assert!(historyVotes == vector<u8>[DOWNVOTED_ITEM], 0);
            assert!(votedUsers == vector<address>[USER1], 0);

            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_downvote_after_upvote_expert_post() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            change_name(scenario, EXPERT_POST);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                true,
                test_scenario::ctx(scenario)
            );

            postLib::voteForumItem(
                postCollection,
                userCollection,
                1,
                0,
                0,
                false,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                author,
                rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                historyVotes,
                votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 0);
            assert!(author == USER, 0);
            assert!(rating == i64Lib::neg_from(1), 0);
            assert!(historyVotes == vector<u8>[DOWNVOTED_ITEM], 0);
            assert!(votedUsers == vector<address>[USER1], 0);

            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };

        test_scenario::end(scenario_val);        
    }
}