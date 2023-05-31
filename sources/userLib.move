module basics::userLib {
    use sui::transfer;
    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use basics::accessControlLib;
    use basics::i64Lib;
    use basics::nftLib;
    use sui::table::{Self, Table};
    use basics::commonLib;
    use sui::vec_map::{Self, VecMap};
    use std::option::{Self};
    friend basics::followCommunityLib;

    // ====== Errors ======

    const E_USER_EXIST: u64 = 9;
    const E_USER_DOES_NOT_EXIST: u64 = 10;
    const E_USER_NOT_FOUND: u64 = 13;
    const E_NOT_ALLOWED_DELETE: u64 = 15;
    const E_NOT_ALLOWED_VOTE_POST: u64 = 16;
    const E_NOT_ALLOWED_VOTE_REPLY: u64 = 17;
    const E_NOT_ALLOWED_VOTE_COMMENT: u64 = 18;
    const E_NOT_ALLOWED_ACTION: u64 = 21;
    const E_LOW_ENERGY: u64 = 22;
    const E_MUST_BE_0_RATING: u64 = 23;
    const E_LOW_RATING_CREATE_POST: u64 = 24;
    const E_LOW_RATING_CREATE_REPLY: u64 = 25;
    const E_LOW_RATING_CREATE_COMMENT: u64 = 26;
    const E_LOW_RATING_EDIT_ITEM: u64 = 27;
    const E_LOW_RATING_DELETE_ITEM: u64 = 28;
    const E_LOW_RATING_UPVOTE_POST: u64 = 29;
    const E_LOW_RATING_UPVOTE_REPLY: u64 = 30;
    const E_LOW_RATING_VOTE_COMMENT: u64 = 31;
    const E_LOW_RATING_DOWNVOTE_POST: u64 = 32;
    const E_LOW_RATING_DOWNVOTE_REPLY: u64 = 33;
    const E_LOW_RATING_CANCEL_VOTE: u64 = 34;
    const E_LOW_RATING_MARK_BEST_REPLY: u64 = 35;
    const E_LOW_RATING_UPDATE_PROFILE: u64 = 36;    // never call
    const E_LOW_RATING_FOLLOW_COMMUNITY: u64 = 37;  // never call
    const E_CHECK_FUNCTION_getMutableTotalRewardShare: u64 = 100; // todo

    // ====== Enum ======

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

    // ====== Constant ======

    const START_USER_RATING: u64 = 10;
    const DEFAULT_IPFS: vector<u8> = x"c09b19f65afd0df610c90ea00120bccd1fc1b8c6e7cdbe440376ee13e156a5bc";

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
        // roles: accessControlLib::Role,
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
        userRatingId: ID,   // need?
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

    struct CreateUserEvent has copy, drop {
        userId: ID,
    }

    struct UpdateUserEvent has copy, drop {     // double event
        userId: ID,
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(UsersRatingCollection {
            id: object::new(ctx),
            usersCommunityRating: table::new(ctx),
            // roles: accessControlLib::initRole()
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

    public entry fun createUser(usersRatingCollection: &mut UsersRatingCollection, ipfsDoc: vector<u8>, ctx: &mut TxContext) {  // add check isExist??
        createUserPrivate(usersRatingCollection, ipfsDoc, ctx)
    }

    fun createUserPrivate(usersRatingCollection: &mut UsersRatingCollection, ipfsHash: vector<u8>, ctx: &mut TxContext) {
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash()); // TODO: TEST

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
        event::emit(CreateUserEvent {userId: object::id(&user)});
        transfer::transfer(
            user, owner
        );
    }

    public entry fun updateUser(usersRatingCollection: &mut UsersRatingCollection, user: &mut User, ipfsDoc: vector<u8>, ctx: &mut TxContext) {
        let _userAddress = tx_context::sender(ctx);  // del
        // createIfDoesNotExist(usersRatingCollection, userAddress);   // add?
        updateUserPrivate(usersRatingCollection, user, ipfsDoc);
    }

    fun updateUserPrivate(usersRatingCollection: &mut UsersRatingCollection, user: &mut User, ipfsHash: vector<u8>) {
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
        event::emit(UpdateUserEvent {userId: userId});
    }

    public entry fun grantRole(userRolesCollection: &mut accessControlLib::UserRolesCollection, admin: &User, userId: ID, role: vector<u8>) {
        let adminId = object::id(admin);
        accessControlLib::grantRole(userRolesCollection, adminId, userId, role)
    }

    public entry fun revokeRole(userRolesCollection: &mut accessControlLib::UserRolesCollection, admin: &User, userId: ID, role: vector<u8>) {
        let adminId = object::id(admin);
        accessControlLib::revokeRole(userRolesCollection, adminId, userId, role)
    }

    public(friend) fun getUserFollowedCommunities(user: &User): &vector<ID> {
        &user.followedCommunities
    }

    public(friend) fun followCommunity(user: &mut User, communityId: ID) {
        vector::push_back(&mut user.followedCommunities, communityId);
    }

    public(friend) fun unfollowCommunity(user: &mut User, communityIndex: u64) {
        vector::remove(&mut user.followedCommunities, communityIndex);
    }

    public fun getStatusEnergy(): u64 {
        1000
    }

    /*plug*/
    public fun updateRating(userCommunityRating: &mut UserCommunityRating, _periodRewardContainer: &mut PeriodRewardContainer, _userId: ID, rating: i64Lib::I64, communityId: ID, _ctx: &mut TxContext) {
        if(i64Lib::compare(&rating, &i64Lib::zero()) == i64Lib::getEual())
            return;
        
        let position = vec_map::get_idx_opt(&mut userCommunityRating.userRating, &communityId);
        if (option::is_none(&position)) {
            vec_map::insert(&mut userCommunityRating.userRating, communityId, i64Lib::from(START_USER_RATING));
        };

        let userRating = vec_map::get_mut(&mut userCommunityRating.userRating, &communityId);
        *userRating = i64Lib::add(&*userRating, &rating);

        if (i64Lib::compare(&rating, &i64Lib::zero()) == i64Lib::getGreaterThan()) {
            let achievementsTypesArray: vector<u8> = vector[nftLib::getAchievementTypeRating(), nftLib::getAchievementTypeSoulRating()];
            // nftLib::mint(...);
        }
    }

    // TODO: add UserLib.Action action + add field UserLib.ActionRole actionRole
    public fun checkActionRole(
        user: &mut User,
        userCommunityRating: &UserCommunityRating,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        actionCallerId: ID,  // need? user -> owner
        dataUserId: ID,
        communityId: ID,
        action: u8,
        actionRole: u8,
        //createUserIfDoesNotExist: bool  // new transfer ???
    ) 
    {
        if (hasModeratorRole(userRolesCollection, actionCallerId, communityId)) {
            return
        };

        accessControlLib::checkHasRole(userRolesCollection, actionCallerId, actionRole, communityId);
        checkRatingAndEnergy(user, userCommunityRating, actionCallerId, dataUserId, communityId, action);
    }

    public fun hasModeratorRole(
        userRolesCollection: &accessControlLib::UserRolesCollection,
        userId: ID,
        communityId: ID
    ): bool {
        let communityModeratorRole = accessControlLib::getCommunityRole(accessControlLib::get_community_moderator_role(), communityId);
        let isModerator = accessControlLib::hasRole(userRolesCollection, communityModeratorRole, userId) || accessControlLib::hasRole(userRolesCollection, accessControlLib::get_protocol_admin_role(), userId);
        if (isModerator) {
            true
        } else {
            false
        }
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
        let ratingAllowed: i64Lib::I64 = i64Lib::neg_from(MINIMUM_RATING);
        let message: u64;
        let energy: u64;

        if (action == ACTION_NONE) {
            ratingAllowed = i64Lib::zero();
            message = E_MUST_BE_0_RATING;
            energy = 0;
        } else if (action == ACTION_PUBLICATION_POST) {
            ratingAllowed = i64Lib::from(POST_QUESTION_ALLOWED);
            message = E_LOW_RATING_CREATE_POST; 
            energy = ENERGY_POST_QUESTION;

        } else if (action == ACTION_PUBLICATION_REPLY) {
            ratingAllowed = i64Lib::from(POST_REPLY_ALLOWED);
            message = E_LOW_RATING_CREATE_REPLY;
            energy = ENERGY_POST_ANSWER;

        } else if (action == ACTION_PUBLICATION_COMMENT) {
            if (actionCaller == dataUser) {
                ratingAllowed = i64Lib::from(POST_OWN_COMMENT_ALLOWED);
            } else {
                ratingAllowed = i64Lib::from(POST_COMMENT_ALLOWED);
            };
            message = E_LOW_RATING_CREATE_COMMENT;
            energy = ENERGY_POST_COMMENT;

        } else if (action == ACTION_EDIT_ITEM) {
            ratingAllowed = i64Lib::neg_from(MINIMUM_RATING);
            message = E_LOW_RATING_EDIT_ITEM;
            energy = ENERGY_MODIFY_ITEM;

        } else if (action == ACTION_DELETE_ITEM) {
            assert!(actionCaller == dataUser, E_NOT_ALLOWED_DELETE);
            ratingAllowed = i64Lib::zero();
            message = E_LOW_RATING_DELETE_ITEM; // delete own item?
            energy = ENERGY_DELETE_ITEM;

        } else if (action == ACTION_UPVOTE_POST) {
            assert!(actionCaller != dataUser, E_NOT_ALLOWED_VOTE_POST);
            ratingAllowed = i64Lib::from(UPVOTE_POST_ALLOWED);
            message = E_LOW_RATING_UPVOTE_POST;
            energy = ENERGY_UPVOTE_QUESTION;

        } else if (action == ACTION_UPVOTE_REPLY) {
            assert!(actionCaller != dataUser, E_NOT_ALLOWED_VOTE_REPLY);
            ratingAllowed = i64Lib::from(UPVOTE_REPLY_ALLOWED);
            message = E_LOW_RATING_UPVOTE_REPLY;
            energy = ENERGY_UPVOTE_ANSWER;

        } else if (action == ACTION_VOTE_COMMENT) {
            assert!(actionCaller != dataUser, E_NOT_ALLOWED_VOTE_COMMENT);
            ratingAllowed = i64Lib::from(VOTE_COMMENT_ALLOWED);
            message = E_LOW_RATING_VOTE_COMMENT;
            energy = ENERGY_VOTE_COMMENT;

        } else if (action == ACTION_DOWNVOTE_POST) {
            assert!(actionCaller != dataUser, E_NOT_ALLOWED_VOTE_POST);     // NEED?
            ratingAllowed = i64Lib::from(DOWNVOTE_POST_ALLOWED);
            message = E_LOW_RATING_DOWNVOTE_POST;
            energy = ENERGY_DOWNVOTE_QUESTION;

        } else if (action == ACTION_DOWNVOTE_REPLY) {
            assert!(actionCaller != dataUser, DOWNVOTE_REPLY_ALLOWED);      // NEED?
            ratingAllowed = i64Lib::from(DOWNVOTE_REPLY_ALLOWED);
            message = E_LOW_RATING_DOWNVOTE_REPLY;
            energy = ENERGY_DOWNVOTE_ANSWER;

        } else if (action == ACTION_CANCEL_VOTE) {
            ratingAllowed = i64Lib::from(CANCEL_VOTE);
            message = E_LOW_RATING_CANCEL_VOTE;
            energy = ENERGY_FORUM_VOTE_CANCEL;

        } else if (action == ACTION_BEST_REPLY) {       // test neg rating?
            message = E_LOW_RATING_MARK_BEST_REPLY;
            energy = ENERGY_MARK_REPLY_AS_CORRECT;

        } else if (action == ACTION_UPDATE_PROFILE) {
            energy = ENERGY_UPDATE_PROFILE;
            message = E_LOW_RATING_UPDATE_PROFILE;

        } else if (action == ACTION_FOLLOW_COMMUNITY) {
            message = E_LOW_RATING_FOLLOW_COMMUNITY;
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
            i64Lib::from(0)
        } else {
            *vec_map::get(&userCommunityRating.userRating, &communityId)
        }
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

    public fun get_action_follow_community(): u8 {
        ACTION_FOLLOW_COMMUNITY
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
