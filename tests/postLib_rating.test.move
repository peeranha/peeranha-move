#[test_only]
module peeranha::postLib_rating_test
{
    use peeranha::postLib::{Self, Post, PostMetaData, Reply, Comment};
    use peeranha::userLib_test;
    use peeranha::communityLib_test;
    use peeranha::postLib_votes_rating_test;
    use peeranha::postLib_change_post_type_test;
    use peeranha::postLib_test;
    use peeranha::i64Lib;
    use peeranha::communityLib::{Community};
    use peeranha::nftLib::{Self, AchievementCollection};
    use peeranha::userLib::{Self, User, UsersRatingCollection};
    use peeranha::accessControlLib::{Self, UserRolesCollection};
    use sui::test_scenario::{Self, Scenario};
    use sui::object;
    use sui::clock;

    // use std::debug;
    // debug::print(community);

    const START_USER_RATING: u64 = 10;

    const DELETE_OWN_POST: u64 = 1;             // negative
    const MODERATOR_DELETE_POST: u64 = 2;       // negative

    const DELETE_OWN_REPLY: u64 = 1;            // negative
    const MODERATOR_DELETE_REPLY: u64 = 2;      // negative

    
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
    const USER3: address = @0xA3;

    #[test]
    fun test_delete_own_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
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

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DELETE_OWN_POST);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_moderator_delete_post() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
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

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - MODERATOR_DELETE_POST);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(0);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_own_post_with_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
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

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DELETE_OWN_POST);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_moderator_delete_post_with_reply() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_postLib_test(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
            let post_meta_data = &mut post_meta_data_val;
            create_reply(&time, post_meta_data, x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc", scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER1);
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

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - MODERATOR_DELETE_POST);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_delete_own_reply() {
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
            postLib_change_post_type_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - DELETE_OWN_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_moderator_delete_reply() {
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
            postLib_change_post_type_test::delete_reply(post_meta_data, 1, &time, scenario);
            test_scenario::return_shared(post_meta_data_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = postLib_test::init_all_shared(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community = &mut community_val;
            let user = &mut user_val;

            let expectedVotedUserRating = i64Lib::from(START_USER_RATING - MODERATOR_DELETE_REPLY);
            let votedUserRating = postLib_votes_rating_test::getUserRating(user_rating_collection, user, community);
            
            assert!(expectedVotedUserRating == votedUserRating, 0);

            postLib_test::return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }



    // ====== Support functions ======

    #[test_only]
    public fun init_postLib_test(scenario: &mut Scenario): clock::Clock {
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
            create_post(&time, x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", scenario);
        };

        time
    }

    #[test_only]
    public fun init_all_shared(scenario: &mut Scenario): (UsersRatingCollection, UserRolesCollection, User, Community, AchievementCollection) {
        let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let community_val = test_scenario::take_shared<Community>(scenario);
        let achievement_collection_val = test_scenario::take_shared<AchievementCollection>(scenario);

        (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val)
    }

    #[test_only]
    public fun return_all_shared(
        user_rating_collection_val: UsersRatingCollection,
        user_roles_collection_val: UserRolesCollection,
        user_val: User,
        community_val: Community,
        achievement_collection_val: AchievementCollection,
        scenario: &mut Scenario
    ) {
        test_scenario::return_shared(user_rating_collection_val);
        test_scenario::return_shared(user_roles_collection_val);
        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(community_val);
        test_scenario::return_shared(achievement_collection_val);
    }

    #[test_only]
    public fun create_post(time: &clock::Clock, ipfsHash: vector<u8>, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = init_all_shared(scenario);
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

        return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    #[test_only]
    public fun create_standart_post(time: &clock::Clock, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = init_all_shared(scenario);
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

        return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    #[test_only]
    public fun create_reply(time: &clock::Clock, postMetadata: &mut PostMetaData, ipfsHash: vector<u8>, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = init_all_shared(scenario);
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
            ipfsHash,
            false,
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario)
        );

        return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    #[test_only]
    public fun create_standart_reply(time: &clock::Clock, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = init_all_shared(scenario);
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
            time,
            user,
            post_meta_data,
            0,
            x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
            false,
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario)
        );

        test_scenario::return_shared(post_meta_data_val);
        return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    #[test_only]
    public fun create_comment(time: &clock::Clock, postMetadata: &mut PostMetaData, parentReplyMetaDataKey: u64, ipfsHash: vector<u8>, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = init_all_shared(scenario);
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

        return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }

    #[test_only]
    public fun create_standart_comment(time: &clock::Clock, parentReplyMetaDataKey: u64, scenario: &mut Scenario) {
        let (user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val) = init_all_shared(scenario);
        let user_rating_collection = &mut user_rating_collection_val;
        let user_roles_collection = &mut user_roles_collection_val;
        let user = &mut user_val;
        let post_meta_data_val = test_scenario::take_shared<PostMetaData>(scenario);
        let post_meta_data = &mut post_meta_data_val;

        postLib::createComment(
            user_rating_collection,
            user_roles_collection,
            time,
            user,
            post_meta_data,
            parentReplyMetaDataKey,
            x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
            ENGLISH_LANGUAGE,
            test_scenario::ctx(scenario)
        );

        test_scenario::return_shared(post_meta_data_val);
        return_all_shared(user_rating_collection_val, user_roles_collection_val, user_val, community_val, achievement_collection_val, scenario);
    }
}