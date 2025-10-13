module aegis_addr::constants {
    // 365 * 24 * 3600
    const SECONDS_IN_YEAR: u64 = 31_536_000;

    // Returns seconds in year (to keep API as function as you are using)
    #[view]
    public fun get_seconds_in_year(): u64 {
        SECONDS_IN_YEAR
    }
}
