module basics::communityLib {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use std::debug;
    use basics::commonLib;
    // friend basics::commonLib;
    // use basics::commonLib::{Self, IpfsHash};

    /// A shared user.
    struct CommunityCollection has key {
        id: UID,
        communities: vector<Community>
    }

    struct Community has store, drop {
        ipfsDoc: commonLib::IpfsHash,
        tagsCount: u64,         //u8? convert type (createCommunity -> tagsCount: vector::length(&mut tags) u8 and u64)
        timeCreate: u64,
        isFrozen: bool,
        tags: vector<Tag>
    }

    struct Tag has store, drop {
        ipfsDoc: commonLib::IpfsHash,
    }

   
    public entry fun initCommunityCollection(ctx: &mut TxContext) {
        transfer::share_object(CommunityCollection {
            id: object::new(ctx),
            communities: vector::empty<Community>()
        })
    }

    public entry fun createCommunity(communityCollection: &mut CommunityCollection, owner: address, ipfsHash: vector<u8>, tags: vector<Tag>) {
        // check role

        assert!(vector::length(&mut tags) >= 5, 20);
        let i = 0;
        while(i < vector::length(&mut tags)) {
            let j = 1;

            while(j < vector::length(&mut tags)) {
                if (i != j) {
                    assert!(commonLib::getIpfsHash(vector::borrow(&mut tags, i).ipfsDoc) != commonLib::getIpfsHash(vector::borrow(&mut tags, j).ipfsDoc), 21);
                };
                j = j + 5;
            };
            i = i +1;
        };

        vector::push_back(&mut communityCollection.communities, Community {
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            tagsCount: vector::length(&mut tags),
            timeCreate: 0,                           // get time
            isFrozen: false,
            tags: tags
        });
    }

    public entry fun updateCommunity(communityCollection: &mut CommunityCollection, communityId: u64, owner: address, ipfsHash: vector<u8>) {
        // check role

        let community = getMutableCommunity(communityCollection, communityId);
        community.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
    }

    public entry fun createTag(communityCollection: &mut CommunityCollection, communityId: u64, owner: address, ipfsHash: vector<u8>) {
        // check role

        let i = 0;
        let community = getMutableCommunity(communityCollection, communityId);
        while(i < vector::length(&mut community.tags)) {
            assert!(commonLib::getIpfsHash(vector::borrow(&mut community.tags, i).ipfsDoc) != ipfsHash, 21);
            i = i +1;
        };

        vector::push_back(&mut community.tags, Tag {
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>())
        });
        community.tagsCount = community.tagsCount + 1;
    }

    public entry fun updateTag(communityCollection: &mut CommunityCollection, tagId: u64, communityId: u64, owner: address, ipfsHash: vector<u8>) {
        // check role

        let community = getMutableCommunity(communityCollection, communityId);
        let tag = vector::borrow_mut(&mut community.tags, tagId);
        tag.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
    }

    public entry fun freezeCommunity(communityCollection: &mut CommunityCollection, communityId: u64, owner: address) {  //Invalid function name 'freeze'. 'freeze' is restricted and cannot be used to name a function
        // check role

        let community = getMutableCommunity(communityCollection, communityId);
        community.isFrozen = true;

        // emit CommunityFrozen(msg.sender, communityId);
    }

    public entry fun unfreezeCommmunity(communityCollection: &mut CommunityCollection, communityId: u64, owner: address) {
        // check role
        let community = vector::borrow_mut(&mut communityCollection.communities, communityId);
        assert!(commonLib::getIpfsHash(community.ipfsDoc) != vector::empty<u8>(), 22);
        community.isFrozen = false;

        // emit CommunityUnfrozen(msg.sender, communityId);
    }

    public entry fun onlyExistingAndNotFrozenCommunity(communityCollection: &mut CommunityCollection, communityId: u64) {
        let community = vector::borrow(&mut communityCollection.communities, communityId);
        assert!(commonLib::getIpfsHash(community.ipfsDoc) != vector::empty<u8>(), 22);
        assert!(!community.isFrozen, 23);
    }

    public entry fun checkTags(communityCollection: &mut CommunityCollection, communityId: u64, tags: vector<u64>) {
        let community = getCommunity(communityCollection, communityId);

        let i = 0;
        while(i < vector::length(&mut tags)) {
            assert!(community.tagsCount >= *vector::borrow(&mut tags, i), 24);
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
}

// #[test_only]
// module basics::communityCollection_test {
//     use sui::test_scenario;
//     use basics::userCollection;

    
// }