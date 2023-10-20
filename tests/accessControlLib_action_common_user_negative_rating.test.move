#[test_only]
module peeranha::accessControlLib_action_common_user_negative_rating_test
{
    use peeranha::userLib;
    use peeranha::postLib::{Self, Post, PostMetaData, Comment};
    use peeranha::nftLib::{Self};
    use peeranha::followCommunityLib;
    use sui::clock;
    use peeranha::userLib_test;
    use peeranha::nft_test;
    use peeranha::communityLib_test;
    use peeranha::postLib_test;
    use peeranha::postLib_bot_test;
    use peeranha::postLib_votes_test;
    use peeranha::accessControlLib_common_role_test;
    use peeranha::accessControlLib;
    use sui::test_scenario::{Self, Scenario};
    use peeranha::i64Lib;
    use sui::object;


    // use std::debug;
    // debug::print(community);

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    const USER3: address = @0xA3;

    const RATING: u64 = 350;

    // ====== community admin action ======

    #[test]
    fun test_common_user_negative_update_profile() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user = &mut user_val;
            
            userLib::updateUser(user, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82");

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }
    
    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_CREATE_POST)]
    fun test_common_user_negative_rating_create_post() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_NOT_BOT_ROLE)]
    fun test_common_user_negative_rating_create_bot_post() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_bot_test::create_standart_post_by_bot(&time, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_EDIT_ITEM)]
    fun test_common_user_negative_rating_edit_own_post() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::authorEditPost(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                user,
                post,
                post_meta_data,
                community,
                x"0000000000000000000000000000000000000000000000000000000000000005",
                1,
                vector<u64>[2, 3],
                1,
                test_scenario::ctx(scenario),
            );
            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, post_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_MODERATOR)]
    fun test_common_user_negative_rating_edit_not_own_post_meta_data() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::moderatorEditPostMetaData(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                user,
                post_meta_data,
                community,
                1,
                vector<u64>[2, 3],
                1,
                test_scenario::ctx(scenario),
            );
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_DELETE_ITEM)]
    fun test_common_user_negative_rating_delete_own_post_meta_data() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                &time,
                user,
                post_meta_data,
                test_scenario::ctx(scenario),
            );
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_NOT_ALLOWED_DELETE)]
    fun test_common_user_negative_rating_delete_not_own_post_meta_data() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                &time,
                user,
                post_meta_data,
                test_scenario::ctx(scenario),
            );
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_CREATE_REPLY)]
    fun test_common_user_negative_rating_create_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_NOT_BOT_ROLE)]
    fun test_common_user_negative_rating_create_bot_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_bot_test::create_standart_reply_by_bot(&time, vector<u8>[1], scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_NOT_COMMUNITY_ADMIN)]
    fun test_common_user_negative_rating_create_official_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            postLib::createReply(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                &time,
                user,
                post_meta_data,
                0,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                true,
                1,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_EDIT_ITEM)]
    fun test_common_user_negative_rating_edit_own_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::moderatorEditReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
                false,
                0
            );
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_REPLY_NOT_EXIST)]
    fun test_common_user_negative_rating_edit_not_exist_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::moderatorEditReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
                false,
                0
            );
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_REPLY_DELETED)]
    fun test_common_user_negative_rating_edit_deleted_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deleteReply(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                &time,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::moderatorEditReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
                false,
                0
            );
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_MODERATOR)]
    fun test_common_user_negative_rating_edit_not_own_reply_meta_data() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::moderatorEditReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
                false,
                0
            );
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_ONLY_OWNER_BY_POST_CAN_CHANGE_STATUS_BEST_REPLY)]
    fun test_common_user_negative_rating_set_not_own_best_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario),
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_ONLY_OWNER_BY_POST_CAN_CHANGE_STATUS_BEST_REPLY)]
    fun test_common_user_negative_rating_set_own_best_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario),
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_DELETE_ITEM)]
    fun test_common_user_negative_rating_deleted_reply_own_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deleteReply(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                &time,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_NOT_ALLOWED_DELETE)]
    fun test_common_user_negative_rating_deleted_not_own_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deleteReply(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                &time,
                user,
                post_meta_data,
                1,
                test_scenario::ctx(scenario)
            );
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_CREATE_COMMENT)]
    fun test_common_user_negative_rating_create_comment_to_not_own_post() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_comment(&time, 0, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_CREATE_COMMENT)]
    fun test_common_user_negative_rating_create_comment_to_not_own_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_comment(&time, 1, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_CREATE_COMMENT)]
    fun test_common_user_negative_rating_create_comment_to_own_post() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_comment(&time, 0, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_CREATE_COMMENT)]
    fun test_common_user_negative_rating_create_comment_to_own_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_comment(&time, 1, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_EDIT_ITEM)]
    fun test_common_user_negative_rating_edit_own_comment_to_post() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            postLib_test::create_standart_comment(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING + 100, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;
            
            postLib::editComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                comment,
                0,
                1,
                x"0000000000000000000000000000000000000000000000000000000000000003",
                1
            );

            test_scenario::return_to_sender(scenario, comment_val);
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };
        
        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_NOT_ALLOWED_DELETE)]
    fun test_common_user_negative_rating_delete_not_own_comment_to_post() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_comment(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deleteComment(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                user,
                post_meta_data,
                0,
                1,
                 test_scenario::ctx(scenario),
            );
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_NOT_ALLOWED_DELETE)]
    fun test_common_user_negative_rating_delete_not_own_comment_to_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_comment(&time, 1, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let achievement_collection = &mut achievement_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deleteComment(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                user,
                post_meta_data,
                1,
                1,
                test_scenario::ctx(scenario),
            );
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_UPVOTE_POST)]
    fun test_common_user_negative_rating_upvote_post() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, true, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_CANCEL_VOTE)]
    fun test_common_user_negative_rating_cancel_vote_post() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, true, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING - 100, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, true, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_DOWNVOTE_POST)]
    fun test_common_user_negative_rating_downvote_post() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, false, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_UPVOTE_REPLY)]
    fun test_common_user_negative_rating_upvote_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, true, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_CANCEL_VOTE)]
    fun test_common_user_negative_rating_cancel_vote_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, true, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING - 100, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, true, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_DOWNVOTE_REPLY)]
    fun test_common_user_negative_rating_downvote_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_reply(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, false, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_VOTE_COMMENT)]
    fun test_common_user_negative_rating_upvote_comment() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_comment(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_comment(post_meta_data, 0, 1, true, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_CANCEL_VOTE)]
    fun test_common_user_negative_rating_cancel_vote_comment() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_comment(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(100, true, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_comment(post_meta_data, 0, 1, true, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING + 100, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_comment(post_meta_data, 0, 1, true, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = userLib::E_LOW_RATING_VOTE_COMMENT)]
    fun test_common_user_negative_rating_downvote_comment() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_comment(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_comment(post_meta_data, 0, 1, false, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_NOT_ADMIN)]
    fun test_common_user_negative_rating_create_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            communityLib_test::create_community(scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_ADMIN)]
    fun test_common_user_negative_rating_update_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            communityLib_test::update_common_community(scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_NOT_COMMUNITY_ADMIN)]
    fun test_common_user_negative_rating_update_documentation() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            communityLib_test::update_common_documentation(scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_ADMIN)]
    fun test_common_user_negative_rating_create_tag() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            communityLib_test::create_common_tag(scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_ADMIN)]
    fun test_common_user_negative_rating_update_tag() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            communityLib_test::update_common_tag(scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_ADMIN)]
    fun test_common_user_negative_rating_freeze_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            communityLib_test::freeze_common_community(scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_ADMIN)]
    fun test_common_user_negative_rating_unfreeze_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            communityLib_test::freeze_common_community(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            communityLib_test::unfreeze_common_community(scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_common_user_negative_rating_follow_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user = &mut user_val;
            let community = &mut community_val;
            
            followCommunityLib::followCommunity(user, community);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::end(scenario_val);
        clock::destroy_for_testing(time);
    }

    #[test]
    fun test_common_user_negative_rating_unfollow_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user = &mut user_val;
            let community = &mut community_val;
            
            followCommunityLib::followCommunity(user, community);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            updateRating(RATING, false, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user = &mut user_val;
            let community = &mut community_val;
            
            followCommunityLib::unfollowCommunity(user, community);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::end(scenario_val);
        clock::destroy_for_testing(time);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_NOT_ADMIN)]
    fun test_bot_create_achievement() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            nft_test::create_standart_achievement(scenario);
        };

        test_scenario::end(scenario_val);
        clock::destroy_for_testing(time);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_ADMIN)]
    fun test_bot_create_community_achievement() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            nft_test::create_community_standart_achievement(scenario);
        };

        test_scenario::end(scenario_val);
        clock::destroy_for_testing(time);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_NOT_ALLOWED_NOT_ADMIN)]
    fun test_bot_unlock_manual_achievement() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time;
        {
            time = init_accessControlLib_user2_is_common_negative_rating(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            nft_test::create_standart_manual_achievement(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            nft_test::unlock_standart_manual_achievement(scenario);
        };

        test_scenario::end(scenario_val);
        clock::destroy_for_testing(time);
    }

    // ====== Support functions ======

    public fun updateRating(changeRating: u64, isPositive: bool, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
        let achievement_collection = &mut achievement_collection_val;
        let userId = object::id(&mut user_val);
        let user_rating_collection = &mut user_rating_collection_val;
        let community = &mut community_val;
        userLib::updateRating_test(
            user_rating_collection,
            userId,
            achievement_collection,
            if(isPositive) i64Lib::from(changeRating) else i64Lib::neg_from(changeRating),
            object::id(community),
            test_scenario::ctx(scenario),
        );

        postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    #[test_only]
    public fun init_accessControlLib_user2_is_common_negative_rating(scenario: &mut Scenario) : clock::Clock {
        let time = clock::create_for_testing(test_scenario::ctx(scenario));
        {
            userLib::test_init(test_scenario::ctx(scenario));
            nftLib::test_init(test_scenario::ctx(scenario));
            accessControlLib::test_init(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            accessControlLib_common_role_test::grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            communityLib_test::create_community(scenario);
        };

        time
    }
}