#[test_only]
module basics::postLib_best_reply_test
{
    use basics::postLib::{Self, PostMetaData};
    use basics::postLib_test;
    use sui::test_scenario::{Self};
    use sui::clock::{Self};

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

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_test::create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
            );

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 1, 1);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_mark_not_own_best_reply() {
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

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
            );

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 1, 1);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
            );

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 1, 0);

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                2,
            );

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 2, 1);


            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
            );

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 1, 0);

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
            );

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 0, 1);


            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
            );

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 1, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deleteReply(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
                1,
            ); 

            let bestReplyMetaDataKey = postLib::getBestReplyMetaDataKey(post_meta_data);
            assert!(bestReplyMetaDataKey == 0, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }
}