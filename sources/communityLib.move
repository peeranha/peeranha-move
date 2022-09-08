module basics::communityLib {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use std::debug;
    use basics::commonLib;
    // friend basics::commonLib;
    // use basics::commonLib::{Self, IpfsHash};

    struct CommunityCollection has key {
        id: UID,
        communities: vector<Community>
    }

    struct Community has store, drop {
        ipfsDoc: commonLib::IpfsHash,
        timeCreate: u64,
        isFrozen: bool,
        tags: vector<Tag>,
    }

    struct Tag has store, drop, copy {
        ipfsDoc: commonLib::IpfsHash,
    }

   
    public entry fun initCommunityCollection(ctx: &mut TxContext) {
        transfer::share_object(CommunityCollection {
            id: object::new(ctx),
            communities: vector::empty<Community>()
        })
    }

    ///
    // tags: vector<Tag> -> tags: vector<vector<u8>>.
    // error "Expected primitive or object type. Got: vector<0x0::communityLib::Tag>"
    // commit - fixed sui move build  (c888fd5b339665abff8e76275866b1fcfb640540)
    ///
    public entry fun createCommunity(communityCollection: &mut CommunityCollection, _owner: address, ipfsHash: vector<u8>, tags: vector<vector<u8>>) {
        // TODO: add check role

        assert!(vector::length(&mut tags) >= 5, 20);
        let i = 0;
        while(i < vector::length(&mut tags)) {
            let j = 1;

            while(j < vector::length(&mut tags)) {
                if (i != j) {
                    assert!(vector::borrow(&mut tags, i) != vector::borrow(&mut tags, j), 21);
                };
                j = j + 5;
            };
            i = i +1;
        };

        vector::push_back(&mut communityCollection.communities, Community {
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            timeCreate: 0,                           // get time
            isFrozen: false,
            tags: vector::empty<Tag>(),
        });

        let communityId = vector::length(&mut communityCollection.communities) -1;
        let community = getMutableCommunity(communityCollection, communityId);
        let tagId = 0;
        while(tagId < vector::length(&mut tags)) {
            vector::push_back(&mut community.tags, Tag {
                ipfsDoc: commonLib::getIpfsDoc(*vector::borrow(&mut tags, tagId), vector::empty<u8>())
            });
            tagId = tagId +1;
        };
    }

    public entry fun updateCommunity(communityCollection: &mut CommunityCollection, communityId: u64, _owner: address, ipfsHash: vector<u8>) {
        // TODO: add check role

        let community = getMutableCommunity(communityCollection, communityId);
        community.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
    }

    public entry fun createTag(communityCollection: &mut CommunityCollection, communityId: u64, _owner: address, ipfsHash: vector<u8>) {
        // TODO: add check role

        let i = 0;
        let community = getMutableCommunity(communityCollection, communityId);
        while(i < vector::length(&mut community.tags)) {
            assert!(commonLib::getIpfsHash(vector::borrow(&mut community.tags, i).ipfsDoc) != ipfsHash, 21);
            i = i +1;
        };

        vector::push_back(&mut community.tags, Tag {
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>())
        });
    }

    public entry fun updateTag(communityCollection: &mut CommunityCollection, communityId: u64, tagId: u64, _owner: address, ipfsHash: vector<u8>) {
        // TODO: add check role

        let community = getMutableCommunity(communityCollection, communityId);
        let tag = vector::borrow_mut(&mut community.tags, tagId);
        tag.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
    }

    public entry fun freezeCommunity(communityCollection: &mut CommunityCollection, communityId: u64, _owner: address) {  //Invalid function name 'freeze'. 'freeze' is restricted and cannot be used to name a function
        // TODO: add check role

        let community = getMutableCommunity(communityCollection, communityId);
        community.isFrozen = true;

        // TODO: add emit CommunityFrozen(msg.sender, communityId);
    }

    public entry fun unfreezeCommmunity(communityCollection: &mut CommunityCollection, communityId: u64, _owner: address) {
        // check role
        let community = vector::borrow_mut(&mut communityCollection.communities, communityId);
        assert!(commonLib::getIpfsHash(community.ipfsDoc) != vector::empty<u8>(), 22);
        community.isFrozen = false;

        // TODO: add emit CommunityUnfrozen(msg.sender, communityId);
    }

    public entry fun onlyExistingAndNotFrozenCommunity(communityCollection: &mut CommunityCollection, communityId: u64) {
        let community = vector::borrow(&mut communityCollection.communities, communityId);
        assert!(commonLib::getIpfsHash(community.ipfsDoc) != vector::empty<u8>(), 22);
        assert!(!community.isFrozen, 23);
    }

    public entry fun checkTags(communityCollection: &mut CommunityCollection, communityId: u64, tags: vector<u64>) {
        let community = getCommunity(communityCollection, communityId);

        let i = 0;
        let communityTagsCount = vector::length(&community.tags);
        while(i < vector::length(&mut tags)) {
            assert!(communityTagsCount >= *vector::borrow(&tags, i), 24);
            assert!(*vector::borrow(&mut tags, i) != 0, 25);
            i = i +1;
        };
    }

    public fun getCommunity(communityCollection: &mut CommunityCollection, communityId: u64): &Community {
        onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        let community = vector::borrow(&mut communityCollection.communities, communityId);
        community
    }

    public fun getMutableCommunity(communityCollection: &mut CommunityCollection, communityId: u64): &mut Community {
        onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        let community = vector::borrow_mut(&mut communityCollection.communities, communityId);
        community
    }

    public entry fun set_value(ctx: &mut TxContext) {       // do something with tx_context
        assert!(tx_context::sender(ctx) == tx_context::sender(ctx), 0);
    }

    public entry fun printCommunity(communityCollection: &mut CommunityCollection, communityId: u64) {
        let community = vector::borrow(&communityCollection.communities, communityId);
        debug::print(community);
    }

    public fun getCommunityData(communityCollection: &mut CommunityCollection, communityId: u64): (vector<u8>, u64, bool, vector<Tag>,) {
        let community = vector::borrow(&mut communityCollection.communities, communityId);
        (commonLib::getIpfsHash(community.ipfsDoc), community.timeCreate, community.isFrozen, community.tags)
    }

    // for UnitTest 5 Tag
    public fun unitTestGetCommunityTags(ipfsHash1: vector<u8>, ipfsHash2: vector<u8>, ipfsHash3: vector<u8>, ipfsHash4: vector<u8>, ipfsHash5: vector<u8>): vector<Tag> {
        vector<Tag>[
            Tag{ipfsDoc: commonLib::getIpfsDoc(ipfsHash1, vector::empty<u8>())},
            Tag{ipfsDoc: commonLib::getIpfsDoc(ipfsHash2, vector::empty<u8>())},
            Tag{ipfsDoc: commonLib::getIpfsDoc(ipfsHash3, vector::empty<u8>())},
            Tag{ipfsDoc: commonLib::getIpfsDoc(ipfsHash4, vector::empty<u8>())},
            Tag{ipfsDoc: commonLib::getIpfsDoc(ipfsHash5, vector::empty<u8>())},
        ]
    }

    // for UnitTest 6 Tag
    public fun unitTestGetMoreCommunityTags(ipfsHash1: vector<u8>, ipfsHash2: vector<u8>, ipfsHash3: vector<u8>, ipfsHash4: vector<u8>, ipfsHash5: vector<u8>, ipfsHash6: vector<u8>): vector<Tag> {
        vector<Tag>[
            Tag{ipfsDoc: commonLib::getIpfsDoc(ipfsHash1, vector::empty<u8>())},
            Tag{ipfsDoc: commonLib::getIpfsDoc(ipfsHash2, vector::empty<u8>())},
            Tag{ipfsDoc: commonLib::getIpfsDoc(ipfsHash3, vector::empty<u8>())},
            Tag{ipfsDoc: commonLib::getIpfsDoc(ipfsHash4, vector::empty<u8>())},
            Tag{ipfsDoc: commonLib::getIpfsDoc(ipfsHash5, vector::empty<u8>())},
            Tag{ipfsDoc: commonLib::getIpfsDoc(ipfsHash6, vector::empty<u8>())},
        ]
    }

}

#[test_only]
module basics::communityLib_test {
    use sui::test_scenario;
    // use basics::userLib;
    use basics::communityLib;

    struct TestCom has store, drop {
        testTest: u64,
    }

    #[test]
    fun test_community() {
        let owner = @0xC0FFEE;
        let user1 = @0xA1;

        let scenario = &mut test_scenario::begin(&user1);

        test_scenario::next_tx(scenario, &owner);
        {
            communityLib::initCommunityCollection(test_scenario::ctx(scenario));
        };

        // create community
        test_scenario::next_tx(scenario, &user1);
        {
            let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);

            communityLib::createCommunity(
                communityCollection,
                user1,
                x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
                vector<vector<u8>>[
                    x"0000000000000000000000000000000000000000000000000000000000000001",
                    x"0000000000000000000000000000000000000000000000000000000000000002",
                    x"0000000000000000000000000000000000000000000000000000000000000003",
                    x"0000000000000000000000000000000000000000000000000000000000000004",
                    x"0000000000000000000000000000000000000000000000000000000000000005"
                ]
            );

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 0);
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

            test_scenario::return_shared(scenario, community_wrapper);
        };

        // update community ipfs
        test_scenario::next_tx(scenario, &user1);
        {
            let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);

            communityLib::updateCommunity(
                communityCollection,
                0,
                user1,
                x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1",
            );

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 0);
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

            test_scenario::return_shared(scenario, community_wrapper);
        };

        //create tag
        test_scenario::next_tx(scenario, &user1);
        {
            let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);

            communityLib::createTag(
                communityCollection,
                0,
                user1,
                x"0000000000000000000000000000000000000000000000000000000000000006",
            );

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 0);
            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
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

            test_scenario::return_shared(scenario, community_wrapper);
        };

        //edit tag
        test_scenario::next_tx(scenario, &user1);
        {
            let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);

            communityLib::updateTag(
                communityCollection,
                0,
                2,
                user1,
                x"0000000000000000000000000000000000000000000000000000000000000007",
            );

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 0);
            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(timeCreate == 0, 2);
            assert!(isFrozen == false, 3);
            assert!(tags == communityLib::unitTestGetMoreCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000007",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005",
                x"0000000000000000000000000000000000000000000000000000000000000006"
            ), 5);

            test_scenario::return_shared(scenario, community_wrapper);
        };

        // freeze community
        test_scenario::next_tx(scenario, &user1);
        {
            let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);

            communityLib::freezeCommunity(
                communityCollection,
                0,
                user1
            );

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 0);
            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(timeCreate == 0, 2);
            assert!(isFrozen == true, 3);
            assert!(tags == communityLib::unitTestGetMoreCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000007",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005",
                x"0000000000000000000000000000000000000000000000000000000000000006"
            ), 5);

            test_scenario::return_shared(scenario, community_wrapper);
        };

        // unfreeze community
        test_scenario::next_tx(scenario, &user1);
        {
            let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);

            communityLib::unfreezeCommmunity(
                communityCollection,
                0,
                user1
            );

            let (ipfsDoc, timeCreate, isFrozen, tags) = communityLib::getCommunityData(communityCollection, 0);
            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(timeCreate == 0, 2);
            assert!(isFrozen == false, 3);
            assert!(tags == communityLib::unitTestGetMoreCommunityTags(
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000007",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005",
                x"0000000000000000000000000000000000000000000000000000000000000006"
            ), 5);

            test_scenario::return_shared(scenario, community_wrapper);
        };



        // x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1"
        // x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82"
        // x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6"
    }
}
