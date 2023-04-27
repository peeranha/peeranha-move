#[test_only]
module basics::postLib_language_test
{
    use basics::postLib::{Self, Post, PostMetaData/*, Reply, Comment*/};
    use basics::userLib_test;
    use basics::communityLib_test;
    use basics::communityLib::{/*Self,*/ Community};
    use basics::userLib::{Self, User, UsersRatingCollection, PeriodRewardContainer};
    use basics::accessControl::{Self, UserRolesCollection/*, DefaultAdminCap*/};
    use sui::test_scenario::{Self, Scenario};
    // use sui::object::{Self /*, ID*/};
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
    const NONE_LANGUAGE: u8 = 3;


    const USER1: address = @0xA1;
    const USER2: address = @0xA2;


    // #[test, expected_failure(abort_code = postLib::E_INVALID_LANGUAGE)]
    // x4 + error
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
            init_postLib_test(&time, scenario); // add language
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

            assert!(language == ENGLISH_LANGUAGE, 13);

            test_scenario::return_to_sender(scenario, post_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(post_meta_data_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_edit_post() {
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

            assert!(language == ENGLISH_LANGUAGE, 13);

            test_scenario::return_shared(post_meta_data_val);
            test_scenario::return_to_sender(scenario, post_val);
            return_all_shared(user_rating_collection_val, user_roles_collection_val, period_reward_container_val, user_val, community_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    // reply comment





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