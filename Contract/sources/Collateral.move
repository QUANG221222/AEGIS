// # Collateral Module
// 
// This module manages collateral deposits for the lending protocol.
// Users can deposit collateral to secure their borrowing positions,
// and the system can liquidate collateral when health factors drop below safe levels.
//
// Key Features:
// - Deposit collateral assets
// - Withdraw collateral (if health factor remains safe)
// - Liquidate under-collateralized positions
// - Calculate collateral value and health factors
// - Support multiple collateral asset types

module aegis_addr::collateral {
    use std::error;
    use std::signer;
    use cedra_framework::event;
    use cedra_framework::timestamp;
    use cedra_framework::coin;  // Add this import for coin operations
    use aegis_addr::oracle;

    // === Vault for storing collateral coins ===
    
    // Vault to store actual collateral coins
    struct CollateralVault<phantom Currency> has key {
        coins: coin::Coin<Currency>,
        admin: address,
    }

    // === Events ===
    
    // Event emitted when collateral is deposited
    #[event]
    struct CollateralDepositEvent has drop, store {
        user: address,
        collateral_type: address,
        amount: u64,
        total_collateral: u64,
        timestamp: u64,
    }

    // Event emitted when collateral is withdrawn
    #[event]
    struct CollateralWithdrawEvent has drop, store {
        user: address,
        collateral_type: address,
        amount: u64,
        remaining_collateral: u64,
        timestamp: u64,
    }

    // Event emitted when liquidation occurs
    #[event]
    struct LiquidationEvent has drop, store {
        liquidator: address,
        borrower: address,
        collateral_type: address,
        liquidated_amount: u64,
        debt_repaid: u64,
        liquidation_bonus: u64,
        timestamp: u64,
    }

    // === Structs ===

    // User's collateral account holding multiple types of collateral
    struct CollateralAccount has key {
        // Map of collateral type -> amount deposited
        // We'll use a simple approach with individual fields for different types
        // In a more advanced implementation, this could use a Table or SimpleMap
        owner: address,
    }

    // Individual collateral position for a specific asset type
    struct CollateralPosition<phantom Currency> has key {
        owner: address,
        amount: u64,
        last_update: u64,
    }

    // Collateral configuration for an asset type
    struct CollateralConfig<phantom Currency> has key {
        admin: address,
        // Loan-to-Value ratio (e.g., 75% = 7500)
        ltv_ratio: u64,
        // Liquidation threshold (e.g., 80% = 8000)
        liquidation_threshold: u64,
        // Liquidation bonus for liquidators (e.g., 5% = 500)
        liquidation_bonus: u64,
        // Minimum collateral amount required
        min_collateral: u64,
        // Whether this asset can be used as collateral
        is_active: bool,
        // Approved oracle to prevent manipulation
        approved_oracle: address,
        // Approved debt pool
        approved_debt_pool: address,
    }

    // === Error Codes ===
    
    const E_COLLATERAL_NOT_EXISTS: u64 = 1;
    const E_INSUFFICIENT_COLLATERAL: u64 = 2;
    const E_ZERO_AMOUNT: u64 = 3;
    const E_NOT_AUTHORIZED: u64 = 4;
    const E_COLLATERAL_CONFIG_NOT_EXISTS: u64 = 5;
    const E_COLLATERAL_NOT_ACTIVE: u64 = 6;
    const E_HEALTH_FACTOR_TOO_LOW: u64 = 7;
    const E_POSITION_HEALTHY: u64 = 8;
    const E_MIN_COLLATERAL_NOT_MET: u64 = 9;
    const E_ORACLE_NOT_EXISTS: u64 = 10;

    // === Constants ===
    
    // Basis points for percentage calculations (10000 = 100%)
    const BASIS_POINTS: u64 = 10000;
    // Minimum health factor to avoid liquidation (1.1 = 11000)
    const MIN_HEALTH_FACTOR: u64 = 11000;
    // Precision for calculations
    const PRECISION: u64 = 100000000; // 8 decimals

    // === Admin Functions ===

    // Initialize collateral configuration for an asset type
    public entry fun init_collateral_config<Currency>(
        admin: &signer,
        ltv_ratio: u64,
        liquidation_threshold: u64,
        liquidation_bonus: u64,
        min_collateral: u64,
        approved_oracle: address,
        approved_debt_pool: address,
    ) {
        let admin_addr = signer::address_of(admin);
        
        // Initialize vault for storing collateral
        let vault = CollateralVault<Currency> {
            coins: coin::zero<Currency>(),
            admin: admin_addr,
        };
        move_to(admin, vault);

        let config = CollateralConfig<Currency> {
            admin: admin_addr,
            ltv_ratio,
            liquidation_threshold,
            liquidation_bonus,
            min_collateral,
            is_active: true,
            approved_oracle,
            approved_debt_pool,
        };

        move_to(admin, config);
    }

    // Update collateral configuration (admin only)
    public entry fun update_collateral_config<Currency>(
        admin: &signer,
        config_address: address,
        is_active: bool,
    ) acquires CollateralConfig {
        let admin_addr = signer::address_of(admin);
        let config = borrow_global_mut<CollateralConfig<Currency>>(config_address);
        assert!(config.admin == admin_addr, error::permission_denied(E_NOT_AUTHORIZED));
        config.is_active = is_active;
    }

    // === User Functions ===

    // Initialize user's collateral account
    public entry fun init_collateral_account(user: &signer) {
        let user_addr = signer::address_of(user);
        let account = CollateralAccount {
            owner: user_addr,
        };
        move_to(user, account);
    }

    // Deposit collateral for a specific currency type
    public entry fun deposit_collateral<Currency>(
        user: &signer,
        config_address: address,
        amount: u64,
    ) acquires CollateralPosition, CollateralConfig, CollateralVault {
        // CollateralAccount is created on first deposit if not exists
        let user_addr = signer::address_of(user);
        
        // Validate inputs
        assert!(amount > 0, error::invalid_argument(E_ZERO_AMOUNT));
        assert!(exists<CollateralConfig<Currency>>(config_address), error::not_found(E_COLLATERAL_CONFIG_NOT_EXISTS));

        // Check collateral config
        let config = borrow_global<CollateralConfig<Currency>>(config_address);
        assert!(config.is_active, error::invalid_state(E_COLLATERAL_NOT_ACTIVE));
        assert!(amount >= config.min_collateral, error::invalid_argument(E_MIN_COLLATERAL_NOT_MET));

        // Validate oracle exists
        assert!(oracle::price_exists<Currency>(config.approved_oracle), error::not_found(E_ORACLE_NOT_EXISTS));

        // Transfer actual coins from user to vault
        let deposit_coins = coin::withdraw<Currency>(user, amount);
        let vault = borrow_global_mut<CollateralVault<Currency>>(config_address);
        coin::merge(&mut vault.coins, deposit_coins);

        // Initialize collateral account if it doesn't exist
        if (!exists<CollateralAccount>(user_addr)) {
            let account = CollateralAccount {
                owner: user_addr,
            };
            move_to(user, account);
        };

        // Update or create collateral position
        let current_time = timestamp::now_seconds();
        
        if (exists<CollateralPosition<Currency>>(user_addr)) {
            let position = borrow_global_mut<CollateralPosition<Currency>>(user_addr);
            position.amount = position.amount + amount;
            position.last_update = current_time;
        } else {
            let position = CollateralPosition<Currency> {
                owner: user_addr,
                amount,
                last_update: current_time,
            };
            move_to(user, position);
        };

        // Get final collateral amount for event
        let final_amount = {
            let position = borrow_global<CollateralPosition<Currency>>(user_addr);
            position.amount
        };

        // Emit event
        event::emit(CollateralDepositEvent {
            user: user_addr,
            collateral_type: config_address,
            amount,
            total_collateral: final_amount,
            timestamp: current_time,
        });
    }

    // Withdraw collateral (only if health factor remains safe)
    public entry fun withdraw_collateral<Currency>(
        user: &signer,
        config_address: address,
        amount: u64,
    ) acquires CollateralPosition, CollateralConfig, CollateralVault {
        let user_addr = signer::address_of(user);
        
        // Validate inputs
        assert!(amount > 0, error::invalid_argument(E_ZERO_AMOUNT));
        assert!(exists<CollateralPosition<Currency>>(user_addr), error::not_found(E_COLLATERAL_NOT_EXISTS));
        assert!(exists<CollateralConfig<Currency>>(config_address), error::not_found(E_COLLATERAL_CONFIG_NOT_EXISTS));

        let config = borrow_global<CollateralConfig<Currency>>(config_address);
        let position = borrow_global_mut<CollateralPosition<Currency>>(user_addr);
        assert!(position.amount >= amount, error::invalid_argument(E_INSUFFICIENT_COLLATERAL));

        // Calculate health factor after withdrawal
        let remaining_collateral = position.amount - amount;
        let health_factor = calculate_health_factor_single<Currency>(
            remaining_collateral,
            config_address,
            config.approved_oracle,
            @aegis_addr, // pool address
            user_addr
        );

        // Ensure health factor remains above minimum
        assert!(health_factor >= MIN_HEALTH_FACTOR, error::invalid_state(E_HEALTH_FACTOR_TOO_LOW));

        // Update position
        position.amount = remaining_collateral;
        position.last_update = timestamp::now_seconds();

        // Transfer actual coins back to user
        let vault = borrow_global_mut<CollateralVault<Currency>>(config_address);
        let withdrawn_coins = coin::extract(&mut vault.coins, amount);
        coin::deposit(user_addr, withdrawn_coins);

        // Emit event
        event::emit(CollateralWithdrawEvent {
            user: user_addr,
            collateral_type: config_address,
            amount,
            remaining_collateral,
            timestamp: timestamp::now_seconds(),
        });
    }

    // === View Functions ===

    // Get collateral amount for a user
    #[view]
    public fun get_collateral_amount<Currency>(user_address: address): u64 acquires CollateralPosition {
        if (!exists<CollateralPosition<Currency>>(user_address)) {
            return 0
        };
        let position = borrow_global<CollateralPosition<Currency>>(user_address);
        position.amount
    }

    // Calculate health factor for a position (simplified version)
    #[view]
    public fun calculate_health_factor_single<Currency>(
        collateral_amount: u64,
        config_address: address,
        oracle_address: address,
        _debt_pool_address: address,  // Pass this as parameter for now
        _user_address: address,
    ): u64 acquires CollateralConfig {
        if (collateral_amount == 0) {
            return 0
        };

        // Get collateral value in USDT
        let collateral_value = oracle::convert_to_usdt<Currency>(oracle_address, collateral_amount);
        
        // For now, return very high health factor since we don't have borrowing yet
        // TODO: Implement proper debt calculation when borrowing module is ready
        let user_debt = 0; // pool::get_user_borrowed<Currency>(debt_pool_address, user_address);
        if (user_debt == 0) {
            return PRECISION * 10 // Very high health factor when no debt
        };

        let debt_value_usdt = oracle::convert_to_usdt<Currency>(oracle_address, user_debt);
        let config = borrow_global<CollateralConfig<Currency>>(config_address);
        let liquidation_value = (collateral_value * config.liquidation_threshold) / BASIS_POINTS;

        (liquidation_value * PRECISION) / debt_value_usdt
    }

    // Check if position is liquidatable
    #[view]
    public fun is_liquidatable<Currency>(
        user_address: address,
        config_address: address,
        oracle_address: address,
        debt_pool_address: address,
    ): bool acquires CollateralPosition, CollateralConfig {
        if (!exists<CollateralPosition<Currency>>(user_address)) {
            return false
        };
        
        let health_factor = calculate_health_factor_single<Currency>(
            get_collateral_amount<Currency>(user_address),
            config_address,
            oracle_address,
            debt_pool_address,
            user_address
        );
        
        health_factor < MIN_HEALTH_FACTOR
    }
}
