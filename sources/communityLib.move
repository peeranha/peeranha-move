module basics::communityLib {
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use std::debug;
    use basics::commonLib;
    // friend basics::commonLib;

    /* errors */
    const E_REQUIRE_AT_LEAST_5_TAGS: u64 = 80;
    const E_REQUIRE_TAGS_WITH_UNIQUE_NAME: u64 = 81;
    const E_COMMUNITY_IS_FROZEN: u64 = 82;
    const E_COMMUNITY_ID_CAN_NOT_BE_0: u64 = 83;
    const E_COMMUNITY_DOES_NOT_EXIST: u64 = 84;
    const E_TAG_ID_CAN_NOT_BE_0: u64 = 85;
    const E_TAG_DOES_NOT_EXIST: u64 = 86;


    struct Community has key/*, store*/ {
        id: UID,
        ipfsDoc: commonLib::IpfsHash,
        timeCreate: u64,
        isFrozen: bool,
        tags: vector<Tag>,
    }

    struct Tag has key, store {
        id: UID,
        ipfsDoc: commonLib::IpfsHash,
    }

    ///
    // tags: vector<Tag> -> tags: vector<vector<u8>>.       // now Works?
    // error "Expected primitive or object type. Got: vector<0x0::communityLib::Tag>"
    // commit - fixed sui move build (c888fd5b339665abff8e76275866b1fcfb640540)
    ///
    public entry fun createCommunity(ipfsHash: vector<u8>, tags: vector<vector<u8>>, ctx: &mut TxContext) {
        let _userAddress = tx_context::sender(ctx);
        // TODO: add check role

        let tagsLength = vector::length(&mut tags);
        assert!(tagsLength >= 5, E_REQUIRE_AT_LEAST_5_TAGS);
        let i = 0;
        while(i < tagsLength) {
            let j = 1;

            while(j < tagsLength) {
                if (i != j) {
                    assert!(vector::borrow(&mut tags, i) != vector::borrow(&mut tags, j), E_REQUIRE_TAGS_WITH_UNIQUE_NAME);
                };
                j = j + 5;
            };
            i = i +1;
        };

        let communityTags = vector::empty<Tag>();
        let tagId = 0;
        while(tagId < tagsLength) {
            vector::push_back(&mut communityTags, Tag {
                id: object::new(ctx),
                ipfsDoc: commonLib::getIpfsDoc(*vector::borrow(&mut tags, tagId), vector::empty<u8>())
            });
            tagId = tagId +1;
        };

        transfer::share_object(Community {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            timeCreate: commonLib::getTimestamp(),
            isFrozen: false,
            tags: communityTags,
        });
    }

    public entry fun updateCommunity(community: &mut Community, ipfsHash: vector<u8>, ctx: &mut TxContext) {
        let _userAddress = tx_context::sender(ctx);
        // TODO: add check role

        community.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
    }

    public entry fun createTag(community: &mut Community, ipfsHash: vector<u8>, ctx: &mut TxContext) {
        let _userAddress = tx_context::sender(ctx);
        // TODO: add check role

        let i = 0;
        while(i < vector::length(&community.tags)) {
            assert!(commonLib::getIpfsHash(vector::borrow(&community.tags, i).ipfsDoc) != ipfsHash, E_REQUIRE_TAGS_WITH_UNIQUE_NAME);
            i = i +1;
        };

        vector::push_back(&mut community.tags, Tag {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>())
        });
    }

    public entry fun updateTag(community: &mut Community, tagId: u64, ipfsHash: vector<u8>, ctx: &mut TxContext) {
        let _userAddress = tx_context::sender(ctx);
        // TODO: add check role
        // CHECK 81 ERROR (E_REQUIRE_TAGS_WITH_UNIQUE_NAME)?

        let tag = getMutableTag(community, tagId);
        tag.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
    }

    public entry fun freezeCommunity(community: &mut Community, ctx: &mut TxContext) {  //Invalid function name 'freeze'. 'freeze' is restricted and cannot be used to name a function
        let _userAddress = tx_context::sender(ctx);
        // TODO: add check role

        community.isFrozen = true;

        // TODO: add emit CommunityFrozen(msg.sender, communityId);
    }

    public entry fun unfreezeCommunity(community: &mut Community, ctx: &mut TxContext) {
        let _userAddress = tx_context::sender(ctx);
        // TODO: add check role   (if community doesnot exist in check will be error)

        // assert!(communityId > 0, E_COMMUNITY_ID_CAN_NOT_BE_0);    // TODO TESTS
        // assert!(vector::length(&communityCollection.communities) >= communityId, E_COMMUNITY_DOES_NOT_EXIST); // TODO TESTS
        community.isFrozen = false;

        // TODO: add emit CommunityUnfrozen(msg.sender, communityId);
    }

    public entry fun onlyExistingAndNotFrozenCommunity(community: &Community) {    // new transfer (drop)+ -> onlyNotFrezenCommunity ?
        // assert!(communityId > 0, E_COMMUNITY_ID_CAN_NOT_BE_0);    // TODO TESTS
        // assert!(vector::length(&communityCollection.communities) >= communityId, E_COMMUNITY_DOES_NOT_EXIST); // TODO TESTS
        // let community = vector::borrow(&mut communityCollection.communities, communityId - 1); // TODO: add get community?
        assert!(!community.isFrozen, E_COMMUNITY_IS_FROZEN);
    }

    public entry fun checkTags(community: &Community, tags: vector<u64>) {      // new transfer community &mut ? (drop)
        let i = 0;
        while(i < vector::length(&mut tags)) {
            let tagId = *vector::borrow(&tags, i);
            getTag(community, tagId);
            i = i + 1;
        };
    }

    // public fun getMutableCommunity(communityCollection: &mut CommunityCollection, communityId: u64): &mut Community {
    //     onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
    //     let community = vector::borrow_mut(&mut communityCollection.communities, communityId - 1);
    //     community
    // }

    // public fun getCommunity(communityCollection: &mut CommunityCollection, communityId: u64): &Community {
    //     onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
    //     let community = vector::borrow(&communityCollection.communities, communityId - 1);
    //     community
    // }

    public fun getMutableTag(community: &mut Community, tagId: u64): &mut Tag {
        assert!(tagId > 0, E_TAG_ID_CAN_NOT_BE_0);
        assert!(vector::length(&community.tags) >= tagId, E_TAG_DOES_NOT_EXIST);
        let tag = vector::borrow_mut(&mut community.tags, tagId - 1);
        tag
    }
    
    public fun getTag(community: &Community, tagId: u64): &Tag {
        assert!(tagId > 0, E_TAG_ID_CAN_NOT_BE_0);
        assert!(vector::length(&community.tags) >= tagId, E_TAG_DOES_NOT_EXIST);
        let tag = vector::borrow(&community.tags, tagId - 1);
        tag
    }

    // public entry fun printCommunit(community: Community) {      // del?
    //     let Community { id: community_id, ipfsDoc: _ipfsDoc, timeCreate: _timeCreate, isFrozen: _isFrozen, tags: _tags } = community;
    //     object::delete(community_id);
    // }

    public fun getCommunityID(community: &Community): ID {
        let Community { id: community_id, ipfsDoc: _ipfsDoc, timeCreate: _timeCreate, isFrozen: _isFrozen, tags: _tags } = community;
        commonLib::getItemId(community_id)
    }

    // #[test_only]
    public entry fun printCommunity(community: &Community) {
        // let community = vector::borrow(&communityCollection.communities, communityId);
        debug::print(community);
    }

    #[test_only]
    public fun getCommunityData(community: &Community): (vector<u8>, u64, bool) {
        (commonLib::getIpfsHash(community.ipfsDoc), community.timeCreate, community.isFrozen)
    }

    #[test_only]
    public fun getCommunityTags(community: &Community): (vector<commonLib::IpfsHash>) {
        let tags: vector<commonLib::IpfsHash> = vector::empty<commonLib::IpfsHash>();
        
        let tagsLength = vector::length(&community.tags);
        assert!(tagsLength >= 5, E_REQUIRE_AT_LEAST_5_TAGS);
        let i = 0;
        while(i < tagsLength) {
            vector::push_back(&mut tags, vector::borrow(&community.tags, i).ipfsDoc);
            i = i + 1;
        };
        tags
    }

    // for UnitTest 5 Tag
    #[test_only]
    public fun unitTestGetCommunityTags(ipfsHash1: vector<u8>, ipfsHash2: vector<u8>, ipfsHash3: vector<u8>, ipfsHash4: vector<u8>, ipfsHash5: vector<u8>): vector<commonLib::IpfsHash> {
        vector<commonLib::IpfsHash>[
            commonLib::getIpfsDoc(ipfsHash1, vector::empty<u8>()),
            commonLib::getIpfsDoc(ipfsHash2, vector::empty<u8>()),
            commonLib::getIpfsDoc(ipfsHash3, vector::empty<u8>()),
            commonLib::getIpfsDoc(ipfsHash4, vector::empty<u8>()),
            commonLib::getIpfsDoc(ipfsHash5, vector::empty<u8>()),
        ]
    }

    // for UnitTest 6 Tag
    #[test_only]
    public fun unitTestGetMoreCommunityTags(ipfsHash1: vector<u8>, ipfsHash2: vector<u8>, ipfsHash3: vector<u8>, ipfsHash4: vector<u8>, ipfsHash5: vector<u8>, ipfsHash6: vector<u8>): vector<commonLib::IpfsHash> {
        vector<commonLib::IpfsHash>[
            commonLib::getIpfsDoc(ipfsHash1, vector::empty<u8>()),
            commonLib::getIpfsDoc(ipfsHash2, vector::empty<u8>()),
            commonLib::getIpfsDoc(ipfsHash3, vector::empty<u8>()),
            commonLib::getIpfsDoc(ipfsHash4, vector::empty<u8>()),
            commonLib::getIpfsDoc(ipfsHash5, vector::empty<u8>()),
            commonLib::getIpfsDoc(ipfsHash6, vector::empty<u8>()),
        ]
    }
}