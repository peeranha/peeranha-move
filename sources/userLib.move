module basics::userLib {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use std::debug;

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
        // roles
    }

    public entry fun initUserCollection(ctx: &mut TxContext) {
        transfer::share_object(UserCollection {
            id: object::new(ctx),
            users: vector::empty<User>(),
            userAddress: vector::empty<address>()
        })
    }

    public entry fun createUser(userCollection: &mut UserCollection, owner: address, ipfsDoc: vector<u8>) {
        vector::push_back(&mut userCollection.users, User {
            ipfsDoc: ipfsDoc,
            owner: owner,
            energy: getStatusEnergy(),
            lastUpdatePeriod: 0,                     // getPeriod()
            followedCommunities: vector::empty<u64>()
        });

        vector::push_back(&mut userCollection.userAddress, owner);
    }

    public entry fun updateUser(userCollection: &mut UserCollection, owner: address, ipfsDoc: vector<u8>) {
        let user = getMutableUser(userCollection, owner);
        user.ipfsDoc = ipfsDoc;
    }

    
    // public entry fun pushCommunity(user: &mut User, communityId: u64) {
    //     vector::push_back(&mut user.followedCommunities, communityId);
    // }

    public fun getStatusEnergy(): u64 {
        1000
    }

    public entry fun printUserCollection(userCollection: &mut UserCollection) {
        debug::print(userCollection);
    }

    public entry fun printUser(userCollection: &mut UserCollection, owner: address) {
        let (isExist, position) = vector::index_of(&mut userCollection.userAddress, &owner);
        debug::print(&isExist);
        debug::print(&position);

        if (isExist) {
            let user = vector::borrow(&mut userCollection.users, position);
            debug::print(user);
        }
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

    public entry fun set_value(ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == tx_context::sender(ctx), 0);
        // let creation_date = tx_context::epoch();
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
}

#[test_only]
module basics::userLib_test {
    use sui::test_scenario;
    use basics::userLib;

    #[test]
    fun test_user() {
        let owner = @0xC0FFEE;
        let user1 = @0xA1;
        let user2 = @0xA2;
        let user3 = @0xA3;
        // let user4 = @0xA4;

        let scenario = &mut test_scenario::begin(&user1);

        test_scenario::next_tx(scenario, &owner);
        {
            userLib::initUserCollection(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, &user1);
        {
            let user_wrapper = test_scenario::take_shared<userLib::UserCollection>(scenario);
            let userCollection = test_scenario::borrow_mut(&mut user_wrapper);

            userLib::createUser(userCollection, user3, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1");
            userLib::createUser(userCollection, user1, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82");
            userLib::createUser(userCollection, user2, x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6");
            userLib::printUser(userCollection, user3);


            // userCollection::printUserCollection(userCollection);

            // assert!(user::owner(user) == owner, 0);
            // assert!(user::energy(user) == 0, 1);

            // user::increment(user);
            // user::increment(user);
            // user::increment(user);

            // user::printUser(user);
            // user::pushCommunity(user, 5);
            // user::printUser(user);
            // user::pushCommunity(user, 2);
            // user::printUser(user);


            test_scenario::return_shared(scenario, user_wrapper);
        };

        // test_scenario::next_tx(scenario, &owner);
        // {
        //     let user_wrapper = test_scenario::take_shared<user::User>(scenario);
        //     let user = test_scenario::borrow_mut(&mut user_wrapper);

        //     assert!(user::owner(user) == owner, 0);
        //     assert!(user::energy(user) == 3, 1);

        //     user::set_value(user, 100, test_scenario::ctx(scenario));
        //     user::printUser(user);


        //     test_scenario::return_shared(scenario, user_wrapper);
        // };

        // test_scenario::next_tx(scenario, &user1);
        // {
        //     let user_wrapper = test_scenario::take_shared<user::User>(scenario);
        //     let user = test_scenario::borrow_mut(&mut user_wrapper);

        //     assert!(user::owner(user) == owner, 0);
        //     assert!(user::energy(user) == 100, 1);

        //     user::increment(user);

        //     assert!(user::energy(user) == 101, 2);

        //     test_scenario::return_shared(scenario, user_wrapper);
        // };
    }
}
