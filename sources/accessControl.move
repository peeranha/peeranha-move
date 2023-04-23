module basics::accessControl {
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use sui::event;
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::table::{Self, Table};
    use sui::vec_map::{Self, VecMap};
    use std::option;

    // ====== Errors ======

    const E_ACCESS_CONTROL_MISSING_ROLE: u64 = 201;
    const E_ACCESS_CONTROL_CAN_ONLY_RENOUNCE_ROLE_FOR_SELF: u64 = 202;
    const E_ACCESS_CONTROL_CAN_NOT_GIVE_DEFAULT_ADMIN_ROLE: u64 = 203;
    const E_NOT_ALLOWED_NOT_ADMIN: u64 = 204;
    const E_NOT_ALLOWED_NOT_BOT: u64 = 205;
    const E_NOT_ALLOWED_NOT_DISPATHER: u64 = 206;
    const E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_MODERATOR: u64 = 207;
    const E_NOT_ALLOWED_ADMIN_OR_COMMUNITY_ADMIN: u64 = 208;
    const E_NOT_ALLOWED_NOT_COMMUNITY_ADMIN: u64 = 209;
    const E_NOT_ALLOWED_NOT_COMMUNITY_MODERATOR: u64 = 210;

    // ====== Constant ======

    const DEFAULT_ADMIN_ROLE: vector<u8> = vector<u8>[1];
    const PROTOCOL_ADMIN_ROLE: vector<u8> = vector<u8>[2];
    const COMMUNITY_ADMIN_ROLE: vector<u8> = vector<u8>[3];
    const COMMUNITY_MODERATOR_ROLE: vector<u8> = vector<u8>[4];
    const BOT_ROLE: vector<u8> = vector<u8>[5];
    const DISPATCHER_ROLE: vector<u8> = vector<u8>[6];

    // ====== Enum ======

    const ACTION_ROLE_NONE: u8 = 0;
    const ACTION_ROLE_BOT: u8 = 1;
    const ACTION_ROLE_ADMIN: u8 = 2;
    const ACTION_ROLE_DISPATCHER: u8 = 3;                           // need?
    const ACTION_ROLE_ADMIN_OR_COMMUNITY_MODERATOR: u8 = 4;
    const ACTION_ROLE_ADMIN_OR_COMMUNITY_ADMIN: u8 = 5;
    const ACTION_ROLE_COMMUNITY_ADMIN: u8 = 6;
    const ACTION_ROLE_COMMUNITY_MODERATOR: u8 = 7;

    struct RoleData has store {
        members: VecMap<ID, bool>,
        adminRole: vector<u8>
    }

    struct UserRolesCollection has key {
        id: UID,
        roles: Table<vector<u8>, RoleData>            // role
    }

    struct DefaultAdminCap has key {
        id: UID,
    }

    // ====== Events ======

    struct RoleAdminChanged has copy, drop {
        role: vector<u8>,
        previousAdminRole: vector<u8>,
        adminRole: vector<u8>,
    }

    struct RoleGranted has copy, drop {
        role: vector<u8>,
        userId: ID,
    }

    struct RoleRevoked has copy, drop {
        role: vector<u8>,
        userId: ID,
    }

    fun init(ctx: &mut TxContext) {
        let roles = UserRolesCollection {
            id: object::new(ctx),
            roles: table::new(ctx)
        };
        // give DEFAULT_ADMIN_ROLE ?

        // grantRole_(&mut roles, DEFAULT_ADMIN_ROLE, tx_context::sender(ctx));
        // grantRole_(&mut roles, PROTOCOL_ADMIN_ROLE, tx_context::sender(ctx));
        // setRoleAdmin_(&mut roles, PROTOCOL_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
        
        
        // _setRoleAdmin(BOT_ROLE, PROTOCOL_ADMIN_ROLE);
        // _setRoleAdmin(DISPATCHER_ROLE, PROTOCOL_ADMIN_ROLE);
        transfer::share_object(roles);

        transfer::transfer(
            DefaultAdminCap {
               id: object::new(ctx), 
            }, tx_context::sender(ctx)
        );
    }

    // bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    // public fun initRole(): Role {
    //     Role{roles: vec_map::empty()}
    // }

    public fun onlyRole(userRolesCollection: &UserRolesCollection, role: vector<u8>, userId: ID) {
        checkRole_(userRolesCollection, role, userId);
    }
    
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

    public fun checkRole_(userRolesCollection: &UserRolesCollection, role: vector<u8>, userId: ID) {
        checkRole(userRolesCollection, role, userId);
    }


    public fun checkRole(userRolesCollection: &UserRolesCollection, role: vector<u8>, userId: ID) {
        if (!hasRole(userRolesCollection, role, userId)) {
            abort E_ACCESS_CONTROL_MISSING_ROLE
            // revert(
            //     string(
            //         abi.encodePacked(
            //             "AccessControl: account ",
            //             StringsUpgradeable.toHexString(uint160(account), 20),
            //             " is missing role ",
            //             StringsUpgradeable.toHexString(uint256(role), 32)
            //         )
            //     )
            // );
        }
    }

    public fun getRoleAdmin(userRolesCollection: &UserRolesCollection, role: vector<u8>): vector<u8> {
        if (table::contains(&userRolesCollection.roles, role)) {
            let role = table::borrow(&userRolesCollection.roles, role);
            role.adminRole
        } else {
            vector::empty<u8>()
        }
    }

    public entry fun grantRole(userRolesCollection: &mut UserRolesCollection, role: vector<u8>, userId: ID) {
        assert!(role == DEFAULT_ADMIN_ROLE, E_ACCESS_CONTROL_CAN_NOT_GIVE_DEFAULT_ADMIN_ROLE);

        let adminRole = getRoleAdmin(userRolesCollection, role);
        onlyRole(userRolesCollection, adminRole, userId);
        grantRole_(userRolesCollection, role, userId);
    }

    public entry fun grantProtocolAdminRole(_: &DefaultAdminCap, userRolesCollection: &mut UserRolesCollection, userId: ID) {
        grantRole_(userRolesCollection, PROTOCOL_ADMIN_ROLE, userId);
    }

    public entry fun revokeRole(userRolesCollection: &mut UserRolesCollection, role: vector<u8>, userId: ID) {    // add revokeProtocolAdminRole
        let adminRole = getRoleAdmin(userRolesCollection, role);
        onlyRole(userRolesCollection, adminRole, userId);
        revokeRole_(userRolesCollection, role, userId);
    }

    public fun renounceRole(userRolesCollection: &mut UserRolesCollection, role: vector<u8>, userId: ID) {
        // assert!(account == tx_context::sender(ctx), E_ACCESS_CONTROL_CAN_ONLY_RENOUNCE_ROLE_FOR_SELF);       // ?????
        revokeRole_(userRolesCollection, role, userId);
    }

    public fun setupRole_(userRolesCollection: &mut UserRolesCollection, role: vector<u8>, userId: ID) {
        grantRole_(userRolesCollection, role, userId);
    }

    public entry fun setRoleAdmin_(userRolesCollection: &mut UserRolesCollection, role: vector<u8>, adminRole: vector<u8>) {
        let previousAdminRole = getRoleAdmin(userRolesCollection, role);

        if (table::contains(&userRolesCollection.roles, role)) {
            let role = table::borrow_mut(&mut userRolesCollection.roles, role);
            role.adminRole = adminRole;
        } else {
            table::add(&mut userRolesCollection.roles, role, RoleData {
                members: vec_map::empty(),
                adminRole: adminRole
            });
        };

        event::emit(RoleAdminChanged{role, previousAdminRole, adminRole});
    }

    // Internal function without access restriction.
    fun grantRole_(userRolesCollection: &mut UserRolesCollection, role: vector<u8>, userId: ID) {
        if (!hasRole(userRolesCollection, role, userId)) {
            if (!table::contains(&userRolesCollection.roles, role)) {
                // let mapPeriodRating: VecMap<u64, PeriodRating> = vec_map::empty();

                table::add(&mut userRolesCollection.roles, role, RoleData {
                    members: vec_map::empty(),
                    adminRole: vector::empty<u8>()
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
            event::emit(RoleGranted{role, userId});    // , _msgSender()????
        }
    }     
    
    // Internal function without access restriction.
    fun revokeRole_(userRolesCollection: &mut UserRolesCollection, role: vector<u8>, userId: ID) {
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
            event::emit(RoleRevoked{role, userId});    // , _msgSender() ??
        }
    }

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
            errorType = E_NOT_ALLOWED_NOT_BOT
        } else if (actionRole == ACTION_ROLE_DISPATCHER && !hasRole(userRolesCollection, DISPATCHER_ROLE, userId)) {
            errorType = E_NOT_ALLOWED_NOT_DISPATHER
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

    fun getCommunityRole(roleTemplate: vector<u8>, communityId: ID): vector<u8> {
        vector::append<u8>(&mut roleTemplate, object::id_to_bytes(&communityId));
        roleTemplate
    }

    public fun get_action_role_none(): u8 {
        ACTION_ROLE_NONE
    }

    public fun get_action_role_admin(): u8 {
        ACTION_ROLE_ADMIN
    }

    public fun get_action_role_bot(): u8 {
        ACTION_ROLE_BOT
    }

    public fun get_action_role_dispatcher(): u8 {
        ACTION_ROLE_DISPATCHER
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
}
