module basics::communityLib {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    // use std::debug;
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

   
    fun init(ctx: &mut TxContext) {                  // public?
        transfer::share_object(CommunityCollection {
            id: object::new(ctx),
            communities: vector::empty<Community>()
        })
    }

    #[test_only]    // call?
    public fun init_test(ctx: &mut TxContext) {
        init(ctx)
    }

    ///
    // tags: vector<Tag> -> tags: vector<vector<u8>>.
    // error "Expected primitive or object type. Got: vector<0x0::communityLib::Tag>"
    // commit - fixed sui move build (c888fd5b339665abff8e76275866b1fcfb640540)
    ///
    public entry fun createCommunity(communityCollection: &mut CommunityCollection, ipfsHash: vector<u8>, tags: vector<vector<u8>>, ctx: &mut TxContext) {
        let _userAddress = tx_context::sender(ctx);
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
            timeCreate: commonLib::getTimestamp(),
            isFrozen: false,
            tags: vector::empty<Tag>(),
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

    public entry fun updateCommunity(communityCollection: &mut CommunityCollection, communityId: u64, ipfsHash: vector<u8>, ctx: &mut TxContext) {
        let _userAddress = tx_context::sender(ctx);
        // TODO: add check role

        let community = getMutableCommunity(communityCollection, communityId);
        community.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
    }

    public entry fun createTag(communityCollection: &mut CommunityCollection, communityId: u64, ipfsHash: vector<u8>, ctx: &mut TxContext) {
        let _userAddress = tx_context::sender(ctx);
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

    public entry fun updateTag(communityCollection: &mut CommunityCollection, communityId: u64, tagId: u64, ipfsHash: vector<u8>, ctx: &mut TxContext) {
        let _userAddress = tx_context::sender(ctx);
        // TODO: add check role

        let tag = getMutableTag(communityCollection, communityId, tagId);
        tag.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
    }

    public entry fun freezeCommunity(communityCollection: &mut CommunityCollection, communityId: u64, ctx: &mut TxContext) {  //Invalid function name 'freeze'. 'freeze' is restricted and cannot be used to name a function
        let _userAddress = tx_context::sender(ctx);
        // TODO: add check role

        let community = getMutableCommunity(communityCollection, communityId);
        community.isFrozen = true;

        // TODO: add emit CommunityFrozen(msg.sender, communityId);
    }

    public entry fun unfreezeCommunity(communityCollection: &mut CommunityCollection, communityId: u64, ctx: &mut TxContext) {
        let _userAddress = tx_context::sender(ctx);
        communityId = communityId -1;

        // TODO: add check role   (if community doesnot exist in check will be error)

        let community = vector::borrow_mut(&mut communityCollection.communities, communityId);
        assert!(commonLib::getIpfsHash(community.ipfsDoc) != vector::empty<u8>(), 22);
        community.isFrozen = false;

        // TODO: add emit CommunityUnfrozen(msg.sender, communityId);
    }

    public entry fun onlyExistingAndNotFrozenCommunity(communityCollection: &mut CommunityCollection, communityId: u64) {
        assert!(communityId > 0 && vector::length(&communityCollection.communities) >= communityId, 27);
        let community = vector::borrow(&mut communityCollection.communities, communityId - 1); // TODO: add get community?
        assert!(commonLib::getIpfsHash(community.ipfsDoc) != vector::empty<u8>(), 22);
        assert!(!community.isFrozen, 23);
    }

    public entry fun checkTags(communityCollection: &mut CommunityCollection, communityId: u64, tags: vector<u64>) {
        let community = getCommunity(communityCollection, communityId);

        let i = 0;
        let communityTagsCount = vector::length(&community.tags);
        while(i < vector::length(&mut tags)) {
            let tagId = *vector::borrow(&tags, i);
            assert!(tagId > 0, 28);
            assert!(communityTagsCount >= tagId - 1, 24);
            i = i +1;
        };
    }

    public fun getMutableCommunity(communityCollection: &mut CommunityCollection, communityId: u64): &mut Community {
        onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        let community = vector::borrow_mut(&mut communityCollection.communities, communityId - 1);
        community
    }

    public fun getCommunity(communityCollection: &mut CommunityCollection, communityId: u64): &Community {
        onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        let community = vector::borrow(&communityCollection.communities, communityId - 1);
        community
    }

    public fun getMutableTag(communityCollection: &mut CommunityCollection, communityId: u64, tagId: u64): &mut Tag {
        let community = getMutableCommunity(communityCollection, communityId);
        assert!(tagId > 0 && vector::length(&community.tags) >= tagId, 28);
        let tag = vector::borrow_mut(&mut community.tags, tagId - 1);
        tag
    }
    
    public fun getTag(communityCollection: &mut CommunityCollection, communityId: u64, tagId: u64): &Tag {
        let community = getCommunity(communityCollection, communityId);
        assert!(tagId > 0 && vector::length(&community.tags) >= tagId, 27);
        let tag = vector::borrow(&community.tags, tagId - 1);
        tag
    }

    // public entry fun printCommunity(communityCollection: &mut CommunityCollection, communityId: u64) {
    //     let community = vector::borrow(&communityCollection.communities, communityId);
    //     debug::print(community);
    // }

    #[test_only]
    public fun getCommunityData(communityCollection: &mut CommunityCollection, communityId: u64): (vector<u8>, u64, bool, vector<Tag>,) {
        assert!(communityId > 0 && vector::length(&communityCollection.communities) >= communityId, 28);
        
        let community = vector::borrow(&mut communityCollection.communities, communityId - 1);
        (commonLib::getIpfsHash(community.ipfsDoc), community.timeCreate, community.isFrozen, community.tags)
    }

    // for UnitTest 5 Tag
    #[test_only]
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
    #[test_only]
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

    #[test_only]
    public fun create_community(communityCollection: &mut CommunityCollection, scenario: &mut TxContext) {
        createCommunity(
            communityCollection,
            x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
            vector<vector<u8>>[
                x"0000000000000000000000000000000000000000000000000000000000000001",
                x"0000000000000000000000000000000000000000000000000000000000000002",
                x"0000000000000000000000000000000000000000000000000000000000000003",
                x"0000000000000000000000000000000000000000000000000000000000000004",
                x"0000000000000000000000000000000000000000000000000000000000000005"
            ],
            scenario
        );
    }
}