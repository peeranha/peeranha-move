// #[test_only]
// module basics::communityLib_test
// {
//     use basics::communityLib::{Self, Community};
//     use basics::userLib::{Self, UsersRatingCollection};
//     use sui::test_scenario::{Self, Scenario};

//     // use std::debug;
//     // debug::print(community);

//     const USER1: address = @0xA1;
//     const USER2: address = @0xA2;

//     #[test]
//     fun test_create_community() {
//         let scenario_val = test_scenario::begin(USER1);
//         let scenario = &mut scenario_val;
//         {
//             userLib::init_test(test_scenario::ctx(scenario));
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             let userRatingCollection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
//             let userRatingCollection = &mut userRatingCollection_val;
//             userLib::createUser(userRatingCollection, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", test_scenario::ctx(scenario));

//             communityLib::createCommunity(
//                 // communityCollection,
//                 x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
//                 vector<vector<u8>>[
//                     x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
//                     x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
//                     x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
//                     x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
//                     x"a1fe8ede53e1989db4eb913bf789759b3573c101d2410343e151908823b4acd8"
//                 ],
//                 test_scenario::ctx(scenario)
//             );
//             test_scenario::return_shared(userRatingCollection_val);
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             let community_val = test_scenario::take_shared<Community>(scenario);
//             let community = &mut community_val;
            
//             let (ipfsDoc, timeCreate, isFrozen) = communityLib::getCommunityData(community);
//             let tags = communityLib::getCommunityTags(community);
//             assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
//             assert!(timeCreate == 0, 2);
//             assert!(isFrozen == false, 3);
//             assert!(tags == communityLib::unitTestGetCommunityTags(
//                 x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
//                 x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
//                 x"5ed5a3e1e862b992ef0bb085979d26615694fbec5106a6cfe2fdf8ac8eb9aedc",
//                 x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc",
//                 x"a1fe8ede53e1989db4eb913bf789759b3573c101d2410343e151908823b4acd8"
//             ), 5);

//             test_scenario::return_shared(community_val);
//         };

//         test_scenario::end(scenario_val);
//     }

//     #[test_only]
//     fun create_user_and_community(scenario: &mut Scenario) {
//         let userRatingCollection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
//         let userRatingCollection = &mut userRatingCollection_val;

//         userLib::createUser(userRatingCollection, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", test_scenario::ctx(scenario));
//         communityLib::createCommunity(
//             x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
//             vector<vector<u8>>[
//                 x"0000000000000000000000000000000000000000000000000000000000000001",
//                 x"0000000000000000000000000000000000000000000000000000000000000002",
//                 x"0000000000000000000000000000000000000000000000000000000000000003",
//                 x"0000000000000000000000000000000000000000000000000000000000000004",
//                 x"0000000000000000000000000000000000000000000000000000000000000005"
//             ],
//             test_scenario::ctx(scenario)
//         );
//         test_scenario::return_shared(userRatingCollection_val);
//     }

//     #[test]
//     fun test_updateIPFS_community() {
//         let scenario_val = test_scenario::begin(USER1);
//         let scenario = &mut scenario_val;
//         {
//             userLib::init_test(test_scenario::ctx(scenario));
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             create_user_and_community(scenario)
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             let community_val = test_scenario::take_shared<Community>(scenario);
//             let community = &mut community_val;

//             communityLib::updateCommunity(community, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", test_scenario::ctx(scenario));

//             let (ipfsDoc, timeCreate, isFrozen) = communityLib::getCommunityData(community);
//             let tags = communityLib::getCommunityTags(community);
//             assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
//             assert!(timeCreate == 0, 2);
//             assert!(isFrozen == false, 3);
//             assert!(tags == communityLib::unitTestGetCommunityTags(
//                 x"0000000000000000000000000000000000000000000000000000000000000001",
//                 x"0000000000000000000000000000000000000000000000000000000000000002",
//                 x"0000000000000000000000000000000000000000000000000000000000000003",
//                 x"0000000000000000000000000000000000000000000000000000000000000004",
//                 x"0000000000000000000000000000000000000000000000000000000000000005"
//             ), 5);

//             test_scenario::return_shared(community_val);
//         };
//         test_scenario::end(scenario_val);        
//     }

//     #[test]
//     fun test_create_tag() {
//         let scenario_val = test_scenario::begin(USER1);
//         let scenario = &mut scenario_val;
//         {
//             userLib::init_test(test_scenario::ctx(scenario));
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             create_user_and_community(scenario);
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             let community_val = test_scenario::take_shared<Community>(scenario);
//             let community = &mut community_val;

//             communityLib::createTag(community, x"0000000000000000000000000000000000000000000000000000000000000006", test_scenario::ctx(scenario));

//             let (ipfsDoc, timeCreate, isFrozen) = communityLib::getCommunityData(community);
//             let tags = communityLib::getCommunityTags(community);
//             assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
//             assert!(timeCreate == 0, 2);
//             assert!(isFrozen == false, 3);
//             assert!(tags == communityLib::unitTestGetMoreCommunityTags(
//                 x"0000000000000000000000000000000000000000000000000000000000000001",
//                 x"0000000000000000000000000000000000000000000000000000000000000002",
//                 x"0000000000000000000000000000000000000000000000000000000000000003",
//                 x"0000000000000000000000000000000000000000000000000000000000000004",
//                 x"0000000000000000000000000000000000000000000000000000000000000005",
//                 x"0000000000000000000000000000000000000000000000000000000000000006"
//             ), 5);

//             test_scenario::return_shared(community_val);
//         };
//         test_scenario::end(scenario_val);        
//     }

//     #[test]
//     fun test_update_tag() {
//         let scenario_val = test_scenario::begin(USER1);
//         let scenario = &mut scenario_val;
//         {
//             userLib::init_test(test_scenario::ctx(scenario));
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             create_user_and_community(scenario);
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             let community_val = test_scenario::take_shared<Community>(scenario);
//             let community = &mut community_val;

//             communityLib::updateTag(community, 2, x"0000000000000000000000000000000000000000000000000000000000000007", test_scenario::ctx(scenario));

//             let (ipfsDoc, timeCreate, isFrozen) = communityLib::getCommunityData(community);
//             let tags = communityLib::getCommunityTags(community);
//             assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
//             assert!(timeCreate == 0, 2);
//             assert!(isFrozen == false, 3);
//             assert!(tags == communityLib::unitTestGetCommunityTags(
//                 x"0000000000000000000000000000000000000000000000000000000000000001",
//                 x"0000000000000000000000000000000000000000000000000000000000000007",
//                 x"0000000000000000000000000000000000000000000000000000000000000003",
//                 x"0000000000000000000000000000000000000000000000000000000000000004",
//                 x"0000000000000000000000000000000000000000000000000000000000000005"
//             ), 5);

//             test_scenario::return_shared(community_val);
//         };
//         test_scenario::end(scenario_val);        
//     }

//     // #[test, expected_failure(abort_code = communityLib::E_COMMUNITY_IS_FROZEN)]
//     #[test]
//     fun test_freeze_community() {
//         let scenario_val = test_scenario::begin(USER1);
//         let scenario = &mut scenario_val;
//         {
//             userLib::init_test(test_scenario::ctx(scenario));
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             create_user_and_community(scenario);
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             let community_val = test_scenario::take_shared<Community>(scenario);
//             let community = &mut community_val;

//             communityLib::freezeCommunity(community, test_scenario::ctx(scenario));

//             let (ipfsDoc, timeCreate, isFrozen) = communityLib::getCommunityData(community);
//             let tags = communityLib::getCommunityTags(community);
//             assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
//             assert!(timeCreate == 0, 2);
//             assert!(isFrozen == true, 3);
//             assert!(tags == communityLib::unitTestGetCommunityTags(
//                 x"0000000000000000000000000000000000000000000000000000000000000001",
//                 x"0000000000000000000000000000000000000000000000000000000000000002",
//                 x"0000000000000000000000000000000000000000000000000000000000000003",
//                 x"0000000000000000000000000000000000000000000000000000000000000004",
//                 x"0000000000000000000000000000000000000000000000000000000000000005"
//             ), 5);

//             test_scenario::return_shared(community_val);
//         };
//         test_scenario::end(scenario_val);        
//     }

//     #[test]
//     fun test_unfreeze_community() {
//         let scenario_val = test_scenario::begin(USER1);
//         let scenario = &mut scenario_val;
//         {
//             userLib::init_test(test_scenario::ctx(scenario));
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             create_user_and_community(scenario);
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             let community_val = test_scenario::take_shared<Community>(scenario);
//             let community = &mut community_val;

//             communityLib::freezeCommunity(community, test_scenario::ctx(scenario));
//             communityLib::unfreezeCommunity(community, test_scenario::ctx(scenario));

//             let (ipfsDoc, timeCreate, isFrozen) = communityLib::getCommunityData(community);
//             let tags = communityLib::getCommunityTags(community);
//             assert!(ipfsDoc == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
//             assert!(timeCreate == 0, 2);
//             assert!(isFrozen == false, 3);
//             assert!(tags == communityLib::unitTestGetCommunityTags(
//                 x"0000000000000000000000000000000000000000000000000000000000000001",
//                 x"0000000000000000000000000000000000000000000000000000000000000002",
//                 x"0000000000000000000000000000000000000000000000000000000000000003",
//                 x"0000000000000000000000000000000000000000000000000000000000000004",
//                 x"0000000000000000000000000000000000000000000000000000000000000005"
//             ), 5);

//             test_scenario::return_shared(community_val);
//         };
//         test_scenario::end(scenario_val);        
//     }

//     #[test]
//     fun test_create2_communities() {
//         let scenario_val = test_scenario::begin(USER1);
//         let scenario = &mut scenario_val;
//         {
//             userLib::init_test(test_scenario::ctx(scenario));
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             create_user_and_community(scenario);
//             communityLib::createCommunity(
//                 x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
//                 vector<vector<u8>>[
//                     x"0000000000000000000000000000000000000000000000000000000000000010",
//                     x"0000000000000000000000000000000000000000000000000000000000000011",
//                     x"0000000000000000000000000000000000000000000000000000000000000012",
//                     x"0000000000000000000000000000000000000000000000000000000000000013",
//                     x"0000000000000000000000000000000000000000000000000000000000000014"
//                 ],
//                 test_scenario::ctx(scenario)
//             );
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             let community_val = test_scenario::take_shared<Community>(scenario);
//             let community = &mut community_val;
//             let community_val2 = test_scenario::take_shared<Community>(scenario);
//             let community2 = &mut community_val2;

//             let (ipfsDoc, timeCreate, isFrozen) = communityLib::getCommunityData(community);
//             let tags = communityLib::getCommunityTags(community);
//             assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 6);
//             assert!(timeCreate == 0, 7);
//             assert!(isFrozen == false, 8);
//             assert!(tags == communityLib::unitTestGetCommunityTags(
//                 x"0000000000000000000000000000000000000000000000000000000000000010",
//                 x"0000000000000000000000000000000000000000000000000000000000000011",
//                 x"0000000000000000000000000000000000000000000000000000000000000012",
//                 x"0000000000000000000000000000000000000000000000000000000000000013",
//                 x"0000000000000000000000000000000000000000000000000000000000000014"
//             ), 9);

//             let (ipfsDoc2, timeCreate2, isFrozen2) = communityLib::getCommunityData(community2);
//             let tags2 = communityLib::getCommunityTags(community2);
//             assert!(ipfsDoc2 == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
//             assert!(timeCreate2 == 0, 2);
//             assert!(isFrozen2 == false, 3);
//             assert!(tags2 == communityLib::unitTestGetCommunityTags(
//                 x"0000000000000000000000000000000000000000000000000000000000000001",
//                 x"0000000000000000000000000000000000000000000000000000000000000002",
//                 x"0000000000000000000000000000000000000000000000000000000000000003",
//                 x"0000000000000000000000000000000000000000000000000000000000000004",
//                 x"0000000000000000000000000000000000000000000000000000000000000005"
//             ), 5);

//             test_scenario::return_shared(community_val);
//             test_scenario::return_shared(community_val2);
//         };
//         test_scenario::end(scenario_val);        
//     }

//     #[test]
//     fun test_create2_communities_by_different_users() {
//         let scenario_val = test_scenario::begin(USER1);
//         let scenario = &mut scenario_val;
//         {
//             userLib::init_test(test_scenario::ctx(scenario));
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             create_user_and_community(scenario);
//         };

//         test_scenario::next_tx(scenario, USER2);
//         {
//             communityLib::createCommunity(
//                 x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82",
//                 vector<vector<u8>>[
//                     x"0000000000000000000000000000000000000000000000000000000000000010",
//                     x"0000000000000000000000000000000000000000000000000000000000000011",
//                     x"0000000000000000000000000000000000000000000000000000000000000012",
//                     x"0000000000000000000000000000000000000000000000000000000000000013",
//                     x"0000000000000000000000000000000000000000000000000000000000000014"
//                 ],
//                 test_scenario::ctx(scenario)
//             );
//         };

//         test_scenario::next_tx(scenario, USER1);
//         {
//             let community_val = test_scenario::take_shared<Community>(scenario);
//             let community = &mut community_val;
//             let community_val2 = test_scenario::take_shared<Community>(scenario);
//             let community2 = &mut community_val2;

//             let (ipfsDoc, timeCreate, isFrozen) = communityLib::getCommunityData(community);
//             let tags = communityLib::getCommunityTags(community);
//             assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 6);
//             assert!(timeCreate == 0, 7);
//             assert!(isFrozen == false, 8);
//             assert!(tags == communityLib::unitTestGetCommunityTags(
//                 x"0000000000000000000000000000000000000000000000000000000000000010",
//                 x"0000000000000000000000000000000000000000000000000000000000000011",
//                 x"0000000000000000000000000000000000000000000000000000000000000012",
//                 x"0000000000000000000000000000000000000000000000000000000000000013",
//                 x"0000000000000000000000000000000000000000000000000000000000000014"
//             ), 9);

//             let (ipfsDoc2, timeCreate2, isFrozen2) = communityLib::getCommunityData(community2);
//             let tags2 = communityLib::getCommunityTags(community2);
//             assert!(ipfsDoc2 == x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6", 1);
//             assert!(timeCreate2 == 0, 2);
//             assert!(isFrozen2 == false, 3);
//             assert!(tags2 == communityLib::unitTestGetCommunityTags(
//                 x"0000000000000000000000000000000000000000000000000000000000000001",
//                 x"0000000000000000000000000000000000000000000000000000000000000002",
//                 x"0000000000000000000000000000000000000000000000000000000000000003",
//                 x"0000000000000000000000000000000000000000000000000000000000000004",
//                 x"0000000000000000000000000000000000000000000000000000000000000005"
//             ), 5);

//             test_scenario::return_shared(community_val);
//             test_scenario::return_shared(community_val2);
//         };
//         test_scenario::end(scenario_val);        
//     }
// }