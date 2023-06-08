module peeranha::followCommunityLib {
    use sui::event;
    use sui::object::{Self, ID};
    use std::vector;
    use peeranha::communityLib;
    use peeranha::userLib;
    use peeranha::commonLib;

    // ====== Errors ======

    const E_ALREADY_FOLLOWED: u64 = 11;
    const E_COMMUNITY_NOT_FOLOWED: u64 = 12;

    // ====== Events ======

    struct FollowCommunityEvent has copy, drop {
        userId: ID,
        communityId: ID
    }

    struct UnfollowCommunityEvent has copy, drop {
        userId: ID,
        communityId: ID
    }

    /// `User` follows the `community`
    public entry fun followCommunity(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        user: &mut userLib::User,
        community: &communityLib::Community
    ) {
        communityLib::onlyNotFrozenCommunity(community);
        let userId = object::id(user);
        let userCommunityRating = userLib::getUserCommunityRating(usersRatingCollection, userId);

        userLib::checkRating(
            user,
            userCommunityRating,
            userId,
            userId,
            commonLib::getZeroId(),
            userLib::get_action_follow_community()
        );

        let i = 0;
        let community_id = object::id(community);
        let userFolowedCommunities = userLib::getUserFollowedCommunities(user);
        let countFolowedCommunities = vector::length(userFolowedCommunities);
        while(i < countFolowedCommunities) {
            assert!(*vector::borrow(userFolowedCommunities, i) != community_id, E_ALREADY_FOLLOWED);
            i = i +1;
        };

        userLib::followCommunity(user, community_id);
        event::emit(FollowCommunityEvent{userId: userId, communityId: community_id});
    }

    /// `User` unfollows the `community`
    public entry fun unfollowCommunity(
        usersRatingCollection: &mut userLib::UsersRatingCollection,
        user: &mut userLib::User,
        community: &communityLib::Community
    ) {
        communityLib::onlyNotFrozenCommunity(community);
        let userId = object::id(user);
        let userCommunityRating = userLib::getUserCommunityRating(usersRatingCollection, userId);

        let user = userLib::checkRating(
            user,
            userCommunityRating,
            userId,
            userId,
            commonLib::getZeroId(),
            userLib::get_action_follow_community()
        );

        let i = 0;
        let community_id = object::id(community);
        let userFolowedCommunities = userLib::getUserFollowedCommunities(user);
        let countFolowedCommunities = vector::length(userFolowedCommunities);
        while(i < countFolowedCommunities) {
            if(*vector::borrow(userFolowedCommunities, i) == community_id) {
                userLib::unfollowCommunity(user, i);

                event::emit(UnfollowCommunityEvent{userId: userId, communityId: community_id});
                return
            };
            i = i +1;
        };
        abort E_COMMUNITY_NOT_FOLOWED
    }
}