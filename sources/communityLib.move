module basics::communityLib {
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use sui::event;
    // use std::debug;
    use basics::commonLib;
    use basics::userLib;
    // friend basics::commonLib;
    use sui::table::{Self, Table};

    /* errors */
    const E_REQUIRE_AT_LEAST_5_TAGS: u64 = 80;
    const E_REQUIRE_TAGS_WITH_UNIQUE_NAME: u64 = 81;
    const E_COMMUNITY_IS_FROZEN: u64 = 82;
    const E_COMMUNITY_ID_CAN_NOT_BE_0: u64 = 83;
    const E_COMMUNITY_DOES_NOT_EXIST: u64 = 84;
    const E_TAG_ID_CAN_NOT_BE_0: u64 = 85;
    const E_TAG_DOES_NOT_EXIST: u64 = 86;
    const E_COMMUNITY_IS_NOT_FROZEN: u64 = 87;


    struct Community has key {
        id: UID,
        ipfsDoc: commonLib::IpfsHash,
        timeCreate: u64,
        isFrozen: bool,
        tags: Table<u64, Tag>,
    }

    struct Tag has key, store {
        id: UID,
        ipfsDoc: commonLib::IpfsHash,
    }

    // ====== Events ======

    struct CreateCommunityEvent has copy, drop {
        userId: ID,
        communityId: ID,
    }

    struct UpdateCommunityEvent has copy, drop {
        userId: ID,
        communityId: ID,
    }

    struct CreateTagEvent has copy, drop {
        userId: ID,
        tagKey: u64,
        communityId: ID,
    }

    struct UpdateTagEvent has copy, drop {
        userId: ID,
        tagKey: u64,
        communityId: ID,
    }

    struct FreezeCommunityEvent has copy, drop {
        userId: ID,
        communityId: ID,
    }

    struct UnfreezeCommunityEvent has copy, drop {
        userId: ID,
        communityId: ID,
    }

    ///
    // tags: vector<Tag> -> tags: vector<vector<u8>>.
    // error "Expected primitive or object type. Got: vector<0x0::communityLib::Tag>"
    ///
    public entry fun createCommunity(
        user: &mut userLib::User,
        ipfsHash: vector<u8>,
        tags: vector<vector<u8>>,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        // peeranhaUser.checkHasRole(user, UserLib.ActionRole.Admin, 0);
        // peeranhaUser.initCommunityAdminPermission(user, communityId);
        
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

        let communityTags = table::new(ctx);
        let tagId = 0;
        while(tagId < tagsLength) {
            table::add(&mut communityTags, tagId + 1, Tag {
                id: object::new(ctx),
                ipfsDoc: commonLib::getIpfsDoc(*vector::borrow(&mut tags, tagId), vector::empty<u8>())
            });
            tagId = tagId +1;
        };

        let community = Community {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            timeCreate: commonLib::getTimestamp(),
            isFrozen: false,
            tags: communityTags,
        };

        event::emit(CreateCommunityEvent {userId: userId, communityId: object::id(&community)});
        transfer::share_object(community);
    }

    public entry fun updateCommunity(user: &mut userLib::User, community: &mut Community, ipfsHash: vector<u8>) {
        // peeranhaUser.checkHasRole(user, UserLib.ActionRole.AdminOrCommunityAdmin, communityId);
        onlyNotFrezenCommunity(community);  // test
        community.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
        event::emit(UpdateCommunityEvent {userId: object::id(user), communityId: object::id(community)});
    }

    public entry fun createTag(user: &mut userLib::User, community: &mut Community, ipfsHash: vector<u8>, ctx: &mut TxContext) {
        // peeranhaUser.checkHasRole(user, UserLib.ActionRole.AdminOrCommunityAdmin, communityId);
        onlyNotFrezenCommunity(community);  // test
        let i = 0;
        let tagsCount = table::length(&community.tags);
        while(i < tagsCount) {
            assert!(commonLib::getIpfsHash(table::borrow(&community.tags, i).ipfsDoc) != ipfsHash, E_REQUIRE_TAGS_WITH_UNIQUE_NAME);
            i = i +1;
        };

        event::emit(CreateTagEvent {userId: object::id(user), tagKey: tagsCount + 1, communityId: object::id(community)});
        table::add(&mut community.tags, tagsCount + 1, Tag {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>())
        });
    }

    public entry fun updateTag(user: &mut userLib::User, community: &mut Community, tagId: u64, ipfsHash: vector<u8>) {
        // peeranhaUser.checkHasRole(user, UserLib.ActionRole.AdminOrCommunityAdmin, communityId);
        onlyNotFrezenCommunity(community);  // test + polygon
        let tag = getMutableTag(community, tagId);
        // CHECK 81 ERROR (E_REQUIRE_TAGS_WITH_UNIQUE_NAME)?

        tag.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
        event::emit(CreateTagEvent {userId: object::id(user), tagKey: tagId, communityId: object::id(community)});
    }

    public entry fun freezeCommunity(user: &mut userLib::User, community: &mut Community) {  //Invalid function name 'freeze'. 'freeze' is restricted and cannot be used to name a function
        // peeranhaUser.checkHasRole(user, UserLib.ActionRole.AdminOrCommunityAdmin, communityId);
        onlyNotFrezenCommunity(community);  // test
        community.isFrozen = true;
        event::emit(FreezeCommunityEvent {userId: object::id(user), communityId: object::id(community)});
    }

    public entry fun unfreezeCommunity(user: &mut userLib::User, community: &mut Community) {
        // peeranhaUser.checkHasRole(user, UserLib.ActionRole.AdminOrCommunityAdmin, communityId);

        if(!community.isFrozen) {
            abort E_COMMUNITY_IS_NOT_FROZEN // add to polygon?
        };
        community.isFrozen = false;
        event::emit(UnfreezeCommunityEvent {userId: object::id(user), communityId: object::id(community)});
    }

    public entry fun onlyNotFrezenCommunity(community: &Community) {
        assert!(!community.isFrozen, E_COMMUNITY_IS_FROZEN);
    }

    public entry fun checkTags(community: &Community, tags: vector<u64>) {
        let i = 1;
        while(i < vector::length(&mut tags)) {
            let tagId = *vector::borrow(&tags, i);
            getTag(community, tagId);
            i = i + 1;
        };
    }

    public fun getMutableTag(community: &mut Community, tagId: u64): &mut Tag {
        assert!(tagId > 0, E_TAG_ID_CAN_NOT_BE_0);
        assert!(table::length(&community.tags) >= tagId, E_TAG_DOES_NOT_EXIST);
        let tag = table::borrow_mut(&mut community.tags, tagId - 1);
        tag
    }

    public fun getTag(community: &Community, tagId: u64): &Tag {
        assert!(tagId > 0, E_TAG_ID_CAN_NOT_BE_0);
        assert!(table::length(&community.tags) >= tagId, E_TAG_DOES_NOT_EXIST);
        let tag = table::borrow(&community.tags, tagId - 1);
        tag
    }

    #[test_only]
    public fun getCommunityData(community: &Community): (vector<u8>, u64, bool) {
        (commonLib::getIpfsHash(community.ipfsDoc), community.timeCreate, community.isFrozen)
    }

    #[test_only]
    public fun getCommunityTags(community: &Community): (vector<commonLib::IpfsHash>) {
        let tags: vector<commonLib::IpfsHash> = vector::empty<commonLib::IpfsHash>();
        
        let tagsLength = table::length(&community.tags);
        assert!(tagsLength >= 5, E_REQUIRE_AT_LEAST_5_TAGS);
        let i = 0;
        while(i < tagsLength) {
            vector::push_back(&mut tags, table::borrow(&community.tags, i + 1).ipfsDoc);
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