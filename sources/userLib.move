module basics::userLib {
    use sui::transfer;
    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    // use std::debug;
    use basics::i64Lib;
    use basics::communityLib;
    use sui::table::{Self, Table};
    // use basics::accessControl;
    use basics::commonLib;
    use sui::vec_map::{Self, VecMap};
    use std::option::{Self};

    /* errors */
    const E_USER_EXIST: u64 = 9;
    const E_USER_DOES_NOT_EXIST: u64 = 10;
    const E_ALREADY_FOLLOWED: u64 = 11;
    const E_COMMUNITY_NOT_FOLOWED: u64 = 12;
    const E_USER_NOT_FOUND: u64 = 13;
    // const E_NOT_ALLOWED_EDIT: u64 = 14;
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
    const ACTION_PUBLICATION_COMMENT: u8 = 3;
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

    struct UsersRatingCollection has key {
        id: UID,
        usersCommunityRating: Table<ID, UserCommunityRating>,
        // roles: accessControl::Role,
    }

    struct PeriodRewardContainer has key {   // Container || Collection??
        id: UID,
        periodRewardShares: VecMap<u64, PeriodRewardShares>,          // key - period   // VecMap? table/bag
    }

    struct User has key {
        id: UID,
        ipfsDoc: commonLib::IpfsHash,
        energy: u64,
        lastUpdatePeriod: u64,
        followedCommunities: vector<ID>,
        userRatingId: ID,   // nned?
        // TODO: add roles                       // add userRatingCollection, periodRewardContainer, achievementsContainer ?
    }

    struct UserCommunityRating has key, store {    // shared
        id: UID,
        userRating: VecMap<ID, i64Lib::I64>,               // key - communityId         // vecMap??
        userPeriodRewards: VecMap<u64, UserPeriodRewards>,  // key - period             // vecMap??
    }

    struct DataUpdateUserRating has drop {
        ratingToReward: u64,
        penalty: u64,
        changeRating: i64Lib::I64,
        ratingToRewardChange: i64Lib::I64
    }

    struct UserPeriodRewards has store, drop, copy {
        periodRating: VecMap<ID, PeriodRating>,          // key - communityId
    }

    struct PeriodRating has store, drop, copy {
        ratingToReward: u64,
        penalty: u64,
    }

    struct PeriodRewardShares has key, store {
        id: UID,                                // uid need??
        totalRewardShares: u64,
        activeUsersInPeriod: vector<ID>,       // Id ??
    }

    // ====== Events ======

    struct EvUser has copy, drop {
        userId: ID,
    }

    struct EvFollowCommunity has copy, drop {
        userId: ID,
        communityId: ID
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(UsersRatingCollection {
            id: object::new(ctx),
            usersCommunityRating: table::new(ctx),
            // roles: accessControl::initRole()
        });

        transfer::share_object(PeriodRewardContainer {
            id: object::new(ctx),
            periodRewardShares: vec_map::empty()
        });
    }

    #[test_only]    // call?
    public fun init_test(ctx: &mut TxContext) {
        init(ctx)
    }

    public entry fun createUser(usersRatingCollection: &mut UsersRatingCollection, ipfsDoc: vector<u8>, ctx: &mut TxContext) {
        // let owner = tx_context::sender(ctx);
        createUserPrivate(usersRatingCollection, ipfsDoc, ctx)
    }

    fun createUserPrivate(usersRatingCollection: &mut UsersRatingCollection, ipfsHash: vector<u8>, ctx: &mut TxContext) {
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash()); // TODO: TEST
        // assert!(!isExists(userRatingCollection, userAddress), E_USER_EXIST); // TODO: TEST     new transfer ???

        let owner = tx_context::sender(ctx);
        let userCommunityRating = UserCommunityRating {
            id: object::new(ctx),
            userRating: vec_map::empty(),
            userPeriodRewards: vec_map::empty(),
        };
        let user = User {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            energy: getStatusEnergy(),
            lastUpdatePeriod: commonLib::getPeriod(),
            followedCommunities: vector::empty<ID>(),
            userRatingId: object::id(&userCommunityRating)
        };

        table::add(&mut usersRatingCollection.usersCommunityRating, object::id(&user), userCommunityRating);
        event::emit(EvUser {userId: object::id(&user)});
        transfer::transfer(
            user, owner
        );
    }

    // public fun createIfDoesNotExist(usersRatingCollection: &mut UsersRatingCollection, userAddress: address) {       // new transfer ???
    //     if (!isExists(userRatingCollection, userAddress)) {
    //         createUserPrivate(userRatingCollection, userAddress, DEFAULT_IPFS);
    //     }
    // }

    public entry fun updateUser(usersRatingCollection: &mut UsersRatingCollection, user: &mut User, ipfsDoc: vector<u8>, ctx: &mut TxContext) {
        let _userAddress = tx_context::sender(ctx);  // del
        // createIfDoesNotExist(usersRatingCollection, userAddress);   // add?
        updateUserPrivate(usersRatingCollection, user, ipfsDoc);
    }

    entry fun updateUserPrivate(usersRatingCollection: &mut UsersRatingCollection, user: &mut User, ipfsHash: vector<u8>) {
        let userId = object::id(user);
        let userCommunityRating = getUserCommunityRating(usersRatingCollection, userId);

        checkRatingAndEnergy(
            user,
            userCommunityRating,
            userId,
            userId,
            commonLib::getZeroId(),
            ACTION_UPDATE_PROFILE
        );
        user.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
        event::emit(EvUser {userId: userId});
    }

    public entry fun followCommunity(usersRatingCollection: &mut UsersRatingCollection, user: &mut User, community: &communityLib::Community, ctx: &mut TxContext) {
        communityLib::onlyNotFrezenCommunity(community);
        let userId = object::id(user);
        let _userAddress = tx_context::sender(ctx);  // del
        let userCommunityRating = getUserCommunityRating(usersRatingCollection, userId);

        checkRatingAndEnergy(
            user,
            userCommunityRating,
            userId,
            userId,
            commonLib::getZeroId(),
            ACTION_FOLLOW_COMMUNITY
        );

        let i = 0;
        let community_id = object::id(community);
        while(i < vector::length(&mut user.followedCommunities)) {
            assert!(*vector::borrow(&user.followedCommunities, i) != community_id, E_ALREADY_FOLLOWED);
            i = i +1;
        };

        vector::push_back(&mut user.followedCommunities, community_id);
        event::emit(EvFollowCommunity{userId: userId, communityId: community_id});
    }

    public entry fun unfollowCommunity(usersRatingCollection: &mut UsersRatingCollection, user: &mut User, community: &communityLib::Community, ctx: &mut TxContext) {
        communityLib::onlyNotFrezenCommunity(community);
        let _userAddress = tx_context::sender(ctx);      // del
        let userId = object::id(user);
        let userCommunityRating = getUserCommunityRating(usersRatingCollection, userId);

        let user = checkRatingAndEnergy(
            user,
            userCommunityRating,
            userId,
            userId,
            commonLib::getZeroId(),
            ACTION_FOLLOW_COMMUNITY
        );

        let i = 0;
        let community_id = object::id(community);
        while(i < vector::length(&mut user.followedCommunities)) {
            if(*vector::borrow(&user.followedCommunities, i) == community_id) {
                vector::remove(&mut user.followedCommunities, i);

                event::emit(EvFollowCommunity{userId: userId, communityId: community_id});
                return
            };
            i = i +1;
        };
        abort E_COMMUNITY_NOT_FOLOWED
    }

    public fun getStatusEnergy(): u64 {
        1000
    }

    // public fun isExists(usersRatingCollection: &mut UsersRatingCollection, userAddress: address): bool { 
    //     let position = vec_map::get_idx_opt(&mut userRatingCollection.users, &userAddress);
    //     !option::is_none(&position)
    // }

    // public fun getUser(usersRatingCollection: &mut UsersRatingCollection, userAddress: address): User {
    //     let position = vec_map::get_idx_opt(&mut userRatingCollection.users, &userAddress);
    //     if (option::is_none(&position)) {
    //         abort E_USER_DOES_NOT_EXIST
    //     } else {
    //         // TODO: add
    //         // let user = vec_map::get(&userRatingCollection.users, &userAddress);
    //         // user
    //         let user = vec_map::get_mut(&mut userRatingCollection.users, &userAddress);
    //         *user
    //     }
    // }

    // public fun getMutableUser(usersRatingCollection: &mut UsersRatingCollection, userAddress: address): &mut User {
    //     let position = vec_map::get_idx_opt(&mut userRatingCollection.users, &userAddress);
    //     if (option::is_none(&position)) {
    //         abort E_USER_DOES_NOT_EXIST
    //     } else {
    //         let user = vec_map::get_mut(&mut userRatingCollection.users, &userAddress);
    //         user
    //     }
    // }

    public fun updateRating(userCommunityRating: &mut UserCommunityRating, periodRewardContainer: &mut PeriodRewardContainer, userId: ID, rating: i64Lib::I64, communityId: ID, ctx: &mut TxContext) {
        if(i64Lib::compare(&rating, &i64Lib::zero()) == i64Lib::getEual())
            return;
        
        updateRatingBase(userCommunityRating, periodRewardContainer, userId, rating, communityId, ctx);
    }
    
    public fun updateRatingBase(userCommunityRating: &mut UserCommunityRating, periodRewardContainer: &mut PeriodRewardContainer, userId: ID, rating: i64Lib::I64, communityId: ID, ctx: &mut TxContext) {
        let currentPeriod: u64 = commonLib::getPeriod();

        // let userCommunityRating = &mut user.userCommunityRating; // del transfer
        // Initialize user rating in the community if this is the first rating change
        let position = vec_map::get_idx_opt(&mut userCommunityRating.userRating, &communityId);
        if (option::is_none(&position)) {
            vec_map::insert(&mut userCommunityRating.userRating, communityId, i64Lib::from(START_USER_RATING));
        };
        // let copyUserCommunityRating = *userCommunityRating;      // del transfer
        
        let pastPeriodsCount: u64 = vec_map::size(&mut userCommunityRating.userPeriodRewards);      // move down?

        if (!vec_map::contains(&periodRewardContainer.periodRewardShares, &currentPeriod)) {
            vec_map::insert(&mut periodRewardContainer.periodRewardShares, currentPeriod, PeriodRewardShares { id: object::new(ctx), totalRewardShares: 0, activeUsersInPeriod: vector::empty<ID>() });
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
            let (key, _) = vec_map::get_entry_by_idx(&userCommunityRating.userPeriodRewards, pastPeriodsCount - 1);
            if (key != &currentPeriod) {
                isFirstTransactionInPeriod = true;
            }
        };

        if (isFirstTransactionInPeriod) {
            let periodRewardShares = vec_map::get_mut(&mut periodRewardContainer.periodRewardShares, &currentPeriod);
            vector::push_back(&mut periodRewardShares.activeUsersInPeriod, userId);     // new transfer ??? user.owner or user.ID?
            pushUserRewardPeriods(userCommunityRating, currentPeriod, communityId);         // TODO: add, what?
        } else {  // rewrite
            pastPeriodsCount = pastPeriodsCount - 1;
            isFirstTransactionInPeriod = pushUserRewardCommunity(userCommunityRating, currentPeriod, communityId);
        };

        let _previousPeriod = 0;    // TODO: add Unused parameter 'previousPeriod'. Consider removing or prefixing with an underscore: '_previousPeriod'?
        if (pastPeriodsCount > 0) {
            let (key, _) = vec_map::get_entry_by_idx(&userCommunityRating.userPeriodRewards, pastPeriodsCount - 1);
            _previousPeriod = *key;
        } else {
            // this means that there is no other previous period
            _previousPeriod = currentPeriod;
        };

        
        updateUserPeriodRating(periodRewardContainer, userCommunityRating, userId, rating, communityId, currentPeriod, _previousPeriod, isFirstTransactionInPeriod);

        changeUserRating(userCommunityRating, communityId, rating);

        // if (rating > 0) {    // todo add
        //     AchievementLib.updateUserAchievements(userContext.achievementsContainer, userAddr, AchievementCommonLib.AchievementsType.Rating, int64(userCommunityRating.userRating[communityId].rating));
        // }
    }

    fun changeUserRating(userCommunityRating: &mut UserCommunityRating, communityId: ID, rating: i64Lib::I64) {
        let userRating = vec_map::get_mut(&mut userCommunityRating.userRating, &communityId);
        *userRating = i64Lib::add(&*userRating, &rating);
    }


    fun pushUserRewardPeriods(userCommunityRating: &mut UserCommunityRating, currentPeriod: u64, communityId: ID) {
        let mapPeriodRating: VecMap<ID, PeriodRating> = vec_map::empty();
        vec_map::insert(&mut mapPeriodRating, communityId, PeriodRating{ ratingToReward: 0, penalty: 0 });

        vec_map::insert(&mut userCommunityRating.userPeriodRewards, currentPeriod, UserPeriodRewards{ periodRating: mapPeriodRating});
    }

    fun pushUserRewardCommunity(userCommunityRating: &mut UserCommunityRating, currentPeriod: u64, communityId: ID): bool { // TODO: add name
        let userPeriodRewards = vec_map::get_mut(&mut userCommunityRating.userPeriodRewards, &currentPeriod);
        if (!vec_map::contains(&userPeriodRewards.periodRating, &communityId)) {
            vec_map::insert(&mut userPeriodRewards.periodRating, communityId, PeriodRating{ ratingToReward: 0, penalty: 0 });
            true
        } else {
            false
        }
    }

    fun getPeriodRating(userCommunityRating: &mut UserCommunityRating, period: u64, communityId: ID): &mut PeriodRating {
        // let (isExist, positionCarentPeriod) = vector::index_of(&user.userCommunityRating.rewardPeriods, &period);   // userPeriodRewards
        // if (!isExist) abort 97; // todo!!!!
        // let userPeriodRewards = vector::borrow_mut(&mut user.userCommunityRating.userPeriodRewards, positionCarentPeriod);

        let userPeriodRewards = vec_map::get_mut(&mut userCommunityRating.userPeriodRewards, &period);

        // let (isExistRewardCommunities, positionRewardCommunities) = vector::index_of(&userPeriodRewards.rewardCommunities, &communityId);
        // if (!isExistRewardCommunities) abort 98;  // todo!!!!??
        // vector::borrow_mut(&mut userPeriodRewards.periodRating, positionRewardCommunities)

        vec_map::get_mut(&mut userPeriodRewards.periodRating, &communityId)
    }

    fun updatePeriodRating(userCommunityRating: &mut UserCommunityRating, period: u64, communityId: ID, penalty: u64, ratingToReward: u64) {
        let periodRating = getPeriodRating(userCommunityRating, period, communityId);
        if (penalty != 0)
            periodRating.penalty = penalty;
        if (ratingToReward != 0)
            periodRating.ratingToReward = ratingToReward;
    }

    fun updateUserPeriodRating(periodRewardContainer: &mut PeriodRewardContainer, userCommunityRating: &mut UserCommunityRating, userId: ID, rating: i64Lib::I64, communityId: ID, currentPeriod: u64, previousPeriod: u64, isFirstTransactionInPeriod: bool ) {
        // RewardLib.PeriodRating storage currentPeriodRating = userCommunityRating.userPeriodRewards[currentPeriod].periodRating[communityId];
        // bool isFirstTransactionInPeriod = !currentPeriodRating.isActive;
        let currentPeriodRating: PeriodRating = *getPeriodRating(userCommunityRating, currentPeriod, communityId);

        let dataUpdateUserRatingCurrentPeriod: DataUpdateUserRating = DataUpdateUserRating {
            ratingToReward: currentPeriodRating.ratingToReward,
            penalty: currentPeriodRating.penalty,
            changeRating: i64Lib::zero(),
            ratingToRewardChange: i64Lib::zero()
        };

        if (currentPeriod == previousPeriod) {   //first period rating?
            dataUpdateUserRatingCurrentPeriod.changeRating = rating;

        } else {
            let previousPeriodRating: &mut PeriodRating = getPeriodRating(userCommunityRating, previousPeriod, communityId);

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
                    let periodRewardShares = getMutableTotalRewardShares(periodRewardContainer, previousPeriod);
                    periodRewardShares.totalRewardShares = periodRewardShares.totalRewardShares + i64Lib::as_u64(&getRewardShare(userId, previousPeriod, dataUpdateUserRatingPreviousPeriod.ratingToRewardChange));
                } else {
                    let periodRewardShares = getMutableTotalRewardShares(periodRewardContainer, previousPeriod);
                    periodRewardShares.totalRewardShares = periodRewardShares.totalRewardShares - i64Lib::as_u64(&i64Lib::mul(&getRewardShare(userId, previousPeriod, dataUpdateUserRatingPreviousPeriod.ratingToRewardChange), &i64Lib::neg_from(1)));
                };
            };
        };      // +

        if (i64Lib::compare(&dataUpdateUserRatingCurrentPeriod.changeRating, &i64Lib::zero()) != i64Lib::getEual()) {
            dataUpdateUserRatingCurrentPeriod.ratingToRewardChange = getRatingToRewardChange(i64Lib::sub(&i64Lib::from(dataUpdateUserRatingCurrentPeriod.ratingToReward), &i64Lib::from(dataUpdateUserRatingCurrentPeriod.penalty)), i64Lib::add(&i64Lib::sub(&i64Lib::from(dataUpdateUserRatingCurrentPeriod.ratingToReward), &i64Lib::from(dataUpdateUserRatingCurrentPeriod.penalty)), &dataUpdateUserRatingCurrentPeriod.changeRating));
            if (i64Lib::compare(&dataUpdateUserRatingCurrentPeriod.ratingToRewardChange, &i64Lib::zero()) == i64Lib::getGreaterThan()) {    // neg?   i64Lib::compare(&dataUpdateUserRatingCurrentPeriod.ratingToRewardChange, &i64Lib::zero()) == i64Lib::getGreaterThan()  //
                let periodRewardShares = getMutableTotalRewardShares(periodRewardContainer, currentPeriod);
                periodRewardShares.totalRewardShares = periodRewardShares.totalRewardShares + i64Lib::as_u64(&getRewardShare(userId, currentPeriod, dataUpdateUserRatingCurrentPeriod.ratingToRewardChange));
            } else {
                let periodRewardShares = getMutableTotalRewardShares(periodRewardContainer, currentPeriod);
                periodRewardShares.totalRewardShares = periodRewardShares.totalRewardShares - i64Lib::as_u64(&i64Lib::mul(&getRewardShare(userId, currentPeriod, dataUpdateUserRatingCurrentPeriod.ratingToRewardChange), &i64Lib::neg_from(1)));
            };

            let _changeRating: i64Lib::I64 = i64Lib::zero();     // TODD: add Unused assignment or binding for local 'changeRating'. Consider removing, replacing with '_', or prefixing with '_' (e.g., '_changeRating')
            if (i64Lib::compare(&dataUpdateUserRatingCurrentPeriod.changeRating, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
                _changeRating = i64Lib::sub(&dataUpdateUserRatingCurrentPeriod.changeRating, &i64Lib::from(dataUpdateUserRatingCurrentPeriod.penalty));
                if (i64Lib::compare(&_changeRating, &i64Lib::zero()) != i64Lib::getLessThan()) {
                    updatePeriodRating(userCommunityRating, currentPeriod, communityId, 0, i64Lib::as_u64(&_changeRating) + currentPeriodRating.ratingToReward);
                } else {
                    updatePeriodRating(userCommunityRating, currentPeriod, communityId, i64Lib::as_u64(&i64Lib::mul(&_changeRating, &i64Lib::neg_from(1))), currentPeriodRating.ratingToReward);
                };

            } else if (i64Lib::compare(&dataUpdateUserRatingCurrentPeriod.changeRating, &i64Lib::zero()) == i64Lib::getLessThan()) {
                _changeRating = i64Lib::add(&i64Lib::from(dataUpdateUserRatingCurrentPeriod.ratingToReward), &dataUpdateUserRatingCurrentPeriod.changeRating);
                if (i64Lib::compare(&_changeRating, &i64Lib::zero()) != i64Lib::getGreaterThan()) {
                    updatePeriodRating(userCommunityRating, currentPeriod, communityId, i64Lib::as_u64(&i64Lib::mul(&_changeRating, &i64Lib::neg_from(1))) + currentPeriodRating.penalty, 0);
                } else {
                    updatePeriodRating(userCommunityRating, currentPeriod, communityId, currentPeriodRating.penalty, i64Lib::as_u64(&_changeRating));
                };
            };
        };
    }

    // TODO: add UserLib.Action action + add field UserLib.ActionRole actionRole
    public fun checkActionRole(
        user: &mut User,
        userCommunityRating: &UserCommunityRating,
        actionCaller: ID,  // need? user -> owner
        dataUser: ID,
        communityId: ID,
        action: u8,
        // role
        //createUserIfDoesNotExist: bool  // new transfer ???
    ) 
    {
        // TODO: add 
        // require(msg.sender == address(userContext.peeranhaContent) || msg.sender == address(userContext.peeranhaCommunity), "internal_call_unauthorized");
       
        /*
        if (createUserIfDoesNotExist) {                     // new transfer ??? commented
            createIfDoesNotExist(userRatingCollection, actionCaller);
        } else {
            checkUser(userRatingCollection, actionCaller);        // need?
        }; 
        */

        // TODO: add 
        // if (hasModeratorRole(actionCaller, communityId)) {
        //     return;
        // }
                
        // checkHasRole(actionCaller, actionRole, communityId);
        checkRatingAndEnergy(user, userCommunityRating, actionCaller, dataUser, communityId, action);
    }

    public fun checkRatingAndEnergy(
        user: &mut User,
        userCommunityRating: &UserCommunityRating,
        actionCaller: ID,
        dataUser: ID,
        communityId: ID,
        action: u8
    ): &mut User
    {
        let userRating = getUserRating(userCommunityRating, communityId);
            
        let (ratingAllowed, message, energy) = getRatingAndEnergyForAction(actionCaller, dataUser, action);
        assert!(i64Lib::compare(&userRating, &ratingAllowed) != i64Lib::getLessThan(), message);
        reduceEnergy(user, energy);

        user
    }

    fun getRatingAndEnergyForAction(
        actionCaller: ID,
        dataUser: ID,
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

        } else if (action == ACTION_PUBLICATION_COMMENT) {
            if (actionCaller == dataUser) {
                ratingAllowed = i64Lib::from(POST_OWN_COMMENT_ALLOWED);
            } else {
                ratingAllowed = i64Lib::from(POST_COMMENT_ALLOWED);
            };
            // message = "low_rating_comment";
            energy = ENERGY_POST_COMMENT;

        } else if (action == ACTION_EDIT_ITEM) {
            // assert!(actionCaller == dataUser, E_NOT_ALLOWED_EDIT);
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

    // fun checkUser(usersRatingCollection: &mut UsersRatingCollection, addr: address) {
    //     assert!(isExists(userRatingCollection, addr), E_USER_NOT_FOUND);
    // }

    fun getMutableTotalRewardShares(periodRewardContainer: &mut PeriodRewardContainer, period: u64): &mut PeriodRewardShares {
        if (vec_map::contains(&periodRewardContainer.periodRewardShares, &period)) {
            vec_map::get_mut(&mut periodRewardContainer.periodRewardShares, &period)
        } else {
            abort E_CHECK_FUNCTION_getMutableTotalRewardShare   // TODO: add del
        }
    }

    public fun getUserRating(userCommunityRating: &UserCommunityRating, communityId: ID): i64Lib::I64 {   // public?  + user &mut?
        let position = vec_map::get_idx_opt(&userCommunityRating.userRating, &communityId);
        if (option::is_none(&position)) {
            i64Lib::from(START_USER_RATING)
        } else {
            *vec_map::get(&userCommunityRating.userRating, &communityId)
        }
    }

    // TODO: add usersRatingCollection: &mut UsersRatingCollection 1-st argument
    fun getRewardShare(_userId: ID, _period: u64, rating: i64Lib::I64): i64Lib::I64 { // FIX
        // TODO: add
        /*return CommonLib.toInt32FromUint256(userContext.peeranhaToken.getBoost(userAddr, period)) * */ rating
    }

    fun getRatingToRewardChange(previosRatingToReward: i64Lib::I64, newRatingToReward: i64Lib::I64): i64Lib::I64 {
        if (i64Lib::compare(&previosRatingToReward, &i64Lib::zero()) != i64Lib::getLessThan() && i64Lib::compare(&newRatingToReward, &i64Lib::zero()) != i64Lib::getLessThan()) i64Lib::sub(&newRatingToReward, &previosRatingToReward)     // previosRatingToReward >= 0 && newRatingToReward >= 0
        else if(i64Lib::compare(&previosRatingToReward, &i64Lib::zero()) == i64Lib::getGreaterThan() && i64Lib::compare(&newRatingToReward, &i64Lib::zero()) == i64Lib::getLessThan()) i64Lib::mul(&previosRatingToReward, &i64Lib::neg_from(1))     // previosRatingToReward > 0 && newRatingToReward < 0
        else if(i64Lib::compare(&previosRatingToReward, &i64Lib::zero()) == i64Lib::getLessThan() && i64Lib::compare(&newRatingToReward, &i64Lib::zero()) == i64Lib::getGreaterThan()) newRatingToReward   // previosRatingToReward < 0 && newRatingToReward > 0
        else i64Lib::zero() // from negative to negative
    }

    public fun getUserRatingId(user: &User): ID {
        user.userRatingId
    }

    public fun getUserCommunityRating(usersRatingCollection: &UsersRatingCollection, userId: ID): &UserCommunityRating {
        table::borrow(&usersRatingCollection.usersCommunityRating, userId)
    }

    public fun getMutableUserCommunityRating(usersRatingCollection: &mut UsersRatingCollection, userId: ID): &mut UserCommunityRating {
        table::borrow_mut(&mut usersRatingCollection.usersCommunityRating, userId)
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

    // public entry fun printUsersRatingCollection(usersRatingCollection: &mut UsersRatingCollection) {
    //     debug::print(userRatingCollection);
    // }

    // public entry fun printUser(usersRatingCollection: &mut UsersRatingCollection, owner: address) {
    //     let (isExist, position) = vector::index_of(&mut userRatingCollection.userAddress, &owner);
    //     debug::print(&isExist);
    //     debug::print(&position);

    //     if (isExist) {
    //         let user = vector::borrow(&mut userRatingCollection.users, position);
    //         debug::print(user);
    //     }
    // }

    public fun get_action_none(): u8 {
        ACTION_NONE
    }

    public fun get_action_publication_post(): u8 {
        ACTION_PUBLICATION_POST
    }

    public fun get_action_publication_reply(): u8 {
        ACTION_PUBLICATION_REPLY
    }

    public fun get_action_publication_comment(): u8 {
        ACTION_PUBLICATION_COMMENT
    }

    public fun get_action_edit_item(): u8 {
        ACTION_EDIT_ITEM
    }

    public fun get_action_delete_item(): u8 {
        ACTION_DELETE_ITEM
    }

    public fun get_action_upvote_post(): u8 {
        ACTION_UPVOTE_POST
    }

    public fun get_action_downvote_post(): u8 {
        ACTION_DOWNVOTE_POST
    }

    public fun get_action_upvote_reply(): u8 {
        ACTION_UPVOTE_REPLY
    }

    public fun get_action_downvote_reply(): u8 {
        ACTION_DOWNVOTE_REPLY
    }

    public fun get_action_vote_comment(): u8 {
        ACTION_VOTE_COMMENT
    }

    public fun get_action_cancel_vote(): u8 {
        ACTION_CANCEL_VOTE
    }

    public fun get_action_best_reply(): u8 {
        ACTION_BEST_REPLY
    }

    #[test_only]
    public fun getUserData(user: &mut User): (vector<u8>, u64, u64, vector<ID>) {
        (commonLib::getIpfsHash(user.ipfsDoc), user.energy, user.lastUpdatePeriod, user.followedCommunities)
    }
    
    
    #[test_only]
    public fun create_user(usersRatingCollection: &mut UsersRatingCollection, scenario: &mut TxContext) {
        createUser(usersRatingCollection, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", scenario);
    }
}
