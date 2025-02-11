#[test_only]
module peeranha::accessControlLib_ban
{
    use peeranha::postLib::{Self, PostMetaData, Reply};
    use peeranha::accessControlLib::{Self, UserRolesCollection};
    use peeranha::communityLib::{Self, Community};
    use peeranha::userLib::{Self, User};
    use peeranha::accessControlLib_common_role_test;
    use std::vector;
    use peeranha::postLib_test;
    use sui::object::{Self, ID};
    use peeranha::postLib_change_post_type_test;
    use sui::test_scenario;
    use sui::clock;

    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    const USER3: address = @0xA3;

    const PROTOCOL_ADMIN_ROLE: vector<u8> = vector<u8>[2];
    const COMMUNITY_ADMIN_ROLE: vector<u8> = vector<u8>[3];
    const COMMUNITY_MODERATOR_ROLE: vector<u8> = vector<u8>[4];
    const BOT_ROLE: vector<u8> = vector<u8>[5];

    const COMMUNITY_BAN_ROLE: vector<u8> = vector<u8>[6];
    const BAN_ROLE: vector<u8> = vector<u8>[7];

    #[test]
    fun test_ban_community_user() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;

            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            let roleTemplate = COMMUNITY_BAN_ROLE;
            vector::append<u8>(&mut roleTemplate, object::id_to_bytes(&object::id(community)));
            userLib::grantRole(user_roles_collection, user, object::id(&user2_val), roleTemplate);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user2 = &mut user2_val;

            let roleTemplate = COMMUNITY_BAN_ROLE;
            roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
            let has_community_ban_role = accessControlLib::hasRole(user_roles_collection, roleTemplate, object::id(user2));
            assert!(has_community_ban_role == true, 1);

            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user2_val);
            test_scenario::return_shared(community_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    #[test]
    fun test_unban_community_user() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;

            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            let roleTemplate = COMMUNITY_BAN_ROLE;
            vector::append<u8>(&mut roleTemplate, object::id_to_bytes(&object::id(community)));
            userLib::grantRole(user_roles_collection, user, object::id(&user2_val), roleTemplate);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
           let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;

            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            let roleTemplate = COMMUNITY_BAN_ROLE;
            vector::append<u8>(&mut roleTemplate, object::id_to_bytes(&object::id(community)));
            userLib::revokeRole(user_roles_collection, user, object::id(&user2_val), roleTemplate);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user2 = &mut user2_val;

            let roleTemplate = COMMUNITY_BAN_ROLE;
            roleTemplate = accessControlLib::getCommunityRole(roleTemplate, object::id(community));
            let has_community_ban_role = accessControlLib::hasRole(user_roles_collection, roleTemplate, object::id(user2));
            assert!(has_community_ban_role == false, 1);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_to_sender(scenario, user2_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }

    ///////////////////////////////////////////////////////////////////////////

    #[test]
    fun test_community_initPermistions() {
        let scenario_val = test_scenario::begin(USER1);
        let time;
        let scenario = &mut scenario_val;
        {
            time = postLib_change_post_type_test::init_postLib_test(EXPERT_POST, scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            communityLib::initPermistions(user_roles_collection, user, vector<ID>[object::id(community)]);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
            test_scenario::return_shared(community_val);
        };
        
        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;

            let roleTemplate = COMMUNITY_BAN_ROLE;
            vector::append<u8>(&mut roleTemplate, object::id_to_bytes(&object::id(community)));
            let verifyRole = accessControlLib::getRoleAdmin(user_roles_collection, roleTemplate);
            
            let moderatorRoleTemplate = COMMUNITY_MODERATOR_ROLE;
            vector::append<u8>(&mut moderatorRoleTemplate, object::id_to_bytes(&object::id(community)));
            assert!(moderatorRoleTemplate == verifyRole, 1);

            test_scenario::return_shared(user_roles_collection_val);     
            test_scenario::return_shared(community_val);
        };

        clock::destroy_for_testing(time);
        test_scenario::end(scenario_val);  
    }


    ////////////////////////////////////////////////////////////////////////////

    
}