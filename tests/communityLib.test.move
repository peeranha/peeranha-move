#[test_only]
module peeranha::communityLib_test
{
    use peeranha::communityLib::{Self, Community};
    use peeranha::userLib::{Self, User};
    use std::vector;
    use peeranha::userLib_test;
    use peeranha::accessControlLib::{Self, UserRolesCollection, DefaultAdminCap};
    use sui::test_scenario::{Self, Scenario};
    use sui::object::{Self/*, ID*/};

    // use std::debug;
    // debug::print(community);

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;
    const COMMUNITY_ADMIN_ROLE: vector<u8> = vector<u8>[3];

    #[test]
    fun test_create_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            
            let (ipfsDoc, documentation, isFrozen) = communityLib::getCommunityData(community);
            let tags = communityLib::getCommunityTags(community);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(documentation == vector<u8>[], 2);
            assert!(isFrozen == false, 3);
            assert!(tags == communityLib::unitTestGetCommunityTags(
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                x"a1fe8ede53e1989db4eb913bf789759b3573c101d2410343e151908823b4acd8"
            ), 5);

            test_scenario::return_shared(community_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_updateIPFS_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            communityLib::updateCommunity(user_roles_collection, user, community, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1");

            let (ipfsDoc, documentation, _isFrozen) = communityLib::getCommunityData(community);
            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(documentation == vector<u8>[], 2);

            test_scenario::return_shared(community_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_updateIPFS_documentation() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_community_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            communityLib::updateDocumentationTree(user_roles_collection, user, community, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c83");

            let (ipfsDoc, documentation, isFrozen) = communityLib::getCommunityData(community);
            let tags = communityLib::getCommunityTags(community);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(documentation == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c83", 2);
            assert!(isFrozen == false, 3);
            assert!(tags == communityLib::unitTestGetCommunityTags(
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                x"a1fe8ede53e1989db4eb913bf789759b3573c101d2410343e151908823b4acd8"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_create_tag() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            communityLib::createTag(user_roles_collection, user, community, x"0000000000000000000000000000000000000000000000000000000000000006", test_scenario::ctx(scenario));

            let tags = communityLib::getCommunityTags(community);
            assert!(tags == communityLib::unitTestGetMoreCommunityTags(
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                x"a1fe8ede53e1989db4eb913bf789759b3573c101d2410343e151908823b4acd8",
                x"0000000000000000000000000000000000000000000000000000000000000006"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_update_tag() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            communityLib::updateTag(user_roles_collection, user, community, 2, x"0000000000000000000000000000000000000000000000000000000000000007");
            let tags = communityLib::getCommunityTags(community);
            assert!(tags == communityLib::unitTestGetCommunityTags(
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
                x"0000000000000000000000000000000000000000000000000000000000000007",
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                x"a1fe8ede53e1989db4eb913bf789759b3573c101d2410343e151908823b4acd8"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test, expected_failure(abort_code = communityLib::E_TAG_DOES_NOT_EXIST)]
    fun test_update_not_exist_tag() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            communityLib::updateTag(user_roles_collection, user, community, 8, x"0000000000000000000000000000000000000000000000000000000000000007");

            test_scenario::return_shared(community_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test, expected_failure(abort_code = communityLib::E_TAG_ID_CAN_NOT_BE_0)]
    fun test_update_0_tag() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            communityLib::updateTag(user_roles_collection, user, community, 0, x"0000000000000000000000000000000000000000000000000000000000000007");

            test_scenario::return_shared(community_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_update_created_tag() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            communityLib::createTag(user_roles_collection, user, community, x"0000000000000000000000000000000000000000000000000000000000000006", test_scenario::ctx(scenario));
            communityLib::updateTag(user_roles_collection, user, community, 6, x"0000000000000000000000000000000000000000000000000000000000000007");

            let tags = communityLib::getCommunityTags(community);
            assert!(tags == communityLib::unitTestGetMoreCommunityTags(
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                x"a1fe8ede53e1989db4eb913bf789759b3573c101d2410343e151908823b4acd8",
                x"0000000000000000000000000000000000000000000000000000000000000007"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_update_first_tag() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            communityLib::updateTag(user_roles_collection, user, community, 1, x"0000000000000000000000000000000000000000000000000000000000000007");

            let tags = communityLib::getCommunityTags(community);
            assert!(tags == communityLib::unitTestGetCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000007",
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                x"a1fe8ede53e1989db4eb913bf789759b3573c101d2410343e151908823b4acd8"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_freeze_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
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

            let (_ipfsDoc, _documentation, isFrozen) = communityLib::getCommunityData(community);
            assert!(isFrozen == true, 3);

            test_scenario::return_shared(community_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_unfreeze_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
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
            communityLib::unfreezeCommunity(user_roles_collection, user, community);

            let (_ipfsDoc, _documentation, isFrozen) = communityLib::getCommunityData(community);
            assert!(isFrozen == false, 3);

            test_scenario::return_shared(community_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_create2_communities() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
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
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_another_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let community_val2 = test_scenario::take_shared<Community>(scenario);
            let community2 = &mut community_val2;

            let (ipfsDoc, documentation, isFrozen) = communityLib::getCommunityData(community);
            let tags = communityLib::getCommunityTags(community);
            assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 6);
            assert!(documentation == vector<u8>[], 7);
            assert!(isFrozen == false, 8);
            assert!(tags == communityLib::unitTestGetCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000003",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005"
            ), 9);

            let (ipfsDoc2, documentation2, isFrozen2) = communityLib::getCommunityData(community2);
            let tags2 = communityLib::getCommunityTags(community2);
            assert!(ipfsDoc2 == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(documentation2 == vector<u8>[], 2);
            assert!(isFrozen2 == false, 3);
            assert!(tags2 == communityLib::unitTestGetCommunityTags(
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                x"a1fe8ede53e1989db4eb913bf789759b3573c101d2410343e151908823b4acd8"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(community_val2);
        };

        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_create2_communities_by_different_users() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::init_test(test_scenario::ctx(scenario));
            accessControlLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            userLib_test::create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            userLib_test::create_user(scenario);
        };

        let user2;
        let user2_val;
        test_scenario::next_tx(scenario, USER2);
        {
            user2_val = test_scenario::take_from_sender<User>(scenario);
            user2 = &mut user2_val;
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let default_admin_cap_val = test_scenario::take_from_sender<DefaultAdminCap>(scenario);
            let default_admin_cap = &mut default_admin_cap_val;
            accessControlLib::grantProtocolAdminRole(default_admin_cap, user_roles_collection, object::id(user2));

            test_scenario::return_to_sender(scenario, default_admin_cap_val);
            test_scenario::return_shared(user_roles_collection_val);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            test_scenario::return_to_sender(scenario, user2_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            grant_protocol_admin_role(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER2);
        {
            create_another_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let community_val2 = test_scenario::take_shared<Community>(scenario);
            let community2 = &mut community_val2;

            let (ipfsDoc, documentation, isFrozen) = communityLib::getCommunityData(community);
            let tags = communityLib::getCommunityTags(community);
            assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 6);
            assert!(documentation == vector<u8>[], 7);
            assert!(isFrozen == false, 8);
            assert!(tags == communityLib::unitTestGetCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000003",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005"
            ), 9);

            let (ipfsDoc2, documentation2, isFrozen2) = communityLib::getCommunityData(community2);
            let tags2 = communityLib::getCommunityTags(community2);
            assert!(ipfsDoc2 == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(documentation2 == vector<u8>[], 2);
            assert!(isFrozen2 == false, 3);
            assert!(tags2 == communityLib::unitTestGetCommunityTags(
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                x"a1fe8ede53e1989db4eb913bf789759b3573c101d2410343e151908823b4acd8"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(community_val2);
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
    public fun grant_community_admin_role(scenario: &mut Scenario) {
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;
        let community_val = test_scenario::take_shared<Community>(scenario);
        let community = &mut community_val;

        let userId = object::id(user);
        let roleTemplate = COMMUNITY_ADMIN_ROLE;
        vector::append<u8>(&mut roleTemplate, object::id_to_bytes(&object::id(community)));
        userLib::grantRole(user_roles_collection, user, userId, roleTemplate);

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
        test_scenario::return_shared(community_val);
    }
    
    #[test_only]
    public fun create_community(scenario: &mut Scenario) {
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;
        
        communityLib::createCommunity(
            user_roles_collection,
            user,
            x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
            vector<vector<u8>>[
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                x"a1fe8ede53e1989db4eb913bf789759b3573c101d2410343e151908823b4acd8"
            ],
            test_scenario::ctx(scenario)
        );

        test_scenario::return_shared(user_roles_collection_val);
        test_scenario::return_to_sender(scenario, user_val);
    }

    #[test_only]
    fun create_another_community(scenario: &mut Scenario) {
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;
        
        communityLib::createCommunity(
            user_roles_collection,
            user,
            x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
            vector<vector<u8>>[
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000003",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005"
            ],
            test_scenario::ctx(scenario)
        );

        test_scenario::return_shared(user_roles_collection_val);
        test_scenario::return_to_sender(scenario, user_val);
    }

    #[test_only]
    public fun update_common_community(scenario: &mut Scenario) {
        let community_val = test_scenario::take_shared<Community>(scenario);
        let community = &mut community_val;
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        communityLib::updateCommunity(user_roles_collection, user, community, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1");

        test_scenario::return_shared(community_val);
        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun update_common_documentation(scenario: &mut Scenario) {
        let community_val = test_scenario::take_shared<Community>(scenario);
        let community = &mut community_val;
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        communityLib::updateDocumentationTree(user_roles_collection, user, community, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c83");

        test_scenario::return_shared(community_val);
        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun create_common_tag(scenario: &mut Scenario) {
        let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
            let user_roles_collection = &mut user_roles_collection_val;
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;

            communityLib::createTag(user_roles_collection, user, community, x"0000000000000000000000000000000000000000000000000000000000000006", test_scenario::ctx(scenario));

            test_scenario::return_shared(community_val);
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun update_common_tag(scenario: &mut Scenario) {
        let community_val = test_scenario::take_shared<Community>(scenario);
        let community = &mut community_val;
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        communityLib::updateTag(user_roles_collection, user, community, 2, x"0000000000000000000000000000000000000000000000000000000000000007");

        test_scenario::return_shared(community_val);
        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun freeze_common_community(scenario: &mut Scenario) {
        let community_val = test_scenario::take_shared<Community>(scenario);
        let community = &mut community_val;
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        communityLib::freezeCommunity(user_roles_collection, user, community);
        let (_ipfsDoc, _documentation, isFrozen) = communityLib::getCommunityData(community);
        assert!(isFrozen == true, 3);

        test_scenario::return_shared(community_val);
        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun unfreeze_common_community(scenario: &mut Scenario) {
        let community_val = test_scenario::take_shared<Community>(scenario);
        let community = &mut community_val;
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;

        communityLib::unfreezeCommunity(user_roles_collection, user, community);
        let (_ipfsDoc, _documentation, isFrozen) = communityLib::getCommunityData(community);
        assert!(isFrozen == false, 3);

        test_scenario::return_shared(community_val);
        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_shared(user_roles_collection_val);
    }
}