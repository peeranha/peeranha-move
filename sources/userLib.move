module basics::userLib {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    // use std::debug;
    use basics::communityLib;

    /// A shared user.
    struct UserCollection has key {
        id: UID,
        users: vector<User>,
        userAddress: vector<address>
    }

    struct User has store, drop {
        ipfsDoc: vector<u8>,
        owner: address,
        energy: u64,
        lastUpdatePeriod: u64,
        followedCommunities: vector<u64>
        // TODO: add roles
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(UserCollection {
            id: object::new(ctx),
            users: vector::empty<User>(),
            userAddress: vector::empty<address>()
        });
    }

    public entry fun createUser(userCollection: &mut UserCollection, owner: address, ipfsDoc: vector<u8>) {
        vector::push_back(&mut userCollection.users, User {
            ipfsDoc: ipfsDoc,
            owner: owner,
            energy: getStatusEnergy(),
            lastUpdatePeriod: 0,                     // TODO: add getPeriod()
            followedCommunities: vector::empty<u64>()
        });

        vector::push_back(&mut userCollection.userAddress, owner);
    }

    public entry fun updateUser(userCollection: &mut UserCollection, owner: address, ipfsDoc: vector<u8>) {
        let user = getMutableUser(userCollection, owner);
        user.ipfsDoc = ipfsDoc;
    }

    public entry fun followCommunity(communityCollection: &mut communityLib::CommunityCollection, userCollection: &mut UserCollection, owner: address, communityId: u64) {
        // check role
        communityLib::onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        let user = getMutableUser(userCollection, owner);

        let i = 0;
        while(i < vector::length(&mut user.followedCommunities)) {
            assert!(*vector::borrow(&mut user.followedCommunities, i) != communityId, 11);
            i = i +1;
        };

        vector::push_back(&mut user.followedCommunities, communityId);
    }

    public entry fun unfollowCommunity(communityCollection: &mut communityLib::CommunityCollection, userCollection: &mut UserCollection, owner: address, communityId: u64) {
        // check role
        communityLib::onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        let user = getMutableUser(userCollection, owner);

        let i = 0;
        while(i < vector::length(&mut user.followedCommunities)) {
            if(*vector::borrow(&mut user.followedCommunities, i) == communityId) {
                vector::remove(&mut user.followedCommunities, i);
                return
            };
            i = i +1;
        };
        abort 12
    }

    public fun getStatusEnergy(): u64 {
        1000
    }

    public fun getUser(userCollection: &mut UserCollection, owner: address): &User {
        let (isExist, position) = vector::index_of(&mut userCollection.userAddress, &owner);
        if (!isExist) abort 10;
        
        let user = vector::borrow(&mut userCollection.users, position);
        user
    }

    public fun getMutableUser(userCollection: &mut UserCollection, owner: address): &mut User {
        let (isExist, position) = vector::index_of(&mut userCollection.userAddress, &owner);
        if (!isExist) abort 10;
        
        let user = vector::borrow_mut(&mut userCollection.users, position);
        user
    }

    public entry fun set_value(ctx: &mut TxContext) {       // do something with tx_context
        assert!(tx_context::sender(ctx) == tx_context::sender(ctx), 0);
    }
    // public entry fun mass_mint(recipients: vector<address>, ctx: &mut TxContext) {
    //     assert!(tx_context::sender(ctx) == CREATOR, EAuthFail);
    //     let i = 0;
    //     while (!vector::is_empty(recipients)) {
    //         let recipient = vector::pop_back(&mut recipients);
    //         let id = tx_context::new_id(ctx);
    //         let creation_date = tx_context::epoch(); // Sui epochs are 24 hours
    //         transfer(CoolAsset { id, creation_date }, recipient)
    //     }
    // }

    // public entry fun printUserCollection(userCollection: &mut UserCollection) {
    //     debug::print(userCollection);
    // }

    // public entry fun printUser(userCollection: &mut UserCollection, owner: address) {
    //     let (isExist, position) = vector::index_of(&mut userCollection.userAddress, &owner);
    //     debug::print(&isExist);
    //     debug::print(&position);

    //     if (isExist) {
    //         let user = vector::borrow(&mut userCollection.users, position);
    //         debug::print(user);
    //     }
    // }

    // for unitTests
    public fun getUserData(userCollection: &mut UserCollection, owner: address): (vector<u8>, address, u64, u64, vector<u64>) {
        let user = getUser(userCollection, owner);
        (user.ipfsDoc, user.owner, user.energy, user.lastUpdatePeriod, user.followedCommunities)
    }


    // #[test]
    // fun test_user() {
    //     use sui::test_scenario;
    //     use basics::communityLib;

    //     // let owner = @0xC0FFEE;
    //     let user1 = @0xA1;

    //     let scenario = &mut test_scenario::begin(&user1);
    //     {
    //         init(test_scenario::ctx(scenario));
    //         communityLib::init(test_scenario::ctx(scenario));
    //     };

    //     // create user
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let user_wrapper = test_scenario::take_shared<UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);

    //         createUser(userCollection, user1, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1");

    //         let (ipfsDoc, owner, energy, lastUpdatePeriod, followedCommunities) = getUserData(userCollection, user1);
    //         assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
    //         assert!(owner == @0xA1, 2);
    //         assert!(energy == 1000, 3);
    //         assert!(lastUpdatePeriod == 0, 4);
    //         assert!(followedCommunities == vector<u64>[], 5);

    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };

    //     // update user ipfs
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let user_wrapper = test_scenario::take_shared<UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    //         updateUser(userCollection, user1, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82");
            
    //         let (ipfsDoc, owner, energy, lastUpdatePeriod, followedCommunities) = getUserData(userCollection, user1);
    //         assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
    //         assert!(owner == @0xA1, 2);
    //         assert!(energy == 1000, 3);
    //         assert!(lastUpdatePeriod == 0, 4);
    //         assert!(followedCommunities == vector<u64>[], 5);

    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };

    //     // followCommunity
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let user_wrapper = test_scenario::take_shared<UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
    //         let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
    //         let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);

    //         communityLib::createCommunity(
    //             communityCollection,
    //             user1,
    //             x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
    //             vector<vector<u8>>[
    //                 x"0000000000000000000000000000000000000000000000000000000000000001",
    //                 x"0000000000000000000000000000000000000000000000000000000000000002",
    //                 x"0000000000000000000000000000000000000000000000000000000000000003",
    //                 x"0000000000000000000000000000000000000000000000000000000000000004",
    //                 x"0000000000000000000000000000000000000000000000000000000000000005"
    //             ]
    //         );

    //         followCommunity(communityCollection, userCollection, user1, 0);
            
    //         let (ipfsDoc, owner, energy, lastUpdatePeriod, followedCommunities) = getUserData(userCollection, user1);
    //         assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
    //         assert!(owner == @0xA1, 2);
    //         assert!(energy == 1000, 3);
    //         assert!(lastUpdatePeriod == 0, 4);
    //         assert!(followedCommunities == vector<u64>[0], 5);

    //         test_scenario::return_shared(scenario, user_wrapper);
    //         test_scenario::return_shared(scenario, community_wrapper);
    //     };

    //     // unfollowCommunity
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let user_wrapper = test_scenario::take_shared<UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
    //         let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
    //         let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);

    //         unfollowCommunity(communityCollection, userCollection, user1, 0);
            
    //         let (ipfsDoc, owner, energy, lastUpdatePeriod, followedCommunities) = getUserData(userCollection, user1);
    //         assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
    //         assert!(owner == @0xA1, 2);
    //         assert!(energy == 1000, 3);
    //         assert!(lastUpdatePeriod == 0, 4);
    //         assert!(followedCommunities == vector<u64>[], 5);

    //         test_scenario::return_shared(scenario, user_wrapper);
    //         test_scenario::return_shared(scenario, community_wrapper);
    //     };


    //     // x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1" - eGEyNjc1MzBmNDlmODI4MDIwMGVkZjMxM2VlN2FmNmI4MjdmMmE4YmNlMjg5Nzc1MWQwNmE4NDNmNjQ0OTY3YjE
    //     // x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82" - eDcwMWI2MTViYmRmYjlkZTY1MjQwYmMyOGJkMjFiYmMwZDk5NjY0NWEzZGQ1N2U3YjEyYmMyYmRmNmYxOTJjODI
    //     // x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6" - eDdjODUyMTE4Mjk0ZTUxZTY1MzcxMmE4MWUwNTgwMGY0MTkxNDE3NTFiZTU4ZjYwNWMzNzFlMTUxNDFiMDA3YTY
    // }   // x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc" - eGMwOWIxOWY2NWFmZDBkZjYxMGM5MGVhMDAxMjBiY2NkMWZjMWI4YzZlN2NkYmU0NDAzNzZlZTEzZTE1NmE1YmM
}
