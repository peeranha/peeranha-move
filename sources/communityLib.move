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

    ///
    // tags: vector<Tag> -> tags: vector<vector<u8>>.
    // error "Expected primitive or object type. Got: vector<0x0::communityLib::Tag>"
    // commit - fixed sui move build  (c888fd5b339665abff8e76275866b1fcfb640540)
    ///
    public entry fun createCommunity(communityCollection: &mut CommunityCollection, owner: address, ipfsHash: vector<u8>, tags: vector<vector<u8>>) {
        // check role

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
            tags: vector::empty<Tag>()
        });

        let communityId = vector::length(&mut communityCollection.communities);
        let community = getMutableCommunity(communityCollection, communityId);
        let tagId = 0;
        while(tagId < vector::length(&mut tags)) {
            vector::push_back(&mut community.tags, Tag {
                ipfsDoc: commonLib::getIpfsDoc(*vector::borrow(&mut tags, tagId), vector::empty<u8>())
            });
            tagId = tagId +1;
        };
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
}

// #[test_only]
// module basics::communityCollection_test {
//     use sui::test_scenario;
//     use basics::userCollection;

    
// }
