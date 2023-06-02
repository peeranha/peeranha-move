#[test_only]
module basics::postLib_exception_test
{
    use basics::postLib::{Self, Post, PostMetaData, Reply, Comment};
    use basics::userLib_test;
    use basics::commonLib;
    use basics::communityLib_test;
    use basics::postLib_votes_test;
    use basics::postLib_change_post_type_test;
    use basics::communityLib::{Self, Community};
    use basics::userLib::{Self, User, UsersRatingCollection};
    use basics::accessControlLib::{Self, UserRolesCollection};
    use sui::test_scenario::{Self, Scenario};
    use sui::clock::{Self};

    // use std::debug;
    // debug::print(community);

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


    #[test, expected_failure(abort_code = communityLib::E_COMMUNITY_IS_FROZEN)]
    fun test_create_post_community_is_frozen() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time = clock::create_for_testing(test_scenario::ctx(scenario));
        {
            userLib::init_test(test_scenario::ctx(scenario));
            accessControlLib::init_test(test_scenario::ctx(scenario));
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
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            communityLib::freezeCommunity(user_roles_collection, user, community);

            test_scenario::return_shared(community_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_post(&time, x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = communityLib::E_TAG_DOES_NOT_EXIST)]
    fun test_create_post_first_tagId_more_than_exist() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time = clock::create_for_testing(test_scenario::ctx(scenario));
        {
            userLib::init_test(test_scenario::ctx(scenario));
            accessControlLib::init_test(test_scenario::ctx(scenario));
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;

            postLib::createPost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                community,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                EXPERT_POST,
                vector<u64>[7, 2],
                ENGLISH_LANGUAGE,
                test_scenario::ctx(scenario)
            );

            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = communityLib::E_TAG_DOES_NOT_EXIST)]
    fun test_create_post_second_tagId_more_than_exist() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time = clock::create_for_testing(test_scenario::ctx(scenario));
        {
            userLib::init_test(test_scenario::ctx(scenario));
            accessControlLib::init_test(test_scenario::ctx(scenario));
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;

            postLib::createPost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                community,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                EXPERT_POST,
                vector<u64>[2, 7],
                ENGLISH_LANGUAGE,
                test_scenario::ctx(scenario)
            );

            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = communityLib::E_TAG_ID_CAN_NOT_BE_0)]
    fun test_create_post_first_tagId_is_0() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time = clock::create_for_testing(test_scenario::ctx(scenario));
        {
            userLib::init_test(test_scenario::ctx(scenario));
            accessControlLib::init_test(test_scenario::ctx(scenario));
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;

            postLib::createPost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                community,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                EXPERT_POST,
                vector<u64>[0, 2],
                ENGLISH_LANGUAGE,
                test_scenario::ctx(scenario)
            );

            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = communityLib::E_TAG_ID_CAN_NOT_BE_0)]
    fun test_create_post_second_tagId_is_0() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time = clock::create_for_testing(test_scenario::ctx(scenario));
        {
            userLib::init_test(test_scenario::ctx(scenario));
            accessControlLib::init_test(test_scenario::ctx(scenario));
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;

            postLib::createPost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                community,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                EXPERT_POST,
                vector<u64>[2, 0],
                ENGLISH_LANGUAGE,
                test_scenario::ctx(scenario)
            );

            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = commonLib::E_INVALIT_IPFSHASH, location = postLib)]
    fun test_create_post_empty_ipfs() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time = clock::create_for_testing(test_scenario::ctx(scenario));
        {
            userLib::init_test(test_scenario::ctx(scenario));
            accessControlLib::init_test(test_scenario::ctx(scenario));
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
            create_post(&time, x"", scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_AT_LEAST_ONE_TAG_IS_REQUIRED)]
    fun test_create_post_without_tags() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        let time = clock::create_for_testing(test_scenario::ctx(scenario));
        {
            userLib::init_test(test_scenario::ctx(scenario));
            accessControlLib::init_test(test_scenario::ctx(scenario));
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
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;

            postLib::createPost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                community,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                EXPERT_POST,
                vector<u64>[],
                ENGLISH_LANGUAGE,
                test_scenario::ctx(scenario)
            );

            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_YOU_CAN_NOT_PUBLISH_REPLIES_IN_TUTORIAL)]
    fun test_create_reply_in_tutorial() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(TUTORIAL, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            postLib_change_post_type_test::create_reply(post_meta_data, &time, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_USER_IS_FORBIDDEN_TO_REPLY_ON_REPLY_FOR_EXPERT_AND_COMMON_TYPE_OF_POST)]
    fun test_create_reply_to_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            postLib::createReply(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
                1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                false,
                ENGLISH_LANGUAGE,
                test_scenario::ctx(scenario)
            );

            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = commonLib::E_INVALIT_IPFSHASH, location = postLib)]
    fun test_create_reply_empty_ipfs() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_USER_CAN_NOT_PUBLISH_2_REPLIES_FOR_POST)]
    fun test_create_two_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_create_reply_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = commonLib::E_INVALIT_IPFSHASH, location = postLib)]
    fun test_create_comment_empty_ipfs() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 0, x"", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_create_comment_to_post_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 0, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_create_comment_to_reply_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 1, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_REPLY_DELETED)]
    fun test_create_comment_to_reply_reply_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };


        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 1, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_REPLY_NOT_EXIST)]
    fun test_create_comment_to_reply_reply_not_exist() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 1, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = commonLib::E_INVALIT_IPFSHASH, location = postLib)]
    fun test_edit_post_empty_ipfs() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;

            postLib::authorEditPost(
                user_rating_collection,
                user_roles_collection,
                user,
                post,
                post_meta_data,
                community,
                x"",
                EXPERT_POST,
                vector<u64>[2, 3],
                ENGLISH_LANGUAGE,
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, post_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_ITEM_ID_NOT_MATCHING)]
    fun test_edit_post_post_and_postMetaData_not_match() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;

            postLib::createPost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                community,
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                EXPERT_POST,
                vector<u64>[1, 2],
                ENGLISH_LANGUAGE,
                test_scenario::ctx(scenario)
            );

            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;

            postLib::authorEditPost(
                user_rating_collection,
                user_roles_collection,
                user,
                post,
                post_meta_data,
                community,
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aeda",
                EXPERT_POST,
                vector<u64>[2, 3],
                ENGLISH_LANGUAGE,
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, post_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_edit_post_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );
            
            postLib::authorEditPost(
                user_rating_collection,
                user_roles_collection,
                user,
                post,
                post_meta_data,
                community,
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aeda",
                EXPERT_POST,
                vector<u64>[2, 3],
                ENGLISH_LANGUAGE,
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, post_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }
    
    #[test, expected_failure(abort_code = communityLib::E_TAG_DOES_NOT_EXIST)]
    fun test_edit_post_tagId_more_than_exist() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;
            
            postLib::authorEditPost(
                user_rating_collection,
                user_roles_collection,
                user,
                post,
                post_meta_data,
                community,
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aeda",
                EXPERT_POST,
                vector<u64>[2, 8],
                ENGLISH_LANGUAGE,
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, post_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = communityLib::E_TAG_ID_CAN_NOT_BE_0)]
    fun test_edit_post_tagId_is_0() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;

            postLib::authorEditPost(
                user_rating_collection,
                user_roles_collection,
                user,
                post,
                post_meta_data,
                community,
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aeda",
                EXPERT_POST,
                vector<u64>[2, 0],
                ENGLISH_LANGUAGE,
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, post_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = commonLib::E_INVALIT_IPFSHASH, location = postLib)]
    fun test_edit_reply_empty_ipfs() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;

            postLib::authorEditReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                reply,
                1,
                x"",
                false,
                ENGLISH_LANGUAGE
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, reply_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_edit_reply_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );
            
            postLib::authorEditReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                reply,
                1,
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                false,
                ENGLISH_LANGUAGE
            );

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_ITEM_ID_NOT_MATCHING)]
    fun test_edit_reply_reply_and_replyMetaData_not_match() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;
            
            postLib::authorEditReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                reply,
                1,
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                false,
                ENGLISH_LANGUAGE
            );

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_edit_comment_to_post_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 0, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;
            
            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );
            
            postLib::editComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                comment,
                0,
                1,
                x"0000000000000000000000000000000000000000000000000000000000000003",
                ENGLISH_LANGUAGE
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, comment_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_edit_comment_to_reply_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 1, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;
            
            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );

            postLib::editComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                comment,
                1,
                1,
                x"0000000000000000000000000000000000000000000000000000000000000002",
                ENGLISH_LANGUAGE
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, comment_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_REPLY_DELETED)]
    fun test_edit_comment_to_reply_reply_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 1, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;

            postLib::deleteReply(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
                1,
            ); 
            
            postLib::editComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                comment,
                1,
                1,
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                ENGLISH_LANGUAGE
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, comment_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = commonLib::E_INVALIT_IPFSHASH, location = postLib)]
    fun test_edit_comment_to_post_empty_ipfs() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 0, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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
                x"",
                ENGLISH_LANGUAGE
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, comment_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = commonLib::E_INVALIT_IPFSHASH, location = postLib)]
    fun test_edit_comment_to_reply_empty_ipfs() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 1, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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
                1,
                1,
                x"",
                ENGLISH_LANGUAGE
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, comment_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_COMMENT_DELETED)]
    fun test_edit_comment_to_post_comment_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 0, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;

            postLib::deleteComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                0,
                1,
            );
            
            postLib::editComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                comment,
                0,
                1,
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                ENGLISH_LANGUAGE
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, comment_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_COMMENT_DELETED)]
    fun test_edit_comment_to_reply_comment_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 1, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;

            postLib::deleteComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
                1,
            );
            
            postLib::editComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                comment,
                1,
                1,
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                ENGLISH_LANGUAGE
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, comment_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_ITEM_ID_NOT_MATCHING)]
    fun test_edit_comment_comment_and_commentMetaData_not_match() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 0, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 0, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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
                2,
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                ENGLISH_LANGUAGE
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, comment_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_delete_post_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_REPLY_DELETED)]
    fun test_delete_reply_reply_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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

            postLib::deleteReply(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
                1,
            ); 

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_YOU_CAN_NOT_DELETE_THE_BEST_REPLY)]
    fun test_common_user_delete_best_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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

            postLib::deleteReply(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
                1,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_COMMENT_DELETED)]
    fun test_delete_comment_to_post_comment_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 0, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deleteComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                0,
                1,
            );
            
            postLib::deleteComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                0,
                1,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_delete_comment_to_post_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 0, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );
            
            postLib::deleteComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                0,
                1,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_delete_comment_to_reply_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 1, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );

            postLib::deleteComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
                1,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_REPLY_DELETED)]
    fun test_delete_comment_to_reply_reply_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(&time, post_meta_data, 1, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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
            
            postLib::deleteComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
                1,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_set_best_reply_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_REPLY_NOT_EXIST)]
    fun test_set_best_reply_reply_not_exist() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_REPLY_DELETED)]
    fun test_set_best_reply_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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

            postLib::changeStatusBestReply(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                1,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_ONLY_OWNER_BY_POST_CAN_CHANGE_STATUS_BEST_REPLY)]
    fun test_set_best_reply_not_post_author() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    fun test_set_best_reply_previous_best_reply_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
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
                2,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_votePost_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, true, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_ERROR_VOTE_POST)]
    fun test_votePost_own_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
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

    #[test, expected_failure(abort_code = postLib::E_POST_DELETED)]
    fun test_voteReply_post_deleted() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                &time,
                user,
                post_meta_data,
            );

            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, true, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_ERROR_VOTE_REPLY)]
    fun test_voteReply_own_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
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


    // ====== Support functions ======

    #[test_only]
    fun init_postLib_test(scenario: &mut Scenario): clock::Clock {
        let time = clock::create_for_testing(test_scenario::ctx(scenario));
        {
            userLib::init_test(test_scenario::ctx(scenario));
            accessControlLib::init_test(test_scenario::ctx(scenario));
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

        test_scenario::next_tx(scenario, USER2);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            create_post(&time, x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", scenario);
        };

        time
    }

    #[test_only]
    fun init_all_shared(scenario: &mut Scenario): (UsersRatingCollection, UserRolesCollection, User, Community) {
        let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let community_val = test_scenario::take_shared<Community>(scenario);

        (user_rating_collection_val, user_roles_collection_val, user_val, community_val)
    }

    #[test_only]
    fun return_all_shared(
        user_rating_collection_val: UsersRatingCollection,
        user_roles_collection_val: UserRolesCollection,
        user_val: User,
        community_val: Community,
        scenario: &mut Scenario
    ) {
        test_scenario::return_shared(user_rating_collection_val);
        test_scenario::return_shared(user_roles_collection_val);
        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(community_val);
    }
       
    #[test_only]
    public fun create_post(time: &clock::Clock, ipfsHash: vector<u8>, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
        let user_rating_collection = &mut user_rating_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &mut user_val;
        let community = &mut community_val;

        postLib::createPost(
            user_rating_collection,
            user_roles_collection,
            time,
            user,
            community,
            ipfsHash,
            EXPERT_POST,
            vector<u64>[1, 2],
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario)
        );

        return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
    }

    #[test_only]
    public fun create_reply(time: &clock::Clock, postMetadata: &mut PostMetaData, ipfsHash: vector<u8>, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
        let user_rating_collection = &mut user_rating_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &mut user_val;

        postLib::createReply(
            user_rating_collection,
            user_roles_collection,
            time,
            user,
            postMetadata,
            0,
            ipfsHash,
            false,
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario)
        );

        return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
    }

    #[test_only]
    public fun create_comment(time: &clock::Clock, postMetadata: &mut PostMetaData, parentReplyMetaDataKey: u64, ipfsHash: vector<u8>, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val) = init_all_shared(scenario);
        let user_rating_collection = &mut user_rating_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &mut user_val;

        postLib::createComment(
            user_rating_collection,
            user_roles_collection,
            time,
            user,
            postMetadata,
            parentReplyMetaDataKey,
            ipfsHash,
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario)
        );

        return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, scenario);
    }
}