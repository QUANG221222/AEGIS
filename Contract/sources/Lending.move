module aegis_addr::lending {
    use std::error;
    use std::signer;
    use cedra_framework::event;
    use cedra_framework::coin;
    use aegis_addr::pool;

    // === Events ===
    // Event emitted when tokens are deposited into a pool
    #[event]
    struct DepositEvent has drop, store {
        pool_address: address,
        depositor: address,
        amount: u64,
        new_total_supply: u64,
    }

    // Error codes
    // Pool does not exist
    const E_POOL_NOT_EXISTS: u64 = 1;
    
    // Insufficient balance for withdrawal
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    
    // Cannot withdraw zero amount
    const E_ZERO_AMOUNT: u64 = 3;
    
    // Pool already exists
    const E_POOL_ALREADY_EXISTS: u64 = 4;

    // Not the pool admin
    const E_NOT_ADMIN: u64 = 5;

    // Cannot initialize UserDeposits - not pool admin
    const E_CANNOT_INIT_USER_DEPOSITS: u64 = 6;

    // === Deposit Functions ===

    // Deposit amount tracking into an existing pool
    // Updates the pool's total_supply (simulates token storage)
    public entry fun deposit_v1<Currency>(
        depositor: &signer,
        pool_address: address,
        amount: u64,
    ) {
        // Verify pool exists
        assert!(pool::pool_exists<Currency>(pool_address), error::not_found(E_POOL_NOT_EXISTS));
        
        // Cannot deposit zero amount
        assert!(amount > 0, error::invalid_argument(E_ZERO_AMOUNT));
        
        // Get current pool stats
        let (current_supply, _) = pool::get_pool_stats<Currency>(pool_address);
        
        // Calculate new total supply
        let new_total_supply = current_supply + amount;
        
        // Update pool state using Pool module's friend function
        pool::update_total_supply<Currency>(pool_address, new_total_supply);
        
        // Emit event
        event::emit(DepositEvent {
            pool_address,
            depositor: signer::address_of(depositor),
            amount,
            new_total_supply,
        });
    }

    // === Deposit Functions ===

    // Deposit actual coins into pool with user tracking
    public entry fun deposit<Currency>(
        depositor: &signer,
        pool_address: address,
        amount: u64,
    ) {
        // Verify pool exists
        assert!(pool::pool_exists<Currency>(pool_address), error::not_found(E_POOL_NOT_EXISTS));
        
        // Cannot deposit zero amount
        assert!(amount > 0, error::invalid_argument(E_ZERO_AMOUNT));
        
        // Check if depositor has sufficient balance
        let depositor_addr = signer::address_of(depositor);
        assert!(coin::balance<Currency>(depositor_addr) >= amount, error::invalid_argument(E_INSUFFICIENT_BALANCE));
        
        // Withdraw coins from depositor
        let coins = coin::withdraw<Currency>(depositor, amount);
        
        // Deposit coins to pool
        pool::deposit_coins<Currency>(pool_address, coins);

        // Check if UserDeposits exists, if not initialize it
        if (!pool::user_deposits_exists<Currency>(pool_address)) {
            // Note: This requires the pool admin to sign for initialization
            // For now, we'll add a workaround by checking if depositor is pool admin
            let pool_admin = pool::get_pool_address<Currency>(pool_address);
            if (depositor_addr == pool_admin) {
                pool::init_user_deposits<Currency>(depositor);
            } else {
                // Cannot initialize UserDeposits as non-admin
                // This should be handled by pool admin beforehand
                assert!(false, error::permission_denied(E_CANNOT_INIT_USER_DEPOSITS));
            }
        };
        
        // Track user deposit
        pool::update_user_deposit<Currency>(pool_address, depositor_addr, amount, true);
        
        // Emit event
        let new_total_supply = pool::get_total_supply<Currency>(pool_address);
        event::emit(DepositEvent {
            pool_address,
            depositor: depositor_addr,
            amount,
            new_total_supply,
        });
    }
}