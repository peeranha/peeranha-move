// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module peeranha::nftLib {
    use peeranha::commonLib;
    use sui::url::{Self, Url};
    use sui::table::{Self, Table};
    use sui::vec_map::{Self, VecMap};
    use std::vector;
    use std::string::{Self, utf8};
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    friend peeranha::userLib;
    friend peeranha::achievementLib;

    // The creator bundle: these two packages often go together.
    use sui::package;
    use sui::display;

    // ====== Errors ======

    const E_MAX_NFT_COUNT: u64 = 300;
    const E_WRONG_ATTRIBUTES_LENGTH: u64 = 301;
    const E_ACHIEVEMENT_ID_CAN_NOT_BE_0: u64 = 302;
    const E_ACHIEVEMENT_NOT_EXIST: u64 = 303;
    const E_YOU_CAN_UNLOCK_ONLY_MANUAL_NFT: u64 = 304;
    const E_ALREADY_UNLOCKED: u64 = 305;
    const E_ALREADY_MINTED: u64 = 306;
    const E_NOT_UNLOCK_ACHIEVEMENT: u64 = 307;

    // ====== Constant ======
    
    const POOL_NFT: u32 = 1000000;

    // ====== Enum ======

    const ACHIEVEMENT_TYPE_RATING: u8 = 0;
    const ACHIEVEMENT_TYPE_MANUAL: u8 = 1;

    /// One-Time-Witness for the module.
    struct NFTLIB has drop {}

    struct AchievementCollection has key {
        id: UID,
        achievements: VecMap<u64, Achievement>,
    }

    struct Achievement has store {
        maxCount: u32,
        factCount: u32,
        lowerBound: u64,
        name: string::String,
        description: string::String,
        url: Url,
        externalUrl: Url,
        achievementType: u8,
        communityId: ID,
        properties: VecMap<u8, vector<u8>>,
        attributes: VecMap<string::String, string::String>,
        /// is minted the achievement for 'user object id'. Table key - `user object id`
        /// false - user can mint nft, but has not minted yet
        /// true - user has minted the nft 
        usersNFTIsMinted: Table<ID, bool>
    }
    
    struct NFT has key, store {
        id: UID,
        /// Name for the token
        name: string::String,
        /// Description of the token
        description: string::String,
        /// URL for the token
        url: Url,
        externalUrl: Url,
        achievementType: u8,
        attributes: VecMap<string::String, string::String>,
    }

    // ===== Events =====

    struct ConfigureAchievementEvent has copy, drop {
        achievementId: u64
    }

    struct UnlockAchievementEvent has copy, drop {
        // The `user object ID` who unlocked the `achievementId`
        userObjectId: ID,
        // The `achievement id key` which the `userObjectId` can mint
        achievementId: u64,
    }

    struct MintNftEvent has copy, drop {
        // The `user object ID` who unlocked the `achievementId`
        userObjectId: ID,
        // The `achievement id key` which the `userObjectId` can mint
        achievementId: u64,
        nftId: ID,
    }

    fun init(otw: NFTLIB, ctx: &mut TxContext) {
        let achievementCollection = AchievementCollection {
            id: object::new(ctx),
            achievements: vec_map::empty(),
        };
        transfer::share_object(achievementCollection);

        //
        // Comment for unit tests start
        //

        let keys = vector[
            utf8(b"name"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"Website"),
        ];

        let values = vector[
            utf8(b"{name}"),
            utf8(b"{url}"),
            utf8(b"{description}"),
            utf8(b"{externalUrl}"),
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `Hero` type.
        let display = display::new_with_fields<NFT>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display);

        transfer::public_transfer(publisher, tx_context::sender(ctx));  // test error
        transfer::public_transfer(display, tx_context::sender(ctx));

        //
        // Comment for unit tests end
        //
    }

    public(friend) fun configureAchievement(
        achievementCollection: &mut AchievementCollection,
        communityId: ID,
        maxCount: u32,
        lowerBound: u64,
        name:  string::String,
        description:  string::String,
        url: vector<u8>,
        achievementType: u8,
        externalUrl: vector<u8>,
        attributesKeys:  vector<string::String>,
        attributesValues:  vector<string::String>,
        ctx: &mut TxContext
    ) {
        assert!(maxCount < POOL_NFT, E_MAX_NFT_COUNT);  // TEST
        let attributeKeysLength = vector::length(&attributesKeys);
        assert!(vector::length(&attributesKeys) == vector::length(&attributesValues), E_WRONG_ATTRIBUTES_LENGTH);

        let attributes: VecMap<string::String, string::String> = vec_map::empty();
        let attributeId = 0;
        while (attributeId < attributeKeysLength) {
            vec_map::insert(&mut attributes, *vector::borrow(&attributesKeys, attributeId), *vector::borrow(&attributesValues, attributeId));
            attributeId = attributeId + 1;
        };
        
        let achievement = Achievement {
            maxCount: maxCount,
            factCount: 0,
            lowerBound: lowerBound,
            name: name,
            description: description,
            url: url::new_unsafe_from_bytes(url),
            externalUrl: url::new_unsafe_from_bytes(externalUrl),
            achievementType: achievementType,
            communityId: communityId,
            properties: vec_map::empty(),
            attributes: attributes,
            usersNFTIsMinted: table::new(ctx)
        };

        let achievementKey = vec_map::size(&achievementCollection.achievements) + 1;
        vec_map::insert(&mut achievementCollection.achievements, achievementKey, achievement);
        event::emit(ConfigureAchievementEvent{achievementId: achievementKey});
    }

    /// Unlock achievements
    public(friend) fun unlockAchievements(
        achievementCollection: &mut AchievementCollection,
        userObjectId: ID,
        communityId: ID,
        currentValue: u64,
        userAchievementsTypes: vector<u8>,
        _ctx: &mut TxContext,                               // del?
    ) {
        let achievementKey = 1;
        let achievementLength = vec_map::size(&achievementCollection.achievements);
        while(achievementKey <= achievementLength) {
            let achievement = getAchievement(achievementCollection, achievementKey);        // mut????

            let achievementTypeId = 0;
            let userAchievementsTypesLength = vector::length(&userAchievementsTypes);
            while (achievementTypeId < userAchievementsTypesLength) {
                let userAchievementType = *vector::borrow(&userAchievementsTypes, achievementTypeId);
                achievementTypeId = achievementTypeId + 1;
                if (userAchievementType == achievement.achievementType) {
                    if (
                        achievement.communityId != communityId &&
                        achievement.communityId != commonLib::getZeroId()
                    ) continue;
                    if (!is_achievement_available(achievement.maxCount, achievement.factCount)) continue;
                    if (achievement.lowerBound > currentValue) continue;
                    let isExistUserNFTIsMinted = table::contains(&mut achievement.usersNFTIsMinted, userObjectId);
                    if (isExistUserNFTIsMinted) continue; //already issued

                    table::add(&mut achievement.usersNFTIsMinted, userObjectId, false);
                    achievement.factCount = achievement.factCount + 1;

                    event::emit(UnlockAchievementEvent {
                        userObjectId: userObjectId,
                        achievementId: achievementKey,
                    });
                };
            };
            achievementKey = achievementKey + 1;
        };     
    }

    public(friend) fun unlockManualNft(
        achievementCollection: &mut AchievementCollection,
        userObjectId: ID,
        achievementId: u64,
    ) {
        let achievement = getAchievement(achievementCollection, achievementId);        // mut????
        assert!(achievement.achievementType == ACHIEVEMENT_TYPE_MANUAL, E_YOU_CAN_UNLOCK_ONLY_MANUAL_NFT);      // TEST
        let isExistUserNFTIsMinted = table::contains(&mut achievement.usersNFTIsMinted, userObjectId);
        assert!(!isExistUserNFTIsMinted, E_ALREADY_UNLOCKED);      // TEST (minted and not)

        table::add(&mut achievement.usersNFTIsMinted, userObjectId, false);
        achievement.factCount = achievement.factCount + 1;                      // test
        
        event::emit(UnlockAchievementEvent {
            userObjectId: userObjectId,
            achievementId: achievementId,
        });
    }

    /// mint nft
    public(friend) fun mint(
        achievementCollection: &mut AchievementCollection,
        userObjectId: ID,
        achievementsKey: vector<u64>,                           // 0 count (assert)
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let achievementsKeyLength = vector::length(&achievementsKey);
        let achievementKeyPosition = 0;

        while (achievementKeyPosition < achievementsKeyLength) {
            let achievementKey = *vector::borrow(&achievementsKey, achievementKeyPosition);
            let achievement = getAchievement(achievementCollection, achievementKey);
            
            let isExistUserNFTIsMinted = table::contains(&mut achievement.usersNFTIsMinted, userObjectId);
            if (!isExistUserNFTIsMinted) {
                abort E_NOT_UNLOCK_ACHIEVEMENT      //TEST
            };

            let isMinted = table::borrow_mut<ID, bool>(&mut achievement.usersNFTIsMinted, userObjectId);
            if (*isMinted) {
                abort E_ALREADY_MINTED
            };

            let nft = NFT {
                id: object::new(ctx),
                name: achievement.name,
                description: achievement.description,
                url: achievement.url,
                externalUrl: achievement.externalUrl,
                achievementType: achievement.achievementType,
                attributes: achievement.attributes
            };

            event::emit(MintNftEvent {
                userObjectId: userObjectId,
                achievementId: achievementKey,
                nftId: object::id(&nft),
            });

            *isMinted = true;
            transfer::public_transfer(nft, sender);
            achievementKeyPosition = achievementKeyPosition + 1;
        }
    }

    fun is_achievement_available(maxCount: u32, factCount: u32): (bool) {
        maxCount > factCount || (maxCount == 0 && factCount < POOL_NFT)
    }

    fun getMutableAchievement(
        achievementCollection: &mut AchievementCollection,
        achievementKey: u64
    ): &mut Achievement {
        let achievementLength = vec_map::size(&achievementCollection.achievements);
        assert!(achievementKey >= 0, E_ACHIEVEMENT_ID_CAN_NOT_BE_0);
        assert!(achievementLength >= achievementKey, E_ACHIEVEMENT_NOT_EXIST);
            
        vec_map::get_mut<u64, Achievement>(&mut achievementCollection.achievements, &achievementKey)
    }

    public fun getAchievement(
        achievementCollection: &mut AchievementCollection,
        achievementKey: u64
    ): &mut Achievement {
        getMutableAchievement(achievementCollection, achievementKey)
    }

    // ===== Entrypoints =====

    /// Update the `description` of `nft` to `new_description`
    public entry fun update_description(
        nft: &mut NFT,
        new_description: vector<u8>,
        _: &mut TxContext
    ) {
        // add event?
        nft.description = string::utf8(new_description)
    }

    /// Permanently delete `nft`
    public entry fun burn(nft: NFT, _: &mut TxContext) {
        let NFT { id, name: _, description: _, url: _, externalUrl: _, achievementType: _, attributes: _} = nft;
        // add event?
        object::delete(id)
    }

    public fun getAchievementTypeRating(): (u8) {
        ACHIEVEMENT_TYPE_RATING
    }

    public fun getAchievementTypeManual(): (u8) {
        ACHIEVEMENT_TYPE_MANUAL
    }

    // --- Testing functions ---
    
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(NFTLIB{}, ctx)
    }

    #[test_only]
    public fun getUsersNFTIsMinted(
        achievementCollection: &mut AchievementCollection,
        userObjectId: ID,
        achievementKey: u64,
    ): bool {
        let achievement = getAchievement(achievementCollection, achievementKey);

        let isExistUserNFTIsMinted = table::contains(&mut achievement.usersNFTIsMinted, userObjectId);
        if (!isExistUserNFTIsMinted) {
            abort E_NOT_UNLOCK_ACHIEVEMENT
        };
        *table::borrow<ID, bool>(&achievement.usersNFTIsMinted, userObjectId)
    }

    #[test_only]
    public fun getAchievementData(
        achievementCollection: &mut AchievementCollection,
        achievementKey: u64
    ): (u32, u32, u64, string::String, string::String, Url, u8, ID, Url, VecMap<string::String, string::String>) {
        let achievement = getAchievement(achievementCollection, achievementKey);
        (
            achievement.maxCount,
            achievement.factCount,
            achievement.lowerBound,
            achievement.name,
            achievement.description,
            achievement.url,
            achievement.achievementType,
            achievement.communityId,
            achievement.externalUrl,
            achievement.attributes,
        )
    }

    #[test_only]
    public fun getNftData(
        nft: &mut NFT,
    ): (string::String, string::String, Url, Url, VecMap<string::String, string::String>, u8) {

        (
            nft.name,
            nft.description,
            nft.url,
            nft.externalUrl,
            nft.attributes,
            nft.achievementType,
        )
    }
}
