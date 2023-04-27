#[test_only]
module basics::postLib_language_test
{
    use basics::postLib::{Self, Post, PostMetaData, Reply, Comment};
    use basics::userLib_test;
    use basics::communityLib_test;
    use basics::communityLib::{Community};
    use basics::userLib::{Self, User, UsersRatingCollection, PeriodRewardContainer};
    use basics::accessControl::{Self, UserRolesCollection};
    use sui::test_scenario::{Self, Scenario};
    use sui::clock::{Self};

    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;
    const DOCUMENTATION: u8 = 3;

    const ENGLISH_LANGUAGE: u8 = 0;
    const CHINESE_LANGUAGE: u8 = 1;
    const SPANISH_LANGUAGE: u8 = 2;
    const VIETNAMESE_LANGUAGE: u8 = 3;
    const LANGUAGE_LENGTH: u8 = 4;

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;

    #[test]
    fun test_create_english_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let community_val = test_scenario::take_shared<Community>(scenario);

            let (
                _ipfsDoc,
                _postId,
                _postType,
                _postTime,
                _author,
                _rating,
                _communityId,
                language,
                _officialReplyMetaDataKey,
                _bestReplyMetaDataKey,
                _deletedReplyCount,
                _isDeleted,
                _tags,
            ) = postLib::getPostData(post_meta_data, post);

            assert!(language == ENGLISH_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, post_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_chinese_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 1, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let community_val = test_scenario::take_shared<Community>(scenario);

            let (
                _ipfsDoc,
                _postId,
                _postType,
                _postTime,
                _author,
                _rating,
                _communityId,
                language,
                _officialReplyMetaDataKey,
                _bestReplyMetaDataKey,
                _deletedReplyCount,
                _isDeleted,
                _tags,
            ) = postLib::getPostData(post_meta_data, post);

            assert!(language == CHINESE_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, post_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_spanish_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 2, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let community_val = test_scenario::take_shared<Community>(scenario);

            let (
                _ipfsDoc,
                _postId,
                _postType,
                _postTime,
                _author,
                _rating,
                _communityId,
                language,
                _officialReplyMetaDataKey,
                _bestReplyMetaDataKey,
                _deletedReplyCount,
                _isDeleted,
                _tags,
            ) = postLib::getPostData(post_meta_data, post);

            assert!(language == SPANISH_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, post_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_vietnamese_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 3, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let community_val = test_scenario::take_shared<Community>(scenario);

            let (
                _ipfsDoc,
                _postId,
                _postType,
                _postTime,
                _author,
                _rating,
                _communityId,
                language,
                _officialReplyMetaDataKey,
                _bestReplyMetaDataKey,
                _deletedReplyCount,
                _isDeleted,
                _tags,
            ) = postLib::getPostData(post_meta_data, post);

            assert!(language == VIETNAMESE_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, post_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_INVALID_LANGUAGE)]
    fun test_create_invalid_language_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 4, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_author_edit_english_post_to_chinese() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;

            postLib::authorEditPost(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post,
                post_meta_data,
                community,
                x"0000000000000000000000000000000000000000000000000000000000000005",
                EXPERT_POST,
                vector<u64>[2, 3],
                1,
                test_scenario::ctx(scenario)
            );

            let (
                _ipfsDoc,
                _postId,
                _postType,
                _postTime,
                _author,
                _rating,
                _communityId,
                language,
                _officialReplyMetaDataKey,
                _bestReplyMetaDataKey,
                _deletedReplyCount,
                _isDeleted,
                _tags,
            ) = postLib::getPostData(post_meta_data, post);

            assert!(language == CHINESE_LANGUAGE, 1);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, post_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_moderator_edit_spanish_post_to_vietnamese() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 2, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;

            postLib::moderatorEditPostMetaData(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                community,
                EXPERT_POST,
                vector<u64>[2, 3],
                3,
                test_scenario::ctx(scenario)
            );

            let (
                _ipfsDoc,
                _postId,
                _postType,
                _postTime,
                _author,
                _rating,
                _communityId,
                language,
                _officialReplyMetaDataKey,
                _bestReplyMetaDataKey,
                _deletedReplyCount,
                _isDeleted,
                _tags,
            ) = postLib::getPostData(post_meta_data, post);

            assert!(language == VIETNAMESE_LANGUAGE, 1);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, post_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_INVALID_LANGUAGE)]
    fun test_edit_english_post_to_invalid_language() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let community = &mut community_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;

            postLib::authorEditPost(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post,
                post_meta_data,
                community,
                x"0000000000000000000000000000000000000000000000000000000000000005",
                EXPERT_POST,
                vector<u64>[2, 3],
                4,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, post_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_english_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(post_meta_data, &time, 0, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);

            let (
                _ipfsDoc,
                _replyId,
                _postTime,
                _author,
                _rating,
                _parentReplyMetaDataKey,
                language,
                _isFirstReply,
                _isQuickReply,
                _isDeleted,
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(language == ENGLISH_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_chinese_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 3, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            create_reply(post_meta_data, &time, 1, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);

            let (
                _ipfsDoc,
                _replyId,
                _postTime,
                _author,
                _rating,
                _parentReplyMetaDataKey,
                language,
                _isFirstReply,
                _isQuickReply,
                _isDeleted,
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(language == CHINESE_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_spanish_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 3, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            create_reply(post_meta_data, &time, 2, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);

            let (
                _ipfsDoc,
                _replyId,
                _postTime,
                _author,
                _rating,
                _parentReplyMetaDataKey,
                language,
                _isFirstReply,
                _isQuickReply,
                _isDeleted,
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(language == SPANISH_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_vietnamese_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 3, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            create_reply(post_meta_data, &time, 3, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);

            let (
                _ipfsDoc,
                _replyId,
                _postTime,
                _author,
                _rating,
                _parentReplyMetaDataKey,
                language,
                _isFirstReply,
                _isQuickReply,
                _isDeleted,
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(language == VIETNAMESE_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_edit_english_reply_to_chinese() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 3, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            create_reply(post_meta_data, &time, 0, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
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
                x"0000000000000000000000000000000000000000000000000000000000000004",
                false,
                1
            );

            let (
                _ipfsDoc,
                _replyId,
                _postTime,
                _author,
                _rating,
                _parentReplyMetaDataKey,
                language,
                _isFirstReply,
                _isQuickReply,
                _isDeleted,
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(language == CHINESE_LANGUAGE, 1);


            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, reply_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_edit_spanish_reply_to_vietnamese() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 3, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            create_reply(post_meta_data, &time, 2, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
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
                x"0000000000000000000000000000000000000000000000000000000000000004",
                false,
                3
            );

            let (
                _ipfsDoc,
                _replyId,
                _postTime,
                _author,
                _rating,
                _parentReplyMetaDataKey,
                language,
                _isFirstReply,
                _isQuickReply,
                _isDeleted,
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(language == VIETNAMESE_LANGUAGE, 1);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, reply_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_INVALID_LANGUAGE)]
    fun test_edit_english_reply_to_invalid_language() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 3, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            create_reply(post_meta_data, &time, 0, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
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
                x"0000000000000000000000000000000000000000000000000000000000000004",
                false,
                4
            );

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, reply_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_english_comment_to_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 0, 0, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;

            let (
                _ipfsDoc,
                _commentId,
                _postTime,
                _author,
                _rating,
                language,
                _isDeleted,
            ) = postLib::getCommentData(post_meta_data, comment, 0, 1);

            assert!(language == ENGLISH_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, comment_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_chinese_comment_to_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 0, 1, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;

            let (
                _ipfsDoc,
                _commentId,
                _postTime,
                _author,
                _rating,
                language,
                _isDeleted,
            ) = postLib::getCommentData(post_meta_data, comment, 0, 1);

            assert!(language == CHINESE_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, comment_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_spanish_comment_to_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(post_meta_data, &time, 0, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 1, 2, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let comment = &mut comment_val;

            let (
                _ipfsDoc,
                _commentId,
                _postTime,
                _author,
                _rating,
                language,
                _isDeleted,
            ) = postLib::getCommentData(post_meta_data, comment, 1, 1);

            assert!(language == SPANISH_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, comment_val);
            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_vietnamese_comment_to_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(post_meta_data, &time, 0, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 1, 3, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let comment = &mut comment_val;

            let (
                _ipfsDoc,
                _commentId,
                _postTime,
                _author,
                _rating,
                language,
                _isDeleted,
            ) = postLib::getCommentData(post_meta_data, comment, 1, 1);

            assert!(language == VIETNAMESE_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, comment_val);
            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_INVALID_LANGUAGE)]
    fun test_create_invalid_comment_to_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 0, 4, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_INVALID_LANGUAGE)]
    fun test_create_invalid_comment_to_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(post_meta_data, &time, 0, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 1, 4, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_edit_english_comment_to_post_to_chinese() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 0, 0, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;
            let user = &mut user_val;

            postLib::editComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                comment,
                0,
                1,
                x"0000000000000000000000000000000000000000000000000000000000000005",
                1
            );

            let (
                _ipfsDoc,
                _commentId,
                _postTime,
                _author,
                _rating,
                language,
                _isDeleted,
            ) = postLib::getCommentData(post_meta_data, comment, 0, 1);

            assert!(language == CHINESE_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, comment_val);
            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_edit_spanish_comment_to_reply_to_vietnamese() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(post_meta_data, &time, 0, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 1, 2, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;
            let user = &mut user_val;

            postLib::editComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                comment,
                1,
                1,
                x"0000000000000000000000000000000000000000000000000000000000000005",
                3
            );

            let (
                _ipfsDoc,
                _commentId,
                _postTime,
                _author,
                _rating,
                language,
                _isDeleted,
            ) = postLib::getCommentData(post_meta_data, comment, 1, 1);

            assert!(language == VIETNAMESE_LANGUAGE, 1);

            test_scenario::return_to_sender(scenario, comment_val);
            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_INVALID_LANGUAGE)]
    fun test_edit_vietnamese_comment_to_reply_to_invalid_language() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, 0, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(post_meta_data, &time, 0, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 1, 3, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;
            let user = &mut user_val;

            postLib::editComment(
                user_rating_collection,
                user_roles_collection,
                user,
                post_meta_data,
                comment,
                1,
                1,
                x"0000000000000000000000000000000000000000000000000000000000000005",
                4
            );

            test_scenario::return_to_sender(scenario, comment_val);
            test_scenario::return_shared(post_meta_data_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }


    // ====== Support functions ======

    #[test_only]
    fun init_postLib_test(time: &clock::Clock, language: u8, scenario: &mut Scenario) {
        {
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
            create_post(time, language, scenario);
        };
    }

    #[test_only]
    fun init_all_shared(scenario: &mut Scenario): (UsersRatingCollection, UserRolesCollection, PeriodRewardContainer, User, Community) {
        let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let period_reward_container_val = test_scenario::take_shared<PeriodRewardContainer>(scenario);
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let community_val = test_scenario::take_shared<Community>(scenario);

        (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val)
    }

    #[test_only]
    fun return_all_shared(
        user_rating_collection_val: UsersRatingCollection,
        user_roles_collection_val: UserRolesCollection,
        period_reward_container_val:PeriodRewardContainer,
        user_val: User,
        community_val: Community,
        scenario: &mut Scenario
    ) {
        test_scenario::return_shared(user_rating_collection_val);
        test_scenario::return_shared(user_roles_collection_val);
        test_scenario::return_shared(period_reward_container_val);
        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(community_val);
    }
       
    #[test_only]
    public fun create_post(time: &clock::Clock, language: u8, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
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
            x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
            EXPERT_POST,
            vector<u64>[1, 2],
            language,
            test_scenario::ctx(scenario)
        );

        return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
    }

    #[test_only]
    public fun create_reply(postMetadata: &mut PostMetaData, time: &clock::Clock, language: u8, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
        let user_rating_collection = &mut user_rating_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let period_reward_container = &mut period_reward_container_val;
        let user = &mut user_val;
        
        postLib::createReply(
            user_rating_collection,
            user_roles_collection,
            period_reward_container,
            time,
            user,
            postMetadata,
            0,
            x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
            false,
            language,
            test_scenario::ctx(scenario)
        );

        return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
    }

    #[test_only]
    public fun create_comment(postMetadata: &mut PostMetaData, time: &clock::Clock, parentReplyMetaDataKey: u64, language: u8, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
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
            x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
            language,
            test_scenario::ctx(scenario)
        );

        return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
    }
}