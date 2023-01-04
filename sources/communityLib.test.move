#[test_only]
module basics::communityLib_test
{
    use basics::communityLib;
    use basics::userLib;
    use sui::test_scenario;

    #[test]
    fun test_create_community() {
        let user1 = @0xA1;

        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, user1);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            communityLib::createCommunity(
                communityCollection,
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

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(timeCreate == 0, 2);
            assert!(isFrozen == false, 3);
            assert!(tags == communityLib::unitTestGetCommunityTags(
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
                x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
                x"a1fe8ede53e1989db4eb913bf789759b3573c101d2410343e151908823b4acd8"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_updateIPFS_community() {
        let user1 = @0xA1;

        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, user1);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            communityLib::updateCommunity(communityCollection, 1, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", test_scenario::ctx(scenario));

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 1);
            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(timeCreate == 0, 2);
            assert!(isFrozen == false, 3);
            assert!(tags == communityLib::unitTestGetCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000003",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_create_tag() {
        let user1 = @0xA1;

        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, user1);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            communityLib::createTag(communityCollection, 1, x"0000000000000000000000000000000000000000000000000000000000000006", test_scenario::ctx(scenario));

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(timeCreate == 0, 2);
            assert!(isFrozen == false, 3);
            assert!(tags == communityLib::unitTestGetMoreCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000003",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005",
                x"0000000000000000000000000000000000000000000000000000000000000006"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_update_tag() {
        let user1 = @0xA1;

        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, user1);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            communityLib::updateTag(communityCollection, 1, 2, x"0000000000000000000000000000000000000000000000000000000000000007", test_scenario::ctx(scenario));

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(timeCreate == 0, 2);
            assert!(isFrozen == false, 3);
            assert!(tags == communityLib::unitTestGetCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000007",
                x"0000000000000000000000000000000000000000000000000000000000000003",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);        
    }

    #[test, expected_failure(abort_code = communityLib::E_COMMUNITY_IS_FROZEN)]
    fun test_freeze_community() {
        let user1 = @0xA1;

        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, user1);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            communityLib::freezeCommunity(communityCollection, 1, test_scenario::ctx(scenario));

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(timeCreate == 0, 2);
            assert!(isFrozen == true, 3);
            assert!(tags == communityLib::unitTestGetCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000003",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_unfreeze_community() {
        let user1 = @0xA1;

        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, user1);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            communityLib::freezeCommunity(communityCollection, 1, test_scenario::ctx(scenario));
            communityLib::unfreezeCommunity(communityCollection, 1, test_scenario::ctx(scenario));

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(timeCreate == 0, 2);
            assert!(isFrozen == false, 3);
            assert!(tags == communityLib::unitTestGetCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000003",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005"
            ), 5);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);        
    }

    #[test]
    fun test_create2_communities() {
        let user1 = @0xA1;

        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;
        {
            communityLib::init_test(test_scenario::ctx(scenario));
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, user1);
        {
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;
            let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = &mut user_val;
            userLib::create_user(userCollection, test_scenario::ctx(scenario));

            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            communityLib::createCommunity(
                communityCollection,
                x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
                vector<vector<u8>>[
                    x"0000000000000000000000000000000000000000000000000000000000000010",
                    x"0000000000000000000000000000000000000000000000000000000000000011",
                    x"0000000000000000000000000000000000000000000000000000000000000012",
                    x"0000000000000000000000000000000000000000000000000000000000000013",
                    x"0000000000000000000000000000000000000000000000000000000000000014"
                ],
                test_scenario::ctx(scenario)
            );

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 1);
            assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
            assert!(timeCreate == 0, 2);
            assert!(isFrozen == false, 3);
            assert!(tags == communityLib::unitTestGetCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000003",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005"
            ), 5);

            let (ipfsDoc2, timeCreate2, isFrozen2, tags2) = communityLib::getCommunityData(communityCollection, 2);
            assert!(ipfsDoc2 == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 6);
            assert!(timeCreate2 == 0, 7);
            assert!(isFrozen2 == false, 8);
            assert!(tags2 == communityLib::unitTestGetCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000010",
                x"0000000000000000000000000000000000000000000000000000000000000011",
                x"0000000000000000000000000000000000000000000000000000000000000012",
                x"0000000000000000000000000000000000000000000000000000000000000013",
                x"0000000000000000000000000000000000000000000000000000000000000014"
            ), 9);

            test_scenario::return_shared(community_val);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);        
    }
}