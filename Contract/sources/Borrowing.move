// Borrowing Module
//
// This module handles the borrowing functionality of the lending protocol.
// It allows users to borrow tokens from the pool, tracks borrowed amounts,
// and enforces borrowing limits.

module aegis_addr::borrowing {
    use std::error;
    use std::signer;
    use cedra_framework::event;
    use aegis_addr::pool;

    // === Events ===
    // Event emitted when tokens are borrowed from a pool
    #[event]
    struct BorrowEvent has drop, store {
        pool_address: address,
        borrower: address,
        amount: u64,
        new_total_borrowed: u64,
    }

    // Error codes
    // Pool does not exist
    const E_POOL_NOT_EXISTS: u64 = 1;
    
    // Insufficient available balance for borrowing
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    
    // Cannot borrow zero amount
    const E_ZERO_AMOUNT: u64 = 3;

    // === Borrow Functions ===

    // Borrow amount from an existing pool
    // Updates the pool's total_borrowed (simulates token transfer)
    public entry fun borrow<Currency>(
        borrower: &signer,
        pool_address: address,
        amount: u64,
    ) {
        // Verify pool exists
        assert!(pool::pool_exists<Currency>(pool_address), error::not_found(E_POOL_NOT_EXISTS));
        
        // Cannot borrow zero amount
        assert!(amount > 0, error::invalid_argument(E_ZERO_AMOUNT));
        
        // Get current pool stats
        let (total_supply, total_borrowed) = pool::get_pool_stats<Currency>(pool_address);
        
        // Calculate available balance
        let available_balance = total_supply - total_borrowed;
        
        // Ensure sufficient available balance for borrowing
        assert!(amount <= available_balance, error::invalid_argument(E_INSUFFICIENT_BALANCE));
        
        // Calculate new total borrowed
        let new_total_borrowed = total_borrowed + amount;
        
        // Update pool state using Pool module's friend function
        pool::update_total_borrowed<Currency>(pool_address, new_total_borrowed);
        
        // Emit event
        event::emit(BorrowEvent {
            pool_address,
            borrower: signer::address_of(borrower),
            amount,
            new_total_borrowed,
        });
    }
}