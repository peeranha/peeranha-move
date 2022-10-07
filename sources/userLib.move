module basics::userLib {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    // use std::debug;
    use basics::i64Lib;
    use basics::communityLib;
    use basics::commonLib;

    const START_USER_RATING: u64 = 10;

    /// A shared user.
    struct UserCollection has key {
        id: UID,
        users: vector<User>,
        userAddress: vector<address>,
        periodRewardContainer: PeriodRewardContainer,
    }

    struct User has store, drop {
        ipfsDoc: vector<u8>,
        owner: address,
        energy: u64,
        lastUpdatePeriod: u64,
        followedCommunities: vector<u64>,
        userCommunityRating: CommunityRatingForUser,
        // TODO: add roles                       // add userRatingCollection, periodRewardContainer, achievementsContainer ?
    }

    struct CommunityRatingForUser has store, drop, copy {
        userRatingCommunityId: vector<u64>,             // position key for userRating      // commity rating
        userRating: vector<i64Lib::I64>,                 // position - userRatingCommunityId  vector<UserRating>
        rewardPeriods: vector<u64>,                     // periods when the rating was changed  // period
        userPeriodRewards: vector<UserPeriodRewards>,   // position - rewardPeriods
    }

    struct UserRating has store {
        rating: i64Lib::I64,
        // isActive: bool
    }

    struct DataUpdateUserRating has drop {
        ratingToReward: u64,
        penalty: u64,
        changeRating: i64Lib::I64,
        ratingToRewardChange: i64Lib::I64
    }

    struct UserPeriodRewards has store, drop, copy {
        rewardCommunities: vector<u64>,             // position key for periodRating    // communityId
        periodRating: vector<PeriodRating>,         // position - rewardCommunities
    }

    struct PeriodRating has store, drop, copy {
        ratingToReward: u64,
        penalty: u64,
        // isActive: bool
    }

    struct PeriodRewardContainer has store {
        periodRewardSharesPosition: vector<u64>,                // period - position key for periodRewardShares
        periodRewardShares: vector<PeriodRewardShares>,         // position - periodRewardSharesPosition
    }

    struct PeriodRewardShares has store {
        totalRewardShares: u64,
        activeUsersInPeriod: vector<address>,
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(UserCollection {
            id: object::new(ctx),
            users: vector::empty<User>(),
            userAddress: vector::empty<address>(),
            periodRewardContainer: PeriodRewardContainer { 
                periodRewardSharesPosition: vector::empty<u64>(),
                periodRewardShares: vector::empty<PeriodRewardShares>()
            }
        });
    }

    public entry fun createUser(userCollection: &mut UserCollection, owner: address, ipfsDoc: vector<u8>) {
        vector::push_back(&mut userCollection.users, User {
            ipfsDoc: ipfsDoc,
            owner: owner,
            energy: getStatusEnergy(),
            lastUpdatePeriod: 0,                     // TODO: add getPeriod()
            followedCommunities: vector::empty<u64>(),
            userCommunityRating: CommunityRatingForUser {
                userRatingCommunityId: vector::empty<u64>(),
                userRating: vector::empty<i64Lib::I64>(),
                rewardPeriods: vector::empty<u64>(),
                userPeriodRewards: vector::empty<UserPeriodRewards>() 
            }
        });

        vector::push_back(&mut userCollection.userAddress, owner);

        updateRatingBase(userCollection, owner, i64Lib::from(9), 1)      // del
    }

    public entry fun updateUser(userCollection: &mut UserCollection, owner: address, ipfsDoc: vector<u8>) {
        let user = getMutableUser(userCollection, owner);
        user.ipfsDoc = ipfsDoc;
    }

    public entry fun followCommunity(communityCollection: &mut communityLib::CommunityCollection, userCollection: &mut UserCollection, owner: address, communityId: u64) {
        // TODO: add check role
        communityLib::onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        let user = getMutableUser(userCollection, owner);

        let i = 0;
        while(i < vector::length(&mut user.followedCommunities)) {
            assert!(*vector::borrow(&user.followedCommunities, i) != communityId, 11);
            i = i +1;
        };

        vector::push_back(&mut user.followedCommunities, communityId);
    }

    public entry fun unfollowCommunity(communityCollection: &mut communityLib::CommunityCollection, userCollection: &mut UserCollection, owner: address, communityId: u64) {
        // TODO: add check role
        communityLib::onlyExistingAndNotFrozenCommunity(communityCollection, communityId);
        let user = getMutableUser(userCollection, owner);

        let i = 0;
        while(i < vector::length(&mut user.followedCommunities)) {
            if(*vector::borrow(&user.followedCommunities, i) == communityId) {
                vector::remove(&mut user.followedCommunities, i);
                return
            };
            i = i +1;
        };
        abort 12
    }

    public fun getStatusEnergy(): u64 {
        1000
    }

    public fun getUser(userCollection: &mut UserCollection, owner: address): &User {
        let (isExist, position) = vector::index_of(&mut userCollection.userAddress, &owner);
        if (!isExist) abort 10;
        
        let user = vector::borrow(&mut userCollection.users, position);
        user
    }

    public fun getMutableUser(userCollection: &mut UserCollection, owner: address): &mut User {
        let (isExist, position) = vector::index_of(&mut userCollection.userAddress, &owner);
        if (!isExist) abort 10;
        
        let user = vector::borrow_mut(&mut userCollection.users, position);
        user
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
        let (isExist, _position) = vector::index_of(&mut userCommunityRating.userRatingCommunityId, &communityId);
        if (!isExist) {
            vector::push_back(&mut userCommunityRating.userRatingCommunityId, communityId);
            vector::push_back(&mut userCommunityRating.userRating, i64Lib::from(START_USER_RATING));
        };
        let copyUserCommunityRating = *userCommunityRating;
        
        let pastPeriodsCount: u64 = vector::length(&mut userCommunityRating.rewardPeriods);
        let (isExist, position) = vector::index_of(&mut userCollection.periodRewardContainer.periodRewardSharesPosition, &currentPeriod);
        if (!isExist) {
            vector::push_back(&mut userCollection.periodRewardContainer.periodRewardSharesPosition, currentPeriod);
            vector::push_back(&mut userCollection.periodRewardContainer.periodRewardShares, PeriodRewardShares { totalRewardShares: 0, activeUsersInPeriod: vector::empty<address>() });
        };
        let periodRewardShares = vector::borrow_mut(&mut userCollection.periodRewardContainer.periodRewardShares, position);

        let isFirstTransactionInPeriod = false;
        // If this is the first user rating change in any community
        if (pastPeriodsCount == 0 || *vector::borrow(&copyUserCommunityRating.rewardPeriods, pastPeriodsCount - 1) != currentPeriod) {
            vector::push_back(&mut periodRewardShares.activeUsersInPeriod, userAddr);
            pushUserRewardPeriods(userCollection, currentPeriod, userAddr, communityId);         // TODO: add
            isFirstTransactionInPeriod = true;
        } else {  // rewrite
            pastPeriodsCount = pastPeriodsCount - 1;

            let (_isExist, positionCarentPeriod) = vector::index_of(&copyUserCommunityRating.rewardPeriods, &currentPeriod);        // is exist ?
            let userPeriodRewards = vector::borrow(&copyUserCommunityRating.userPeriodRewards, positionCarentPeriod);       // was position?

            let (isExistRewardCommunities, _positionRewardCommunities) = vector::index_of(&userPeriodRewards.rewardCommunities, &communityId);
            if (!isExistRewardCommunities) {    // !userPeriodCommuntiyRating.isActive
                pushUserRewardCommunity(userCollection, positionCarentPeriod, userAddr, communityId);
                isFirstTransactionInPeriod = true;
            };

        };

        let _previousPeriod = 0;    // TODO: add Unused parameter 'previousPeriod'. Consider removing or prefixing with an underscore: '_previousPeriod'?
        if (pastPeriodsCount > 0) {
            _previousPeriod = *vector::borrow(&copyUserCommunityRating.rewardPeriods, pastPeriodsCount - 1);
        } else {
            // this means that there is no other previous period
            _previousPeriod = currentPeriod;
        };

        updateUserPeriodRating(userCollection, userAddr, rating, communityId, currentPeriod, _previousPeriod, isFirstTransactionInPeriod);

        // userCommunityRating.userRating[communityId].rating += rating;

        // if (rating > 0) {
        //     AchievementLib.updateUserAchievements(userContext.achievementsContainer, userAddr, AchievementCommonLib.AchievementsType.Rating, int64(userCommunityRating.userRating[communityId].rating));
        // }
    }

    fun pushUserRewardPeriods(userCollection: &mut UserCollection, currentPeriod: u64, userAddr: address, communityId: u64) {
        let user: &mut User = getMutableUser(userCollection, userAddr);
        vector::push_back(&mut user.userCommunityRating.rewardPeriods, currentPeriod);
        vector::push_back(&mut user.userCommunityRating.userPeriodRewards, UserPeriodRewards {
            rewardCommunities: vector::singleton<u64>(communityId),
            periodRating: vector::singleton<PeriodRating>(PeriodRating{ ratingToReward: 0, penalty: 0 })
        });
    }

    fun pushUserRewardCommunity(userCollection: &mut UserCollection, positionCarentPeriod: u64, userAddr: address, positionRewardCommunities: u64) {
        let user: &mut User = getMutableUser(userCollection, userAddr);
        let userPeriodRewards = vector::borrow_mut(&mut user.userCommunityRating.userPeriodRewards, positionCarentPeriod);

        vector::push_back(&mut userPeriodRewards.rewardCommunities, positionRewardCommunities);
        vector::push_back(&mut userPeriodRewards.periodRating, PeriodRating{ ratingToReward: 0, penalty: 0 });
    }

    fun getPeriodRating(userCollection: &mut UserCollection, userAddr: address, period: u64, communityId: u64): &mut PeriodRating {
        let user: &mut User = getMutableUser(userCollection, userAddr);
        let (isExist, positionCarentPeriod) = vector::index_of(&user.userCommunityRating.rewardPeriods, &period);
        if (!isExist) abort 98;
        let userPeriodRewards = vector::borrow_mut(&mut user.userCommunityRating.userPeriodRewards, positionCarentPeriod);
        let (isExistRewardCommunities, positionRewardCommunities) = vector::index_of(&userPeriodRewards.rewardCommunities, &communityId);
        if (!isExistRewardCommunities) abort 99;
        
        vector::borrow_mut(&mut userPeriodRewards.periodRating, positionRewardCommunities)
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
                periodRewardShares.totalRewardShares = periodRewardShares.totalRewardShares + i64Lib::as_u64(&getRewardShare(userAddr, previousPeriod, dataUpdateUserRatingCurrentPeriod.ratingToRewardChange));
            } else {
                // let periodRewardShares = getMutableTotalRewardShares(userCollection, currentPeriod);
                // periodRewardShares.totalRewardShares = periodRewardShares.totalRewardShares - i64Lib::as_u64(&i64Lib::mul(&getRewardShare(userAddr, previousPeriod, dataUpdateUserRatingCurrentPeriod.ratingToRewardChange), &i64Lib::neg_from(1)));
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

    fun getMutableTotalRewardShares(userCollection: &mut UserCollection, period: u64): &mut PeriodRewardShares {
        let (isExist, positionCarentPeriod) = vector::index_of(&userCollection.periodRewardContainer.periodRewardSharesPosition, &period);
        if (isExist) {
            vector::borrow_mut(&mut userCollection.periodRewardContainer.periodRewardShares, positionCarentPeriod)
        } else {
            abort 100   // TODO: add del
        }
    }

    // TODO: add userCollection: &mut UserCollection 1-st argument
    fun getRewardShare(_userAddr: address, _period: u64, rating: i64Lib::I64): i64Lib::I64 { // FIX
        // TODO: add
        /*return CommonLib.toInt32FromUint256(userContext.peeranhaToken.getBoost(userAddr, period)) * */ rating
    }

    fun getRatingToRewardChange(previosRatingToReward: i64Lib::I64, newRatingToReward: i64Lib::I64): i64Lib::I64 {
        if (i64Lib::compare(&previosRatingToReward, &i64Lib::zero()) == i64Lib::getLessThan() && i64Lib::compare(&newRatingToReward, &i64Lib::zero()) == i64Lib::getLessThan()) i64Lib::sub(&newRatingToReward, &previosRatingToReward)     // previosRatingToReward >= 0 && newRatingToReward >= 0
        else if(i64Lib::compare(&previosRatingToReward, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&newRatingToReward, &i64Lib::zero()) == i64Lib::getLessThan()) i64Lib::mul(&previosRatingToReward, &i64Lib::neg_from(1))     // previosRatingToReward > 0 && newRatingToReward < 0
        else if(i64Lib::compare(&previosRatingToReward, &i64Lib::zero()) == i64Lib::getLessThan() && i64Lib::compare(&newRatingToReward, &i64Lib::zero()) == i64Lib::getGreaterThan()) newRatingToReward   // previosRatingToReward < 0 && newRatingToReward > 0
        else i64Lib::zero() // from negative to negative
    }

    public entry fun set_value(ctx: &mut TxContext) {       // do something with tx_context
        assert!(tx_context::sender(ctx) == tx_context::sender(ctx), 0);
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

    // for unitTests
    public fun getUserData(userCollection: &mut UserCollection, owner: address): (vector<u8>, address, u64, u64, vector<u64>) {
        let user = getUser(userCollection, owner);
        (user.ipfsDoc, user.owner, user.energy, user.lastUpdatePeriod, user.followedCommunities)
    }


    // #[test]
    // fun test_user() {
    //     use sui::test_scenario;
    //     // use basics::communityLib;

    //     // let owner = @0xC0FFEE;
    //     let user1 = @0xA1;

    //     let scenario = &mut test_scenario::begin(&user1);
    //     {
    //         init(test_scenario::ctx(scenario));
    //         // communityLib::init(test_scenario::ctx(scenario));
    //     };

    //     // create user
    //     test_scenario::next_tx(scenario, &user1);
    //     {
    //         let user_wrapper = test_scenario::take_shared<UserCollection>(scenario);
    //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);

    //         createUser(userCollection, user1, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1");

    //         let (ipfsDoc, owner, energy, lastUpdatePeriod, followedCommunities) = getUserData(userCollection, user1);
    //         assert!(ipfsDoc == x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", 1);
    //         assert!(owner == @0xA1, 2);
    //         assert!(energy == 1000, 3);
    //         assert!(lastUpdatePeriod == 0, 4);
    //         assert!(followedCommunities == vector<u64>[], 5);

    //         printUserCollection(userCollection);

    //         test_scenario::return_shared(scenario, user_wrapper);
    //     };

    // //     // update user ipfs
    // //     test_scenario::next_tx(scenario, &user1);
    // //     {
    // //         let user_wrapper = test_scenario::take_shared<UserCollection>(scenario);
    // //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    // //         updateUser(userCollection, user1, x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82");
            
    // //         let (ipfsDoc, owner, energy, lastUpdatePeriod, followedCommunities) = getUserData(userCollection, user1);
    // //         assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
    // //         assert!(owner == @0xA1, 2);
    // //         assert!(energy == 1000, 3);
    // //         assert!(lastUpdatePeriod == 0, 4);
    // //         assert!(followedCommunities == vector<u64>[], 5);

    // //         test_scenario::return_shared(scenario, user_wrapper);
    // //     };

    // //     test_scenario::next_tx(scenario, &user1);
    // //     {
    // //         let user_wrapper = test_scenario::take_shared<UserCollection>(scenario);
    // //         let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
            
    // //         testError2Fix(userCollection, user1);

    // //         printUserCollection(userCollection);
    // //         test_scenario::return_shared(scenario, user_wrapper);
    // //     };

    //     // // followCommunity
    //     // test_scenario::next_tx(scenario, &user1);
    //     // {
    //     //     let user_wrapper = test_scenario::take_shared<UserCollection>(scenario);
    //     //     let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
    //     //     let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
    //     //     let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);

    //     //     communityLib::createCommunity(
    //     //         communityCollection,
    //     //         user1,
    //     //         x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
    //     //         vector<vector<u8>>[
    //     //             x"0000000000000000000000000000000000000000000000000000000000000001",
    //     //             x"0000000000000000000000000000000000000000000000000000000000000002",
    //     //             x"0000000000000000000000000000000000000000000000000000000000000003",
    //     //             x"0000000000000000000000000000000000000000000000000000000000000004",
    //     //             x"0000000000000000000000000000000000000000000000000000000000000005"
    //     //         ]
    //     //     );

    //     //     followCommunity(communityCollection, userCollection, user1, 0);
            
    //     //     let (ipfsDoc, owner, energy, lastUpdatePeriod, followedCommunities) = getUserData(userCollection, user1);
    //     //     assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
    //     //     assert!(owner == @0xA1, 2);
    //     //     assert!(energy == 1000, 3);
    //     //     assert!(lastUpdatePeriod == 0, 4);
    //     //     assert!(followedCommunities == vector<u64>[0], 5);

    //     //     test_scenario::return_shared(scenario, user_wrapper);
    //     //     test_scenario::return_shared(scenario, community_wrapper);
    //     // };

    //     // // unfollowCommunity
    //     // test_scenario::next_tx(scenario, &user1);
    //     // {
    //     //     let user_wrapper = test_scenario::take_shared<UserCollection>(scenario);
    //     //     let userCollection = test_scenario::borrow_mut(&mut user_wrapper);
    //     //     let community_wrapper = test_scenario::take_shared<communityLib::CommunityCollection>(scenario);
    //     //     let communityCollection = test_scenario::borrow_mut(&mut community_wrapper);

    //     //     unfollowCommunity(communityCollection, userCollection, user1, 0);
            
    //     //     let (ipfsDoc, owner, energy, lastUpdatePeriod, followedCommunities) = getUserData(userCollection, user1);
    //     //     assert!(ipfsDoc == x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82", 1);
    //     //     assert!(owner == @0xA1, 2);
    //     //     assert!(energy == 1000, 3);
    //     //     assert!(lastUpdatePeriod == 0, 4);
    //     //     assert!(followedCommunities == vector<u64>[], 5);

    //     //     test_scenario::return_shared(scenario, user_wrapper);
    //     //     test_scenario::return_shared(scenario, community_wrapper);
    //     // };


    // //      // x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1" - eGEyNjc1MzBmNDlmODI4MDIwMGVkZjMxM2VlN2FmNmI4MjdmMmE4YmNlMjg5Nzc1MWQwNmE4NDNmNjQ0OTY3YjE
    // //      // x"701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82" - eDcwMWI2MTViYmRmYjlkZTY1MjQwYmMyOGJkMjFiYmMwZDk5NjY0NWEzZGQ1N2U3YjEyYmMyYmRmNmYxOTJjODI
    // //      // x"7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6" - eDdjODUyMTE4Mjk0ZTUxZTY1MzcxMmE4MWUwNTgwMGY0MTkxNDE3NTFiZTU4ZjYwNWMzNzFlMTUxNDFiMDA3YTY
    // //      // x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc" - eGMwOWIxOWY2NWFmZDBkZjYxMGM5MGVhMDAxMjBiY2NkMWZjMWI4YzZlN2NkYmU0NDAzNzZlZTEzZTE1NmE1YmM
    // }
}
