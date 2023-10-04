module peeranha::userLib {
    use sui::transfer;
    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use peeranha::accessControlLib;
    use peeranha::i64Lib;
    use peeranha::nftLib;
    use sui::table::{Self, Table};
    use peeranha::commonLib;
    use sui::vec_map::{Self, VecMap};
    use std::option::{Self};
    friend peeranha::followCommunityLib;
    friend peeranha::postLib;

    // ====== Errors. Available values 1 - 99 ======

    const E_USER_EXIST: u64 = 1;
    const E_USER_DOES_NOT_EXIST: u64 = 2;
    const E_USER_NOT_FOUND: u64 = 3;
    const E_NOT_ALLOWED_DELETE: u64 = 4;
    const E_NOT_ALLOWED_VOTE_POST: u64 = 5;
    const E_NOT_ALLOWED_VOTE_REPLY: u64 = 6;
    const E_NOT_ALLOWED_VOTE_COMMENT: u64 = 7;
    const E_NOT_ALLOWED_ACTION: u64 = 8;
    const E_LOW_ENERGY: u64 = 9;
    const E_MUST_BE_0_RATING: u64 = 10;
    const E_LOW_RATING_CREATE_POST: u64 = 11;
    const E_LOW_RATING_CREATE_REPLY: u64 = 12;
    const E_LOW_RATING_CREATE_COMMENT: u64 = 13;
    const E_LOW_RATING_EDIT_ITEM: u64 = 14;
    const E_LOW_RATING_DELETE_ITEM: u64 = 15;
    const E_LOW_RATING_UPVOTE_POST: u64 = 16;
    const E_LOW_RATING_UPVOTE_REPLY: u64 = 17;
    const E_LOW_RATING_VOTE_COMMENT: u64 = 18;
    const E_LOW_RATING_DOWNVOTE_POST: u64 = 19;
    const E_LOW_RATING_DOWNVOTE_REPLY: u64 = 20;
    const E_LOW_RATING_CANCEL_VOTE: u64 = 21;
    const E_LOW_RATING_MARK_BEST_REPLY: u64 = 22;
    const E_CHECK_FUNCTION_getMutableTotalRewardShare: u64 = 99; // todo

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

    struct UsersRatingCollection has key {
        id: UID,
        /// All `users` rating in all `communities`. Table key - `user object id`
        usersCommunityRating: Table<ID, UserCommunityRating>,
    }

    struct User has key {
        id: UID,
        /// `IPFS hash` of document with `user` information
        ipfsDoc: commonLib::IpfsHash,
        /// Followed `communities` for the `user`
        followedCommunities: vector<ID>,
        /// `Object rating id` for the `user`
        userRatingId: ID,   // need?
        /// `Properties` for the `user`
        properties: VecMap<u8, vector<u8>>,
    }

    struct UserCommunityRating has key, store {    // shared
        id: UID,
        /// `Community rating` for the `user`. Depends on `object community id`. VecMap key - `communityId`
        userRating: VecMap<ID, i64Lib::I64>,                // vecMap??
        /// `Properties` for the `user rating`
        properties: VecMap<u8, vector<u8>>,
    }

    // ====== Events ======

    struct CreateUserEvent has copy, drop {
        userId: ID,
    }

    struct UpdateUserEvent has copy, drop {
        userId: ID,
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(UsersRatingCollection {
            id: object::new(ctx),
            usersCommunityRating: table::new(ctx),
        });
    }

    /// Create new `user` info record
    public entry fun createUser(usersRatingCollection: &mut UsersRatingCollection, ipfsHash: vector<u8>, ctx: &mut TxContext) {
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash()); // TODO: TEST
        let owner = tx_context::sender(ctx);

        let userCommunityRating = UserCommunityRating {
            id: object::new(ctx),
            userRating: vec_map::empty(),
            properties: vec_map::empty(),
        };
        let user = User {
            id: object::new(ctx),
            ipfsDoc: commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>()),
            followedCommunities: vector::empty<ID>(),
            userRatingId: object::id(&userCommunityRating),
            properties: vec_map::empty(),
        };

        table::add(&mut usersRatingCollection.usersCommunityRating, object::id(&user), userCommunityRating);
        event::emit(CreateUserEvent {userId: object::id(&user)});
        transfer::transfer(
            user, owner
        );
    }

    /// Update `user` info record
    public entry fun updateUser(user: &mut User, ipfsHash: vector<u8>) {
        assert!(!commonLib::isEmptyIpfs(ipfsHash), commonLib::getErrorInvalidIpfsHash()); // TODO: TEST

        user.ipfsDoc = commonLib::getIpfsDoc(ipfsHash, vector::empty<u8>());
        event::emit(UpdateUserEvent {userId: object::id(user)});
    }

    /// Grant the `role` for the `user object id`
    public entry fun grantRole(userRolesCollection: &mut accessControlLib::UserRolesCollection, admin: &User, userId: ID, role: vector<u8>) {
        let adminId = object::id(admin);
        accessControlLib::grantRole(userRolesCollection, adminId, userId, role)
    }

    /// Revoke the `role` for the `user object id`
    public entry fun revokeRole(userRolesCollection: &mut accessControlLib::UserRolesCollection, admin: &User, userId: ID, role: vector<u8>) {
        let adminId = object::id(admin);
        accessControlLib::revokeRole(userRolesCollection, adminId, userId, role)
    }

    /// Get user's `folowed communies` by `user object id`
    public(friend) fun getUserFollowedCommunities(user: &User): &vector<ID> {
        &user.followedCommunities
    }

    /// Follow to the `object community id` for `user object id`
    public(friend) fun followCommunity(user: &mut User, communityId: ID) {
        vector::push_back(&mut user.followedCommunities, communityId);
    }

    /// Unfollow from the `object community id` for `user object id`
    public(friend) fun unfollowCommunity(user: &mut User, communityIndex: u64) {
        vector::remove(&mut user.followedCommunities, communityIndex);
    }

    /*plug*/
    // to do arguments: userRating, acievements, userId...
    /// Update rating for `user object id` in `community object id`
    public(friend) fun updateRating(
        usersRatingCollection: &mut UsersRatingCollection,
        userId: ID,
        achievementCollection: &mut nftLib::AchievementCollection,
        rating: i64Lib::I64,
        communityId: ID,
        ctx: &mut TxContext
    ) {
        if (userId == commonLib::get_bot_id())
            return;
        if (i64Lib::compare(&rating, &i64Lib::zero()) == i64Lib::getEual())
            return;

        let userCommunityRating = getMutableUserCommunityRating(usersRatingCollection, userId);
        let position = vec_map::get_idx_opt(&mut userCommunityRating.userRating, &communityId);
        if (option::is_none(&position)) {
            vec_map::insert(&mut userCommunityRating.userRating, communityId, i64Lib::from(START_USER_RATING));
        };

        let userRating = vec_map::get_mut(&mut userCommunityRating.userRating, &communityId);
        *userRating = i64Lib::add(&*userRating, &rating);

        let isGrovedRating = i64Lib::compare(&rating, &i64Lib::zero()) == i64Lib::getGreaterThan();
        let isPositiveRating = i64Lib::compare(userRating, &i64Lib::zero()) == i64Lib::getGreaterThan();
        if (isGrovedRating && isPositiveRating) {
            let achievementsTypesArray: vector<u8> = vector[nftLib::getAchievementTypeRating()];
            nftLib::unlockAchievements(achievementCollection, userId, communityId, i64Lib::as_u64(userRating), achievementsTypesArray, ctx);
        }
    }

    /// Check the `role/rating` of the `user` to perform some action
    public fun checkActionRole(
        usersRatingCollection: &UsersRatingCollection,
        userRolesCollection: &accessControlLib::UserRolesCollection,
        actionCaller: &User,
        dataUserId: ID,
        communityId: ID,
        action: u8,
        actionRole: u8,
    ) {
        let actionCallerId = object::id(actionCaller);
        if (hasModeratorRole(userRolesCollection, actionCallerId, communityId)) {
            return
        };

        accessControlLib::checkHasRole(userRolesCollection, actionCallerId, actionRole, communityId);
        checkRating(usersRatingCollection, actionCallerId, dataUserId, communityId, action);
    }

    /// Check the `role/rating` of the `user` to perform some action
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

    /// Check the `user's rating` with rating what must be for the action
    public fun checkRating(
        usersRatingCollection: &UsersRatingCollection,
        actionCallerId: ID,
        dataUserId: ID,
        communityId: ID,
        action: u8
    ) {
        let userCommunityRating = getUserCommunityRating(usersRatingCollection, actionCallerId);
        let userRating = getUserRating(userCommunityRating, communityId);
        let (ratingAllowed, message) = getRatingForAction(actionCallerId, dataUserId, action);
        assert!(i64Lib::compare(&userRating, &ratingAllowed) != i64Lib::getLessThan(), message);
    }

    /// Get rating what must be for the action
    /// Return ratingAllowed and message
    fun getRatingForAction(
        actionCaller: ID,
        dataUser: ID,
        action: u8
    ): (i64Lib::I64, u64) {
        let ratingAllowed: i64Lib::I64 = i64Lib::neg_from(MINIMUM_RATING);
        let message: u64;

        if (action == ACTION_NONE) {
            ratingAllowed = i64Lib::zero();
            message = E_MUST_BE_0_RATING;
        } else if (action == ACTION_PUBLICATION_POST) {
            ratingAllowed = i64Lib::from(POST_QUESTION_ALLOWED);
            message = E_LOW_RATING_CREATE_POST; 

        } else if (action == ACTION_PUBLICATION_REPLY) {
            ratingAllowed = i64Lib::from(POST_REPLY_ALLOWED);
            message = E_LOW_RATING_CREATE_REPLY;

        } else if (action == ACTION_PUBLICATION_COMMENT) {
            if (actionCaller == dataUser) {
                ratingAllowed = i64Lib::from(POST_OWN_COMMENT_ALLOWED);
            } else {
                ratingAllowed = i64Lib::from(POST_COMMENT_ALLOWED);
            };
            message = E_LOW_RATING_CREATE_COMMENT;

        } else if (action == ACTION_EDIT_ITEM) {
            ratingAllowed = i64Lib::neg_from(MINIMUM_RATING);
            message = E_LOW_RATING_EDIT_ITEM;

        } else if (action == ACTION_DELETE_ITEM) {
            assert!(actionCaller == dataUser, E_NOT_ALLOWED_DELETE);
            ratingAllowed = i64Lib::zero();
            message = E_LOW_RATING_DELETE_ITEM; // delete own item?

        } else if (action == ACTION_UPVOTE_POST) {
            assert!(actionCaller != dataUser, E_NOT_ALLOWED_VOTE_POST);
            ratingAllowed = i64Lib::from(UPVOTE_POST_ALLOWED);
            message = E_LOW_RATING_UPVOTE_POST;

        } else if (action == ACTION_UPVOTE_REPLY) {
            assert!(actionCaller != dataUser, E_NOT_ALLOWED_VOTE_REPLY);
            ratingAllowed = i64Lib::from(UPVOTE_REPLY_ALLOWED);
            message = E_LOW_RATING_UPVOTE_REPLY;

        } else if (action == ACTION_VOTE_COMMENT) {
            assert!(actionCaller != dataUser, E_NOT_ALLOWED_VOTE_COMMENT);
            ratingAllowed = i64Lib::from(VOTE_COMMENT_ALLOWED);
            message = E_LOW_RATING_VOTE_COMMENT;

        } else if (action == ACTION_DOWNVOTE_POST) {
            assert!(actionCaller != dataUser, E_NOT_ALLOWED_VOTE_POST);     // NEED?
            ratingAllowed = i64Lib::from(DOWNVOTE_POST_ALLOWED);
            message = E_LOW_RATING_DOWNVOTE_POST;

        } else if (action == ACTION_DOWNVOTE_REPLY) {
            assert!(actionCaller != dataUser, DOWNVOTE_REPLY_ALLOWED);      // NEED?
            ratingAllowed = i64Lib::from(DOWNVOTE_REPLY_ALLOWED);
            message = E_LOW_RATING_DOWNVOTE_REPLY;

        } else if (action == ACTION_CANCEL_VOTE) {
            ratingAllowed = i64Lib::from(CANCEL_VOTE);
            message = E_LOW_RATING_CANCEL_VOTE;

        } else if (action == ACTION_BEST_REPLY) {       // test neg rating?
            message = E_LOW_RATING_MARK_BEST_REPLY;

        } else {
            abort E_NOT_ALLOWED_ACTION
        };
        (ratingAllowed, message)
    }

    /// Get the `user's rating`
    public fun getUserRating(userCommunityRating: &UserCommunityRating, communityId: ID): i64Lib::I64 {   // public?  + user &mut?
        let position = vec_map::get_idx_opt(&userCommunityRating.userRating, &communityId);
        if (option::is_none(&position)) {
            i64Lib::from(0)
        } else {
            *vec_map::get(&userCommunityRating.userRating, &communityId)
        }
    }

    /// Get the `user's rating objectId`
    public fun getUserRatingId(user: &User): ID {
        user.userRatingId
    }

    /// Get the `user's community rating`
    public fun getUserCommunityRating(usersRatingCollection: &UsersRatingCollection, userId: ID): &UserCommunityRating {
        table::borrow(&usersRatingCollection.usersCommunityRating, userId)
    }

    /// Get the mutable `user's community rating`
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

    // --- Testing functions ---

    #[test_only]
    /// Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(ctx)
    }

    #[test_only]
    public fun updateRating_test(usersRatingCollection: &mut UsersRatingCollection, userId: ID, achievementCollection: &mut nftLib::AchievementCollection, rating: i64Lib::I64, communityId: ID, ctx: &mut TxContext) {
        updateRating(usersRatingCollection, userId, achievementCollection, rating, communityId, ctx);
    }

    #[test_only]
    public fun getUserData(user: &mut User): (vector<u8>, vector<ID>) {
        (commonLib::getIpfsHash(user.ipfsDoc), user.followedCommunities)
    }

    #[test_only]
    public fun create_user(usersRatingCollection: &mut UsersRatingCollection, scenario: &mut TxContext) {
        createUser(usersRatingCollection, x"a267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1", scenario);
    }
}
