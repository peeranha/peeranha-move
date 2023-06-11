// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module peeranha::nftLib {
    use peeranha::commonLib;
    use sui::url::{Self, Url};
    use sui::table::{Self, Table};
    use sui::vec_map::{Self, VecMap};
    use std::vector;
    use std::string;
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    friend peeranha::userLib;
    friend peeranha::achievementLib;

    // ====== Errors ======

    const E_MAX_NFT_COUNT: u64 = 300;
    const E_YOU_CAN_NOT_TRANSFER_SOUL_BOUND_NFT: u64 = 301;

    // ====== Constant ======
    
    const POOL_NFT: u32 = 1000000;

    // ====== Enum ======

    const ACHIEVEMENT_TYPE_RATING: u8 = 0;
    const ACHIEVEMENT_TYPE_MANUAL: u8 = 1;
    const ACHIEVEMENT_TYPE_SOUL_RATING: u8 = 2;

    struct AchievementCollection has key {
        id: UID,
        achievements: VecMap<u64, Achievement>,
    }

    struct Achievement has store {
        maxCount: u32,
        factCount: u32,
        lowerBound: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        achievementsType: u8,
        communityId: ID,
        properties: VecMap<u8, vector<u8>>,
        userAchievementsIssued: Table<address, bool>
    }
    
    struct NFT has key, store {
        id: UID,
        /// Name for the token
        name: string::String,
        /// Description of the token
        description: string::String,
        /// URL for the token
        url: Url,
        achievementType: u8,
        // TODO: allow custom attributes
    }

    // ===== Events =====

    struct NFTTransferEvent has copy, drop {
        // The Object ID of the NFT
        object_id: ID,
        from: address,
        // The creator of the NFT       ///
        to: address,
    }

    struct ConfigureNewAchievementNFTEvent has copy, drop {
        achievementId: u64
    }

    fun init(ctx: &mut TxContext) {
        let achievementCollection = AchievementCollection {
            id: object::new(ctx),
            achievements: vec_map::empty(),
        };
        transfer::share_object(achievementCollection);
    }

    // ===== Public view functions =====

    /// Get the NFT's `name`
    public fun name(nft: &NFT): &string::String {
        &nft.name
    }

    /// Get the NFT's `description`
    public fun description(nft: &NFT): &string::String {
        &nft.description
    }

    /// Get the NFT's `url`
    public fun url(nft: &NFT): &Url {
        &nft.url
    }

    // ===== Entrypoints =====


    public(friend) fun configure_new_nft(
        achievementCollection: &mut AchievementCollection,
        maxCount: u32,
        lowerBound: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        achievementsType: u8,
        communityId: ID,
        ctx: &mut TxContext
    ) {
        // require(achievementId == achievementsNFTContainer.achievementsCount, "Wrong achievement Id");
        assert!(maxCount < POOL_NFT, E_MAX_NFT_COUNT);

        let achievement = Achievement {
            maxCount: maxCount,
            factCount: 0,
            lowerBound: lowerBound,
            name: name,
            description: description,
            url: url,
            achievementsType: achievementsType,
            communityId: communityId,
            properties: vec_map::empty(),
            userAchievementsIssued: table::new(ctx)
        };

        let achievementKey = vec_map::size(&achievementCollection.achievements) + 1;
        vec_map::insert(&mut achievementCollection.achievements, achievementKey, achievement);
        event::emit(ConfigureNewAchievementNFTEvent{achievementId: achievementKey});
    }


    /// Create a new nft
    public(friend) fun mint(
        achievementCollection: &mut AchievementCollection,
        currentValue: u64,
        communityId: ID,
        userAchievementsTypes: vector<u8>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        let achievementId = 1;
        let achievementLength = vec_map::size(&achievementCollection.achievements);
        while(achievementId <= achievementLength) {
            let achievement = vec_map::get_mut<u64, Achievement>(&mut achievementCollection.achievements, &achievementId);
            
            let achievementTypeId = 0;
            let userAchievementsTypesLength = vector::length(&userAchievementsTypes);
            while (achievementTypeId < userAchievementsTypesLength) {
                let userAchievementType = *vector::borrow(&userAchievementsTypes, achievementTypeId);
                if (userAchievementType == achievement.achievementsType) {
                    if (
                        achievement.communityId != communityId &&
                        achievement.communityId != commonLib::getZeroId()
                    ) continue;
                    if (!is_achievement_available(achievement.maxCount, achievement.factCount)) continue;
                    if (achievement.lowerBound > currentValue) continue;
                    let isIssued = table::borrow_mut<address, bool>(&mut achievement.userAchievementsIssued, sender);
                    if (*isIssued) continue; //already issued

                    *isIssued = true;
                    achievement.factCount = achievement.factCount + 1;

                    let nft = NFT {
                        id: object::new(ctx),
                        name: string::utf8(achievement.name),
                        description: string::utf8(achievement.description),
                        url: url::new_unsafe_from_bytes(achievement.url),
                        achievementType: userAchievementType,
                    };

                    event::emit(NFTTransferEvent {
                        object_id: object::id(&nft),
                        from: @0x0,
                        to: sender,
                    });

                    transfer::public_transfer(nft, sender);
                };
            };
            achievementId = achievementId + 1;
        };        
    }

    fun is_achievement_available(maxCount: u32, factCount: u32): (bool) {
        maxCount > factCount || (maxCount == 0 && factCount < POOL_NFT)
    }

    /// Transfer `nft` to `recipient`
    public entry fun transfer(
        nft: NFT, recipient: address, ctx: &mut TxContext
    ) {
        assert!(nft.achievementType != ACHIEVEMENT_TYPE_SOUL_RATING, E_YOU_CAN_NOT_TRANSFER_SOUL_BOUND_NFT);
        let sender = tx_context::sender(ctx);
        event::emit(NFTTransferEvent {
            object_id: object::id(&nft),
            from: sender,
            to: recipient,
        });
        transfer::public_transfer(nft, recipient)
    }

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
        let NFT { id, name: _, description: _, url: _, achievementType: _} = nft;
        object::delete(id)
    }

    public fun getAchievementTypeRating(): (u8) {
        ACHIEVEMENT_TYPE_RATING
    }

    public fun getAchievementTypeManual(): (u8) {
        ACHIEVEMENT_TYPE_MANUAL
    }

    public fun getAchievementTypeSoulRating(): (u8) {
        ACHIEVEMENT_TYPE_SOUL_RATING
    }

    // --- Testing functions ---

    #[test_only]
    public fun init_test(ctx: &mut TxContext) {
        init(ctx)
    }
}
