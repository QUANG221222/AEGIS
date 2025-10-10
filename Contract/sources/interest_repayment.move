module aegis_addr::interest_repayment {
    use std::signer;
    use std::timestamp;
    use std::coin;
    use cedra_framework::event;

    use aegis_addr::pool;
    use aegis_addr::constants;

    /// Borrow account by Currency
    struct BorrowAccount<phantom Currency> has key {
        borrowed_amount: u64,
        accrued_interest: u64, // interest accrued but NOT YET paid
        interest_rate: u64,    // borrower's APY (if different from pool)
        last_update: u64,
    }

    /// Event: borrower pays interest
    #[event]
    struct InterestRepayEvent has drop, store {
        borrower: address,
        amount: u64,
        timestamp: u64,
    }

    /// Initialize BorrowAccount for user (when starting to borrow)
    public entry fun init_borrow_account<Currency>(
        borrower: &signer,
        borrowed_amount: u64,
        interest_rate: u64
    ) {
        let now = timestamp::now_seconds();
        move_to<BorrowAccount<Currency>>(borrower, BorrowAccount<Currency> {
            borrowed_amount,
            accrued_interest: 0,
            interest_rate,
            last_update: now,
        });
    }

    /// Calculate accrued interest since last update (calculate only, don't record to pool)
    public fun calculate_interest_due<Currency>(acc: &BorrowAccount<Currency>): u64 {
        let now = timestamp::now_seconds();
        let elapsed = now - acc.last_update;
        (acc.borrowed_amount * acc.interest_rate * elapsed) / constants::get_seconds_in_year()
    }

    /// Add accrued interest to borrower's accrued_interest (periodically)
    public entry fun auto_collect_interest<Currency>(
        borrower_addr: address
    ) acquires BorrowAccount {
        let acc = borrow_global_mut<BorrowAccount<Currency>>(borrower_addr);
        let due = calculate_interest_due(acc);
        acc.accrued_interest = acc.accrued_interest + due;
        acc.last_update = timestamp::now_seconds();
        // DO NOT increase pool.total_interest here.
        // pool.total_interest will only increase when actual payment is made
    }

    /// Borrower pays interest -> money flows to pool wallet + increases interest fund (total_interest)
    public entry fun repay_interest<Currency>(
        borrower: &signer,
        pool_address: address,
        amount: u64
    ) acquires BorrowAccount {
        let addr = signer::address_of(borrower);
        let acc = borrow_global_mut<BorrowAccount<Currency>>(addr);

        // Deduct interest debt from borrower
        if (amount >= acc.accrued_interest) {
            acc.accrued_interest = 0;
        } else {
            acc.accrued_interest = acc.accrued_interest - amount;
        };

        // Transfer coin from borrower to pool owner wallet
        let pool_owner_addr = pool::get_pool_address<Currency>(pool_address);
        coin::transfer<Currency>(borrower, pool_owner_addr, amount);

        // Record to pool's collected interest fund
        let current_interest = pool::get_total_interest<Currency>(pool_address);
        pool::update_total_interest<Currency>(pool_address, current_interest + amount);

        event::emit(InterestRepayEvent {
            borrower: addr,
            amount,
            timestamp: timestamp::now_seconds(),
        });
    }

    /// View unpaid interest of borrower
    #[view]
    public fun get_interest_debt<Currency>(borrower_addr: address): u64 acquires BorrowAccount {
        let acc = borrow_global<BorrowAccount<Currency>>(borrower_addr);
        acc.accrued_interest
    }
}
