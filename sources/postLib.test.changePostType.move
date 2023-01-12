//
// done
// edit post type (without ratings)
//

#[test_only]
module basics::postLib_test_changePostType
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
    const USER: address = @0xA1;

    fun change_name(        // todo: change name
        userCollection: &mut userLib::UserCollection,
        communityCollection: &mut communityLib::CommunityCollection,
        postCollection: &mut postLib::PostCollection,
        scenario: &mut Scenario,
        post_type: u8
    ) {        // name from tests solidity
        userLib::create_user(userCollection, test_scenario::ctx(scenario));
        communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
        postLib::create_post_with_type(postCollection, communityCollection, userCollection, post_type, test_scenario::ctx(scenario));
    }


    #[test, expected_failure(abort_code = postLib::E_POST_NOT_EXIST)]
    fun test_change_post_type_post_does_not_exist() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2],
                1,
                COMMON_POST,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_change_post_type_post_has_been_deleted() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            change_name(userCollection, communityCollection, postCollection, scenario, EXPERT_POST);
            postLib::deletePost(
                postCollection,
                userCollection,
                1,
                test_scenario::ctx(scenario)
            );

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2],
                1,
                COMMON_POST,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_post_type_expert_to_common() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            change_name(userCollection, communityCollection, postCollection, scenario, EXPERT_POST);

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2],
                1,
                COMMON_POST,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                ipfsDoc,
                _postTime,
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

            
            assert!(postType == COMMON_POST, 0);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 0);
            assert!(author == USER, 0);
            assert!(rating == i64Lib::zero(), 0);
            assert!(communityId == 1, 0);
            assert!(officialReply == 0, 0);
            assert!(bestReply == 0, 0);
            assert!(deletedReplyCount == 0, 0);
            assert!(isDeleted == false, 0);
            assert!(tags == vector<u64>[1, 2], 0);
            assert!(properties == vector<u8>[], 0);
            assert!(historyVotes == vector<u8>[], 0);
            assert!(votedUsers == vector<address>[], 0);
            
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_post_type_expert_to_tutorial() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            change_name(userCollection, communityCollection, postCollection, scenario, EXPERT_POST);

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2],
                1,
                TUTORIAL,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                _historyVotes,
                _votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == TUTORIAL, 0);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_ERROR_POST_TYPE)]
    fun test_change_post_type_expert_to_tutorial_post_has_reply() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            change_name(userCollection, communityCollection, postCollection, scenario, EXPERT_POST);
            postLib::create_reply(postCollection, test_scenario::ctx(scenario));

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2],
                1,
                TUTORIAL,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_post_type_expert_to_tutorial_post_had_reply() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            change_name(userCollection, communityCollection, postCollection, scenario, EXPERT_POST);
            postLib::create_reply(postCollection, test_scenario::ctx(scenario));
            postLib::deleteReply(
                postCollection,
                userCollection,
                1,
                1,
                test_scenario::ctx(scenario)
            );

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2],
                1,
                TUTORIAL,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                _historyVotes,
                _votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == TUTORIAL, 0);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_post_type_common_to_expert() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            change_name(userCollection, communityCollection, postCollection, scenario, COMMON_POST);

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2],
                1,
                EXPERT_POST,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                ipfsDoc,
                _postTime,
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
            assert!(author == USER, 0);
            assert!(rating == i64Lib::zero(), 0);
            assert!(communityId == 1, 0);
            assert!(officialReply == 0, 0);
            assert!(bestReply == 0, 0);
            assert!(deletedReplyCount == 0, 0);
            assert!(isDeleted == false, 0);
            assert!(tags == vector<u64>[1, 2], 0);
            assert!(properties == vector<u8>[], 0);
            assert!(historyVotes == vector<u8>[], 0);
            assert!(votedUsers == vector<address>[], 0);
            
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_post_type_common_to_tutorial() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            change_name(userCollection, communityCollection, postCollection, scenario, COMMON_POST);

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2],
                1,
                TUTORIAL,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                _historyVotes,
                _votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == TUTORIAL, 0);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_ERROR_POST_TYPE)]
    fun test_change_post_type_common_to_tutorial_post_has_reply() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            change_name(userCollection, communityCollection, postCollection, scenario, COMMON_POST);
            postLib::create_reply(postCollection, test_scenario::ctx(scenario));

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2],
                1,
                TUTORIAL,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_post_type_common_to_tutorial_post_had_reply() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            change_name(userCollection, communityCollection, postCollection, scenario, COMMON_POST);
            postLib::create_reply(postCollection, test_scenario::ctx(scenario));
            postLib::deleteReply(
                postCollection,
                userCollection,
                1,
                1,
                test_scenario::ctx(scenario)
            );

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2],
                1,
                TUTORIAL,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                _historyVotes,
                _votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == TUTORIAL, 0);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_post_type_tutorial_to_expert_post() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            change_name(userCollection, communityCollection, postCollection, scenario, TUTORIAL);

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2],
                1,
                EXPERT_POST,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                _historyVotes,
                _votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == EXPERT_POST, 0);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_post_type_tutorial_to_common_post() {
        let scenario_val = test_scenario::begin(USER);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            postLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
            let postCollection = &mut post_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            change_name(userCollection, communityCollection, postCollection, scenario, TUTORIAL);

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<u64>[1, 2],
                1,
                COMMON_POST,
                test_scenario::ctx(scenario)
            );

            let (
                postType,
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                _isDeleted,
                _tags,
                _properties,
                _historyVotes,
                _votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(postType == COMMON_POST, 0);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }
}