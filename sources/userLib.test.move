#[test_only]
module basics::userLib_test
{
    use basics::communityLib::{Self, Community};
    use basics::userLib::{Self, User, UsersRatingCollection};
    use basics::followCommunityLib::{Self};
    use basics::accessControl::{Self, UserRolesCollection, DefaultAdminCap};
    use sui::test_scenario::{Self, Scenario};
    use sui::object::{Self, ID};
    // use std::debug;

    const ENERGY_DOWNVOTE_QUESTION: u64 = 5;
    const ENERGY_DOWNVOTE_ANSWER: u64 = 3;
    const ENERGY_DOWNVOTE_COMMENT: u64 = 2;
    const ENERGY_UPVOTE_QUESTION: u64 = 1;
    const ENERGY_UPVOTE_ANSWER: u64 = 1;
    const ENERGY_VOTE_COMMENT: u64 = 1;
    const ENERGY_FORUM_VOTE_CANCEL: u64 = 1;
    const ENERGY_POST_QUESTION: u64 = 10;
    const ENERGY_POST_ANSWER: u64 = 6;
    const ENERGY_POST_COMMENT: u64 = 4;
    const ENERGY_MODIFY_ITEM: u64 = 2;
    const ENERGY_DELETE_ITEM: u64 = 2;

    const ENERGY_MARK_REPLY_AS_CORRECT: u64 = 1;
    const ENERGY_UPDATE_PROFILE: u64 = 1;
    const ENERGY_FOLLOW_COMMUNITY: u64 = 1;

    const USER1: address = @0xA1;
    const USER2: address = @0xA2;

    #[test]
    fun test_create_user() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            userLib::createUser(user_rating_collection, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", test_scenario::ctx(scenario));

            test_scenario::return_shared(user_rating_collection_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user = test_scenario::take_from_sender<User>(scenario);

            let (ipfsDoc, energy, lastUpdatePeriod, followedCommunities) = userLib::getUserData(&mut user);
            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(energy == 1000, 1);
            assert!(lastUpdatePeriod == 0, 1);
            assert!(followedCommunities == vector<ID>[], 1);

            test_scenario::return_to_sender(scenario, user);
        };

        test_scenario::end(scenario_val);
    }
    
    #[test]
    fun test_updateIPFS_user() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            userLib::createUser(user_rating_collection, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", test_scenario::ctx(scenario));

            test_scenario::return_shared(user_rating_collection_val);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;
            let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            userLib::updateUser(user_rating_collection, user, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", test_scenario::ctx(scenario));

            let (ipfsDoc, energy, lastUpdatePeriod, followedCommunities) = userLib::getUserData(user);
            assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
            assert!(energy == 1000 - ENERGY_UPDATE_PROFILE, 3);
            assert!(lastUpdatePeriod == 0, 4);
            assert!(followedCommunities == vector<ID>[], 5);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_rating_collection_val);
        };

        test_scenario::end(scenario_val);
    }


    
    #[test]
    fun test_follow_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::init_test(test_scenario::ctx(scenario));
            accessControl::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;
            let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;
            followCommunityLib::followCommunity(user_rating_collection, user, community);

            let (ipfsDoc, energy, lastUpdatePeriod, followedCommunities) = userLib::getUserData(user);
            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(energy == 1000 - ENERGY_FOLLOW_COMMUNITY, 3);
            assert!(lastUpdatePeriod == 0, 4);
            assert!(followedCommunities == vector<ID>[object::id(community)], 5);
            
            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_rating_collection_val);
            test_scenario::return_shared(community_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_unfollow_community() {
        let scenario_val = test_scenario::begin(USER1);
        let scenario = &mut scenario_val;
        {
            userLib::init_test(test_scenario::ctx(scenario));
            accessControl::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_user(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            create_community(scenario);
        };

        test_scenario::next_tx(scenario, USER1);
        {
            let user_val = test_scenario::take_from_sender<User>(scenario);
            let user = &mut user_val;
            let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
            let user_rating_collection = &mut user_rating_collection_val;
            let community_val = test_scenario::take_shared<Community>(scenario);
            let community = &mut community_val;

            followCommunityLib::followCommunity(user_rating_collection, user, community);
            followCommunityLib::unfollowCommunity(user_rating_collection, user, community);

            let (ipfsDoc, energy, lastUpdatePeriod, followedCommunities) = userLib::getUserData(user);
            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(energy == 1000 - ENERGY_FOLLOW_COMMUNITY * 2, 3);
            assert!(lastUpdatePeriod == 0, 4);
            assert!(followedCommunities == vector<ID>[], 5);

            test_scenario::return_to_sender(scenario, user_val);
            test_scenario::return_shared(user_rating_collection_val);
            test_scenario::return_shared(community_val);
        };

        test_scenario::end(scenario_val);
    }

    #[test_only]
    fun create_community(scenario: &mut Scenario) {
        let user_roles_collection_val = test_scenario::take_shared<UserRolesCollection>(scenario);
        let user_roles_collection = &mut user_roles_collection_val;
        let default_admin_cap_val = test_scenario::take_from_sender<DefaultAdminCap>(scenario);
        let default_admin_cap = &mut default_admin_cap_val;
        let user_val = test_scenario::take_from_sender<User>(scenario);
        let user = &mut user_val;
        accessControl::grantProtocolAdminRole(default_admin_cap, user_roles_collection, object::id(user));
        
        communityLib::createCommunity(
            user_roles_collection,
            user,
            x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
            vector<vector<u8>>[
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000003",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005"
            ],
            test_scenario::ctx(scenario)
        );

        test_scenario::return_to_sender(scenario, user_val);
        test_scenario::return_to_sender(scenario, default_admin_cap_val);
        test_scenario::return_shared(user_roles_collection_val);
    }

    #[test_only]
    public fun create_user(scenario: &mut Scenario) {
        let user_rating_collection_val = test_scenario::take_shared<UsersRatingCollection>(scenario);
        let user_rating_collection = &mut user_rating_collection_val;

        userLib::createUser(user_rating_collection, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", test_scenario::ctx(scenario));
        test_scenario::return_shared(user_rating_collection_val);
    }
}