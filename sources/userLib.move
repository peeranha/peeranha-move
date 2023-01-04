module basics::userLib {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    // use std::debug;
    use basics::i64Lib;
    use basics::communityLib;
    use basics::commonLib;
    use sui::vec_map::{Self, VecMap};
    use std::option;

    /* errors */

    const E_USER_EXIST: u64 = 9;
    const E_USER_DOES_NOT_EXIST: u64 = 10;
    const E_ALREADY_FOLLOWED: u64 = 11;
    const E_COMMUNITY_NOT_FOLOWED: u64 = 12;
    const E_USER_NOT_FOUND: u64 = 13;
    const E_NOT_ALLOWED_EDIT: u64 = 14;
    const E_NOT_ALLOWED_DELETE: u64 = 15;
    const E_NOT_ALLOWED_VOTE_POST: u64 = 16;
    const E_NOT_ALLOWED_VOTE_REPLY: u64 = 17;
    const E_NOT_ALLOWED_VOTE_COMMENT: u64 = 18;
    const E_NOT_ALLOWED_ACTION: u64 = 21;
    const E_LOW_ENERGY: u64 = 22;
    const E_CHECK_FUNCTION_getRatingAndEnergyForAction: u64 = 99;
    const E_CHECK_FUNCTION_getMutableTotalRewardShare: u64 = 100; // todo

    const START_USER_RATING: u64 = 10;
    const DEFAULT_IPFS: vector<u8> = x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc";

    // TODO: add enum Action
    const ACTION_NONE: u8 = 0;
    const ACTION_PUBLICATION_POST: u8 = 1;
    const ACTION_PUBLICATION_REPLY: u8 = 2;
    const ACTION_PUBLICATION_COMMNET: u8 = 3;
    const ACTION_EDIT_ITEM: u8 = 4;
    const ACTION_DELETE_ITEM: u8 = 5;
    const ACTION_UPVOTE_POST: u8 = 6;
    const ACTION_DOWNVOTE_POST: u8 = 7;
    const ACTION_UPVOTE_REPLY: u8 = 8;
    const ACTION_DOWNVOTE_REPLY: u8 = 9;
    const ACTION_VOTE_COMMENT: u8 = 10;
    const ACTION_CANCEL_VOTE: u8 = 11;
    const ACTION_BEST_REPLY: u8 = 12;
    const ACTION_UPDATE_PROFILE: u8 = 13;
    const ACTION_FOLLOW_COMMUNITY: u8 = 14;

    const MINIMUM_RATING: u64 = 300;        //neg
    const POST_QUESTION_ALLOWED: u64 = 0;
    const POST_REPLY_ALLOWED: u64 = 0;
    const POST_COMMENT_ALLOWED: u64 = 35;
    const POST_OWN_COMMENT_ALLOWED: u64 = 0;

    const UPVOTE_POST_ALLOWED: u64 = 35;
    const DOWNVOTE_POST_ALLOWED: u64 = 100;
    const UPVOTE_REPLY_ALLOWED: u64 = 35;
    const DOWNVOTE_REPLY_ALLOWED: u64 = 100;
    const VOTE_COMMENT_ALLOWED: u64 = 0;
    const CANCEL_VOTE: u64 = 0;
    const UPDATE_PROFILE_ALLOWED: u64 = 0;

    // u8?
    const ENERGY_DOWNVOTE_QUESTION: u64 = 5;
    const ENERGY_DOWNVOTE_ANSWER: u64 = 3;
    const ENERGY_DOWNVOTE_COMMENT: u64 = 2;
    const ENERGY_UPVOTE_QUESTION: u64 = 1;
    const ENERGY_UPVOTE_ANSWER: u64 = 1;
    const ENERGY_VOTE_COMMENT: u64 = 1;
    const ENERGY_FORUM_VOTE_CANCEL: u64 = 1;
    const ENERGY_POST_QUESTION: u64 = 10;
    const ENERGY_POST_ANSWER: u64 = 6;
    const ENERGY_POST_COMMENT: u64 = 4;
    const ENERGY_MODIFY_ITEM: u64 = 2;
    const ENERGY_DELETE_ITEM: u64 = 2;

    const ENERGY_MARK_REPLY_AS_CORRECT: u64 = 1;
    const ENERGY_UPDATE_PROFILE: u64 = 1;
    const ENERGY_FOLLOW_COMMUNITY: u64 = 1;

    /// A shared user.
    struct UserCollection has key {
        id: UID,
        users: VecMap<address, User>,               // key - userAddress        
        periodRewardContainer: PeriodRewardContainer,
    }

    struct User has store, drop, copy {     // copy?
        ipfsDoc: commonLib::IpfsHash,
        owner: address,
        energy: u64,
        lastUpdatePeriod: u64,
        followedCommunities: vector<u64>,
        userCommunityRating: CommunityRatingForUser,
        // TODO: add roles                       // add userRatingCollection, periodRewardContainer, achievementsContainer ?
    }

    struct UserTest has key, store {  // del
        id: UID,
        owner: address,
        energy: u64,
    }

    struct UserTestt has key {  // del
        id: UID,
        owner: address,
        energy: u64,
    }

    struct CommunityRatingForUser has store, drop, copy {
        userRating: VecMap<u64, i64Lib::I64>,               // key - communityId        
        userPeriodRewards: VecMap<u64, UserPeriodRewards>,  // key - period
    }

    struct DataUpdateUserRating has drop {
        ratingToReward: u64,
        penalty: u64,
        changeRating: i64Lib::I64,
        ratingToRewardChange: i64Lib::I64
    }

    struct UserPeriodRewards has store, drop, copy {
        periodRating: VecMap<u64, PeriodRating>,          // key - communityId
    }

    struct PeriodRating has store, drop, copy {
        ratingToReward: u64,
        penalty: u64,
    }

    struct PeriodRewardContainer has store {
        periodRewardShares: VecMap<u64, PeriodRewardShares>,          // key - period
    }

    struct PeriodRewardShares has store {
        totalRewardShares: u64,
        activeUsersInPeriod: vector<address>,
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(UserCollection {
            id: object::new(ctx),
            users: vec_map::empty(),
            periodRewardContainer: PeriodRewardContainer {
                periodRewardShares: vec_map::empty(),
            }
        });
    }

    #[test_only]    // call?
    public fun init_test(ctx: &mut TxContext) {
        init(ctx)
    }

    public entry fun createUser(userCollection: &mut UserCollection, ipfsDoc: vector<u8>, ctx: &mut TxContext) {
        let owner = tx_context::sender(ctx);

        createUserPrivate(userCollection, owner, ipfsDoc)
    }

    entry fun createUserPrivate(userCollection: &mut UserCollection, userAddress: address, ipfsHash: vector<u8>) {
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIphsHash()); // TODO: TEST
        assert!(!isExists(userCollection, userAddress), E_USER_EXIST); // TODO: TEST

        vec_map::insert(&mut userCollection.users, userAddress, User {
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            owner: userAddress,
            energy: getStatusEnergy(),
            lastUpdatePeriod: commonLib::getPeriod(),
            followedCommunities: vector::empty<u64>(),
            userCommunityRating: CommunityRatingForUser {
                userRating: vec_map::empty(),
                userPeriodRewards: vec_map::empty(),
            }
        });

        // updateRatingBase(userCollection, owner, i64Lib::from(9), 1);      // del
    }

    public entry fun createIfDoesNotExist(userCollection: &mut UserCollection, userAddress: address) {
        if (!isExists(userCollection, userAddress)) {
            createUserPrivate(userCollection, userAddress, DEFAULT_IPFS);
        }
    }

    public entry fun updateUser(userCollection: &mut UserCollection, ipfsDoc: vector<u8>, ctx: &mut TxContext) {
        let userAddress = tx_context::sender(ctx);
        createIfDoesNotExist(userCollection, userAddress);
        updateUserPrivate(userCollection, userAddress, ipfsDoc);
    }

    entry fun updateUserPrivate(userCollection: &mut UserCollection, userAddress: address, ipfsHash: vector<u8>) {
        let user = checkRatingAndEnergy(
            userCollection,
            userAddress,
            userAddress,
            0,
            ACTION_UPDATE_PROFILE
        );
        user.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
    }

    entry fun updateUserTest(userTest: &mut UserTest) { // del
        userTest.energy = 3;
    }

    entry fun updateUserTestt(userTest: &mut UserTestt) { // del
        userTest.energy = 3;
    }

    public entry fun followCommunity(communityCollection: &mut communityLib::CommunityCollection, userCollection: &mut UserCollection, communityId: u64, ctx: &mut TxContext) {
        communityLib::onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        let userAddress = tx_context::sender(ctx);
        let user = checkRatingAndEnergy(
            userCollection,
            userAddress,
            userAddress,
            0,
            ACTION_FOLLOW_COMMUNITY
        );

        let i = 0;
        while(i < vector::length(&mut user.followedCommunities)) {
            assert!(*vector::borrow(&user.followedCommunities, i) != communityId, E_ALREADY_FOLLOWED);
            i = i +1;
        };

        vector::push_back(&mut user.followedCommunities, communityId);
    }

    public entry fun unfollowCommunity(communityCollection: &mut communityLib::CommunityCollection, userCollection: &mut UserCollection, communityId: u64, ctx: &mut TxContext) {
        communityLib::onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        let userAddress = tx_context::sender(ctx);
        let user = checkRatingAndEnergy(
            userCollection,
            userAddress,
            userAddress,
            0,
            ACTION_FOLLOW_COMMUNITY
        );

        let i = 0;
        while(i < vector::length(&mut user.followedCommunities)) {
            if(*vector::borrow(&user.followedCommunities, i) == communityId) {
                vector::remove(&mut user.followedCommunities, i);
                return
            };
            i = i +1;
        };
        abort E_COMMUNITY_NOT_FOLOWED
    }

    public fun getStatusEnergy(): u64 {
        1000
    }

    public fun isExists(userCollection: &mut UserCollection, userAddress: address): bool { 
        let position = vec_map::get_idx_opt(&mut userCollection.users, &userAddress);
        !option::is_none(&position)
    }

    public fun getUser(userCollection: &mut UserCollection, userAddress: address): User {
        let position = vec_map::get_idx_opt(&mut userCollection.users, &userAddress);
        if (option::is_none(&position)) {
            abort E_USER_DOES_NOT_EXIST
        } else {
            // TODO: add
            // let user = vec_map::get(&userCollection.users, &userAddress);
            // user
            let user = vec_map::get_mut(&mut userCollection.users, &userAddress);
            *user
        }
    }

    public fun getMutableUser(userCollection: &mut UserCollection, userAddress: address): &mut User {
        let position = vec_map::get_idx_opt(&mut userCollection.users, &userAddress);
        if (option::is_none(&position)) {
            abort E_USER_DOES_NOT_EXIST
        } else {
            let user = vec_map::get_mut(&mut userCollection.users, &userAddress);
            user
        }
    }

    // public fun testError(userCollection: &mut UserCollection, userAddr: address) {
    //     let user: &mut User = getMutableUser(userCollection, userAddr);
    //     let userCommunityRating = &mut user.userCommunityRating;
        
    //     vector::push_back(&mut userCollection.periodRewardContainer.periodRewardSharesPosition, 1);
    //     vector::borrow(&userCollection.users, 1);
        
    //     let _rewardPeriods = vector::borrow(&userCommunityRating.rewardPeriods, 1);
    // }

    // public fun testErrorFix(userCollection: &mut UserCollection, userAddr: address) {
    //     let user: &mut User = getMutableUser(userCollection, userAddr);
    //     let userCommunityRating = &mut user.userCommunityRating;
        
    //     let copyUserCommunityRating = *userCommunityRating;
    //     vector::push_back(&mut userCollection.periodRewardContainer.periodRewardSharesPosition, 1);
    //     vector::borrow(&userCollection.users, 1);
        
    //     let _rewardPeriods = vector::borrow(&copyUserCommunityRating.rewardPeriods, 1);
    // }

    // public fun testErrorFix2(userCollection: &mut UserCollection, userAddr: address) {
    //     let user: &mut User = getMutableUser(userCollection, userAddr);
    //     let userCommunityRating = &mut user.userCommunityRating;

    //     let _rewardPeriods = vector::borrow(&userCommunityRating.rewardPeriods, 1);
    //     vector::push_back(&mut userCollection.periodRewardContainer.periodRewardSharesPosition, 1);
    //     let _periodRewardShares = vector::borrow(&userCollection.users, 1);
        
    // }

    // public fun testError2(userCollection: &mut UserCollection, userAddr: address) {
    //     let user: &mut User = getMutableUser(userCollection, userAddr);
    //     let userCommunityRating = &mut user.userCommunityRating;
    //     let copyUserCommunityRating = *userCommunityRating;

    //     vector::push_back(&mut userCollection.periodRewardContainer.periodRewardSharesPosition, 1);
    //     vector::borrow(&userCollection.users, 1);
    //     vector::borrow(&copyUserCommunityRating.rewardPeriods, 1);
    // }

    // public fun testError2(userCollection: &mut UserCollection, userAddr: address) {
    //     let user: &mut User = getMutableUser(userCollection, userAddr);
    //     let userCommunityRating = &mut user.userCommunityRating;
    //     vector::push_back(&mut userCollection.periodRewardContainer.periodRewardSharesPosition, 1);
    //     vector::push_back(&mut userCommunityRating.rewardPeriods, 1);
    // }

    // public fun testError2Fix(userCollection: &mut UserCollection, userAddr: address) {
    //     vector::push_back(&mut userCollection.periodRewardContainer.periodRewardSharesPosition, 1);
    //     testLo(userCollection, userAddr);
    // }

    // public fun testLo(userCollection: &mut UserCollection, userAddr: address) {
    //     let user: &mut User = getMutableUser(userCollection, userAddr);
    //     let userCommunityRating = &mut user.userCommunityRating;
    //     vector::push_back(&mut userCommunityRating.rewardPeriods, 1)
    // }


    public fun updateRatingBase(userCollection: &mut UserCollection, userAddr: address, rating: i64Lib::I64, communityId: u64) {
        let currentPeriod: u64 = commonLib::getPeriod();
        let user: &mut User = getMutableUser(userCollection, userAddr);

        let userCommunityRating = &mut user.userCommunityRating;
        // Initialize user rating in the community if this is the first rating change
        let position = vec_map::get_idx_opt(&mut userCommunityRating.userRating, &communityId);
        if (option::is_none(&position)) {
            vec_map::insert(&mut userCommunityRating.userRating, communityId, i64Lib::from(START_USER_RATING));
        };
        let copyUserCommunityRating = *userCommunityRating;
        
        let pastPeriodsCount: u64 = vec_map::size(&mut userCommunityRating.userPeriodRewards);      // move down?

        if (!vec_map::contains(&userCollection.periodRewardContainer.periodRewardShares, &currentPeriod)) {
            vec_map::insert(&mut userCollection.periodRewardContainer.periodRewardShares, currentPeriod, PeriodRewardShares { totalRewardShares: 0, activeUsersInPeriod: vector::empty<address>() });
        };

        let isFirstTransactionInPeriod = false;
        // If this is the first user rating change in any community
        
        ////
        // TODO: add split 1 f (pastPeriodsCount == 0 || *vector::borrow(&copyUserCommunityRating.rewardPeriods, pastPeriodsCount - 1) != currentPeriod) {
        // mb back to 1 if
        ////
        if (pastPeriodsCount == 0) {
            isFirstTransactionInPeriod = true;
        } else {
            let (key, _) = vec_map::get_entry_by_idx(&copyUserCommunityRating.userPeriodRewards, pastPeriodsCount - 1);
            if (key != &currentPeriod) {
                isFirstTransactionInPeriod = true;
            }
        };

        if (isFirstTransactionInPeriod) {
            let periodRewardShares = vec_map::get_mut(&mut userCollection.periodRewardContainer.periodRewardShares, &currentPeriod);
            vector::push_back(&mut periodRewardShares.activeUsersInPeriod, userAddr);
            pushUserRewardPeriods(userCollection, currentPeriod, userAddr, communityId);         // TODO: add, what?
        } else {  // rewrite
            pastPeriodsCount = pastPeriodsCount - 1;

            isFirstTransactionInPeriod = pushUserRewardCommunity(userCollection, currentPeriod, userAddr, communityId);
        };

        let _previousPeriod = 0;    // TODO: add Unused parameter 'previousPeriod'. Consider removing or prefixing with an underscore: '_previousPeriod'?
        if (pastPeriodsCount > 0) {
            let (key, _) = vec_map::get_entry_by_idx(&copyUserCommunityRating.userPeriodRewards, pastPeriodsCount - 1);
            _previousPeriod = *key;
        } else {
            // this means that there is no other previous period
            _previousPeriod = currentPeriod;
        };

        
        updateUserPeriodRating(userCollection, userAddr, rating, communityId, currentPeriod, _previousPeriod, isFirstTransactionInPeriod);

        changeUserRating(userCollection, userAddr, communityId, rating);

        // if (rating > 0) {
        //     AchievementLib.updateUserAchievements(userContext.achievementsContainer, userAddr, AchievementCommonLib.AchievementsType.Rating, int64(userCommunityRating.userRating[communityId].rating));
        // }
    }

    fun changeUserRating(userCollection: &mut UserCollection, userAddr: address, communityId: u64, rating: i64Lib::I64) {
        let user: &mut User = getMutableUser(userCollection, userAddr);

        let userRating = vec_map::get_mut(&mut user.userCommunityRating.userRating, &communityId);
        *userRating = i64Lib::add(&*userRating, &rating);
    }


    fun pushUserRewardPeriods(userCollection: &mut UserCollection, currentPeriod: u64, userAddr: address, communityId: u64) {
        let user: &mut User = getMutableUser(userCollection, userAddr);
        let mapPeriodRating: VecMap<u64, PeriodRating> = vec_map::empty();
        vec_map::insert(&mut mapPeriodRating, communityId, PeriodRating{ ratingToReward: 0, penalty: 0 });

        vec_map::insert(&mut user.userCommunityRating.userPeriodRewards, currentPeriod, UserPeriodRewards{ periodRating: mapPeriodRating});

    }

    fun pushUserRewardCommunity(userCollection: &mut UserCollection, currentPeriod: u64, userAddr: address, communityId: u64): bool { // TODO: add name
        let user: &mut User = getMutableUser(userCollection, userAddr);
        
        let userPeriodRewards = vec_map::get_mut(&mut user.userCommunityRating.userPeriodRewards, &currentPeriod);
        if (!vec_map::contains(&userPeriodRewards.periodRating, &communityId)) {
            vec_map::insert(&mut userPeriodRewards.periodRating, communityId, PeriodRating{ ratingToReward: 0, penalty: 0 });
            true
        } else {
            false
        }
    }

    fun getPeriodRating(userCollection: &mut UserCollection, userAddr: address, period: u64, communityId: u64): &mut PeriodRating {
        let user: &mut User = getMutableUser(userCollection, userAddr);
        // let (isExist, positionCarentPeriod) = vector::index_of(&user.userCommunityRating.rewardPeriods, &period);   // userPeriodRewards
        // if (!isExist) abort 97; // todo!!!!
        // let userPeriodRewards = vector::borrow_mut(&mut user.userCommunityRating.userPeriodRewards, positionCarentPeriod);

        let userPeriodRewards = vec_map::get_mut(&mut user.userCommunityRating.userPeriodRewards, &period);

        // let (isExistRewardCommunities, positionRewardCommunities) = vector::index_of(&userPeriodRewards.rewardCommunities, &communityId);
        // if (!isExistRewardCommunities) abort 98;  // todo!!!!??
        // vector::borrow_mut(&mut userPeriodRewards.periodRating, positionRewardCommunities)

        vec_map::get_mut(&mut userPeriodRewards.periodRating, &communityId)
    }

    fun updatePeriodRating(userCollection: &mut UserCollection, userAddr: address, period: u64, communityId: u64, penalty: u64, ratingToReward: u64) {
        let periodRating = getPeriodRating(userCollection, userAddr, period, communityId);
        if (penalty != 0)
            periodRating.penalty = penalty;
        if (ratingToReward != 0)
            periodRating.ratingToReward = ratingToReward;
    }

    fun updateUserPeriodRating(userCollection: &mut UserCollection, userAddr: address, rating: i64Lib::I64, communityId: u64, currentPeriod: u64, previousPeriod: u64, isFirstTransactionInPeriod: bool ) {
        // RewardLib.PeriodRating storage currentPeriodRating = userCommunityRating.userPeriodRewards[currentPeriod].periodRating[communityId];
        // bool isFirstTransactionInPeriod = !currentPeriodRating.isActive;
        let currentPeriodRating: PeriodRating = *getPeriodRating(userCollection, userAddr, currentPeriod, communityId);

        let dataUpdateUserRatingCurrentPeriod: DataUpdateUserRating = DataUpdateUserRating {
            ratingToReward: currentPeriodRating.ratingToReward,
            penalty: currentPeriodRating.penalty,
            changeRating: i64Lib::zero(),
            ratingToRewardChange: i64Lib::zero()
        };

        if (currentPeriod == previousPeriod) {   //first period rating?
            dataUpdateUserRatingCurrentPeriod.changeRating = rating;

        } else {
            let previousPeriodRating: &mut PeriodRating = getPeriodRating(userCollection, userAddr, previousPeriod, communityId);

            let dataUpdateUserRatingPreviousPeriod: DataUpdateUserRating = DataUpdateUserRating {
                ratingToReward: previousPeriodRating.ratingToReward,
                penalty: previousPeriodRating.penalty,
                changeRating: i64Lib::zero(),
                ratingToRewardChange: i64Lib::zero()
            };

            if (previousPeriod != currentPeriod - 1) {
                if (isFirstTransactionInPeriod && dataUpdateUserRatingPreviousPeriod.penalty > dataUpdateUserRatingPreviousPeriod.ratingToReward) {
                    dataUpdateUserRatingCurrentPeriod.changeRating = i64Lib::sub(&i64Lib::add(&rating, &i64Lib::from(dataUpdateUserRatingPreviousPeriod.ratingToReward)), &i64Lib::from(dataUpdateUserRatingPreviousPeriod.penalty));
                } else {
                    dataUpdateUserRatingCurrentPeriod.changeRating = rating;
                }
            } else {
                if (isFirstTransactionInPeriod && dataUpdateUserRatingPreviousPeriod.penalty > dataUpdateUserRatingPreviousPeriod.ratingToReward) {
                    dataUpdateUserRatingCurrentPeriod.changeRating = i64Lib::sub(&i64Lib::from(dataUpdateUserRatingPreviousPeriod.ratingToReward), &i64Lib::from(dataUpdateUserRatingPreviousPeriod.penalty));
                };

                // int32 differentRatingCurrentPeriod;
                if (i64Lib::compare(&rating, &i64Lib::zero()) == i64Lib::getGreaterThan() && dataUpdateUserRatingPreviousPeriod.penalty > 0) {
                    if (dataUpdateUserRatingPreviousPeriod.ratingToReward == 0) {
                        dataUpdateUserRatingCurrentPeriod.changeRating = i64Lib::add(&dataUpdateUserRatingCurrentPeriod.changeRating, &rating);
                    } else {
                        let differentRatingPreviousPeriod: i64Lib::I64 = i64Lib::sub(&rating, &i64Lib::from(dataUpdateUserRatingPreviousPeriod.penalty));       // name
                        if (i64Lib::compare(&differentRatingPreviousPeriod, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&differentRatingPreviousPeriod, &i64Lib::zero()) == i64Lib::getEual()) { // differentRatingPreviousPeriod >= 0
                            dataUpdateUserRatingPreviousPeriod.changeRating = i64Lib::from(dataUpdateUserRatingPreviousPeriod.penalty);
                            dataUpdateUserRatingCurrentPeriod.changeRating = differentRatingPreviousPeriod;
                        } else {
                            dataUpdateUserRatingPreviousPeriod.changeRating = rating;
                        };
                    };
                } else if (i64Lib::compare(&rating, &i64Lib::zero()) == i64Lib::getLessThan() && dataUpdateUserRatingPreviousPeriod.ratingToReward > dataUpdateUserRatingPreviousPeriod.penalty) {

                    let differentRatingCurrentPeriod = i64Lib::sub(&i64Lib::from(dataUpdateUserRatingCurrentPeriod.penalty), &rating);   // penalty is always positive, we need add rating to penalty
                    if (i64Lib::compare(&differentRatingCurrentPeriod, &i64Lib::from(dataUpdateUserRatingCurrentPeriod.ratingToReward)) == i64Lib::getGreaterThan()) {
                        dataUpdateUserRatingCurrentPeriod.changeRating = i64Lib::sub(&dataUpdateUserRatingCurrentPeriod.changeRating, &i64Lib::sub(&i64Lib::from(dataUpdateUserRatingCurrentPeriod.ratingToReward), &i64Lib::from(dataUpdateUserRatingCurrentPeriod.penalty)));  // - current ratingToReward
                        dataUpdateUserRatingPreviousPeriod.changeRating = i64Lib::sub(&rating, &dataUpdateUserRatingCurrentPeriod.changeRating);                                       // + previous penalty
                        if (i64Lib::compare(&i64Lib::from(dataUpdateUserRatingPreviousPeriod.ratingToReward), &i64Lib::sub(&i64Lib::from(dataUpdateUserRatingPreviousPeriod.penalty), &dataUpdateUserRatingPreviousPeriod.changeRating)) == i64Lib::getLessThan()) {
                            let extraPenalty: i64Lib::I64 = i64Lib::sub(&i64Lib::from(dataUpdateUserRatingPreviousPeriod.penalty), &i64Lib::sub(&i64Lib::from(dataUpdateUserRatingPreviousPeriod.ratingToReward), &dataUpdateUserRatingPreviousPeriod.changeRating));
                            dataUpdateUserRatingPreviousPeriod.changeRating = i64Lib::add(&dataUpdateUserRatingPreviousPeriod.changeRating, &extraPenalty);  // - extra previous penalty
                            dataUpdateUserRatingCurrentPeriod.changeRating = i64Lib::sub(&dataUpdateUserRatingCurrentPeriod.changeRating, &extraPenalty);   // + extra current penalty
                        }
                    } else {
                        dataUpdateUserRatingCurrentPeriod.changeRating = rating;
                        // dataUpdateUserRatingCurrentPeriod.changeRating += 0;
                    };
                } else {
                    dataUpdateUserRatingCurrentPeriod.changeRating = i64Lib::add(&dataUpdateUserRatingCurrentPeriod.changeRating, &rating);
                };
            };

            if (i64Lib::compare(&dataUpdateUserRatingPreviousPeriod.changeRating, &i64Lib::zero()) != i64Lib::getEual()) {
                if (i64Lib::compare(&dataUpdateUserRatingPreviousPeriod.changeRating, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                    previousPeriodRating.penalty = previousPeriodRating.penalty - i64Lib::as_u64(&dataUpdateUserRatingPreviousPeriod.changeRating);
                } else {
                    previousPeriodRating.penalty = previousPeriodRating.penalty + i64Lib::as_u64(&i64Lib::mul(&dataUpdateUserRatingPreviousPeriod.changeRating, &i64Lib::neg_from(1)));     // previousPeriodRating.penalty += -dataUpdateUserRatingPreviousPeriod.changeRating;
                };

                dataUpdateUserRatingPreviousPeriod.ratingToRewardChange = getRatingToRewardChange(i64Lib::sub(&i64Lib::from(dataUpdateUserRatingPreviousPeriod.ratingToReward), &i64Lib::from(dataUpdateUserRatingPreviousPeriod.penalty)), i64Lib::add(&i64Lib::sub(&i64Lib::from(dataUpdateUserRatingPreviousPeriod.ratingToReward), &i64Lib::from(dataUpdateUserRatingPreviousPeriod.penalty)), &dataUpdateUserRatingPreviousPeriod.changeRating));
                if (i64Lib::compare(&dataUpdateUserRatingPreviousPeriod.ratingToRewardChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                    let periodRewardShares = getMutableTotalRewardShares(userCollection, previousPeriod);
                    periodRewardShares.totalRewardShares = periodRewardShares.totalRewardShares + i64Lib::as_u64(&getRewardShare(userAddr, previousPeriod, dataUpdateUserRatingPreviousPeriod.ratingToRewardChange));
                } else {
                    let periodRewardShares = getMutableTotalRewardShares(userCollection, previousPeriod);
                    periodRewardShares.totalRewardShares = periodRewardShares.totalRewardShares - i64Lib::as_u64(&i64Lib::mul(&getRewardShare(userAddr, previousPeriod, dataUpdateUserRatingPreviousPeriod.ratingToRewardChange), &i64Lib::neg_from(1)));
                };
            };
        };      // +

        if (i64Lib::compare(&dataUpdateUserRatingCurrentPeriod.changeRating, &i64Lib::zero()) != i64Lib::getEual()) {
            dataUpdateUserRatingCurrentPeriod.ratingToRewardChange = getRatingToRewardChange(i64Lib::sub(&i64Lib::from(dataUpdateUserRatingCurrentPeriod.ratingToReward), &i64Lib::from(dataUpdateUserRatingCurrentPeriod.penalty)), i64Lib::add(&i64Lib::sub(&i64Lib::from(dataUpdateUserRatingCurrentPeriod.ratingToReward), &i64Lib::from(dataUpdateUserRatingCurrentPeriod.penalty)), &dataUpdateUserRatingCurrentPeriod.changeRating));
            if (i64Lib::compare(&dataUpdateUserRatingCurrentPeriod.ratingToRewardChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {    // neg?   i64Lib::compare(&dataUpdateUserRatingCurrentPeriod.ratingToRewardChange, &i64Lib::zero()) == i64Lib::getGreaterThan()  //
                let periodRewardShares = getMutableTotalRewardShares(userCollection, currentPeriod);
                periodRewardShares.totalRewardShares = periodRewardShares.totalRewardShares + i64Lib::as_u64(&getRewardShare(userAddr, currentPeriod, dataUpdateUserRatingCurrentPeriod.ratingToRewardChange));
            } else {
                let periodRewardShares = getMutableTotalRewardShares(userCollection, currentPeriod);
                periodRewardShares.totalRewardShares = periodRewardShares.totalRewardShares - i64Lib::as_u64(&i64Lib::mul(&getRewardShare(userAddr, currentPeriod, dataUpdateUserRatingCurrentPeriod.ratingToRewardChange), &i64Lib::neg_from(1)));
            };

            let _changeRating: i64Lib::I64 = i64Lib::zero();     // TODD: add Unused assignment or binding for local 'changeRating'. Consider removing, replacing with '_', or prefixing with '_' (e.g., '_changeRating')
            if (i64Lib::compare(&dataUpdateUserRatingCurrentPeriod.changeRating, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                _changeRating = i64Lib::sub(&dataUpdateUserRatingCurrentPeriod.changeRating, &i64Lib::from(dataUpdateUserRatingCurrentPeriod.penalty));
                if (i64Lib::compare(&_changeRating, &i64Lib::zero()) != i64Lib::getLessThan()) {
                    updatePeriodRating(userCollection, userAddr, currentPeriod, communityId, 0, i64Lib::as_u64(&_changeRating) + currentPeriodRating.ratingToReward);
                } else {
                    updatePeriodRating(userCollection, userAddr, currentPeriod, communityId, i64Lib::as_u64(&i64Lib::mul(&_changeRating, &i64Lib::neg_from(1))), currentPeriodRating.ratingToReward);
                };

            } else if (i64Lib::compare(&dataUpdateUserRatingCurrentPeriod.changeRating, &i64Lib::zero()) == i64Lib::getLessThan()) {
                _changeRating = i64Lib::add(&i64Lib::from(dataUpdateUserRatingCurrentPeriod.ratingToReward), &dataUpdateUserRatingCurrentPeriod.changeRating);
                if (i64Lib::compare(&_changeRating, &i64Lib::zero()) != i64Lib::getGreaterThan()) {
                    updatePeriodRating(userCollection, userAddr, currentPeriod, communityId, i64Lib::as_u64(&i64Lib::mul(&_changeRating, &i64Lib::neg_from(1))) + currentPeriodRating.penalty, 0);
                } else {
                    updatePeriodRating(userCollection, userAddr, currentPeriod, communityId, currentPeriodRating.penalty, i64Lib::as_u64(&_changeRating));
                };
            };
        };
    }

    // TODO: add UserLib.Action action + add field UserLib.ActionRole actionRole
    public fun checkActionRole(
        userCollection: &mut UserCollection,
        actionCaller: address,
        dataUser: address,
        communityId: u64,
        action: u8,
        createUserIfDoesNotExist: bool
    ) 
    {
        // TODO: add 
        // require(msg.sender == address(userContext.peeranhaContent) || msg.sender == address(userContext.peeranhaCommunity), "internal_call_unauthorized");
       
        if (createUserIfDoesNotExist) {
            createIfDoesNotExist(userCollection, actionCaller);
        } else {
            checkUser(userCollection, actionCaller);        // need?
        };

        // TODO: add 
        // if (hasModeratorRole(actionCaller, communityId)) {
        //     return;
        // }
                
        // checkHasRole(actionCaller, actionRole, communityId);
        checkRatingAndEnergy(userCollection, actionCaller, dataUser, communityId, action);
    }

    public fun checkRatingAndEnergy(
        userCollection: &mut UserCollection,
        actionCaller: address,
        dataUser: address,
        communityId: u64,
        action: u8
    ): &mut User // &mut?
    {
        let user = getMutableUser(userCollection, actionCaller);
        let userRating = getUserRating(*user, communityId);
            
        let (ratingAllowed, message, energy) = getRatingAndEnergyForAction(actionCaller, dataUser, action);
        assert!(i64Lib::compare(&userRating, &ratingAllowed) != i64Lib::getLessThan(), message);
        reduceEnergy(user, energy);

        user
    }

    fun getRatingAndEnergyForAction(
        actionCaller: address,
        dataUser: address,
        action: u8
    ): (i64Lib::I64, u64, u64) { // ratingAllowed, message, energy
        let ratingAllowed: i64Lib::I64 = i64Lib::zero();
        let message: u64 = E_CHECK_FUNCTION_getRatingAndEnergyForAction;
        let energy: u64 = 0;

        if (action == ACTION_NONE) {
        } else if (action == ACTION_PUBLICATION_POST) {
            ratingAllowed = i64Lib::from(POST_QUESTION_ALLOWED);
            // message = "low_rating_post";
            energy = ENERGY_POST_QUESTION;

        } else if (action == ACTION_PUBLICATION_REPLY) {
            ratingAllowed = i64Lib::from(POST_REPLY_ALLOWED);
            // message = "low_rating_reply";
            energy = ENERGY_POST_ANSWER;

        } else if (action == ACTION_PUBLICATION_COMMNET) {
            if (actionCaller == dataUser) {
                ratingAllowed = i64Lib::from(POST_OWN_COMMENT_ALLOWED);
            } else {
                ratingAllowed = i64Lib::from(POST_COMMENT_ALLOWED);
            };
            // message = "low_rating_comment";
            energy = ENERGY_POST_COMMENT;

        } else if (action == ACTION_EDIT_ITEM) {
            assert!(actionCaller == dataUser, E_NOT_ALLOWED_EDIT);
            ratingAllowed = i64Lib::neg_from(MINIMUM_RATING);
            // message = "low_rating_edit";
            energy = ENERGY_MODIFY_ITEM;

        } else if (action == ACTION_DELETE_ITEM) {
            assert!(actionCaller == dataUser, E_NOT_ALLOWED_DELETE);
            ratingAllowed = i64Lib::zero();
            // message = "low_rating_delete"; // delete own item?
            energy = ENERGY_DELETE_ITEM;

        } else if (action == ACTION_UPVOTE_POST) {
            assert!(actionCaller != dataUser, E_NOT_ALLOWED_VOTE_POST);
            ratingAllowed = i64Lib::from(UPVOTE_POST_ALLOWED);
            // message = "low_rating_upvote";       // TODO unittests
            energy = ENERGY_UPVOTE_QUESTION;

        } else if (action == ACTION_UPVOTE_REPLY) {
            assert!(actionCaller != dataUser, E_NOT_ALLOWED_VOTE_REPLY);
            ratingAllowed = i64Lib::from(UPVOTE_REPLY_ALLOWED);
            // message = "low_rating_upvote_post";
            energy = ENERGY_UPVOTE_ANSWER;

        } else if (action == ACTION_VOTE_COMMENT) {
            assert!(actionCaller != dataUser, E_NOT_ALLOWED_VOTE_COMMENT);
            ratingAllowed = i64Lib::from(VOTE_COMMENT_ALLOWED);
            // message = "low_rating_vote_comment";
            energy = ENERGY_VOTE_COMMENT;

        } else if (action == ACTION_DOWNVOTE_POST) {
            assert!(actionCaller != dataUser, E_NOT_ALLOWED_VOTE_POST);
            ratingAllowed = i64Lib::from(DOWNVOTE_POST_ALLOWED);
            // message = "low_rating_downvote_post";
            energy = ENERGY_DOWNVOTE_QUESTION;

        } else if (action == ACTION_DOWNVOTE_REPLY) {
            assert!(actionCaller != dataUser, DOWNVOTE_REPLY_ALLOWED);
            ratingAllowed = i64Lib::from(DOWNVOTE_REPLY_ALLOWED);
            // message = "low_rating_downvote_reply";
            energy = ENERGY_DOWNVOTE_ANSWER;

        } else if (action == ACTION_CANCEL_VOTE) {
            ratingAllowed = i64Lib::from(CANCEL_VOTE);
            // message = "low_rating_cancel_vote";
            energy = ENERGY_FORUM_VOTE_CANCEL;

        } else if (action == ACTION_BEST_REPLY) {
            ratingAllowed = i64Lib::neg_from(MINIMUM_RATING);
            // message = "low_rating_mark_best";
            energy = ENERGY_MARK_REPLY_AS_CORRECT;

        } else if (action == ACTION_UPDATE_PROFILE) {
            energy = ENERGY_UPDATE_PROFILE;
            // message = "low_update_profile";   //TODO uniTest

        } else if (action == ACTION_FOLLOW_COMMUNITY) {
            ratingAllowed = i64Lib::neg_from(MINIMUM_RATING);
            // message = "low_rating_follow_comm";
            energy = ENERGY_FOLLOW_COMMUNITY;

        } else {
            abort E_NOT_ALLOWED_ACTION
        };
        (ratingAllowed, message, energy)
    }

    fun reduceEnergy(user: &mut User, energy: u64) {
        let currentPeriod: u64 = commonLib::getPeriod();
        let periodsHavePassed: u64 = currentPeriod - user.lastUpdatePeriod;

        let userEnergy: u64;
        if (periodsHavePassed == 0) {
            userEnergy = user.energy;
        } else {
            userEnergy = getStatusEnergy();
            user.lastUpdatePeriod = currentPeriod;
        };

        assert!(userEnergy >= energy, E_LOW_ENERGY);
        user.energy = userEnergy - energy;
    }

    fun checkUser(userCollection: &mut UserCollection, addr: address) {
        assert!(isExists(userCollection, addr), E_USER_NOT_FOUND);
    }

    fun getMutableTotalRewardShares(userCollection: &mut UserCollection, period: u64): &mut PeriodRewardShares {
        if (vec_map::contains(&userCollection.periodRewardContainer.periodRewardShares, &period)) {
            vec_map::get_mut(&mut userCollection.periodRewardContainer.periodRewardShares, &period)
        } else {
            abort E_CHECK_FUNCTION_getMutableTotalRewardShare   // TODO: add del
        }
    }

    public fun getUserRating(user: User, communityId: u64): i64Lib::I64 {   // public?
        let position = vec_map::get_idx_opt(&mut user.userCommunityRating.userRating, &communityId);
        if (option::is_none(&position)) {
            i64Lib::from(START_USER_RATING)
        } else {
            *vec_map::get(&user.userCommunityRating.userRating, &communityId)
        }
    }

    // TODO: add userCollection: &mut UserCollection 1-st argument
    fun getRewardShare(_userAddr: address, _period: u64, rating: i64Lib::I64): i64Lib::I64 { // FIX
        // TODO: add
        /*return CommonLib.toInt32FromUint256(userContext.peeranhaToken.getBoost(userAddr, period)) * */ rating
    }

    fun getRatingToRewardChange(previosRatingToReward: i64Lib::I64, newRatingToReward: i64Lib::I64): i64Lib::I64 {
        if (i64Lib::compare(&previosRatingToReward, &i64Lib::zero()) != i64Lib::getLessThan() && i64Lib::compare(&newRatingToReward, &i64Lib::zero()) != i64Lib::getLessThan()) i64Lib::sub(&newRatingToReward, &previosRatingToReward)     // previosRatingToReward >= 0 && newRatingToReward >= 0
        else if(i64Lib::compare(&previosRatingToReward, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&newRatingToReward, &i64Lib::zero()) == i64Lib::getLessThan()) i64Lib::mul(&previosRatingToReward, &i64Lib::neg_from(1))     // previosRatingToReward > 0 && newRatingToReward < 0
        else if(i64Lib::compare(&previosRatingToReward, &i64Lib::zero()) == i64Lib::getLessThan() && i64Lib::compare(&newRatingToReward, &i64Lib::zero()) == i64Lib::getGreaterThan()) newRatingToReward   // previosRatingToReward < 0 && newRatingToReward > 0
        else i64Lib::zero() // from negative to negative
    }

    // public entry fun mass_mint(recipients: vector<address>, ctx: &mut TxContext) {
    //     assert!(tx_context::sender(ctx) == CREATOR, EAuthFail);
    //     let i = 0;
    //     while (!vector::is_empty(recipients)) {
    //         let recipient = vector::pop_back(&mut recipients);
    //         let id = tx_context::new_id(ctx);
    //         let creation_date = tx_context::epoch(); // Sui epochs are 24 hours
    //         transfer(CoolAsset { id, creation_date }, recipient)
    //     }
    // }

    // public entry fun printUserCollection(userCollection: &mut UserCollection) {
    //     debug::print(userCollection);
    // }

    // public entry fun printUser(userCollection: &mut UserCollection, owner: address) {
    //     let (isExist, position) = vector::index_of(&mut userCollection.userAddress, &owner);
    //     debug::print(&isExist);
    //     debug::print(&position);

    //     if (isExist) {
    //         let user = vector::borrow(&mut userCollection.users, position);
    //         debug::print(user);
    //     }
    // }

    public fun getUserData(userCollection: &mut UserCollection, owner: address): (vector<u8>, address, u64, u64, vector<u64>) {
        let user = getUser(userCollection, owner);
        (commonLib::getIpfsHash(user.ipfsDoc), user.owner, user.energy, user.lastUpdatePeriod, user.followedCommunities)
    }

    public fun get_user_collection(userCollection: UserCollection): UserCollection {
        userCollection
    }
    
    
    #[test_only]
    public fun create_user(userCollection: &mut UserCollection, scenario: &mut TxContext) {
        createUser(userCollection, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", scenario);
    }
    
    #[test]
    fun test_create_user() {
        use sui::test_scenario;
        // let owner = @0xC0FFEE;
        let user1 = @0xA1;

        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;
        {
            init(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, user1);
        {
            let user_val = test_scenario::take_shared<UserCollection>(scenario);
            let userCollection = &mut user_val;

            createUser(userCollection, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", test_scenario::ctx(scenario));

            let (ipfsDoc, owner, energy, lastUpdatePeriod, followedCommunities) = getUserData(userCollection, user1);
            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(owner == @0xA1, 2);
            assert!(energy == 1000, 3);
            assert!(lastUpdatePeriod == 0, 4);
            assert!(followedCommunities == vector<u64>[], 5);

            // printUserCollection(userCollection);
            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_updateIPFS_user() {
        use sui::test_scenario;

        let user1 = @0xA1;
        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;
        {
            init(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, user1);
        {
            let user_val = test_scenario::take_shared<UserCollection>(scenario);
            let userCollection = &mut user_val;

            create_user(userCollection, test_scenario::ctx(scenario));
            updateUser(userCollection, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", test_scenario::ctx(scenario));

            let (ipfsDoc, owner, energy, lastUpdatePeriod, followedCommunities) = getUserData(userCollection, user1);
            assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
            assert!(owner == @0xA1, 2);
            assert!(energy == 1000 - ENERGY_UPDATE_PROFILE, 3);
            assert!(lastUpdatePeriod == 0, 4);
            assert!(followedCommunities == vector<u64>[], 5);

            test_scenario::return_shared(user_val);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_follow_community() {
        use sui::test_scenario;
        use basics::communityLib;

        let user1 = @0xA1;
        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;
        {
            init(test_scenario::ctx(scenario));
            communityLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, user1);
        {
            let user_val = test_scenario::take_shared<UserCollection>(scenario);
            let userCollection = &mut user_val;
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;

            create_user(userCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            followCommunity(communityCollection, userCollection, 1, test_scenario::ctx(scenario));

            let (ipfsDoc, owner, energy, lastUpdatePeriod, followedCommunities) = getUserData(userCollection, user1);
            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(owner == @0xA1, 2);
            assert!(energy == 1000 - ENERGY_FOLLOW_COMMUNITY, 3);
            assert!(lastUpdatePeriod == 0, 4);
            assert!(followedCommunities == vector<u64>[1], 5);

            test_scenario::return_shared(user_val);
            test_scenario::return_shared(community_val);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_unfollow_community() {
        use sui::test_scenario;
        use basics::communityLib;

        let user1 = @0xA1;
        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;
        {
            init(test_scenario::ctx(scenario));
            communityLib::init_test(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, user1);
        {
            let user_val = test_scenario::take_shared<UserCollection>(scenario);
            let userCollection = &mut user_val;
            let community_val = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
            let communityCollection = &mut community_val;

            create_user(userCollection, test_scenario::ctx(scenario));
            communityLib::create_community(communityCollection, test_scenario::ctx(scenario));
            followCommunity(communityCollection, userCollection, 1, test_scenario::ctx(scenario));
            unfollowCommunity(communityCollection, userCollection, 1, test_scenario::ctx(scenario));

            let (ipfsDoc, owner, energy, lastUpdatePeriod, followedCommunities) = getUserData(userCollection, user1);
            assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
            assert!(owner == @0xA1, 2);
            assert!(energy == 1000 - ENERGY_FOLLOW_COMMUNITY * 2, 3);
            assert!(lastUpdatePeriod == 0, 4);
            assert!(followedCommunities == vector<u64>[], 5);

            test_scenario::return_shared(user_val);
            test_scenario::return_shared(community_val);
        };
        test_scenario::end(scenario_val);
    }

    // x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1" - eGEyNjc1MzBmNDlmODI4MDIwMGVkZjMxM2VlN2FmNmI4MjdmMmE4YmNlMjg5Nzc1MWQwNmE4NDNmNjQ0OTY3YjE
    // x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82" - eDcwMWI2MTViYmRmYjlkZTY1MjQwYmMyOGJkMjFiYmMwZDk5NjY0NWEzZGQ1N2U3YjEyYmMyYmRmNmYxOTJjODI
    // x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6" - eDdjODUyMTE4Mjk0ZTUxZTY1MzcxMmE4MWUwNTgwMGY0MTkxNDE3NTFiZTU4ZjYwNWMzNzFlMTUxNDFiMDA3YTY
    // x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc" - eGMwOWIxOWY2NWFmZDBkZjYxMGM5MGVhMDAxMjBiY2NkMWZjMWI4YzZlN2NkYmU0NDAzNzZlZTEzZTE1NmE1YmM
}
