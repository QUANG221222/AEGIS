module aegis_addr::withdraw {
    use std::error;
    use std::signer;
    use cedra_framework::event;
    use cedra_framework::coin;
    use aegis_addr::pool;

    // Event emitted when tokens are withdrawn from a pool
    #[event]
    struct WithdrawEvent has drop, store {
        pool_address: address,
        withdrawer: address,
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

    // User cannot withdraw more than they deposited
    const E_EXCEED_USER_DEPOSIT: u64 = 6;

    // === Withdraw Functions ===

    // Withdraw amount tracking from a pool
    // Only pool owner can withdraw
    public entry fun withdraw<Currency>(
        pool_owner: &signer,
        amount: u64,
    ) {
        let pool_address = signer::address_of(pool_owner);
        
        // Verify pool exists
        assert!(pool::pool_exists<Currency>(pool_address), error::not_found(E_POOL_NOT_EXISTS));
        
        // Cannot withdraw zero amount
        assert!(amount > 0, error::invalid_argument(E_ZERO_AMOUNT));
        
        // Get current pool stats
        let (current_supply, current_borrowed) = pool::get_pool_stats<Currency>(pool_address);
        
        // Check sufficient balance (cannot withdraw borrowed funds)
        let available_balance = current_supply - current_borrowed;
        assert!(available_balance >= amount, error::invalid_state(E_INSUFFICIENT_BALANCE));
        
        // Calculate new total supply
        let new_total_supply = current_supply - amount;
        
        // Update pool state using Pool module's friend function
        pool::update_total_supply<Currency>(pool_address, new_total_supply);
        
        // Emit event
        event::emit(WithdrawEvent {
            pool_address,
            withdrawer: pool_address,
            amount,
            new_total_supply,
        });
    }

    // Withdraw coins with user deposit validation
    public entry fun withdraw_from_pool<Currency>(
        withdrawer: &signer,
        pool_address: address,
        amount: u64,
    ) {   
        // Verify pool exists
        assert!(pool::pool_exists<Currency>(pool_address), error::not_found(E_POOL_NOT_EXISTS));
        
        // Cannot withdraw zero amount
        assert!(amount > 0, error::invalid_argument(E_ZERO_AMOUNT));
        
        let withdrawer_addr = signer::address_of(withdrawer);
        
        // Check user's deposit amount
        let user_deposit = pool::get_user_deposit<Currency>(pool_address, withdrawer_addr);
        assert!(user_deposit >= amount, error::invalid_argument(E_EXCEED_USER_DEPOSIT));
        
        // Get current pool balance
        let pool_balance = pool::get_total_supply<Currency>(pool_address);
        assert!(pool_balance >= amount, error::invalid_state(E_INSUFFICIENT_BALANCE));
        
        // Withdraw coins from pool
        let coins = pool::withdraw_coins<Currency>(pool_address, amount);
        
        // Deposit coins to withdrawer's account
        coin::deposit(withdrawer_addr, coins);
        
        // Update user deposit tracking
        pool::update_user_deposit<Currency>(pool_address, withdrawer_addr, amount, false);
        
        // Get new total supply after withdrawal
        let new_total_supply = pool::get_total_supply<Currency>(pool_address);
        
        // Emit event
        event::emit(WithdrawEvent {
            pool_address,
            withdrawer: withdrawer_addr,
            amount,
            new_total_supply,
        });
    }

    // Check maximum amount user can withdraw
    #[view]
    public fun get_withdrawable_amount<Currency>(
        pool_address: address,
        user: address
    ): u64 {
        pool::get_user_deposit<Currency>(pool_address, user)
    }
}