/// Oracle Module - Simple Price Feed for USDT Conversion
/// Provides basic price feeds to convert any asset to USDT value

module aegis_addr::oracle {
    use std::error;
    use std::signer;
    use cedra_framework::event;
    use cedra_framework::timestamp;

    // === Events ===
    #[event]
    struct PriceUpdateEvent has drop, store {
        asset: address,
        old_price: u64,
        new_price: u64,
        updater: address,
        timestamp: u64,
    }

    // === Structs ===
    /// Price feed for a currency type (price in USDT)
    struct PriceFeed<phantom Currency> has key {
        price: u64,           // Price in USDT with 8 decimals (e.g., 300000000000 = $3000.00)
        admin: address,       // Who can update this price
        last_updated: u64,    // Timestamp of last price update
    }

    // Error codes
    const E_NOT_ADMIN: u64 = 1;
    const E_PRICE_NOT_EXISTS: u64 = 2;
    const E_ZERO_PRICE: u64 = 3;
    const E_STALE_PRICE: u64 = 4;

    // Constants
    const PRICE_FRESHNESS_THRESHOLD: u64 = 3600; // 1 hour in seconds

    // === Admin Functions ===
    
    /// Initialize price feed for a currency type
    public entry fun init_price_feed<Currency>(
        admin: &signer,
        initial_price: u64,  // Price in USDT (8 decimals)
    ) {
        assert!(initial_price > 0, error::invalid_argument(E_ZERO_PRICE));
        
        let admin_addr = signer::address_of(admin);
        let current_time = timestamp::now_seconds();
        
        let price_feed = PriceFeed<Currency> {
            price: initial_price,
            admin: admin_addr,
            last_updated: current_time,
        };
        
        move_to(admin, price_feed);
    }
    
    /// Update price for a currency type
    public entry fun update_price<Currency>(
        admin: &signer,
        new_price: u64,
    ) acquires PriceFeed {
        assert!(new_price > 0, error::invalid_argument(E_ZERO_PRICE));
        
        let admin_addr = signer::address_of(admin);
        assert!(exists<PriceFeed<Currency>>(admin_addr), error::not_found(E_PRICE_NOT_EXISTS));
        
        let price_feed = borrow_global_mut<PriceFeed<Currency>>(admin_addr);
        assert!(price_feed.admin == admin_addr, error::permission_denied(E_NOT_ADMIN));
        
        let old_price = price_feed.price;
        let current_time = timestamp::now_seconds();
        
        price_feed.price = new_price;
        price_feed.last_updated = current_time;
        
        event::emit(PriceUpdateEvent {
            asset: admin_addr,  // Use admin address as identifier
            old_price,
            new_price,
            updater: admin_addr,
            timestamp: current_time,
        });
    }

    // === View Functions ===
    
    /// Get current price in USDT for a currency type
    #[view]
    public fun get_price_usdt<Currency>(oracle_address: address): u64 acquires PriceFeed {
        assert!(exists<PriceFeed<Currency>>(oracle_address), error::not_found(E_PRICE_NOT_EXISTS));
        let price_feed = borrow_global<PriceFeed<Currency>>(oracle_address);
        price_feed.price
    }
    
    /// Convert currency amount to USDT value
    /// Example: 1 ETH (100000000) * $3000 price = $3000 USDT (300000000000)
    #[view]
    public fun convert_to_usdt<Currency>(
        oracle_address: address,
        currency_amount: u64
    ): u64 acquires PriceFeed {
        let price = get_price_usdt<Currency>(oracle_address);
        (currency_amount * price) / 100000000  // Adjust for 8 decimal places
    }
    
    /// Convert USDT amount to currency amount  
    /// Example: $3000 USDT (300000000000) / $3000 price = 1 ETH (100000000)
    #[view]
    public fun convert_from_usdt<Currency>(
        oracle_address: address,
        usdt_amount: u64
    ): u64 acquires PriceFeed {
        let price = get_price_usdt<Currency>(oracle_address);
        (usdt_amount * 100000000) / price  // Adjust for 8 decimal places
    }
    
    /// Check if price feed exists for a currency
    #[view]
    public fun price_exists<Currency>(oracle_address: address): bool {
        exists<PriceFeed<Currency>>(oracle_address)
    }

    /// Get the timestamp of last price update
    #[view]
    public fun get_last_updated<Currency>(oracle_address: address): u64 acquires PriceFeed {
        assert!(exists<PriceFeed<Currency>>(oracle_address), error::not_found(E_PRICE_NOT_EXISTS));
        let price_feed = borrow_global<PriceFeed<Currency>>(oracle_address);
        price_feed.last_updated
    }

    /// Get price and last update timestamp
    #[view]
    public fun get_price_with_timestamp<Currency>(oracle_address: address): (u64, u64) acquires PriceFeed {
        assert!(exists<PriceFeed<Currency>>(oracle_address), error::not_found(E_PRICE_NOT_EXISTS));
        let price_feed = borrow_global<PriceFeed<Currency>>(oracle_address);
        (price_feed.price, price_feed.last_updated)
    }

    /// Check if price is fresh (updated within threshold time)
    #[view]
    public fun is_price_fresh<Currency>(oracle_address: address): bool acquires PriceFeed {
        if (!exists<PriceFeed<Currency>>(oracle_address)) {
            return false
        };
        
        let price_feed = borrow_global<PriceFeed<Currency>>(oracle_address);
        let current_time = timestamp::now_seconds();
        let time_diff = current_time - price_feed.last_updated;
        
        time_diff <= PRICE_FRESHNESS_THRESHOLD
    }

    /// Get time since last update in seconds
    #[view]
    public fun get_time_since_update<Currency>(oracle_address: address): u64 acquires PriceFeed {
        assert!(exists<PriceFeed<Currency>>(oracle_address), error::not_found(E_PRICE_NOT_EXISTS));
        let price_feed = borrow_global<PriceFeed<Currency>>(oracle_address);
        let current_time = timestamp::now_seconds();
        current_time - price_feed.last_updated
    }

    /// Get price only if it's fresh, otherwise throw error
    #[view]
    public fun get_fresh_price<Currency>(oracle_address: address): u64 acquires PriceFeed {
        assert!(is_price_fresh<Currency>(oracle_address), error::invalid_state(E_STALE_PRICE));
        get_price_usdt<Currency>(oracle_address)
    }
}
