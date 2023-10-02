module peeranha::accessControlLib {
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use sui::event;
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::table::{Self, Table};
    use sui::vec_map::{Self, VecMap};
    use std::option;
    friend peeranha::communityLib;
    friend peeranha::userLib;

    // ====== Errors. Available values 300 - 399 ======

    const E_ACCESS_CONTROL_MISSING_ROLE: u64 = 300;                      // test all error
    const E_ACCESS_CONTROL_CAN_NOT_GIVE_PROTOCOL_ADMIN_ROLE: u64 = 301;
    const E_NOT_ALLOWED_NOT_ADMIN: u64 = 302;
    const E_NOT_ALLOWED_NOT_BOT_ROLE: u64 = 303;
    const E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_MODERATOR: u64 = 305;
    const E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_ADMIN: u64 = 306;
    const E_NOT_ALLOWED_NOT_COMMUNITY_ADMIN: u64 = 307;
    const E_NOT_ALLOWED_NOT_COMMUNITY_MODERATOR: u64 = 308;
    const E_EMPTY_ROLE: u64 = 309;                              // how test?  test_common_user_revoke_not_exist_role, test_common_user_grant_not_exist_role

    // ====== Constant ======

    const PROTOCOL_ADMIN_ROLE: vector<u8> = vector<u8>[2];
    const COMMUNITY_ADMIN_ROLE: vector<u8> = vector<u8>[3];
    const COMMUNITY_MODERATOR_ROLE: vector<u8> = vector<u8>[4];
    const BOT_ROLE: vector<u8> = vector<u8>[5];
    const DISPATCHER_ROLE: vector<u8> = vector<u8>[6];

    // ====== Enum ======

    const ACTION_ROLE_NONE: u8 = 0;
    const ACTION_ROLE_BOT: u8 = 1;
    const ACTION_ROLE_ADMIN: u8 = 2;
    const ACTION_ROLE_ADMIN_OR_COMMUNITY_MODERATOR: u8 = 4;
    const ACTION_ROLE_ADMIN_OR_COMMUNITY_ADMIN: u8 = 5;
    const ACTION_ROLE_COMMUNITY_ADMIN: u8 = 6;
    const ACTION_ROLE_COMMUNITY_MODERATOR: u8 = 7;
    const ACTION_ROLE_MINT_NFT: u8 = 8;

    struct UserRolesCollection has key {
        id: UID,
        /// All `roles` and `users object id` who have it. Table key - `role`
        roles: Table<vector<u8>, RoleData>,            // role
    }

    struct RoleData has store {
        /// `Users object id` who have the role. VecMap key - `user object id`
        members: VecMap<ID, bool>,
        /// `Role` which must be for grant the `role`
        adminRole: vector<u8>,
        /// `Properties` for the `role data`
        properties: VecMap<u8, vector<u8>>,
    }

    struct DefaultAdminCap has key {
        id: UID,
        /// `Properties` for the `default admin cap`
        properties: VecMap<u8, vector<u8>>,
    }

    // ====== Events ======

    struct RoleAdminChangedEvent has copy, drop {
        role: vector<u8>,
        previousAdminRole: vector<u8>,      // set??
        adminRole: vector<u8>,
    }

    struct RoleGrantedEvent has copy, drop {
        role: vector<u8>,
        userId: ID,
    }

    struct RoleRevokedEvent has copy, drop {
        role: vector<u8>,
        userId: ID,
    }

    fun init(ctx: &mut TxContext) {
        let userRolesCollection = UserRolesCollection {
            id: object::new(ctx),
            roles: table::new(ctx),
        };
        setRoleAdmin(&mut userRolesCollection, BOT_ROLE, PROTOCOL_ADMIN_ROLE);
        transfer::share_object(userRolesCollection);

        transfer::transfer(
            DefaultAdminCap {
                id: object::new(ctx),
                properties: vec_map::empty(),
            }, tx_context::sender(ctx)
        );
    }

    /// Returns `true` if `account` has been granted `role`.
    public fun hasRole(userRolesCollection: &UserRolesCollection, role: vector<u8>, userId: ID): bool {
        if (table::contains(&userRolesCollection.roles, role)) {
            let role = table::borrow(&userRolesCollection.roles, role);
            let accountPosition = vec_map::get_idx_opt(&role.members, &userId);
            if (option::is_none(&accountPosition)) {
                false
            } else {
                let status = *vec_map::get(&role.members, &userId);
                status
            }
        } else {
            false
        }
    }

    /// Abort if 'user object id' is missing `role`.
    public fun onlyRole(userRolesCollection: &UserRolesCollection, role: vector<u8>, userId: ID) {
        if (!hasRole(userRolesCollection, role, userId)) {
            abort E_ACCESS_CONTROL_MISSING_ROLE
        }
    }

    /// Returns the admin role that controls `role`. See {grantRole} and
    /// * {revokeRole}.
    public fun getRoleAdmin(userRolesCollection: &UserRolesCollection, role: vector<u8>): vector<u8> {
        if (table::contains(&userRolesCollection.roles, role)) {
            let role = table::borrow(&userRolesCollection.roles, role);
            role.adminRole
        } else {
            vector::empty<u8>()
        }
    }

    /// Grants `role` to `object user id`
    public(friend) fun grantRole(userRolesCollection: &mut UserRolesCollection, adminId: ID, userId: ID, role: vector<u8>) {
        assert!(role != PROTOCOL_ADMIN_ROLE, E_ACCESS_CONTROL_CAN_NOT_GIVE_PROTOCOL_ADMIN_ROLE);

        let adminRole = getRoleAdmin(userRolesCollection, role);
        onlyRole(userRolesCollection, adminRole, adminId);
        grantRole_(userRolesCollection, role, userId);
    }

    /// Grants `admin role` to `object user id`
    /// Only `default admin` can call
    public entry fun grantProtocolAdminRole(_: &DefaultAdminCap, userRolesCollection: &mut UserRolesCollection, userId: ID) {
        grantRole_(userRolesCollection, PROTOCOL_ADMIN_ROLE, userId);
    }

    /// Revokes `role` from `object user id`
    public(friend) fun revokeRole(userRolesCollection: &mut UserRolesCollection, adminId: ID, userId: ID, role: vector<u8>) {
        assert!(role != PROTOCOL_ADMIN_ROLE, E_ACCESS_CONTROL_CAN_NOT_GIVE_PROTOCOL_ADMIN_ROLE);

        let adminRole = getRoleAdmin(userRolesCollection, role);
        onlyRole(userRolesCollection, adminRole, adminId);
        revokeRole_(userRolesCollection, role, userId);
    }

    /// Revoke `admin role` from `object user id`
    /// Only `default admin` can call
    public entry fun revokeProtocolAdminRole(_: &DefaultAdminCap, userRolesCollection: &mut UserRolesCollection, userId: ID) {
        revokeRole_(userRolesCollection, PROTOCOL_ADMIN_ROLE, userId);
    }

    /// Sets `adminRole` as ``role``'s admin role.
    fun setRoleAdmin(userRolesCollection: &mut UserRolesCollection, role: vector<u8>, adminRole: vector<u8>) {
        let previousAdminRole = getRoleAdmin(userRolesCollection, role);

        if (table::contains(&userRolesCollection.roles, role)) {
            let role = table::borrow_mut(&mut userRolesCollection.roles, role);
            role.adminRole = adminRole;
        } else {
            table::add(&mut userRolesCollection.roles, role, RoleData {
                members: vec_map::empty(),
                adminRole: adminRole,
                properties: vec_map::empty(),
            });
        };

        event::emit(RoleAdminChangedEvent{role, previousAdminRole, adminRole});
    }

    /// Grants `role` to `object user id`.
    /// Internal function without access restriction.
    fun grantRole_(userRolesCollection: &mut UserRolesCollection, role: vector<u8>, userId: ID) {
        assert!(role != vector::empty<u8>(), E_EMPTY_ROLE);
        if (!hasRole(userRolesCollection, role, userId)) {
            if (!table::contains(&userRolesCollection.roles, role)) {
                // let mapPeriodRating: VecMap<u64, PeriodRating> = vec_map::empty();

                table::add(&mut userRolesCollection.roles, role, RoleData {
                    members: vec_map::empty(),
                    adminRole: vector::empty<u8>(),
                    properties: vec_map::empty(),
                });

                // vec_map::insert(&mut roles.roles.members, account, true)
            };

            let role_ = table::borrow_mut(&mut userRolesCollection.roles, role);
            let accountPosition = vec_map::get_idx_opt(&role_.members, &userId);
            if (option::is_none(&accountPosition)) {
                vec_map::insert(&mut role_.members, userId, true);
            } else {
                let status = vec_map::get_mut(&mut role_.members, &userId);
                *status = true;
            };
            event::emit(RoleGrantedEvent{role, userId});    // , _msgSender()????
        }
    }     
    
    /// Revokes `role` from `object user id`
    /// Internal function without access restriction.
    fun revokeRole_(userRolesCollection: &mut UserRolesCollection, role: vector<u8>, userId: ID) {
        assert!(role != vector::empty<u8>(), E_EMPTY_ROLE);
        if (hasRole(userRolesCollection, role, userId)) {
            if (!table::contains(&userRolesCollection.roles, role)) {
                return
            };

            let role_ = table::borrow_mut(&mut userRolesCollection.roles, role);
            let accountPosition = vec_map::get_idx_opt(&role_.members, &userId);
            if (option::is_none(&accountPosition)) {
                return
            } else {
                let status = vec_map::get_mut(&mut role_.members, &userId);
                *status = false;
            };
            event::emit(RoleRevokedEvent{role, userId});    // , _msgSender() ??
        }
    }

    /// Sets `adminRole` as ``role``'s admin role for 'communityAdminRole' and `communityModeratorRole`.
    public(friend) fun setCommunityPermission(userRolesCollection: &mut UserRolesCollection, communityId: ID, userId: ID) {
        let communityAdminRole = getCommunityRole(COMMUNITY_ADMIN_ROLE, communityId);
        let communityModeratorRole = getCommunityRole(COMMUNITY_MODERATOR_ROLE, communityId);

        setRoleAdmin(userRolesCollection, communityModeratorRole, communityAdminRole);
        setRoleAdmin(userRolesCollection, communityAdminRole, PROTOCOL_ADMIN_ROLE);

        grantRole_(userRolesCollection, communityAdminRole, userId);        // test
        grantRole_(userRolesCollection, communityModeratorRole, userId);    // test
    }

    /// Abort if `user object id` is missing `actionRole`.
    public fun checkHasRole(userRolesCollection: &UserRolesCollection, userId: ID, actionRole: u8, communityId: ID) {
        // TODO: fix error messages. If checkActionRole() call checkHasRole() admin and comModerator can do actions. But about they are not mentioned in error message.
        let isAdmin = hasRole(userRolesCollection, PROTOCOL_ADMIN_ROLE, userId);
        let isCommunityAdmin = hasRole(userRolesCollection, getCommunityRole(COMMUNITY_ADMIN_ROLE, communityId), userId);
        let isCommunityModerator = hasRole(userRolesCollection, getCommunityRole(COMMUNITY_MODERATOR_ROLE, communityId), userId);

        let errorType;
        if (actionRole == ACTION_ROLE_NONE) {
            return
        } else if (actionRole == ACTION_ROLE_ADMIN && !isAdmin) {
            errorType = E_NOT_ALLOWED_NOT_ADMIN
        } else if (actionRole == ACTION_ROLE_BOT && !hasRole(userRolesCollection, BOT_ROLE, userId)) {
            errorType = E_NOT_ALLOWED_NOT_BOT_ROLE
        } else if (actionRole == ACTION_ROLE_ADMIN_OR_COMMUNITY_MODERATOR && 
            !(isAdmin || (isCommunityModerator))) {
            errorType = E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_MODERATOR
        } else if (actionRole == ACTION_ROLE_ADMIN_OR_COMMUNITY_ADMIN && !(isAdmin || (isCommunityAdmin))) {
            errorType = E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_ADMIN
        } else if (actionRole == ACTION_ROLE_COMMUNITY_ADMIN && !isCommunityAdmin) {
            errorType = E_NOT_ALLOWED_NOT_COMMUNITY_ADMIN
        } else if (actionRole == ACTION_ROLE_COMMUNITY_MODERATOR && !isCommunityModerator) {
            errorType = E_NOT_ALLOWED_NOT_COMMUNITY_MODERATOR
        } else {
            return
        };

        abort errorType
    }

    /// Get community role from `community roleTemplate` and `community object id`
    public fun getCommunityRole(roleTemplate: vector<u8>, communityId: ID): vector<u8> {
        vector::append<u8>(&mut roleTemplate, object::id_to_bytes(&communityId));
        roleTemplate
    }

    // ====== get enum "action role" ======

    public fun get_action_role_none(): u8 {
        ACTION_ROLE_NONE
    }

    public fun get_action_role_admin(): u8 {
        ACTION_ROLE_ADMIN
    }

    public fun get_action_role_bot(): u8 {
        ACTION_ROLE_BOT
    }

    public fun get_action_role_admin_or_community_moderator(): u8 {
        ACTION_ROLE_ADMIN_OR_COMMUNITY_MODERATOR
    }

    public fun get_action_role_admin_or_community_admin(): u8 {
        ACTION_ROLE_ADMIN_OR_COMMUNITY_ADMIN
    }

    public fun get_action_role_community_admin(): u8 {
        ACTION_ROLE_COMMUNITY_ADMIN
    }

    public fun get_action_role_community_moderator(): u8 {
        ACTION_ROLE_COMMUNITY_MODERATOR
    }

    public fun get_action_role_mint_nft(): u8 {
        ACTION_ROLE_MINT_NFT
    }

    // ====== get role ======

    public fun get_protocol_admin_role(): vector<u8> {
        PROTOCOL_ADMIN_ROLE
    }

    public fun get_community_admin_role(): vector<u8> {
        COMMUNITY_ADMIN_ROLE
    }

    public fun get_community_moderator_role(): vector<u8> {
        COMMUNITY_MODERATOR_ROLE
    }

    // --- Testing functions ---

    #[test_only]
    /// Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(ctx)
    }
}
