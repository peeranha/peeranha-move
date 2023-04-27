#[test_only]
module basics::postLib_test
{
    use basics::postLib::{Self, Post, PostMetaData, Reply, Comment};
    use basics::userLib_test;
    use basics::communityLib_test;
    use basics::i64Lib;
    use basics::communityLib::{/*Self,*/ Community};
    use basics::userLib::{Self, User, UsersRatingCollection, PeriodRewardContainer};
    use basics::accessControl::{Self, UserRolesCollection/*, DefaultAdminCap*/};
    use sui::test_scenario::{Self, Scenario};
    use sui::object::{Self /*, ID*/};
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
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;

            let (
                ipfsDoc,
                postId,
                postType,
                postTime,
                author,
                rating,
                communityId,
                language,
                officialReplyMetaDataKey,
                bestReplyMetaDataKey,
                deletedReplyCount,
                isDeleted,
                tags,
            ) = postLib::getPostData(post_meta_data, post);

            assert!(postType == EXPERT_POST, 1);
            assert!(postId == object::id(post), 12);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 2);
            assert!(postTime == 0, 3);
            assert!(author == object::id(user), 4);
            assert!(rating == i64Lib::zero(), 5);
            assert!(communityId == object::id(community), 6);
            assert!(language == ENGLISH_LANGUAGE, 13);
            assert!(officialReplyMetaDataKey == 0, 7);
            assert!(bestReplyMetaDataKey == 0, 8);
            assert!(deletedReplyCount == 0, 9);
            assert!(isDeleted == false, 10);
            assert!(tags == vector<u64>[1, 2], 11);

            test_scenario::return_to_sender(scenario, post_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            let (
                ipfsDoc,
                replyId,
                postTime,
                author,
                rating,
                parentReplyMetaDataKey,
                language,
                isFirstReply,
                isQuickReply,
                isDeleted,
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(ipfsDoc == x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", 1);
            assert!(replyId == object::id(reply), 11);
            assert!(postTime == 0, 2);
            assert!(author == object::id(user), 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(parentReplyMetaDataKey == 0, 5);
            assert!(language == ENGLISH_LANGUAGE, 5);
            assert!(isFirstReply == false, 6);
            assert!(isQuickReply == false, 7);
            assert!(isDeleted == false, 9);

            test_scenario::return_to_sender(scenario, reply_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_comment_to_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 0, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            let (
                ipfsDoc,
                commentId,
                postTime,
                author,
                rating,
                language,
                isDeleted,
            ) = postLib::getCommentData(post_meta_data, comment, 0, 1);

            assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
            assert!(commentId == object::id(comment), 11);
            assert!(postTime == 0, 2);
            assert!(author == object::id(user), 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(language == ENGLISH_LANGUAGE, 5);
            assert!(isDeleted == false, 9);

            test_scenario::return_to_sender(scenario, comment_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_comment_to_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 1, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            let (
                ipfsDoc,
                commentId,
                postTime,
                author,
                rating,
                language,
                isDeleted,
            ) = postLib::getCommentData(post_meta_data, comment, 1, 1);

            assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
            assert!(commentId == object::id(comment), 11);
            assert!(postTime == 0, 2);
            assert!(author == object::id(user), 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(language == ENGLISH_LANGUAGE, 5);
            assert!(isDeleted == false, 9);

            test_scenario::return_to_sender(scenario, comment_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_edit_post() {  // edit Ipfs + tags
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, scenario);
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
                ENGLISH_LANGUAGE,
                test_scenario::ctx(scenario)
            );

            let (
                ipfsDoc,
                postId,
                postType,
                postTime,
                author,
                rating,
                communityId,
                language,
                officialReplyMetaDataKey,
                bestReplyMetaDataKey,
                deletedReplyCount,
                isDeleted,
                tags,
            ) = postLib::getPostData(post_meta_data, post);

            assert!(postType == EXPERT_POST, 1);
            assert!(postId == object::id(post), 12);
            assert!(ipfsDoc == x"0000000000000000000000000000000000000000000000000000000000000005", 2);
            assert!(postTime == 0, 3);
            assert!(author == object::id(user), 4);
            assert!(rating == i64Lib::zero(), 5);
            assert!(communityId == object::id(community), 6);
            assert!(language == ENGLISH_LANGUAGE, 13);
            assert!(officialReplyMetaDataKey == 0, 7);
            assert!(bestReplyMetaDataKey == 0, 8);
            assert!(deletedReplyCount == 0, 9);
            assert!(isDeleted == false, 10);
            assert!(tags == vector<u64>[2, 3], 11);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, post_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_edit_reply() {   // edit Ipfs
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(post_meta_data, &time, scenario);
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
                ENGLISH_LANGUAGE
            );

            let (
                ipfsDoc,
                replyId,
                postTime,
                author,
                rating,
                parentReplyMetaDataKey,
                language,
                isFirstReply,
                isQuickReply,
                isDeleted,
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(ipfsDoc == x"0000000000000000000000000000000000000000000000000000000000000004", 1);
            assert!(replyId == object::id(reply), 11);
            assert!(postTime == 0, 2);
            assert!(author == object::id(user), 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(parentReplyMetaDataKey == 0, 5);
            assert!(language == ENGLISH_LANGUAGE, 5);
            assert!(isFirstReply == false, 6);
            assert!(isQuickReply == false, 7);
            assert!(isDeleted == false, 9);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, reply_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_edit_comment_to_post() {   // edit ipfs
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, scenario);
        };
        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 0, scenario);
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
                ENGLISH_LANGUAGE
            );

            let (
                ipfsDoc,
                commentId,
                postTime,
                author,
                rating,
                language,
                isDeleted,
            ) = postLib::getCommentData(post_meta_data, comment, 0, 1);

            assert!(ipfsDoc == x"0000000000000000000000000000000000000000000000000000000000000003", 1);
            assert!(commentId == object::id(comment), 11);
            assert!(postTime == 0, 2);
            assert!(author == object::id(user), 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(language == ENGLISH_LANGUAGE, 5);
            assert!(isDeleted == false, 9);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, comment_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_edit_comment_to_reply() {   // edit ipfs
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 1, scenario);
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
                x"0000000000000000000000000000000000000000000000000000000000000002",
                ENGLISH_LANGUAGE
            );

            let (
                ipfsDoc,
                commentId,
                postTime,
                author,
                rating,
                language,
                isDeleted,
            ) = postLib::getCommentData(post_meta_data, comment, 1, 1);

            assert!(ipfsDoc == x"0000000000000000000000000000000000000000000000000000000000000002", 1);
            assert!(commentId == object::id(comment), 11);
            assert!(postTime == 0, 2);
            assert!(author == object::id(user), 3);
            assert!(rating == i64Lib::zero(), 4);
            assert!(language == ENGLISH_LANGUAGE, 5);
            assert!(isDeleted == false, 9);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, comment_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_post() {  // delete post
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let post_val = test_scenario::take_from_sender<Post>(scenario);
            let post = &mut post_val;
            
            postLib::deletePost(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                &time,
                user,
                post_meta_data,
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
                _language,
                _officialReplyMetaDataKey,
                _bestReplyMetaDataKey,
                _deletedReplyCount,
                isDeleted,
                _tags,
            ) = postLib::getPostData(post_meta_data, post);

            assert!(isDeleted == true, 10);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, post_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test] // delete post
    fun test_delete_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
             let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let reply_val = test_scenario::take_from_sender<Reply>(scenario);
            let reply = &mut reply_val;

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

            let (
                _ipfsDoc,
                _replyId,
                _postTime,
                _author,
                _rating,
                _parentReplyMetaDataKey,
                _language,
                _isFirstReply,
                _isQuickReply,
                isDeleted,
            ) = postLib::getReplyData(post_meta_data, reply, 1);

            assert!(isDeleted == true, 9);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, reply_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_delete_comment_to_post() {   // delete comment
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, scenario);
        };
        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 0, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;   

            postLib::deleteComment(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                0,
                1,
                test_scenario::ctx(scenario)
            );

            let (
                _ipfsDoc,
                _commentId,
                _postTime,
                _author,
                _rating,
                _language,
                isDeleted,
            ) = postLib::getCommentData(post_meta_data, comment, 0, 1);

            assert!(isDeleted == true, 9);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, comment_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_comment_to_reply() {    // delete comment
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = clock::create_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            init_postLib_test(&time, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(post_meta_data, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_comment(post_meta_data, &time, 1, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val) = init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let period_reward_container = &mut period_reward_container_val;
            let user = &mut user_val;
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            let comment_val = test_scenario::take_from_sender<Comment>(scenario);
            let comment = &mut comment_val;   

            postLib::deleteComment(
                user_rating_collection,
                user_roles_collection,
                period_reward_container,
                user,
                post_meta_data,
                1,
                1,
                test_scenario::ctx(scenario)
            );

            let (
                _ipfsDoc,
                _commentId,
                _postTime,
                _author,
                _rating,
                _language,
                isDeleted,
            ) = postLib::getCommentData(post_meta_data, comment, 1, 1);

            assert!(isDeleted == true, 9);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, comment_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }
  

    // ====== Support functions ======

    #[test_only]
    fun init_postLib_test(time: &clock::Clock, scenario: &mut Scenario) {
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
            create_post(time, scenario);
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
    public fun create_post(time: &clock::Clock, scenario: &mut Scenario) {
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
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario)
        );

        return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
    }

    #[test_only]
    public fun create_reply(postMetadata: &mut PostMetaData, time: &clock::Clock, scenario: &mut Scenario) {
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
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario)
        );

        return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
    }

    #[test_only]
    public fun create_comment(postMetadata: &mut PostMetaData, time: &clock::Clock, parentReplyMetaDataKey: u64, scenario: &mut Scenario) {
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
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario)
        );

        return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
    }
}