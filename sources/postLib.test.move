#[test_only]
module basics::postLib_test
{
    use basics::postLib::{Self/*, Post, PostMetaData*/};
    use basics::userLib_test;
    use basics::communityLib_test;
    // use basics::i64Lib;
    use basics::communityLib::{/*Self,*/ Community};
    use basics::userLib::{Self, User, UsersRatingCollection};
    use basics::accessControl::{Self, UserRolesCollection/*, DefaultAdminCap*/};
    use sui::test_scenario::{Self, Scenario};
    // use sui::object::{Self, ID};
    use sui::clock::{Self, /*Clock*/};

    // TODO: add enum PostType      //export
    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;
    const DOCUMENTATION: u8 = 3;

    const ENGLISH_LANGUAGE: u8 = 0;
    const CHINESE_LANGUAGE: u8 = 1;
    const SPANISH_LANGUAGE: u8 = 2;
    const VIETNAMESE_LANGUAGE: u8 = 3;

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;

    #[test]
    fun test_create_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
            accessControl::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            communityLib_test::grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            communityLib_test::create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_post(scenario, &time);
        };

        // test_scenario::next_tx(scenario, USER1);
        // {
        //     let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
        //     let post_meta_data = &mut post_meta_data_val;
        //     let post_val = test_scenario::take_from_sender<Post>(scenario);
        //     let post = &mut post_val;

        //     // let (
        //     //     postType,
        //     //     ipfsDoc,
        //     //     postTime,
        //     //     author,
        //     //     rating,
        //     //     communityId,
        //     //     officialReply,
        //     //     bestReply,
        //     //     deletedReplyCount,
        //     //     isDeleted,
        //     //     tags,
        //     //     properties,
        //     //     historyVotes,
        //     //     votedUsers
        //     // ) = postLib::getPostData(postCollection, 1);

        //     assert!(postType == EXPERT_POST, 1);
        //     assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
        //     assert!(postTime == 0, 3);
        //     assert!(author == USER, 4);
        //     assert!(rating == i64Lib::zero(), 5);
        //     assert!(communityId == 1, 6);
        //     assert!(officialReply == 0, 7);
        //     assert!(bestReply == 0, 8);
        //     assert!(deletedReplyCount == 0, 9);
        //     assert!(isDeleted == false, 10);
        //     assert!(tags == vector<u64>[1, 2], 11);
        //     assert!(properties == vector<u8>[], 12);
        //     assert!(historyVotes == vector<u8>[], 13);
        //     assert!(votedUsers == vector<address>[], 14);

        //     test_scenario::return_shared(community_val);
        //     test_scenario::return_shared(post_val);
        //     test_scenario::return_shared(user_val);
        // };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    /*
    #[test]
    fun test_create_reply() {
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
            let user_val = test_scenario::take_shared<userLib::UsersRatingCollection>(scenario);
            let userRatingCollection = &mut user_val;
            userLib::create_user(userRatingCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            postLib::create_post(postCollection, communityCollection, userRatingCollection, test_scenario::ctx(scenario));
            
            postLib::createReply(
                postCollection,
                1,
                0,
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                false,
                test_scenario::ctx(scenario)
            );

            let (
                ipfsDoc,
                postTime,
                author,
                rating,
                parentReplyId,
                isFirstReply,
                isQuickReply,
                isDeleted,
                properties,
                historyVotes,
                votedUsers
            ) = postLib::getReplyData(postCollection, 1, 1);

            assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
            assert!(postTime == 0, 2);
            assert!(author == USER, 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(parentReplyId == 0, 5);
            assert!(isFirstReply == false, 6);
            assert!(isQuickReply == false, 7);
            assert!(isDeleted == false, 9);
            assert!(properties == vector<u8>[], 11);
            assert!(historyVotes == vector<u8>[], 12);
            assert!(votedUsers == vector<address>[], 13);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_comment_to_post() {
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
            let user_val = test_scenario::take_shared<userLib::UsersRatingCollection>(scenario);
            let userRatingCollection = &mut user_val;
            userLib::create_user(userRatingCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            postLib::create_post(postCollection, communityCollection, userRatingCollection, test_scenario::ctx(scenario));

            postLib::createComment(
                postCollection,
                1,
                0,
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                test_scenario::ctx(scenario)
            );

            let (
                ipfsDoc,
                postTime,
                author,
                rating,                
                isDeleted,
                properties,
                historyVotes,
                votedUsers
            ) = postLib::getCommentData(postCollection, 1, 0, 1);

            assert!(ipfsDoc == x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc", 1);
            assert!(postTime == 0, 2);
            assert!(author == USER, 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(isDeleted == false, 9);
            assert!(properties == vector<u8>[], 11);
            assert!(historyVotes == vector<u8>[], 12);
            assert!(votedUsers == vector<address>[], 13);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_comment_to_reply() {
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
            let user_val = test_scenario::take_shared<userLib::UsersRatingCollection>(scenario);
            let userRatingCollection = &mut user_val;
            userLib::create_user(userRatingCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            postLib::create_post(postCollection, communityCollection, userRatingCollection, test_scenario::ctx(scenario));
            postLib::create_reply(postCollection, test_scenario::ctx(scenario));

            postLib::createComment(
                postCollection,
                1,
                1,
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                test_scenario::ctx(scenario)
            );

            let (
                ipfsDoc,
                postTime,
                author,
                rating,                
                isDeleted,
                properties,
                historyVotes,
                votedUsers
            ) = postLib::getCommentData(postCollection, 1, 1, 1);

            assert!(ipfsDoc == x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc", 1);
            assert!(postTime == 0, 2);
            assert!(author == USER, 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(isDeleted == false, 9);
            assert!(properties == vector<u8>[], 11);
            assert!(historyVotes == vector<u8>[], 12);
            assert!(votedUsers == vector<address>[], 13);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_edit_post() {
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
            let user_val = test_scenario::take_shared<userLib::UsersRatingCollection>(scenario);
            let userRatingCollection = &mut user_val;
            userLib::create_user(userRatingCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            postLib::create_post(postCollection, communityCollection, userRatingCollection, test_scenario::ctx(scenario));

            postLib::editPost(
                postCollection,
                communityCollection,
                1,
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                vector<u64>[2],
                1,
                EXPERT_POST,
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

            assert!(postType == 0, 1);
            assert!(ipfsDoc == x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc", 2);
            assert!(postTime == 0, 3);
            assert!(author == USER, 4);
            assert!(rating == i64Lib::zero(), 5);
            assert!(communityId == 1, 6);
            assert!(officialReply == 0, 7);
            assert!(bestReply == 0, 8);
            assert!(deletedReplyCount == 0, 9);
            assert!(isDeleted == false, 10);
            assert!(tags == vector<u64>[2], 11);
            assert!(properties == vector<u8>[], 12);
            assert!(historyVotes == vector<u8>[], 13);
            assert!(votedUsers == vector<address>[], 14);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_edit_reply() {
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
            let user_val = test_scenario::take_shared<userLib::UsersRatingCollection>(scenario);
            let userRatingCollection = &mut user_val;
            userLib::create_user(userRatingCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            postLib::create_post(postCollection, communityCollection, userRatingCollection, test_scenario::ctx(scenario));
            postLib::create_reply(postCollection, test_scenario::ctx(scenario));

            postLib::editReply(
                postCollection,
                1,
                1,
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
                false,
                test_scenario::ctx(scenario)
            );

            let (
                ipfsDoc,
                postTime,
                author,
                rating,
                parentReplyId,
                isFirstReply,
                isQuickReply,
                isDeleted,
                properties,
                historyVotes,
                votedUsers
            ) = postLib::getReplyData(postCollection, 1, 1);

            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(postTime == 0, 2);
            assert!(author == USER, 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(parentReplyId == 0, 5);
            assert!(isFirstReply == false, 6);
            assert!(isQuickReply == false, 7);
            assert!(isDeleted == false, 9);
            assert!(properties == vector<u8>[], 11);
            assert!(historyVotes == vector<u8>[], 12);
            assert!(votedUsers == vector<address>[], 13);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_edit_comment_to_post() {
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
            let user_val = test_scenario::take_shared<userLib::UsersRatingCollection>(scenario);
            let userRatingCollection = &mut user_val;
            userLib::create_user(userRatingCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            postLib::create_post(postCollection, communityCollection, userRatingCollection, test_scenario::ctx(scenario));
            postLib::create_reply(postCollection, test_scenario::ctx(scenario));
            postLib::createComment(
                postCollection,
                1,
                0,
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                test_scenario::ctx(scenario)
            );

            postLib::editComment(
                postCollection,
                1,
                0,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                test_scenario::ctx(scenario)
            );

            let (
                ipfsDoc,
                postTime,
                author,
                rating,                
                isDeleted,
                properties,
                historyVotes,
                votedUsers
            ) = postLib::getCommentData(postCollection, 1, 0, 1);

            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(postTime == 0, 2);
            assert!(author == USER, 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(isDeleted == false, 9);
            assert!(properties == vector<u8>[], 11);
            assert!(historyVotes == vector<u8>[], 12);
            assert!(votedUsers == vector<address>[], 13);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_edit_comment_to_reply() {
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
            let user_val = test_scenario::take_shared<userLib::UsersRatingCollection>(scenario);
            let userRatingCollection = &mut user_val;
            userLib::create_user(userRatingCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            postLib::create_post(postCollection, communityCollection, userRatingCollection, test_scenario::ctx(scenario));
            postLib::create_reply(postCollection, test_scenario::ctx(scenario));
            postLib::createComment(
                postCollection,
                1,
                1,
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                test_scenario::ctx(scenario)
            );

            postLib::editComment(
                postCollection,
                1,
                1,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                test_scenario::ctx(scenario)
            );

            let (
                ipfsDoc,
                postTime,
                author,
                rating,                
                isDeleted,
                properties,
                historyVotes,
                votedUsers
            ) = postLib::getCommentData(postCollection, 1, 1, 1);

            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(postTime == 0, 2);
            assert!(author == USER, 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(isDeleted == false, 9);
            assert!(properties == vector<u8>[], 11);
            assert!(historyVotes == vector<u8>[], 12);
            assert!(votedUsers == vector<address>[], 13);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_post() {
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
            let user_val = test_scenario::take_shared<userLib::UsersRatingCollection>(scenario);
            let userRatingCollection = &mut user_val;
            userLib::create_user(userRatingCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            postLib::create_post(postCollection, communityCollection, userRatingCollection, test_scenario::ctx(scenario));
            
            postLib::deletePost(
                postCollection,
                userRatingCollection,
                1,
                test_scenario::ctx(scenario)
            );

            let (
                _postType,
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _communityId,
                _officialReply,
                _bestReply,
                _deletedReplyCount,
                isDeleted,
                _tags,
                _properties,
                _historyVotes,
                _votedUsers
            ) = postLib::getPostData(postCollection, 1);

            assert!(isDeleted == true, 10);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_reply() {
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
            let user_val = test_scenario::take_shared<userLib::UsersRatingCollection>(scenario);
            let userRatingCollection = &mut user_val;
            userLib::create_user(userRatingCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            postLib::create_post(postCollection, communityCollection, userRatingCollection, test_scenario::ctx(scenario));
            postLib::create_reply(postCollection, test_scenario::ctx(scenario));
            
            postLib::deleteReply(
                postCollection,
                userRatingCollection,
                1,
                1,
                test_scenario::ctx(scenario)
            );

            let (
                _ipfsDoc,
                _postTime,
                _author,
                _rating,
                _parentReplyId,
                _isFirstReply,
                _isQuickReply,
                isDeleted,
                _properties,
                _historyVotes,
                _votedUsers
            ) = postLib::getReplyData(postCollection, 1, 1);

            assert!(isDeleted == true, 9);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_comment_to_post() {
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
            let user_val = test_scenario::take_shared<userLib::UsersRatingCollection>(scenario);
            let userRatingCollection = &mut user_val;
            userLib::create_user(userRatingCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            postLib::create_post(postCollection, communityCollection, userRatingCollection, test_scenario::ctx(scenario));
            postLib::createComment(
                postCollection,
                1,
                0,
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                test_scenario::ctx(scenario)
            );

            postLib::deleteComment(
                postCollection,
                1,
                0,
                1,
                test_scenario::ctx(scenario)
            );

            let (
                _ipfsDoc,
                _postTime,
                _author,
                _rating,                
                isDeleted,
                _properties,
                _historyVotes,
                _votedUsers
            ) = postLib::getCommentData(postCollection, 1, 0, 1);

            assert!(isDeleted == true, 9);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_comment_to_reply() {
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
            let user_val = test_scenario::take_shared<userLib::UsersRatingCollection>(scenario);
            let userRatingCollection = &mut user_val;
            userLib::create_user(userRatingCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            postLib::create_post(postCollection, communityCollection, userRatingCollection, test_scenario::ctx(scenario));
            postLib::create_reply(postCollection, test_scenario::ctx(scenario));

            postLib::createComment(
                postCollection,
                1,
                1,
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                test_scenario::ctx(scenario)
            );

            postLib::deleteComment(
                postCollection,
                1,
                1,
                1,
                test_scenario::ctx(scenario)
            );

            let (
                _ipfsDoc,
                _postTime,
                _author,
                _rating,                
                isDeleted,
                _properties,
                _historyVotes,
                _votedUsers
            ) = postLib::getCommentData(postCollection, 1, 1, 1);

            assert!(isDeleted == true, 9);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);  
    }
    */

    #[test_only]
    public fun create_post(scenario: &mut Scenario, time: &clock::Clock) {
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;
        let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
        let user_rating_collection = &mut user_rating_collection_val;
        let community_val = test_scenario::take_shared<Community>(scenario);
        let community = &mut community_val;
        
        // usersRatingCollection: &userLib::UsersRatingCollection,
        // user: &mut userLib::User,
        // community: &communityLib::Community,
        // userRolesCollection: &accessControl::UserRolesCollection,
        // ipfsHash: vector<u8>, 
        // postType: u8,
        // tags: vector<u64>,
        // language: u8,
        // time: &Clock,
        // ctx: &mut TxContext

        
        postLib::createPost(
            user_rating_collection,
            user_roles_collection,
            time,
            user,
            community,
            x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
            EXPERT_POST,
            vector<u64>[1, 2],
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario)
        );

        test_scenario::return_shared(user_roles_collection_val);
        test_scenario::return_shared(user_rating_collection_val);
        test_scenario::return_shared(community_val);
        test_scenario::return_to_sender(scenario, user_val);
    }
}