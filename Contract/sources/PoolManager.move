// # Pool Manager Module
// 

module aegis_addr::pool_manager {
    use std::error;
    use std::signer;
    use aegis_addr::pool;

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

    // === Pool Management Functions ===

    // Create a new pool for a specific currency type
    // This is a wrapper around pool::init_pool with additional checks
    public entry fun create_pool<Currency>(account: &signer) {
        let pool_address = signer::address_of(account);
        
        // Check if pool already exists
        assert!(!pool::pool_exists<Currency>(pool_address), error::already_exists(E_POOL_ALREADY_EXISTS));
        
        // Create the pool
        pool::init_pool<Currency>(account);
    }

    // === View Functions ===

    // Get available balance for withdrawal (total_supply - total_borrowed)
    #[view]
    public fun get_available_balance<Currency>(pool_address: address): u64 {
        assert!(pool::pool_exists<Currency>(pool_address), error::not_found(E_POOL_NOT_EXISTS));
        
        let (total_supply, total_borrowed) = pool::get_pool_stats<Currency>(pool_address);
        total_supply - total_borrowed
    }

    // Check if a deposit is valid
    #[view]
    public fun can_deposit<Currency>(pool_address: address, amount: u64): bool {
        pool::pool_exists<Currency>(pool_address) && amount > 0
    }

    // Check if a withdrawal is valid
    #[view]
    public fun can_withdraw<Currency>(pool_address: address, amount: u64): bool {
        if (!pool::pool_exists<Currency>(pool_address) || amount == 0) {
            return false
        };
        
        let available = get_available_balance<Currency>(pool_address);
        available >= amount
    }

    // Check can borrow
    #[view]
    public fun can_borrow<Currency>(pool_address: address, amount: u64): bool {
        pool::pool_exists<Currency>(pool_address) && amount > 0 && amount <= get_available_balance<Currency>(pool_address)
    }
}