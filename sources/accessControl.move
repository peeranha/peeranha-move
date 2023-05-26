module basics::accessControl {
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use sui::vec_map::{Self, VecMap};
    use std::option;


    /* errors */

    const E_ACCESS_CONTROL_MISSING_ROLE: u64 = 1;
    const E_ACCESS_CONTROL_CAN_ONLY_RENOUNCE_ROLE_FOR_SELF: u64 = 2;

    struct RoleData has store, drop, copy {
        members: VecMap<address, bool>,      
        adminRole: vector<u8>
    }

    struct Role has store, copy, drop {
        _roles: VecMap<vector<u8>, RoleData>        // private
    }

    // bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    public fun initRole(): Role {
        Role{_roles: vec_map::empty()}
    }

    public fun onlyRole(roles: &Role, role: vector<u8>, ctx: &TxContext) {
        checkRole_(roles, role, ctx);
    }
    
    public fun hasRole(roles: &Role, role: vector<u8>, account: address): bool {
        let position = vec_map::get_idx_opt(&roles._roles, &role);
        if (option::is_none(&position)) {
            false
        } else {
            let role = vec_map::get(&roles._roles, &role);      // rename  role -> roles ewerywhere

            let accountPosition = vec_map::get_idx_opt(&role.members, &account);
            if (option::is_none(&accountPosition)) {
                false
            } else {
                let status = *vec_map::get(&role.members, &account);
                status
            }
        }
    }

    public fun checkRole_(roles: &Role, role: vector<u8>, ctx: &TxContext) {
        let account = tx_context::sender(ctx);
        checkRole(roles, role, account);
    }


    public fun checkRole(roles: &Role, role: vector<u8>, account: address) {
        if (!hasRole(roles, role, account)) {
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

    public fun getRoleAdmin(roles: &Role, role: vector<u8>): vector<u8> {
        let position = vec_map::get_idx_opt(&roles._roles, &role);
        if (option::is_none(&position)) {
            vector::empty<u8>()
        } else {
            let role = vec_map::get(&roles._roles, &role);
            role.adminRole
        }
    }

    public fun grantRole(roles: &mut Role, role: vector<u8>, account: address, ctx: &TxContext) {
        let adminRole = getRoleAdmin(roles, role);
        onlyRole(roles, adminRole, ctx);

        grantRole_(roles, role, account);
    }

    public fun revokeRole(roles: &mut Role, role: vector<u8>, account: address, ctx: &TxContext) {
        let adminRole = getRoleAdmin(roles, role);
        onlyRole(roles, adminRole, ctx);
        revokeRole_(roles, role, account);
    }

    public fun renounceRole(roles: &mut Role, role: vector<u8>, account: address, ctx: &TxContext) {
        assert!(account == tx_context::sender(ctx), E_ACCESS_CONTROL_CAN_ONLY_RENOUNCE_ROLE_FOR_SELF);
        revokeRole_(roles, role, account);
    }

    public fun setupRole_(roles: &mut Role, role: vector<u8>, account: address) {
        grantRole_(roles, role, account);
    }

    public fun setRoleAdmin_(roles: &mut Role, role: vector<u8>, adminRole: vector<u8>) {
        let _previousAdminRole = getRoleAdmin(roles, role);

        let position = vec_map::get_idx_opt(&roles._roles, &role);
        if (option::is_none(&position)) {
            vec_map::insert(&mut roles._roles, role, RoleData {
                members: vec_map::empty(),      
                adminRole: adminRole
            });
        } else {
            let role = vec_map::get_mut(&mut roles._roles, &role);
            role.adminRole = adminRole;
        }

        // emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    public fun grantRole_(roles: &mut Role, role: vector<u8>, account: address) {
        if (!hasRole(roles, role, account)) {
            let position = vec_map::get_idx_opt(&roles._roles, &role);
            if (option::is_none(&position)) {
                // let mapPeriodRating: VecMap<u64, PeriodRating> = vec_map::empty();

                vec_map::insert(&mut roles._roles, role, RoleData {
                    members: vec_map::empty(),
                    adminRole: vector::empty<u8>()
                });
                // vec_map::insert(&mut roles._roles.members, account, true)
            };

            let role_ = vec_map::get_mut(&mut roles._roles, &role);
            let accountPosition = vec_map::get_idx_opt(&role_.members, &account);
            if (option::is_none(&accountPosition)) {
                vec_map::insert(&mut role_.members, account, true);
            } else {
                let status = vec_map::get_mut(&mut role_.members, &account);
                *status = true;
            }
            // emit RoleGranted(role, account, _msgSender());
        }
    }     
    

    public fun revokeRole_(roles: &mut Role, role: vector<u8>, account: address) {
        if (hasRole(roles, role, account)) {
            let position = vec_map::get_idx_opt(&roles._roles, &role);
            if (option::is_none(&position)) {
                return
            };

            let role_ = vec_map::get_mut(&mut roles._roles, &role);
            let accountPosition = vec_map::get_idx_opt(&role_.members, &account);
            if (option::is_none(&accountPosition)) {
                return
            } else {
                let status = vec_map::get_mut(&mut role_.members, &account);
                *status = false;
            }
            // emit RoleRevoked(role, account, _msgSender());
        }
    }
}
