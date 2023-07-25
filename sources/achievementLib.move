module peeranha::achievementLib {
    use sui::object;
    use peeranha::accessControlLib;
    use peeranha::communityLib;
    use peeranha::userLib;
    use peeranha::commonLib;
    use peeranha::nftLib;
    use sui::tx_context::{TxContext};
    use sui::object::{ID};

    public entry fun configureAchievement(
        roles: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        user: &userLib::User,
        maxCount: u32,
        lowerBound: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        achievementsType: u8,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        accessControlLib::checkHasRole(roles, userId, accessControlLib::get_action_role_admin(), commonLib::getZeroId());
        nftLib::configureAchievement(achievementCollection, commonLib::getZeroId(), maxCount, lowerBound, name, description, url, achievementsType, ctx);
    }

    public entry fun configureCommunityAchievement(
        roles: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        user: &userLib::User,
        community: &communityLib::Community,
        maxCount: u32,
        lowerBound: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        achievementsType: u8,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        accessControlLib::checkHasRole(roles, userId, accessControlLib::get_action_role_admin_or_community_admin(), object::id(community)); // test
        communityLib::onlyNotFrozenCommunity(community);
        nftLib::configureAchievement(achievementCollection, object::id(community), maxCount, lowerBound, name, description, url, achievementsType, ctx);
    }

    public entry fun mintUserNFT(
        achievementCollection: &mut nftLib::AchievementCollection,
        user: &userLib::User,
        achievementsKeys: vector<u64>,
        ctx: &mut TxContext
    ) {
        nftLib::mint(achievementCollection, object::id(user), achievementsKeys, ctx);
    }

    public entry fun unlockManualNft(
        roles: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        user: &userLib::User,
        targetUser: ID,
        achievementId: u64
    ) {
        accessControlLib::checkHasRole(roles, object::id(user), accessControlLib::get_action_role_admin(), commonLib::getZeroId()); //test
        nftLib::unlockManualNft(achievementCollection, targetUser, achievementId);
    }
}