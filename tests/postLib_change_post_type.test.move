#[test_only]
module peeranha::postLib_change_post_type_test
{
    use peeranha::postLib::{Self, Post, PostMetaData};
    use peeranha::userLib_test;
    use peeranha::communityLib_test;
    use peeranha::postLib_test;
    use peeranha::userLib::{Self, UsersRatingCollection, User};
    use peeranha::nftLib::{Self, AchievementCollection};
    use peeranha::communityLib::{Community};
    use peeranha::accessControlLib::{Self, UserRolesCollection};
    use sui::test_scenario::{Self, Scenario};
    use sui::clock;

    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;
    const INVALID_POST_TYPE: u8 = 3;

    const ENGLISH_LANGUAGE: u8 = 0;

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    const USER3: address = @0xA3;

    #[test]
    fun test_change_expert_post_to_common() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            assert!(postLib::getPostType(post_meta_data) == EXPERT_POST, 1);

            change_post_type(post_meta_data, COMMON_POST, scenario);
            
            assert!(postLib::getPostType(post_meta_data) == COMMON_POST, 2);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_expert_post_to_tutorial() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            assert!(postLib::getPostType(post_meta_data) == EXPERT_POST, 1);

            change_post_type(post_meta_data, TUTORIAL, scenario);
            
            assert!(postLib::getPostType(post_meta_data) == TUTORIAL, 2);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_common_post_to_expert() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            assert!(postLib::getPostType(post_meta_data) == COMMON_POST, 1);

            change_post_type(post_meta_data, EXPERT_POST, scenario);
            
            assert!(postLib::getPostType(post_meta_data) == EXPERT_POST, 2);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_common_post_to_tutorial() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            assert!(postLib::getPostType(post_meta_data) == COMMON_POST, 1);

            change_post_type(post_meta_data, TUTORIAL, scenario);
            
            assert!(postLib::getPostType(post_meta_data) == TUTORIAL, 2);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_tutorial_post_to_expert() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(TUTORIAL, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            assert!(postLib::getPostType(post_meta_data) == TUTORIAL, 1);

            change_post_type(post_meta_data, EXPERT_POST, scenario);
            
            assert!(postLib::getPostType(post_meta_data) == EXPERT_POST, 2);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_tutorial_post_to_common() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(TUTORIAL, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            assert!(postLib::getPostType(post_meta_data) == TUTORIAL, 1);

            change_post_type(post_meta_data, COMMON_POST, scenario);
            
            assert!(postLib::getPostType(post_meta_data) == COMMON_POST, 2);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_INVALID_POST_TYPE)]
    fun test_change_expert_post_to_invalid_post_type() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            change_post_type(post_meta_data, INVALID_POST_TYPE, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_INVALID_POST_TYPE)]
    fun test_change_common_post_to_invalid_post_type() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            change_post_type(post_meta_data, INVALID_POST_TYPE, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_INVALID_POST_TYPE)]
    fun test_change_tutorial_post_to_invalid_post_type() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(TUTORIAL, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            change_post_type(post_meta_data, INVALID_POST_TYPE, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_expert_post_to_common_with_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            create_reply(post_meta_data, &time, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            change_post_type(post_meta_data, COMMON_POST, scenario);
            
            assert!(postLib::getPostType(post_meta_data) == COMMON_POST, 1);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_common_post_to_expert_with_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            create_reply(post_meta_data, &time, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            change_post_type(post_meta_data, EXPERT_POST, scenario);
            
            assert!(postLib::getPostType(post_meta_data) == EXPERT_POST, 1);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_ERROR_POST_TYPE)]
    fun test_change_expert_post_to_tutorial_with_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            create_reply(post_meta_data, &time, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            change_post_type(post_meta_data, TUTORIAL, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test, expected_failure(abort_code = postLib::E_ERROR_POST_TYPE)]
    fun test_change_common_post_to_tutorial_with_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            create_reply(post_meta_data, &time, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            change_post_type(post_meta_data, TUTORIAL, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_expert_post_to_tutorial_with_deleted_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            create_reply(post_meta_data, &time, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            change_post_type(post_meta_data, TUTORIAL, scenario);

            assert!(postLib::getPostType(post_meta_data) == TUTORIAL, 1);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_change_common_post_to_tutorial_with_deleted_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(COMMON_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            
            create_reply(post_meta_data, &time, scenario);

            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;

            change_post_type(post_meta_data, TUTORIAL, scenario);

            assert!(postLib::getPostType(post_meta_data) == TUTORIAL, 1);

            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val); 
    }

    

    // ====== Support functions ======

    #[test_only]
    public fun init_postLib_test(postType: u8, scenario: &mut Scenario): clock::Clock {
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

        test_scenario::next_tx(scenario, USER3);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            create_post(&time, postType, scenario);
        };

        time
    }
       
    #[test_only]
    public fun create_post(time: &clock::Clock, postType: u8, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
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
            postType,
            vector<u64>[1, 2],
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario)
        );

        postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    #[test_only]
    public fun create_reply(postMetadata: &mut PostMetaData, time: &clock::Clock, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
        let user_rating_collection = &mut user_rating_collection_val;
        let achievement_collection = &mut achievement_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &mut user_val;
        
        postLib::createReply(
            user_rating_collection,
            user_roles_collection,
            achievement_collection,
            time,
            user,
            postMetadata,
            0,
            x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
            false,
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario)
        );

        postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    #[test_only]
    public fun delete_reply(postMetadata: &mut PostMetaData, replyMetaDataKey: u64, time: &clock::Clock, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
        let user_rating_collection = &mut user_rating_collection_val;
        let achievement_collection = &mut achievement_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &mut user_val;

        postLib::deleteReply(
            user_rating_collection,
            user_roles_collection,
            achievement_collection,
            time,
            user,
            postMetadata,
            replyMetaDataKey,
            test_scenario::ctx(scenario),
        );

        postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    #[test_only]
    public fun change_post_type(post_meta_data: &mut PostMetaData, postType: u8, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
        let user_rating_collection = &mut user_rating_collection_val;
        let achievement_collection = &mut achievement_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &mut user_val;
        let community = &mut community_val;
        let post_val = test_scenario::take_from_sender<Post>(scenario);
        let post = &mut post_val;

        postLib::authorEditPost(
            user_rating_collection,
            user_roles_collection,
            achievement_collection,
            user,
            post,
            post_meta_data,
            community,
            x"0000000000000000000000000000000000000000000000000000000000000005",
            postType,
            vector<u64>[2, 3],
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario),
        );

        test_scenario::return_to_sender(scenario, post_val);
        postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    #[test_only]
    public fun change_post_type_all_params(
        user_rating_collection: &mut UsersRatingCollection,
        user_roles_collection: &mut UserRolesCollection,
        achievement_collection: &mut AchievementCollection,
        user: &mut User,
        post_meta_data: &mut PostMetaData,
        community: &mut Community,
        postType: u8,
        scenario: &mut Scenario
    ) {
        let post_val = test_scenario::take_from_sender<Post>(scenario);
        let post = &mut post_val;

        let (
            ipfsDoc,
            _postId,
            _postType,
            _author,
            _rating,
            _communityId,
            language,
            _officialReplyMetaDataKey,
            _bestReplyMetaDataKey,
            _deletedRepliesCount,
            _isDeleted,
            tags,
            _historyVotes
        ) = postLib::getPostData(post_meta_data, post);

        postLib::authorEditPost(
            user_rating_collection,
            user_roles_collection,
            achievement_collection,
            user,
            post,
            post_meta_data,
            community,
            ipfsDoc,
            postType,
            tags,
            language,
            test_scenario::ctx(scenario),
        );

        test_scenario::return_to_sender(scenario, post_val);
    }
}
