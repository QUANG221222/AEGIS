module aegis_addr::lending {
    use std::error;
    use std::signer;
    use cedra_framework::event;
    use aegis_addr::pool;

    // === Events ===
    /// Event emitted when tokens are deposited into a pool
    #[event]
    struct DepositEvent has drop, store {
        pool_address: address,
        depositor: address,
        amount: u64,
        new_total_supply: u64,
    }

    // Error codes
    /// Pool does not exist
    const E_POOL_NOT_EXISTS: u64 = 1;
    
    /// Insufficient balance for withdrawal
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    
    /// Cannot withdraw zero amount
    const E_ZERO_AMOUNT: u64 = 3;
    
    /// Pool already exists
    const E_POOL_ALREADY_EXISTS: u64 = 4;

    /// Not the pool admin
    const E_NOT_ADMIN: u64 = 5;

    // === Deposit Functions ===

    /// Deposit amount tracking into an existing pool
    /// Updates the pool's total_supply (simulates token storage)
    public entry fun deposit<Currency>(
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
}