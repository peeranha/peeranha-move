module basics::achievementLib {
    use sui::object;
    use basics::accessControlLib;
    use basics::communityLib;
    use basics::userLib;
    use basics::commonLib;
    use basics::nftLib;
    use sui::tx_context::{TxContext};

    public entry fun configure_new_nft(
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
        nftLib::configure_new_nft(achievementCollection, maxCount, lowerBound, name, description, url, achievementsType, commonLib::getZeroId(), ctx);
    }

    public entry fun configure_new_community_nft(
        roles: &accessControlLib::UserRolesCollection,
        achievementCollection: &mut nftLib::AchievementCollection,
        user: &userLib::User,
        maxCount: u32,
        lowerBound: u64,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        community: &communityLib::Community,
        achievementsType: u8,
        ctx: &mut TxContext
    ) {
        let userId = object::id(user);
        accessControlLib::checkHasRole(roles, userId, accessControlLib::get_action_role_admin_or_community_admin(), object::id(community));
        communityLib::onlyNotFrozenCommunity(community);
        nftLib::configure_new_nft(achievementCollection, maxCount, lowerBound, name, description, url, achievementsType, object::id(community), ctx);
    }
}