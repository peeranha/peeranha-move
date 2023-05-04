#[test_only]
module basics::postLib_best_reply_rating_test
{
    use sui::object::{Self};
    use basics::postLib::{Self, PostMetaData};
    use basics::postLib_test;
    use sui::test_scenario::{Self};
    use basics::communityLib::{Community};
    use basics::userLib::{Self, User, UsersRatingCollection};
    use sui::clock::{Self};
    use basics::i64Lib;


    // use std::debug;
    // debug::print(community);

    const EXPERT_POST: u8 = 0;

    const ENGLISH_LANGUAGE: u8 = 0;

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;

    #[test]
    fun test_mark_best_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_test::init_postLib_test(scenario);
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

            // let expectedReplyAuthorIdRating = i64Lib::add(
            //     &i64Lib::add(&i64Lib::from(START_USER_RATING), &i64Lib::from(FIRST_EXPERT_REPLY)),
            //     &i64Lib::from(QUICK_EXPERT_REPLY)
            // );
            
            let _replyAuthorRating = getUserRating(user_rating_collection, user, community);

            // assert!(expectedVoteUserRating == voteUserRating, 0);

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

    /*

    #[test]
    fun test_change_another_best_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_test::init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
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

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 1, 0);

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                2,
                test_scenario::ctx(scenario)
            );

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 2, 1);


            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_unmark_best_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_test::init_postLib_test(scenario);
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

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 1, 0);

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 0, 1);


            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_admin_delete_best_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_test::init_postLib_test(scenario);
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

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 1, 0);

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

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 0, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }
    */

    #[test_only]
    public fun getUserRating(
        user_rating_collection: &UsersRatingCollection,
        user: &User,
        community: &Community,
    ): i64Lib::I64 {
        let communityId = object::id(community);
        let userId = object::id(user);
        let userCommunityRating = userLib::getUserCommunityRating(user_rating_collection, userId);
        userLib::getUserRating(userCommunityRating, communityId)
    }
}