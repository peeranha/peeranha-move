#[test_only]
module basics::postLib_best_reply_rating_test
{
    use basics::postLib::{Self, PostMetaData};
    use basics::postLib_test;
    use basics::postLib_votes_rating_test;
    use basics::postLib_change_post_type_test;
    use sui::test_scenario::{Self};
    use basics::userLib::{User};
    use sui::clock::{Self};
    use basics::i64Lib;


    // use std::debug;
    // debug::print(community);

    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;

    const ENGLISH_LANGUAGE: u8 = 0;

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    const USER3: address = @0xA3;

    const START_USER_RATING: u64 = 10;

    // ====== Rating ======

    const DELETE_OWN_POST: u64 = 1;             // negative
    const MODERATOR_DELETE_POST: u64 = 2;       // negative

    //expert reply
    const DOWNVOTE_EXPERT_REPLY: u64 = 1;       // negative
    const UPVOTED_EXPERT_REPLY: u64 = 10;
    const DOWNVOTED_EXPERT_REPLY: u64 = 2;      // negative
    const ACCEPTED_EXPERT_REPLY: u64 = 15;
    const ACCEPT_EXPERT_REPLY: u64 = 2;
    const FIRST_EXPERT_REPLY: u64 = 5;
    const QUICK_EXPERT_REPLY: u64 = 5;

    //common reply 
    const DOWNVOTE_COMMON_REPLY: u64 = 1;       // negative
    const UPVOTED_COMMON_REPLY: u64 = 1;
    const DOWNVOTED_COMMON_REPLY: u64 = 1;      // negative
    const ACCEPTED_COMMON_REPLY: u64 = 3;
    const ACCEPT_COMMON_REPLY: u64 = 1;
    const FIRST_COMMON_REPLY: u64 = 1;
    const QUICK_COMMON_REPLY: u64 = 1;
    
    const DELETE_OWN_REPLY: u64 = 1;            // negative
    const MODERATOR_DELETE_REPLY: u64 = 2;      // negative     // to do

    #[test]
    fun test_mark_best_reply_expert() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user1_val;
        test_scenario::next_tx(scenario, USER1);
        {
            user1_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            let expectedPostAuthorIdRating = i64Lib::from(START_USER_RATING + ACCEPT_EXPERT_REPLY);
            let postAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let expectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY + ACCEPTED_EXPERT_REPLY);
            let replyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user1_val, community);            

            assert!(expectedPostAuthorIdRating == postAuthorRating, 0);
            assert!(expectedReplyAuthorIdRating == replyAuthorRating, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            test_scenario::return_to_sender(scenario, user1_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_mark_best_reply_common() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user1_val;
        test_scenario::next_tx(scenario, USER1);
        {
            user1_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            let expectedPostAuthorIdRating = i64Lib::from(START_USER_RATING + ACCEPT_COMMON_REPLY);
            let postAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let expectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY + ACCEPTED_COMMON_REPLY);
            let replyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user1_val, community);            

            assert!(expectedPostAuthorIdRating == postAuthorRating, 0);
            assert!(expectedReplyAuthorIdRating == replyAuthorRating, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            test_scenario::return_to_sender(scenario, user1_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_mark_own_best_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            let expectedAuthorIdRating = i64Lib::from(0);
            let authorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);

            assert!(expectedAuthorIdRating == authorRating, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_unmark_own_best_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );
            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            let expectedAuthorIdRating = i64Lib::from(0);
            let authorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);

            assert!(expectedAuthorIdRating == authorRating, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_change_another_best_reply_expert() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user1_val;
        test_scenario::next_tx(scenario, USER1);
        {
            user1_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );
            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                2,
                test_scenario::ctx(scenario)
            );

            let expectedPostAuthorIdRating = i64Lib::from(START_USER_RATING + ACCEPT_EXPERT_REPLY);
            let postAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let expectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY);
            let replyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user1_val, community);
            let expectedSecondReplyAuthorIdRating = i64Lib::from(START_USER_RATING + QUICK_EXPERT_REPLY + ACCEPTED_EXPERT_REPLY);
            let secondReplyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user3_val, community); 

            assert!(expectedPostAuthorIdRating == postAuthorRating, 0);
            assert!(expectedReplyAuthorIdRating == replyAuthorRating, 0);
            assert!(expectedSecondReplyAuthorIdRating == secondReplyAuthorRating, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            test_scenario::return_to_sender(scenario, user1_val);
        };


        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_change_another_best_reply_common() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user1_val;
        test_scenario::next_tx(scenario, USER1);
        {
            user1_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );
            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                2,
                test_scenario::ctx(scenario)
            );

            let expectedPostAuthorIdRating = i64Lib::from(START_USER_RATING + ACCEPT_COMMON_REPLY);
            let postAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let expectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY);
            let replyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user1_val, community);
            let expectedSecondReplyAuthorIdRating = i64Lib::from(START_USER_RATING + QUICK_COMMON_REPLY + ACCEPTED_COMMON_REPLY);
            let secondReplyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user3_val, community); 

            assert!(expectedPostAuthorIdRating == postAuthorRating, 0);
            assert!(expectedReplyAuthorIdRating == replyAuthorRating, 0);
            assert!(expectedSecondReplyAuthorIdRating == secondReplyAuthorRating, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            test_scenario::return_to_sender(scenario, user1_val);
        };


        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_unmark_best_reply_expert() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user1_val;
        test_scenario::next_tx(scenario, USER1);
        {
            user1_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );
            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            let expectedPostAuthorIdRating = i64Lib::from(START_USER_RATING);
            let postAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let expectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING + FIRST_EXPERT_REPLY + QUICK_EXPERT_REPLY);
            let replyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user1_val, community);

            assert!(expectedPostAuthorIdRating == postAuthorRating, 0);
            assert!(expectedReplyAuthorIdRating == replyAuthorRating, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            test_scenario::return_to_sender(scenario, user1_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_unmark_best_reply_common() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user1_val;
        test_scenario::next_tx(scenario, USER1);
        {
            user1_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );
            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            let expectedPostAuthorIdRating = i64Lib::from(START_USER_RATING);
            let postAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let expectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING + FIRST_COMMON_REPLY + QUICK_COMMON_REPLY);
            let replyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user1_val, community);

            assert!(expectedPostAuthorIdRating == postAuthorRating, 0);
            assert!(expectedReplyAuthorIdRating == replyAuthorRating, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            test_scenario::return_to_sender(scenario, user1_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_admin_delete_best_reply_expert() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deleteReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                &time,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;

            let expectedPostAuthorIdRating = i64Lib::from(START_USER_RATING + ACCEPT_EXPERT_REPLY);
            let postAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let expectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING - MODERATOR_DELETE_REPLY);
            let replyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user3_val, community);
            
            assert!(expectedPostAuthorIdRating == postAuthorRating, 0);
            assert!(expectedReplyAuthorIdRating == replyAuthorRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };


        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_admin_delete_best_reply_common() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deleteReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                &time,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;

            let expectedPostAuthorIdRating = i64Lib::from(START_USER_RATING + ACCEPT_COMMON_REPLY);
            let postAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let expectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING - MODERATOR_DELETE_REPLY);
            let replyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user3_val, community);
            
            assert!(expectedPostAuthorIdRating == postAuthorRating, 0);
            assert!(expectedReplyAuthorIdRating == replyAuthorRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };


        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_author_delete_post_with_best_reply_expert() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                &time,
                user,
                post_meta_data,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;

            let expectedPostAuthorIdRating = i64Lib::from(START_USER_RATING - DELETE_OWN_POST);
            let postAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let expectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING);
            let replyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user3_val, community);
            
            assert!(expectedPostAuthorIdRating == postAuthorRating, 0);
            assert!(expectedReplyAuthorIdRating == replyAuthorRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };


        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_author_delete_post_with_best_reply_common() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                &time,
                user,
                post_meta_data,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;

            let expectedPostAuthorIdRating = i64Lib::from(START_USER_RATING - DELETE_OWN_POST);
            let postAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            let expectedReplyAuthorIdRating = i64Lib::from(START_USER_RATING);
            let replyAuthorRating = postLib_votes_rating_test::getUserRating(user_rating_collection, &mut user3_val, community);
            
            assert!(expectedPostAuthorIdRating == postAuthorRating, 0);
            assert!(expectedReplyAuthorIdRating == replyAuthorRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };


        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }
}