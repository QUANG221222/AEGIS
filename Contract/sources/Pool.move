/// # Pool Module
/// 
/// This module implements a basic lending pool structure that can manage
/// different types of currencies/tokens. It tracks the total supply of tokens
/// in the pool and the total amount borrowed from the pool.
/// 
/// This is a minimal implementation that focuses on the core data structure
/// without implementing deposit, withdrawal, borrowing, or interest calculation
/// functionality yet.

module aegis_addr::pool {
    use std::signer;
    use std::error; 
    
    friend aegis_addr::lending;
    friend aegis_addr::pool_manager;
    friend aegis_addr::withdraw;
    friend aegis_addr::borrowing;
    friend aegis_addr::collateral; 
    friend aegis_addr::interest_payment;
    friend aegis_addr::interest_repayment; 
    
    // === Structs ===
    
    /// # Pool Resource
    /// 
    /// A generic pool that can hold any type of currency/token.
    /// The pool tracks two key metrics:
    /// - total_supply: The total amount of tokens available in the pool
    /// - total_borrowed: The total amount of tokens currently borrowed from the pool
    /// 
    /// The `has key` ability allows this struct to be stored as a resource
    /// under an account's address, making it globally accessible and owned
    /// by the account that publishes it.
    /// 
    /// Generic type parameter `Currency` allows the same pool logic to work
    /// with different token types (e.g., USDT, USDC, ETH, etc.)
    struct Pool<phantom Currency> has key {
        /// Address of the pool administrator
        admin: address,

        /// Total tokens managed by this pool
        /// This represents the liquidity available for borrowing
        total_supply: u64,
        
        /// Total tokens currently borrowed from this pool
        /// This should always be <= total_supply
        total_borrowed: u64,
        
        /// Total interest accumulated in the pool
        total_interest: u64,
        
        /// Annual Percentage Yield (APY) for this pool
        apy: u64,
        
        /// Timestamp of last update
        last_update: u64,
        
        /// Pool address for transfers
        address: address,
    }

    /// # Borrow Position Resource
    /// 
    /// Tracks individual user's borrowing position for a specific currency.
    /// Each user can have one borrow position per currency type.
    struct BorrowPosition<phantom Currency> has key {
        /// The pool from which this debt was borrowed
        pool: address,
        
        /// Amount currently borrowed by this user
        amount: u64,
        
        /// Timestamp when the position was last updated
        last_update: u64,
    }

    // === Error Codes ===
    const E_BORROW_POSITION_NOT_EXISTS: u64 = 1;
    const E_INVALID_POOL: u64 = 2;
    const E_INSUFFICIENT_BORROWED: u64 = 3;
    const E_POOL_NOT_EXISTS: u64 = 4;

    /// # Initialize Pool
    /// 
    /// Creates a new pool resource and publishes it under the signer's account.
    /// This function can only be called once per account per currency type.
    /// 
    /// ## Parameters
    /// - `account`: The signer who will own and control this pool
    /// 
    /// ## Behavior
    /// - Creates a new Pool<Currency> with zero supply and zero borrowed amount
    /// - Publishes the pool resource under the account's address
    /// - After calling this function, the pool exists but contains no tokens
    /// 
    /// ## Aborts
    /// - If a pool of the same currency type already exists under this account
    /// - If the account doesn't have permission to publish resources
    /// 
    /// ## Example Usage
    /// ```
    /// // Initialize a USDT pool
    /// init_pool<USDT>(&account);
    /// 
    /// // Initialize a different currency pool under the same account
    /// init_pool<USDC>(&account);
    /// ```

    public entry fun init_pool<Currency>(account: &signer) {
        use cedra_framework::timestamp;
        
        let admin_addr = signer::address_of(account);
        
        // Create a new pool with initial values
        let new_pool = Pool<Currency> {
            admin: admin_addr,
            total_supply: 0,
            total_borrowed: 0,
            total_interest: 0,
            apy: 500000, // Default 5% APY (500000 / 10000000 = 0.05)
            last_update: timestamp::now_seconds(),
            address: admin_addr,
        };
        
        // Publish the pool resource under the account's address
        // This makes the pool globally accessible at this address
        move_to(account, new_pool);
    }

    // === View Functions ===
    // These functions will be useful for querying pool state in the future

    /// Check if a pool exists for the given currency type at the specified address
    #[view]
    public fun pool_exists<Currency>(pool_address: address): bool {
        exists<Pool<Currency>>(pool_address)
    }

    /// Get the total supply of a pool (read-only access)
    #[view]
    public fun get_total_supply<Currency>(pool_address: address): u64 acquires Pool {
        let pool = borrow_global<Pool<Currency>>(pool_address);
        pool.total_supply
    }

    /// Get the total borrowed amount of a pool (read-only access)  
    #[view]
    public fun get_total_borrowed<Currency>(pool_address: address): u64 acquires Pool {
        let pool = borrow_global<Pool<Currency>>(pool_address);
        pool.total_borrowed
    }

    /// Get both total supply and total borrowed in one call
    #[view]
    public fun get_pool_stats<Currency>(pool_address: address): (u64, u64) acquires Pool {
        let pool = borrow_global<Pool<Currency>>(pool_address);
        (pool.total_supply, pool.total_borrowed)
    }

    /// Get the amount borrowed by a specific user
    #[view]
    public fun get_user_borrowed<Currency>(pool_address: address, borrower_addr: address): u64 acquires BorrowPosition {
        if (!exists<BorrowPosition<Currency>>(borrower_addr)) {
            return 0
        };
        let pos = borrow_global<BorrowPosition<Currency>>(borrower_addr);
        if (pos.pool != pool_address) {
            return 0
        };
        pos.amount
    }

    /// Repay debt for a user (used in liquidation)
    public(friend) fun repay_for_user<Currency>(
        pool_address: address,
        borrower_addr: address,
        repay_amount: u64
    ) acquires BorrowPosition, Pool {
        assert!(exists<BorrowPosition<Currency>>(borrower_addr), error::not_found(E_BORROW_POSITION_NOT_EXISTS));
        assert!(exists<Pool<Currency>>(pool_address), error::not_found(E_POOL_NOT_EXISTS));
        
        let pos = borrow_global_mut<BorrowPosition<Currency>>(borrower_addr);
        assert!(pos.pool == pool_address, error::invalid_argument(E_INVALID_POOL));
        assert!(pos.amount >= repay_amount, error::invalid_argument(E_INSUFFICIENT_BORROWED));
        
        // Update user's borrowed amount
        pos.amount = pos.amount - repay_amount;
        
        // Update pool's total borrowed amount
        let pool = borrow_global_mut<Pool<Currency>>(pool_address);
        assert!(pool.total_borrowed >= repay_amount, error::invalid_argument(E_INSUFFICIENT_BORROWED));
        pool.total_borrowed = pool.total_borrowed - repay_amount;
    }

    /// Update the total supply of a pool (for deposit/withdraw operations)
    /// Only callable by friend modules for security
    public(friend) fun update_total_supply<Currency>(pool_address: address, new_supply: u64) acquires Pool {
        let pool = borrow_global_mut<Pool<Currency>>(pool_address);
        pool.total_supply = new_supply;
    }

    /// Update the total borrowed amount of a pool (for borrow/repay operations)  
    /// Only callable by friend modules for security
    public(friend) fun update_total_borrowed<Currency>(pool_address: address, new_borrowed: u64) acquires Pool {
        let pool = borrow_global_mut<Pool<Currency>>(pool_address);
        pool.total_borrowed = new_borrowed;
    }

    /// Update both total supply and borrowed amounts in one call
    /// Only callable by friend modules for security
    public(friend) fun update_pool_state<Currency>(
        pool_address: address, 
        new_supply: u64, 
        new_borrowed: u64
    ) acquires Pool {
        let pool = borrow_global_mut<Pool<Currency>>(pool_address);
        pool.total_supply = new_supply;
        pool.total_borrowed = new_borrowed;
    }

    // === Borrow Position Functions ===

    /// Initialize a borrow position for a user
    public(friend) fun init_borrow_position<Currency>(
        borrower: &signer,
        pool_address: address,
        initial_amount: u64
    ) {
        use cedra_framework::timestamp;
        
        let borrower_addr = signer::address_of(borrower);
        
        // Check if position already exists
        assert!(!exists<BorrowPosition<Currency>>(borrower_addr), error::already_exists(E_BORROW_POSITION_NOT_EXISTS));
        
        let position = BorrowPosition<Currency> {
            pool: pool_address,
            amount: initial_amount,
            last_update: timestamp::now_seconds(),
        };
        
        move_to(borrower, position);
    }

    /// Update an existing borrow position
    public(friend) fun update_borrow_position<Currency>(
        borrower_addr: address,
        pool_address: address,
        new_amount: u64
    ) acquires BorrowPosition {
        use cedra_framework::timestamp;
        
        assert!(exists<BorrowPosition<Currency>>(borrower_addr), error::not_found(E_BORROW_POSITION_NOT_EXISTS));
        
        let pos = borrow_global_mut<BorrowPosition<Currency>>(borrower_addr);
        assert!(pos.pool == pool_address, error::invalid_argument(E_INVALID_POOL));
        
        pos.amount = new_amount;
        pos.last_update = timestamp::now_seconds();
    }

    /// Check if a user has a borrow position for a specific currency
    #[view]
    public fun has_borrow_position<Currency>(borrower_addr: address): bool {
        exists<BorrowPosition<Currency>>(borrower_addr)
    }

    /// Get borrow position details
    #[view]
    public fun get_borrow_position<Currency>(borrower_addr: address): (address, u64, u64) acquires BorrowPosition {
        assert!(exists<BorrowPosition<Currency>>(borrower_addr), error::not_found(E_BORROW_POSITION_NOT_EXISTS));
        
        let pos = borrow_global<BorrowPosition<Currency>>(borrower_addr);
        (pos.pool, pos.amount, pos.last_update)
    }

    // === Interest Management Functions ===

    /// Get total interest from pool (friend only)
    public(friend) fun get_total_interest<Currency>(pool_address: address): u64 acquires Pool {
        let pool = borrow_global<Pool<Currency>>(pool_address);
        pool.total_interest
    }

    /// Get APY from pool (friend only)
    public(friend) fun get_apy<Currency>(pool_address: address): u64 acquires Pool {
        let pool = borrow_global<Pool<Currency>>(pool_address);
        pool.apy
    }

    /// Get last update timestamp from pool (friend only)
    public(friend) fun get_last_update<Currency>(pool_address: address): u64 acquires Pool {
        let pool = borrow_global<Pool<Currency>>(pool_address);
        pool.last_update
    }

    /// Get pool address (friend only)
    public(friend) fun get_pool_address<Currency>(pool_address: address): address acquires Pool {
        let pool = borrow_global<Pool<Currency>>(pool_address);
        pool.address
    }

    /// Update total interest (friend only)
    public(friend) fun update_total_interest<Currency>(pool_address: address, new_interest: u64) acquires Pool {
        let pool = borrow_global_mut<Pool<Currency>>(pool_address);
        pool.total_interest = new_interest;
    }

    /// Update last update timestamp (friend only)
    public(friend) fun update_last_update<Currency>(pool_address: address, timestamp: u64) acquires Pool {
        let pool = borrow_global_mut<Pool<Currency>>(pool_address);
        pool.last_update = timestamp;
    }

    /// Update APY (friend only)
    public(friend) fun update_apy<Currency>(pool_address: address, new_apy: u64) acquires Pool {
        let pool = borrow_global_mut<Pool<Currency>>(pool_address);
        pool.apy = new_apy;
    }
}