#[test_only]
module peeranha::accessControlLib_verify
{
    use peeranha::postLib::{Self, Post, PostMetaData};
    use peeranha::userLib_test;
    use peeranha::communityLib_test;
    use peeranha::postLib_test;
    use peeranha::userLib::{Self, UsersRatingCollection, User};
    use peeranha::nftLib::{Self, AchievementCollection};
    use peeranha::communityLib;
    use peeranha::accessControlLib::{Self, UserRolesCollection};
    use sui::test_scenario::{Self, Scenario};
    use sui::clock;
    use sui::object::{Self, ID};

    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;
    const INVALID_POST_TYPE: u8 = 3;

    const ENGLISH_LANGUAGE: u8 = 0;

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    const USER3: address = @0xA3;

    #[test]
    fun test_give_verifier_role_user() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_verify_test(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;
            
            let verifyRole = accessControlLib::get_verifier_role();
            userLib::grantRole(user_roles_collection, user, object::id(&user2_val), verifyRole);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user2 = &mut user2_val;

            let verifyRole = accessControlLib::get_verifier_role();
            let has_verify_role = accessControlLib::hasRole(user_roles_collection, verifyRole, object::id(user2));
            assert!(has_verify_role == true, 1);

            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user2_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_give_verifier_role_2_user() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_verify_with_verifier_test(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user2 = &mut user2_val;

            let verifyRole = accessControlLib::get_verifier_role();
            let has_verify_role = accessControlLib::hasRole(user_roles_collection, verifyRole, object::id(user2));
            assert!(has_verify_role == true, 1);

            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user2_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_verify_user() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_verify_with_verifier_test(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;
            
            let verifiedRole = accessControlLib::get_verified_role();
            userLib::grantRole(user_roles_collection, user, object::id(&user3_val), verifiedRole);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user3 = &mut user3_val;

            let verifiedRole = accessControlLib::get_verified_role();
            let has_verified_role = accessControlLib::hasRole(user_roles_collection, verifiedRole, object::id(user3));
            assert!(has_verified_role == true, 1);

            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user3_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }




//////////////////////////////////////////////////////////////////////////
/// 
    #[test]
    fun test_create_community_without_verified_role() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_verify_with_verifier_test(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            communityLib_test::create_community(scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_create_community_with_verified_role() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = init_verify_with_verifier_test(scenario);
        };

        let user1_val;
        test_scenario::next_tx(scenario, USER1);
        {
            user1_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;
            
            let verifiedRole = accessControlLib::get_verified_role();
            userLib::grantRole(user_roles_collection, user, object::id(&user1_val), verifiedRole);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            test_scenario::return_to_sender(scenario, user1_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            communityLib_test::create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            create_post(&time, 1, scenario);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
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

/////////////////////////////////////////////////////////////////////////////////////////

    // ====== Support functions ======

    #[test_only]
    public fun init_verify_test(scenario: &mut Scenario): clock::Clock {
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
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            communityLib::initPermistions(user_roles_collection, user, vector<ID>[]);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        time
    }

    #[test_only]
    public fun init_verify_with_verifier_test(scenario: &mut Scenario): clock::Clock {
        let time;
        {
            time = init_verify_test(scenario)
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;
            
            let verifyRole = accessControlLib::get_verifier_role();
            userLib::grantRole(user_roles_collection, user, object::id(&user2_val), verifyRole);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        time
    }
}