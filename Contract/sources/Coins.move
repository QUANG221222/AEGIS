/// Coins Module - Define different coin types for the protocol
/// 
/// This module defines phantom types for different cryptocurrencies
/// that can be used as type parameters in generic functions and structs.

module aegis_addr::coins {
    
    /// Phantom type representing Ethereum (ETH)
    struct ETH has drop {}
    
    /// Phantom type representing Bitcoin (BTC)  
    struct BTC has drop {}
    
    /// Phantom type representing Aptos Coin (APT)
    struct APT has drop {}
    
    /// Phantom type representing USD Coin (USDC)
    struct USDC has drop {}
    
    /// Phantom type representing Tether USD (USDT)
    struct USDT has drop {}
    
    /// Phantom type representing Binance Coin (BNB)
    struct BNB has drop {}
    
    /// Phantom type representing Solana (SOL)
    struct SOL has drop {}
    
    /// Phantom type representing Cardano (ADA)
    struct ADA has drop {}
    
    /// Phantom type representing Polkadot (DOT)
    struct DOT has drop {}
    
    /// Phantom type representing Chainlink (LINK)
    struct LINK has drop {}
}