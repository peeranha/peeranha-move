//
// done
//
//

#[test_only]
module basics::postLib_test_changeCommunityId
{
    use basics::communityLib;
    use basics::postLib;
    use basics::userLib;
    // use basics::i64Lib;
    use sui::test_scenario::{Self, Scenario};

    // TODO: add enum PostType      //import
    const EXPERT_POST: u8 = 0;
    const COMMON_POST: u8 = 1;
    const TUTORIAL: u8 = 2;
    const DOCUMENTATION: u8 = 3;

    const DEFAULT_COMMUNITY: u64 = 3;

    const USER: address = @0xA1;

    fun change_name(        // todo: change name
        userCollection: &mut userLib::UserCollection,
        communityCollection: &mut communityLib::CommunityCollection,
        postCollection: &mut postLib::PostCollection,
        scenario: &mut Scenario,
        post_type: u8
    ) {        // name from tests solidity
        userLib::create_user(userCollection, test_scenario::ctx(scenario));
        communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
        communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
        postLib::create_post_with_type(postCollection, communityCollection, userCollection, post_type, test_scenario::ctx(scenario));
    }


    // #[test, expected_failure(abort_code = postLib::E_POST_NOT_EXIST)]
    // fun test_change_community_id_community_does_not_exist() {
    //     let scenario_val = test_scenario::begin(USER);
    //     let scenario = &mut scenario_val;
    //     {
    //         communityLib::init_test(test_scenario::ctx(scenario));
    //         postLib::init_test(test_scenario::ctx(scenario));
    //         userLib::init_test(test_scenario::ctx(scenario));
    //     };

    //     test_scenario::next_tx(scenario, USER);
    //     {
    //         let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
    //         let communityCollection = &mut community_val;
    //         let post_val = test_scenario::take_shared<postLib::PostCollection>(scenario);
    //         let postCollection = &mut post_val;
    //         let user_val = test_scenario::take_shared<userLib::UserCollection>(scenario);
    //         let userCollection = &mut user_val;
    //         userLib::create_user(userCollection, test_scenario::ctx(scenario));
    //         communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
    //         postLib::create_post_with_type(postCollection, communityCollection, userCollection, EXPERT_POST, test_scenario::ctx(scenario));

    //         postLib::editPost(
    //             postCollection,
    //             communityCollection,
    //             1,
    //             x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
    //             vector<u64>[1, 2],
    //             2,
    //             EXPERT_POST,
    //             test_scenario::ctx(scenario)
    //         );

    //         test_scenario::return_shared(community_val);
    //         test_scenario::return_shared(post_val);
    //         test_scenario::return_shared(user_val);
    //     };
    //     test_scenario::end(scenario_val);  
    // }
}