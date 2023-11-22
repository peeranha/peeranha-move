#[test_only]
module peeranha::postLib_bot_test
{
    use peeranha::postLib::{Self, Post, PostMetaData, Reply};
    use peeranha::nftLib;
    use peeranha::userLib_test;
    use peeranha::communityLib_test;
    use peeranha::postLib_votes_rating_test;
    use peeranha::postLib_test;
    use peeranha::postLib_votes_test;
    use peeranha::i64Lib;
    use peeranha::communityLib::{Community};
    use peeranha::commonLib;
    use peeranha::userLib::{Self, User, UsersRatingCollection};
    use peeranha::accessControlLib::{Self, UserRolesCollection};
    use sui::test_scenario::{Self, Scenario};
    use sui::object;
    use sui::clock;

    // use std::debug;
    // debug::print(community);

    const EXPERT_POST: u8 = 0;

    const ENGLISH_LANGUAGE: u8 = 0;
    const CHINESE_LANGUAGE: u8 = 1;

    // const MESSENGER_TYPE_UNKNOWN: u8 = 0;
    const MESSENGER_TYPE_TELEGRAM: u8 = 1;
    // const MESSENGER_TYPE_DISCORD: u8 = 2;
    // const MESSENGER_TYPE_SLACK: u8 = 3;

    const UPVOTE_FLAG: bool = true;
    const DOWNVOTE_FLAG: bool = false;

    const HANDLE1: vector<u8> = vector<u8>[1];
    const HANDLE2: vector<u8> = vector<u8>[2];

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;

    const BOT_ROLE: vector<u8> = vector<u8>[5];

    #[test]
    fun test_create_post_by_bot() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_by_bot_test_and_create_post(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;

            let (
                ipfsDoc,
                postId,
                postType,
                author,
                rating,
                communityId,
                language,
                officialReplyMetaDataKey,
                bestReplyMetaDataKey,
                deletedRepliesCount,
                isDeleted,
                tags,
                _historyVotes
            ) = postLib::getPostData(post_meta_data, post);

            assert!(postType == EXPERT_POST, 1);
            assert!(postId == object::id(post), 12);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
            assert!(author == commonLib::get_bot_id(), 4);
            assert!(rating == i64Lib::zero(), 5);
            assert!(communityId == object::id(community), 6);
            assert!(language == ENGLISH_LANGUAGE, 13);
            assert!(officialReplyMetaDataKey == 0, 7);
            assert!(bestReplyMetaDataKey == 0, 8);
            assert!(deletedRepliesCount == 0, 9);
            assert!(isDeleted == false, 10);
            assert!(tags == vector<u64>[1, 2], 11);
            let authorMetaData = postLib::getPostAuthorMetaData(post_meta_data);
            assert!(authorMetaData == commonLib::compose_messenger_sender_property(MESSENGER_TYPE_TELEGRAM, HANDLE1), 12);

            test_scenario::return_to_sender(scenario, post_val);
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_chinese_post_by_bot() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_by_bot_test(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user = &mut user_val;
            let community = &mut community_val;

            postLib::createPostByBot(
                user_roles_collection,
                &time,
                user,
                community,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                EXPERT_POST,
                vector<u64>[1, 2],
                CHINESE_LANGUAGE,
                MESSENGER_TYPE_TELEGRAM,
                HANDLE1,
                test_scenario::ctx(scenario)
            );

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            assert!(postLib::getPostLanguage(post_meta_data) == CHINESE_LANGUAGE, 1);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_reply_by_bot_to_post_from_bot() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_by_bot_test_and_create_post(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            create_standart_reply_by_bot(&time, HANDLE1, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;

            let (
                ipfsDoc,
                replyId,
                author,
                rating,
                parentReplyMetaDataKey,
                language,
                isFirstReply,
                isQuickReply,
                isDeleted,
                _historyVotes
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(replyId == object::id(reply), 11);
            assert!(author == commonLib::get_bot_id(), 4);
            assert!(rating == i64Lib::zero(), 4);
            assert!(parentReplyMetaDataKey == 0, 5);
            assert!(language == ENGLISH_LANGUAGE, 5);
            assert!(isFirstReply == false, 6);
            assert!(isQuickReply == false, 7);
            assert!(isDeleted == false, 9);
            let authorMetaData = postLib::getReplyAuthorMetaData(post_meta_data, 1);
            assert!(authorMetaData == commonLib::compose_messenger_sender_property(MESSENGER_TYPE_TELEGRAM, HANDLE1), 12);

            let expectedBotRating = i64Lib::from(0);
            let botRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            assert!(expectedBotRating == botRating, 0);            
            
            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_reply_by_bot_to_post_from_common_user() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_by_bot_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            create_standart_reply_by_bot(&time, HANDLE1, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;

            let (
                ipfsDoc,
                replyId,
                author,
                rating,
                parentReplyMetaDataKey,
                language,
                isFirstReply,
                isQuickReply,
                isDeleted,
                _historyVotes
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(replyId == object::id(reply), 11);
            assert!(author == commonLib::get_bot_id(), 4);
            assert!(rating == i64Lib::zero(), 4);
            assert!(parentReplyMetaDataKey == 0, 5);
            assert!(language == ENGLISH_LANGUAGE, 5);
            assert!(isFirstReply == true, 6);
            assert!(isQuickReply == true, 7);
            assert!(isDeleted == false, 9);
            let authorMetaData = postLib::getReplyAuthorMetaData(post_meta_data, 1);
            assert!(authorMetaData == commonLib::compose_messenger_sender_property(MESSENGER_TYPE_TELEGRAM, HANDLE1), 12);

            let expectedBotRating = i64Lib::from(0);
            let botRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            assert!(expectedBotRating == botRating, 0);

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_chinese_reply_by_bot() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_by_bot_test_and_create_post(scenario);
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
            
            postLib::createReplyByBot(
                user_rating_collection,
                user_roles_collection,
                achievement_collection,
                &time,
                user,
                post_meta_data,
                0,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                CHINESE_LANGUAGE,
                MESSENGER_TYPE_TELEGRAM,
                HANDLE1,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            assert!(postLib::getReplyLanguage(post_meta_data, 1) == CHINESE_LANGUAGE, 1);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_2_different_replies_by_bot() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_by_bot_test_and_create_post(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            create_standart_reply_by_bot(&time, HANDLE1, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            create_standart_reply_by_bot(&time, HANDLE2, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply2_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply2 = &mut reply2_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;

            let (
                ipfsDoc,
                replyId,
                author,
                rating,
                parentReplyMetaDataKey,
                language,
                isFirstReply,
                isQuickReply,
                isDeleted,
                _historyVotes
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(replyId == object::id(reply), 11);
            assert!(author == commonLib::get_bot_id(), 4);
            assert!(rating == i64Lib::zero(), 4);
            assert!(parentReplyMetaDataKey == 0, 5);
            assert!(language == ENGLISH_LANGUAGE, 5);
            assert!(isFirstReply == false, 6);
            assert!(isQuickReply == false, 7);
            assert!(isDeleted == false, 9);
            let authorMetaData = postLib::getReplyAuthorMetaData(post_meta_data, 1);
            assert!(authorMetaData == commonLib::compose_messenger_sender_property(MESSENGER_TYPE_TELEGRAM, HANDLE1), 12);

            let (
                ipfsDoc2,
                replyId2,
                author2,
                rating2,
                parentReplyMetaDataKey2,
                language2,
                isFirstReply2,
                isQuickReply2,
                isDeleted2,
                _historyVotes2
            ) = postLib::getReplyData(post_meta_data, reply2, 2);

            assert!(ipfsDoc2 == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(replyId2 == object::id(reply2), 11);
            assert!(author2 == commonLib::get_bot_id(), 4);
            assert!(rating2 == i64Lib::zero(), 4);
            assert!(parentReplyMetaDataKey2 == 0, 5);
            assert!(language2 == ENGLISH_LANGUAGE, 5);
            assert!(isFirstReply2 == false, 6);
            assert!(isQuickReply2 == false, 7);
            assert!(isDeleted2 == false, 9);
            let authorMetaData2 = postLib::getReplyAuthorMetaData(post_meta_data, 2);
            assert!(authorMetaData2 == commonLib::compose_messenger_sender_property(MESSENGER_TYPE_TELEGRAM, HANDLE2), 12);

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_to_sender(scenario, reply2_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = postLib::E_USER_CAN_NOT_PUBLISH_2_REPLIES_FOR_POST)]
    fun test_create_2_replies_by_bot() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_by_bot_test_and_create_post(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            create_standart_reply_by_bot(&time, HANDLE1, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            create_standart_reply_by_bot(&time, HANDLE1, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_upvote_bot_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_by_bot_test_and_create_post(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            let (rating) = postLib::getPostRating(post_meta_data);
            assert!(rating == i64Lib::from(1), 5);

            let expectedBotRating = i64Lib::from(0);
            let botRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            assert!(expectedBotRating == botRating, 0);  

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_downvote_bot_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_by_bot_test_and_create_post(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_post(post_meta_data, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            let (rating) = postLib::getPostRating(post_meta_data);
            assert!(rating == i64Lib::neg_from(1), 5);

            let expectedBotRating = i64Lib::from(0);
            let botRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            assert!(expectedBotRating == botRating, 0);  

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_upvote_reply_by_bot_to_post_from_common_user() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_by_bot_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            create_standart_reply_by_bot(&time, HANDLE1, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, UPVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            let (rating) = postLib::getReplyRating(post_meta_data, 1);
            assert!(rating == i64Lib::from(1), 4);

            let expectedBotRating = i64Lib::from(0);
            let botRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            assert!(expectedBotRating == botRating, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_downvote_reply_by_bot_to_post_from_common_user() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_by_bot_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            postLib_test::create_standart_post(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            create_standart_reply_by_bot(&time, HANDLE1, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            postLib_votes_test::vote_reply(post_meta_data, 1, DOWNVOTE_FLAG, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            let (rating) = postLib::getReplyRating(post_meta_data, 1);
            assert!(rating == i64Lib::neg_from(1), 4);

            let expectedBotRating = i64Lib::from(0);
            let botRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            assert!(expectedBotRating == botRating, 0);

            test_scenario::return_shared(post_meta_data_val);
            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    // ====== Support functions ======

    #[test_only]
    public fun init_postLib_by_bot_test_and_create_post(scenario: &mut Scenario): clock::Clock {
        let time = init_postLib_by_bot_test(scenario);

        test_scenario::next_tx(scenario, USER2);
        {
            create_standart_post_by_bot(&time, scenario);
        };

        time
    }

    #[test_only]
    public fun init_postLib_by_bot_test(scenario: &mut Scenario): clock::Clock {
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

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };
        
        test_scenario::next_tx(scenario, USER1);
        {
            let user2 = &mut user2_val;
            grant_bot_role(object::id(user2), scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        time
    }

    #[test_only]
    public fun init_all_shared(scenario: &mut Scenario): (UsersRatingCollection, UserRolesCollection, User, Community) {
        let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let community_val = test_scenario::take_shared<Community>(scenario);

        (user_rating_collection_val, user_roles_collection_val, user_val, community_val)
    }

    #[test_only]
    public fun return_all_shared(
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
    public fun grant_bot_role(userId: sui::object::ID, scenario: &mut Scenario) {
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        userLib::grantRole(user_roles_collection, user, userId, BOT_ROLE);

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }
    
    #[test_only]
    public fun create_standart_post_by_bot(time: &clock::Clock, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &mut user_val;
        let community = &mut community_val;

        postLib::createPostByBot(
            user_roles_collection,
            time,
            user,
            community,
            x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
            EXPERT_POST,
            vector<u64>[1, 2],
            ENGLISH_LANGUAGE,
            MESSENGER_TYPE_TELEGRAM,
            HANDLE1,
            test_scenario::ctx(scenario)
        );

        postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    #[test_only]
    public fun create_standart_reply_by_bot(time: &clock::Clock, handle: vector<u8>, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
        let user_rating_collection = &mut user_rating_collection_val;
        let achievement_collection = &mut achievement_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &mut user_val;
        let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
        let post_meta_data = &mut post_meta_data_val;
        
        postLib::createReplyByBot(
            user_rating_collection,
            user_roles_collection,
            achievement_collection,
            time,
            user,
            post_meta_data,
            0,
            x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
            ENGLISH_LANGUAGE,
            MESSENGER_TYPE_TELEGRAM,
            handle,
            test_scenario::ctx(scenario)
        );

        test_scenario::return_shared(post_meta_data_val);
        postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }
}