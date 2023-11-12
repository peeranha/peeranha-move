module peeranha::communityLib {
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use std::vector;
    use sui::event;
    use peeranha::commonLib;
    use peeranha::accessControlLib;
    use peeranha::userLib;
    use sui::table::{Self, Table};
    use sui::vec_map::{Self, VecMap};

    // ====== Errors. Available values 200 - 299 ======

    const E_REQUIRE_AT_LEAST_5_TAGS: u64 = 200;
    const E_REQUIRE_TAGS_WITH_UNIQUE_NAME: u64 = 201;
    const E_COMMUNITY_IS_FROZEN: u64 = 202;
    const E_COMMUNITY_ID_CAN_NOT_BE_0: u64 = 203;
    const E_COMMUNITY_DOES_NOT_EXIST: u64 = 204;
    const E_TAG_ID_CAN_NOT_BE_0: u64 = 205;
    const E_TAG_DOES_NOT_EXIST: u64 = 206;
    const E_COMMUNITY_IS_NOT_FROZEN: u64 = 207;


    struct Community has key {
        id: UID,
        /// `IPFS hash` of document with `community` information
        ipfsDoc: commonLib::IpfsHash,
        /// `Docomentation` of the `community`
        documentation: commonLib::IpfsHash,
        /// Frozen status of the `community`
        isFrozen: bool,
        /// `Tags` for the `community`. Table key - `tag key`.
        tags: Table<u64, Tag>,
        /// `Properties` for the `community`
        properties: VecMap<u8, vector<u8>>,
    }

    struct Tag has key, store {
        id: UID,
        /// `IPFS hash` of document with `tag` information
        ipfsDoc: commonLib::IpfsHash,
        /// `Properties` for the `tag`
        properties: VecMap<u8, vector<u8>>,
    }

    // ====== Events ======

    struct CreateCommunityEvent has copy, drop {
        /// The transaction `sender`
        userId: ID,
        /// The `object ID` of the `community`
        communityId: ID,
    }

    struct UpdateCommunityEvent has copy, drop {
        /// The transaction `sender`
        userId: ID,
        /// The `object ID` of the `community`
        communityId: ID,
    }

    struct SetDocumentationTree has copy, drop {
        /// The transaction `sender`
        userId: ID,
        /// Set `documentation` for the `community`
        communityId: ID,
    }

    struct CreateTagEvent has copy, drop {
        /// The transaction `sender `
        userId: ID,
        /// The `tag key` of the new `tag`
        tagKey: u64,
        /// The `object ID` of the `community`
        communityId: ID,
    }

    struct UpdateTagEvent has copy, drop {
        /// The transaction `sender`
        userId: ID,
        /// The `tag key` of the updated `tag`
        tagKey: u64,
        /// The `object ID` of the `community`
        communityId: ID,
    }

    struct FreezeCommunityEvent has copy, drop {
        /// The transaction `sender`
        userId: ID,
        /// The `object ID` of the frozen community
        communityId: ID,
    }

    struct UnfreezeCommunityEvent has copy, drop {
        /// The transaction `sender`
        userId: ID,
        /// The `object ID` of the unfrozen `community`
        communityId: ID,
    }

    /// Create new `community` info record
    public entry fun createCommunity(
        roles: &mut accessControlLib::UserRolesCollection,
        user: &userLib::User,
        ipfsHash: vector<u8>,
        tags: vector<vector<u8>>,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        accessControlLib::checkHasRole(roles, userId, accessControlLib::get_action_role_admin(), commonLib::getZeroId());
        
        let tagsLength = vector::length(&tags);
        assert!(tagsLength >= 5, E_REQUIRE_AT_LEAST_5_TAGS);
        let i = 0;
        while(i < tagsLength) {
            let j = 1;

            while(j < tagsLength) {
                if (i != j) {
                    assert!(vector::borrow(&tags, i) != vector::borrow(&tags, j), E_REQUIRE_TAGS_WITH_UNIQUE_NAME);
                };
                j = j + 5;
            };
            i = i + 1;
        };

        let communityTags = table::new(ctx);
        let tagId = 0;
        while(tagId < tagsLength) {
            table::add(&mut communityTags, tagId + 1, Tag {
                id: object::new(ctx),
                ipfsDoc: commonLib::getIpfsDoc(*vector::borrow(&tags, tagId), vector::empty<u8>()),
                properties: vec_map::empty(),
            });
            tagId = tagId + 1;
        };

        let community = Community {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            documentation: commonLib::getIpfsDoc(vector::empty<u8>(), vector::empty<u8>()),
            isFrozen: false,
            tags: communityTags,
            properties: vec_map::empty(),
        };

        let communityId = object::id(&community);
        accessControlLib::setCommunityPermission(roles, communityId, userId);
        event::emit(CreateCommunityEvent {userId: userId, communityId: communityId});
        transfer::share_object(community);
    }

    /// Update `community` info record
    public entry fun updateCommunity(roles: &accessControlLib::UserRolesCollection, user: &userLib::User, community: &mut Community, ipfsHash: vector<u8>) {
        let userId = object::id(user);
        accessControlLib::checkHasRole(roles, userId, accessControlLib::get_action_role_admin_or_community_admin(), object::id(community));
        onlyNotFrozenCommunity(community);  // test

        community.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
        event::emit(UpdateCommunityEvent {userId: userId, communityId: object::id(community)});
    }

    /// Update `documentation ipfs` tree
    public entry fun updateDocumentationTree(
        usersRatingCollection: &userLib::UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        user: &userLib::User,
        community: &mut Community,
        ipfsHash: vector<u8>
    ) {
        let userId = object::id(user);
        let communityId = object::id(community);
        accessControlLib::checkHasRole(
            userRolesCollection,
            userId,
            accessControlLib::get_action_role_admin_or_community_admin_or_community_moderator(),
            object::id(community)
        );

        onlyNotFrozenCommunity(community);

        community.documentation = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
        event::emit(SetDocumentationTree {userId: userId, communityId: object::id(community)});
    }

    /// Create new `tag` info record
    public entry fun createTag(roles: &accessControlLib::UserRolesCollection, user: &userLib::User, community: &mut Community, ipfsHash: vector<u8>, ctx: &mut TxContext) {
        let userId = object::id(user);
        let communityId = object::id(community);
        accessControlLib::checkHasRole(roles, userId, accessControlLib::get_action_role_admin_or_community_admin(), communityId);

        onlyNotFrozenCommunity(community);  // test
        let i = 1;
        let tagsCount = table::length(&community.tags);
        while(i <= tagsCount) {
            assert!(commonLib::getIpfsHash(table::borrow(&community.tags, i).ipfsDoc) != ipfsHash, E_REQUIRE_TAGS_WITH_UNIQUE_NAME);
            i = i + 1;
        };

        event::emit(CreateTagEvent {userId: userId, tagKey: tagsCount + 1, communityId: communityId});
        table::add(&mut community.tags, tagsCount + 1, Tag {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            properties: vec_map::empty(),
        });
    }
    /// Update `tag` info record
    public entry fun updateTag(roles: &accessControlLib::UserRolesCollection, user: &userLib::User, community: &mut Community, tagId: u64, ipfsHash: vector<u8>) {
        let userId = object::id(user);
        let communityId = object::id(community);
        accessControlLib::checkHasRole(roles, userId, accessControlLib::get_action_role_admin_or_community_admin(), communityId);

        onlyNotFrozenCommunity(community);  // test + polygon
        let tag = getMutableTag(community, tagId);
        // CHECK 81 ERROR (E_REQUIRE_TAGS_WITH_UNIQUE_NAME)?

        tag.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
        event::emit(UpdateTagEvent {userId: userId, tagKey: tagId, communityId: communityId});
    }

    /// Freeze the `community`
    public entry fun freezeCommunity(roles: &accessControlLib::UserRolesCollection, user: &userLib::User, community: &mut Community) {  //Invalid function name 'freeze'. 'freeze' is restricted and cannot be used to name a function
        let userId = object::id(user);
        let communityId = object::id(community);
        accessControlLib::checkHasRole(roles, userId, accessControlLib::get_action_role_admin_or_community_admin(), communityId);

        onlyNotFrozenCommunity(community);  // test
        community.isFrozen = true;
        event::emit(FreezeCommunityEvent {userId: userId, communityId: communityId});
    }

    /// Unfreeze the `community`
    public entry fun unfreezeCommunity(roles: &accessControlLib::UserRolesCollection, user: &userLib::User, community: &mut Community) {
        let userId = object::id(user);
        let communityId = object::id(community);
        accessControlLib::checkHasRole(roles, userId, accessControlLib::get_action_role_admin_or_community_admin(), communityId);

        if(!community.isFrozen) {
            abort E_COMMUNITY_IS_NOT_FROZEN // add to polygon?
        };
        community.isFrozen = false;
        event::emit(UnfreezeCommunityEvent {userId: userId, communityId: communityId});
    }



    /// Give community administrator permission by admin or community admin
    public fun giveCommunityAdminPermission(
        roles: &mut accessControlLib::UserRolesCollection,
        admin: &userLib::User,
        userId: ID,
        community: &Community
    ) {
        onlyNotFrozenCommunity(community);
        let communityId = object::id(community);
        let adminId = object::id(admin);
        accessControlLib::grantCommunityAdminRole(roles, communityId, adminId, userId);
    }

    /// Give community moderator permission by admin or community admin
    public fun giveCommunityModeratorPermission(
        roles: &mut accessControlLib::UserRolesCollection,
        admin: &userLib::User,
        userId: ID,
        community: &Community
    ) {
        onlyNotFrozenCommunity(community);
        let communityId = object::id(community);
        let adminId = object::id(admin);
        accessControlLib::grantCommunityModeratorRole(roles, communityId, adminId, userId);
    }

    /// Revoke community administrator permission by admin or community admin
    public fun revokeCommunityAdminPermission(
        roles: &mut accessControlLib::UserRolesCollection,
        admin: &userLib::User,
        userId: ID,
        community: &Community
    ) {
        let communityId = object::id(community);
        let adminId = object::id(admin);
        accessControlLib::revokeCommunityAdminRole(roles, communityId, adminId, userId);
    }

    /// Revoke community moderator permission by admin or community admin
    public fun revokeCommunityModeratorPermission(
        roles: &mut accessControlLib::UserRolesCollection,
        admin: &userLib::User,
        userId: ID,
        community: &Community
    ) {
        let communityId = object::id(community);
        let adminId = object::id(admin);
        accessControlLib::revokeCommunityModeratorRole(roles, communityId, adminId, userId);
    }

    /// Check status of the `community`
    public fun onlyNotFrozenCommunity(community: &Community) {
        assert!(!community.isFrozen, E_COMMUNITY_IS_FROZEN);
    }

    public fun checkTags(community: &Community, tags: vector<u64>) {
        let i = 0;
        while(i < vector::length(&mut tags)) {
            let tagId = *vector::borrow(&tags, i);
            getTag(community, tagId);
            i = i + 1;
        };
    }

    /// Get list of mutable `tags` in the `community`
    public fun getMutableTag(community: &mut Community, tagId: u64): &mut Tag {
        assert!(tagId > 0, E_TAG_ID_CAN_NOT_BE_0);
        assert!(table::length(&community.tags) >= tagId, E_TAG_DOES_NOT_EXIST);
        let tag = table::borrow_mut(&mut community.tags, tagId);
        tag
    }

    /// Get list of `tags` in `community`
    public fun getTag(community: &Community, tagId: u64): &Tag {
        assert!(tagId > 0, E_TAG_ID_CAN_NOT_BE_0);
        assert!(table::length(&community.tags) >= tagId, E_TAG_DOES_NOT_EXIST);
        let tag = table::borrow(&community.tags, tagId);
        tag
    }

    // --- Testing functions ---

    #[test_only]
    public fun getCommunityData(community: &Community): (vector<u8>, vector<u8>, bool) {
        (commonLib::getIpfsHash(community.ipfsDoc), commonLib::getIpfsHash(community.documentation), community.isFrozen)
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