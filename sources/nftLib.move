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
    const E_ACHIEVEMENT_ID_CAN_NOT_BE_0: u64 = 302;
    const E_ACHIEVEMENT_NOT_EXIST: u64 = 303;

    const E_NEW_ERROR: u64 = 399;       // add

    // ====== Constant ======
    
    const POOL_NFT: u32 = 1000000;

    // ====== Enum ======

    const ACHIEVEMENT_TYPE_RATING: u8 = 1;
    const ACHIEVEMENT_TYPE_MANUAL: u8 = 2;
    const ACHIEVEMENT_TYPE_SOUL_RATING: u8 = 3;

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
        achievementType: u8,
        communityId: ID,
        properties: VecMap<u8, vector<u8>>,
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
        achievementType: u8,
        // TODO: allow custom attributes
    }

    // ===== Events =====

    struct ConfigureNewAchievementNFTEvent has copy, drop {
        achievementId: u64
    }

    struct UnlockAchievementEvent has copy, drop {
        // The `user object ID` who unlocked the `achievement_Id`
        user_object_id: ID,
        // The `achievement Id key` which the `user_object_id` can mint
        achievement_Id: u64,
    }

    struct NFTTransferEvent has copy, drop {
        // The Object ID of the NFT
        object_id: ID,
        from: address,
        // The creator of the NFT       ///
        to: address,
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
        achievementType: u8,
        communityId: ID,
        ctx: &mut TxContext
    ) {
        assert!(maxCount < POOL_NFT, E_MAX_NFT_COUNT);

        let achievement = Achievement {
            maxCount: maxCount,
            factCount: 0,
            lowerBound: lowerBound,
            name: name,
            description: description,
            url: url,
            achievementType: achievementType,
            communityId: communityId,
            properties: vec_map::empty(),
            usersNFTIsMinted: table::new(ctx)
        };

        let achievementKey = vec_map::size(&achievementCollection.achievements) + 1;
        vec_map::insert(&mut achievementCollection.achievements, achievementKey, achievement);
        event::emit(ConfigureNewAchievementNFTEvent{achievementId: achievementKey});
    }

    /// Unlock achievements
    public(friend) fun unlockAchievements(
        achievementCollection: &mut AchievementCollection,
        userObjectId: ID,
        currentValue: u64,
        communityId: ID,
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
                        user_object_id: userObjectId,
                        achievement_Id: achievementKey,
                    });
                };
                achievementTypeId = achievementTypeId + 1;
            };
            achievementKey = achievementKey + 1;
        };        
    }

    /// mint nft
    public(friend) fun mint(
        achievementCollection: &mut AchievementCollection,
        userObjectId: ID,
        achievementsKey: vector<u64>,
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
                abort E_NEW_ERROR
            };

            let isMinted = table::borrow_mut<ID, bool>(&mut achievement.usersNFTIsMinted, userObjectId);
            if (*isMinted) {
                // error already minted
            };

            let nft = NFT {
                id: object::new(ctx),
                name: string::utf8(achievement.name),
                description: string::utf8(achievement.description),
                url: url::new_unsafe_from_bytes(achievement.url),
                achievementType: achievement.achievementType,
            };

            event::emit(NFTTransferEvent {
                object_id: object::id(&nft),
                from: @0x0,
                to: sender,
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

    #[test_only]
    public fun getUsersNFTIsMinted(
        achievementCollection: &mut AchievementCollection,
        userObjectId: ID,
        achievementKey: u64,
    ): &mut bool {
        let achievement = getAchievement(achievementCollection, achievementKey);

        let isExistUserNFTIsMinted = table::contains(&mut achievement.usersNFTIsMinted, userObjectId);
        if (!isExistUserNFTIsMinted) {
            abort E_NEW_ERROR
        };

        table::borrow_mut<ID, bool>(&mut achievement.usersNFTIsMinted, userObjectId)
    }
}
