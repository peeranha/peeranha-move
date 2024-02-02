module peeranha::followCommunityLib {
    use sui::event;
    use sui::object::{Self, ID};
    use std::vector;
    use peeranha::communityLib;
    use peeranha::userLib;

    // ====== Errors ======

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
        user: &mut userLib::User,
        community: &communityLib::Community
    ) {
        communityLib::onlyNotFrozenCommunity(community);

        let i = 0;
        let community_id = object::id(community);
        let userFolowedCommunities = userLib::getUserFollowedCommunities(user);
        let countFolowedCommunities = vector::length(userFolowedCommunities);
        let isAlreadyFollowed = false;
        while(i < countFolowedCommunities) {
            if (*vector::borrow(userFolowedCommunities, i) == community_id) {
                isAlreadyFollowed = true;
                break;
            };
            i = i +1;
        };

        if (!isAlreadyFollowed)
            userLib::followCommunity(user, community_id);

        event::emit(FollowCommunityEvent{userId: object::id(user), communityId: community_id});
    }

    /// `User` unfollows the `community`
    public entry fun unfollowCommunity(
        user: &mut userLib::User,
        community: &communityLib::Community
    ) {
        communityLib::onlyNotFrozenCommunity(community);

        let i = 0;
        let community_id = object::id(community);
        let userFolowedCommunities = userLib::getUserFollowedCommunities(user);
        let countFolowedCommunities = vector::length(userFolowedCommunities);
        while(i < countFolowedCommunities) {
            if(*vector::borrow(userFolowedCommunities, i) == community_id) {
                userLib::unfollowCommunity(user, i);

                event::emit(UnfollowCommunityEvent{userId: object::id(user), communityId: community_id});
                return
            };
            i = i +1;
        };
        abort E_COMMUNITY_NOT_FOLOWED
    }
}