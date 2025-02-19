#[test_only]
module peeranha::accessControlLib_common_role_test
{
    use peeranha::communityLib::{Self, Community};
    use peeranha::userLib::{Self, User};
    use std::vector;
    use peeranha::userLib_test;
    use peeranha::communityLib_test;
    use peeranha::postLib_bot_test;
    use peeranha::accessControlLib::{Self, UserRolesCollection, DefaultAdminCap};
    use sui::test_scenario::{Self, Scenario};
    use sui::object::{Self/*, ID*/};

    // use std::debug;
    // debug::print(community);

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    const USER3: address = @0xA3;

    const PROTOCOL_ADMIN_ROLE: vector<u8> = vector<u8>[2];
    const COMMUNITY_ADMIN_ROLE: vector<u8> = vector<u8>[3];
    const COMMUNITY_MODERATOR_ROLE: vector<u8> = vector<u8>[4];
    const BOT_ROLE: vector<u8> = vector<u8>[5];

    // ====== grant/revoke role ======
    
    #[test]
    fun test_init() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            accessControlLib::test_init(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let default_admin_cap_val = test_scenario::take_from_sender<DefaultAdminCap>(scenario);
            test_scenario::return_to_sender(scenario, default_admin_cap_val);

            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let admin_role_for_bot = accessControlLib::getRoleAdmin(user_roles_collection, BOT_ROLE);
            assert!(admin_role_for_bot == PROTOCOL_ADMIN_ROLE, 2);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = test_scenario::EEmptyInventory)]
    fun test_defaul_admin_cap_not_init_role() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            let default_admin_cap_val = test_scenario::take_from_sender<DefaultAdminCap>(scenario);
            
            test_scenario::return_to_sender(scenario, default_admin_cap_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_defaul_admin_grant_protocol_admin_himself() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::test_init(test_scenario::ctx(scenario));
            accessControlLib::test_init(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            let has_protocol_admin_role = accessControlLib::hasRole(user_roles_collection, PROTOCOL_ADMIN_ROLE, object::id(user));
            assert!(has_protocol_admin_role == true, 1);

            let admin_role_for_protocol_admin = accessControlLib::getRoleAdmin(user_roles_collection, PROTOCOL_ADMIN_ROLE);
            assert!(admin_role_for_protocol_admin == vector<u8>[], 2);

            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_CAN_NOT_GIVE_PROTOCOL_ADMIN_ROLE)]
    fun test_defaul_admin_grant_protocol_admin_by_common_action() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::test_init(test_scenario::ctx(scenario));
            accessControlLib::test_init(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;
            let userId = object::id(user);

            let roleTemplate = PROTOCOL_ADMIN_ROLE;
            userLib::grantRole(user_roles_collection, user, userId, roleTemplate);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_defaul_admin_grant_protocol_admin_another_user() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::test_init(test_scenario::ctx(scenario));
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

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user2 = &mut user2_val;

            let has_protocol_admin_role = accessControlLib::hasRole(user_roles_collection, PROTOCOL_ADMIN_ROLE, object::id(user2));
            assert!(has_protocol_admin_role == true, 1);

            let admin_role_for_protocol_admin = accessControlLib::getRoleAdmin(user_roles_collection, PROTOCOL_ADMIN_ROLE);
            assert!(admin_role_for_protocol_admin == vector<u8>[], 2);

            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = test_scenario::EEmptyInventory)]
    fun test_common_user_grant_protocol_admin_another_user() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::test_init(test_scenario::ctx(scenario));
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

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            grant_protocol_admin_role_to_user(&mut user3_val, scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }
    
    #[test]
    fun test_defaul_admin_revorke_protocol_admin_another_user() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::test_init(test_scenario::ctx(scenario));
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

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            revoke_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user2 = &mut user2_val;

            let has_protocol_admin_role = accessControlLib::hasRole(user_roles_collection, PROTOCOL_ADMIN_ROLE, object::id(user2));
            assert!(has_protocol_admin_role == false, 1);

            let admin_role_for_protocol_admin = accessControlLib::getRoleAdmin(user_roles_collection, PROTOCOL_ADMIN_ROLE);
            assert!(admin_role_for_protocol_admin == vector<u8>[], 2);

            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_CAN_NOT_GIVE_PROTOCOL_ADMIN_ROLE)]
    fun test_defaul_admin_revoke_protocol_admin_by_common_action() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::test_init(test_scenario::ctx(scenario));
            accessControlLib::test_init(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;
            let userId = object::id(user);

            let roleTemplate = PROTOCOL_ADMIN_ROLE;
            userLib::revokeRole(user_roles_collection, user, userId, roleTemplate);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_defaul_admin_revorke_not_exist_protocol_admin() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::test_init(test_scenario::ctx(scenario));
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

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            revoke_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user2 = &mut user2_val;

            let has_protocol_admin_role = accessControlLib::hasRole(user_roles_collection, PROTOCOL_ADMIN_ROLE, object::id(user2));
            assert!(has_protocol_admin_role == false, 1);

            let admin_role_for_protocol_admin = accessControlLib::getRoleAdmin(user_roles_collection, PROTOCOL_ADMIN_ROLE);
            assert!(admin_role_for_protocol_admin == vector<u8>[], 2);

            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_MISSING_ROLE)]
    fun test_common_user_revoke_not_exist_role() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let userId = object::id(&mut user_val);
            let user = &mut user_val;

            userLib::revokeRole(user_roles_collection, user, userId, vector<u8>[]);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_defaul_admin_revorke_not_given_protocol_admin() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::test_init(test_scenario::ctx(scenario));
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

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };
        
        test_scenario::next_tx(scenario, USER1);
        {
            revoke_protocol_admin_role_to_user(&mut user3_val, scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user3 = &mut user3_val;

            let has_protocol_admin_role = accessControlLib::hasRole(user_roles_collection, PROTOCOL_ADMIN_ROLE, object::id(user3));
            assert!(has_protocol_admin_role == false, 1);

            let admin_role_for_protocol_admin = accessControlLib::getRoleAdmin(user_roles_collection, PROTOCOL_ADMIN_ROLE);
            assert!(admin_role_for_protocol_admin == vector<u8>[], 2);

            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = test_scenario::EEmptyInventory)]
    fun test_common_user_revoke_protocol_admin_another_user() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::test_init(test_scenario::ctx(scenario));
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

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user3_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            revoke_protocol_admin_role_to_user(&mut user3_val, scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_create_community_check_new_roles() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user1_val = test_scenario::take_from_sender<User>(scenario);
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user1 = &mut user1_val;
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;

            let community_admin_template = COMMUNITY_ADMIN_ROLE;
            vector::append<u8>(&mut community_admin_template, object::id_to_bytes(&object::id(community)));
            let admin_role_for_community_admin = accessControlLib::getRoleAdmin(user_roles_collection, community_admin_template);
            assert!(admin_role_for_community_admin == PROTOCOL_ADMIN_ROLE, 2);

            let community_moderator_template = COMMUNITY_MODERATOR_ROLE;
            vector::append<u8>(&mut community_moderator_template, object::id_to_bytes(&object::id(community)));
            let admin_role_for_community_moderator = accessControlLib::getRoleAdmin(user_roles_collection, community_moderator_template);
            assert!(admin_role_for_community_moderator == community_admin_template, 2);

            let has_community_admin_role = accessControlLib::hasRole(user_roles_collection, community_admin_template, object::id(user1));
            assert!(has_community_admin_role == true, 1);

            let has_community_moderator_role = accessControlLib::hasRole(user_roles_collection, community_moderator_template, object::id(user1));
            assert!(has_community_moderator_role == true, 1);

            test_scenario::return_to_sender(scenario, user1_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_shared(community_val);
        };
        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_MISSING_ROLE)]
    fun test_defaul_admin_grant_community_admin() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::test_init(test_scenario::ctx(scenario));
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

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            communityLib_test::create_community(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_MISSING_ROLE)]
    fun test_defaul_admin_grant_community_moderator() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::test_init(test_scenario::ctx(scenario));
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

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            communityLib_test::create_community(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_moderator_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_MISSING_ROLE)]
    fun test_defaul_admin_grant_bot_role() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::test_init(test_scenario::ctx(scenario));
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

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            communityLib_test::create_community(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user3 = &mut user3_val;
            postLib_bot_test::grant_bot_role(object::id(user3), scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_MISSING_ROLE)]
    fun test_common_user_grant_not_exist_role() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let userId = object::id(&mut user_val);
            let user = &mut user_val;

            userLib::grantRole(user_roles_collection, user, userId, vector<u8>[]);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_protocol_admin_grant_community_admin() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user3 = &mut user3_val;

            let roleTemplate = COMMUNITY_ADMIN_ROLE;
            roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
            let has_community_admin_role = accessControlLib::hasRole(user_roles_collection, roleTemplate, object::id(user3));
            assert!(has_community_admin_role == true, 1);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_MISSING_ROLE)]
    fun test_protocol_admin_grant_community_moderator() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_moderator_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_protocol_admin_grant_community_moderator_correct_action() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_moderator_role_correct_action(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user3 = &mut user3_val;

            let roleTemplate = COMMUNITY_MODERATOR_ROLE;
            roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
            let has_community_moderator_role = accessControlLib::hasRole(user_roles_collection, roleTemplate, object::id(user3));
            assert!(has_community_moderator_role == true, 1);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_protocol_admin_grant_bot_role() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let user3 = &mut user3_val;
            postLib_bot_test::grant_bot_role(object::id(user3), scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user3 = &mut user3_val;

            let has_community_admin_role = accessControlLib::hasRole(user_roles_collection, BOT_ROLE, object::id(user3));
            assert!(has_community_admin_role == true, 1);

            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_MISSING_ROLE)]
    fun test_community_admin_grant_community_admin() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user2 = &mut user2_val;
            grant_community_admin_role(object::id(user2), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_community_admin_grant_community_admin_correct_action() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user2 = &mut user2_val;
            grant_community_admin_role_correct_action(object::id(user2), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user2 = &mut user2_val;

            let roleTemplate = COMMUNITY_ADMIN_ROLE;
            roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
            let has_community_moderator_role = accessControlLib::hasRole(user_roles_collection, roleTemplate, object::id(user2));
            assert!(has_community_moderator_role == true, 1);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_community_admin_grant_community_moderator() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user2 = &mut user2_val;
            grant_community_moderator_role(object::id(user2), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user2 = &mut user2_val;

            let roleTemplate = COMMUNITY_MODERATOR_ROLE;
            roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
            let has_community_moderator_role = accessControlLib::hasRole(user_roles_collection, roleTemplate, object::id(user2));
            assert!(has_community_moderator_role == true, 1);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_MISSING_ROLE)]
    fun test_community_admin_grant_bot_role() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let user2 = &mut user2_val;
            postLib_bot_test::grant_bot_role(object::id(user2), scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_MISSING_ROLE)]
    fun test_community_moderator_grant_community_moderator() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user2 = &mut user2_val;
            grant_community_moderator_role(object::id(user2), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_moderator_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_MISSING_ROLE)]
    fun test_community_admin_grant_community_moderator_for_another_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            communityLib_test::create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user2 = &mut user2_val;
            grant_community_moderator_role(object::id(user2), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::end(scenario_val);
    }
    
    #[test]
    fun test_protocol_admin_revoke_community_admin() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            revoke_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user3 = &mut user3_val;

            let roleTemplate = COMMUNITY_ADMIN_ROLE;
            roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
            let has_community_admin_role = accessControlLib::hasRole(user_roles_collection, roleTemplate, object::id(user3));
            assert!(has_community_admin_role == false, 1);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_protocol_admin_revoke_community_admin_correct_action() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role_correct_action(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            revoke_community_admin_role_correct_action(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user3 = &mut user3_val;

            let roleTemplate = COMMUNITY_ADMIN_ROLE;
            roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
            let has_community_admin_role = accessControlLib::hasRole(user_roles_collection, roleTemplate, object::id(user3));
            assert!(has_community_admin_role == false, 1);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_SELF_REVOKE)]
    fun test_community_admin_revoke_community_admin_from_himself() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role_correct_action(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection = &mut user_roles_collection_val;
            let userId = object::id(&mut user3_val);
            let user = &mut user3_val;

            communityLib::revokeCommunityAdminPermission(user_roles_collection, user, userId, community);

            test_scenario::return_to_sender(scenario, user3_val);
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_community_admin_revoke_community_moderator() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user2 = &mut user2_val;
            grant_community_moderator_role(object::id(user2), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user2 = &mut user2_val;
            revoke_community_moderator_role(object::id(user2), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user2 = &mut user2_val;

            let roleTemplate = COMMUNITY_MODERATOR_ROLE;
            roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
            let has_community_moderator_role = accessControlLib::hasRole(user_roles_collection, roleTemplate, object::id(user2));
            assert!(has_community_moderator_role == false, 1);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_community_admin_revoke_community_moderator_correct_action() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user2 = &mut user2_val;
            grant_community_moderator_role(object::id(user2), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user2 = &mut user2_val;
            revoke_community_moderator_role_correct_action(object::id(user2), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user2 = &mut user2_val;

            let roleTemplate = COMMUNITY_MODERATOR_ROLE;
            roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
            let has_community_moderator_role = accessControlLib::hasRole(user_roles_collection, roleTemplate, object::id(user2));
            assert!(has_community_moderator_role == false, 1);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_MISSING_ROLE)]
    fun test_community_admin_revoke_community_moderator_for_another_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            communityLib_test::create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user2 = &mut user2_val;
            revoke_community_moderator_role(object::id(user2), community, scenario);
            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = accessControlLib::E_ACCESS_CONTROL_MISSING_ROLE)]
    fun test_community_moderator_revoke_community_moderator() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user2 = &mut user2_val;
            grant_community_moderator_role(object::id(user2), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        let user1_val;
        test_scenario::next_tx(scenario, USER1);
        {
            user1_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user1 = &mut user1_val;
            revoke_community_moderator_role(object::id(user1), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            test_scenario::return_to_sender(scenario, user1_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = communityLib::E_COMMUNITY_IS_FROZEN)]
    fun test_protocol_admin_grant_community_admin_community_is_frozen() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
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

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role_correct_action(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = communityLib::E_COMMUNITY_IS_FROZEN)]
    fun test_protocol_admin_grant_community_moderator_community_is_frozen() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
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

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_moderator_role_correct_action(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_protocol_admin_revoke_community_admin_community_is_frozen() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_admin_role_correct_action(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
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

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            revoke_community_admin_role_correct_action(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user3 = &mut user3_val;

            let roleTemplate = COMMUNITY_ADMIN_ROLE;
            roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
            let has_community_admin_role = accessControlLib::hasRole(user_roles_collection, roleTemplate, object::id(user3));
            assert!(has_community_admin_role == false, 1);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_protocol_admin_revoke_community_moderator_community_is_frozen() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER1);
        {
            init_accessControlLib_common_role(scenario);
        };

        let user3_val;
        test_scenario::next_tx(scenario, USER3);
        {
            user3_val = test_scenario::take_from_sender<User>(scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role_to_user(&mut user2_val, scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            grant_community_moderator_role_correct_action(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
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

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user3 = &mut user3_val;
            revoke_community_moderator_role_correct_action(object::id(user3), community, scenario);

            test_scenario::return_shared(community_val);
        };

        test_scenario::next_tx(scenario, USER3);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user3 = &mut user3_val;

            let roleTemplate = COMMUNITY_MODERATOR_ROLE;
            roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
            let has_community_moderator_role = accessControlLib::hasRole(user_roles_collection, roleTemplate, object::id(user3));
            assert!(has_community_moderator_role == false, 1);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user3_val);
        };

        test_scenario::end(scenario_val);
    }

    // ====== Support functions ======

    #[test_only]
    public fun grant_protocol_admin_role(scenario: &mut Scenario) {
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let default_admin_cap_val = test_scenario::take_from_sender<DefaultAdminCap>(scenario);
        let default_admin_cap = &mut default_admin_cap_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;
        accessControlLib::grantProtocolAdminRole(default_admin_cap, user_roles_collection, object::id(user));

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_to_sender(scenario, default_admin_cap_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun grant_protocol_admin_role_to_user(user: &mut User, scenario: &mut Scenario) {
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let default_admin_cap_val = test_scenario::take_from_sender<DefaultAdminCap>(scenario);
        let default_admin_cap = &mut default_admin_cap_val;
        accessControlLib::grantProtocolAdminRole(default_admin_cap, user_roles_collection, object::id(user));

        test_scenario::return_to_sender(scenario, default_admin_cap_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun revoke_protocol_admin_role_to_user(user: &mut User, scenario: &mut Scenario) {
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let default_admin_cap_val = test_scenario::take_from_sender<DefaultAdminCap>(scenario);
        let default_admin_cap = &mut default_admin_cap_val;
        accessControlLib::revokeProtocolAdminRole(default_admin_cap, user_roles_collection, object::id(user));

        test_scenario::return_to_sender(scenario, default_admin_cap_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun grant_community_admin_role(userId: sui::object::ID, community: &mut Community, scenario: &mut Scenario) {    // only for protocol admin
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        let roleTemplate = COMMUNITY_ADMIN_ROLE;
        vector::append<u8>(&mut roleTemplate, object::id_to_bytes(&object::id(community)));
        userLib::grantRole(user_roles_collection, user, userId, roleTemplate);

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun grant_community_role(userId: sui::object::ID, role: vector<u8>, community: &mut Community, scenario: &mut Scenario) {
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        let roleTemplate = role;
        vector::append<u8>(&mut roleTemplate, object::id_to_bytes(&object::id(community)));
        userLib::grantRole(user_roles_collection, user, userId, roleTemplate);

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun grant_community_admin_role_correct_action(userId: sui::object::ID, community: &mut Community, scenario: &mut Scenario) { // for protocol admin and community admin
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        communityLib::giveCommunityAdminPermission(user_roles_collection, user, userId, community);

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun grant_himself_community_admin_role(community: &mut Community, scenario: &mut Scenario) { // only for protocol admin
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;
        let userId = object::id(user);

        let roleTemplate = COMMUNITY_ADMIN_ROLE;
        vector::append<u8>(&mut roleTemplate, object::id_to_bytes(&object::id(community)));
        userLib::grantRole(user_roles_collection, user, userId, roleTemplate);

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun grant_community_moderator_role(userId: sui::object::ID, community: &mut Community, scenario: &mut Scenario) { // only for protocol admin
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        let roleTemplate = COMMUNITY_MODERATOR_ROLE;
        vector::append<u8>(&mut roleTemplate, object::id_to_bytes(&object::id(community)));
        userLib::grantRole(user_roles_collection, user, userId, roleTemplate);

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun grant_community_moderator_role_correct_action(userId: sui::object::ID, community: &mut Community, scenario: &mut Scenario) { // for protocol admin and community admin
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        communityLib::giveCommunityModeratorPermission(user_roles_collection, user, userId, community);

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun revoke_community_admin_role(userId: sui::object::ID, community: &mut Community, scenario: &mut Scenario) { // only for protocol admin
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        let roleTemplate = COMMUNITY_ADMIN_ROLE;
        roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
        userLib::revokeRole(user_roles_collection, user, userId, roleTemplate);

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun revoke_community_admin_role_correct_action(userId: sui::object::ID, community: &mut Community, scenario: &mut Scenario) { // for protocol admin and community admin
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        communityLib::revokeCommunityAdminPermission(user_roles_collection, user, userId, community);

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun revoke_community_moderator_role(userId: sui::object::ID, community: &mut Community, scenario: &mut Scenario) { // only for community admin
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        let roleTemplate = COMMUNITY_MODERATOR_ROLE;
        roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
        userLib::revokeRole(user_roles_collection, user, userId, roleTemplate);

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun revoke_community_moderator_role_correct_action(userId: sui::object::ID, community: &mut Community, scenario: &mut Scenario) { // for protocol admin and community admin
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        communityLib::revokeCommunityModeratorPermission(user_roles_collection, user, userId, community);

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun init_accessControlLib_common_role(scenario: &mut Scenario) {
        {
            userLib::test_init(test_scenario::ctx(scenario));
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            communityLib_test::create_community(scenario);
        };
    }
}