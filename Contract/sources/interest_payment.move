module aegis_addr::interest_payment {
    use std::signer;
    use std::timestamp;
    use std::error;
    use std::coin;
    use cedra_framework::event;

    use aegis_addr::pool;
    use aegis_addr::constants;

    const E_ZERO_AMOUNT: u64 = 1;
    const E_POOL_INSUFFICIENT: u64 = 2;
    const SCALE_PPM: u64 = 1_000_000; // parts-per-million

    /// Lender account by Currency
    struct LenderAccount<phantom Currency> has key {
        deposited_amount: u64,
        accrued_interest: u64, // interest accrued ready to claim
        pool_share: u64,       // parts-per-million (e.g. 285_714 ~ 28.5714%)
        last_update: u64,
    }

    /// Event: lender claims interest
    #[event]
    struct InterestClaimedEvent has drop, store {
        lender: address,
        amount: u64,
        timestamp: u64,
    }

    /// Event: credit interest to 1 lender from pool fund (no coin withdrawal)
    #[event]
    struct InterestDistributedEvent has drop, store {
        pool: address,
        lender: address,
        amount: u64,
        timestamp: u64,
    }

    /// Initialize LenderAccount (on first deposit)
    public entry fun init_lender_account<Currency>(
        lender: &signer,
        deposited_amount: u64,
        pool_share_ppm: u64
    ) {
        let now = timestamp::now_seconds();
        move_to<LenderAccount<Currency>>(lender, LenderAccount<Currency> {
            deposited_amount,
            accrued_interest: 0,
            pool_share: pool_share_ppm,
            last_update: now,
        });
    }

    /// (Optional) Update last_update of pool; no change to interest fund
    public entry fun accrue_interest<Currency>(pool_address: address) {
        let now = timestamp::now_seconds();
        pool::update_last_update<Currency>(pool_address, now);
    }

    /// Credit interest to 1 lender based on pool_share from interest fund (total_interest)
    /// No coin withdrawal, just add to lender.accrued_interest
    public fun distribute_interest<Currency>(
        lender_addr: address,
        pool_address: address
    ) acquires LenderAccount {
        let lender_acc = borrow_global_mut<LenderAccount<Currency>>(lender_addr);

        let share_ppm = lender_acc.pool_share;
        if (share_ppm == 0) {
            return;
        };

        let total_interest = pool::get_total_interest<Currency>(pool_address);
        if (total_interest == 0) {
            return;
        };

        // Allocate according to ratio on current fund (simple crediting method)
        let reward = (total_interest * share_ppm) / SCALE_PPM;
        if (reward == 0) {
            return;
        };

        lender_acc.accrued_interest = lender_acc.accrued_interest + reward;

        event::emit(InterestDistributedEvent {
            pool: pool::get_pool_address<Currency>(pool_address),
            lender: lender_addr,
            amount: reward,
            timestamp: timestamp::now_seconds(),
        });

        // NOTE: DO NOT subtract pool.total_interest here.
        // pool.total_interest will decrease when lender claims (actual coin payment).
    }

    /// Lender claims interest: pool owner (signer) pays coin from pool wallet to lender
    /// REQUIREMENT: `pool_signer` is the correct address equal to pool.address
    public entry fun claim_interest<Currency>(
        pool_signer: &signer,
        lender_addr: address,
        pool_address: address
    ) acquires LenderAccount {
        let amount;
        {
            let lender_acc = borrow_global_mut<LenderAccount<Currency>>(lender_addr);
            amount = lender_acc.accrued_interest;
            assert!(amount > 0, error::invalid_argument(E_ZERO_AMOUNT));
            lender_acc.accrued_interest = 0;
        };

        // Check if interest fund is sufficient for payout
        let pool_interest = pool::get_total_interest<Currency>(pool_address);
        assert!(pool_interest >= amount, error::invalid_state(E_POOL_INSUFFICIENT));

        // Reduce pool interest fund in accounting
        pool::update_total_interest<Currency>(pool_address, pool_interest - amount);

        // Actually transfer from pool owner wallet to lender
        coin::transfer<Currency>(pool_signer, lender_addr, amount);

        event::emit(InterestClaimedEvent {
            lender: lender_addr,
            amount,
            timestamp: timestamp::now_seconds(),
        });
    }

    /// View unclaimed interest of lender
    #[view]
    public fun get_pending_interest<Currency>(lender_addr: address): u64 acquires LenderAccount {
        let acc = borrow_global<LenderAccount<Currency>>(lender_addr);
        acc.accrued_interest
    }
}
