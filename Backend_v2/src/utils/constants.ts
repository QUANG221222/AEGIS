import { env } from "../configs/environment";
/**
 * Constants for Aegis Backend
 */

export const TYPE_ARGS = {
  CEDRA: "0x1::cedra_coin::CedraCoin",
  ETH: `${env.ORACLE_ADDRESS}::coins::ETH`,
  BTC: `${env.ORACLE_ADDRESS}::coins::BTC`,
  APT: `${env.ORACLE_ADDRESS}::coins::APT`,
  USDC: `${env.ORACLE_ADDRESS}::coins::USDC`,
  USDT: `${env.ORACLE_ADDRESS}::coins::USDT`,
  BNB: `${env.ORACLE_ADDRESS}::coins::BNB`,
  SOL: `${env.ORACLE_ADDRESS}::coins::SOL`,
  ADA: `${env.ORACLE_ADDRESS}::coins::ADA`,
  DOT: `${env.ORACLE_ADDRESS}::coins::DOT`,
  LINK: `${env.ORACLE_ADDRESS}::coins::LINK`,
} as const;

export const CURRENCIES = {
  CEDRA: "CEDRA",
  ETH: "ETH",
  BTC: "BTC",
  APT: "APT",
  // USDC: "USDC",
  // USDT: "USDT",
  BNB: "BNB",
  SOL: "SOL",
  ADA: "ADA",
  DOT: "DOT",
  LINK: "LINK",
} as const;

// Oracle Price API Endpoints
export const PRICE_API_ENDPOINTS = {
  BINANCE: "https://api.binance.com/api/v3/ticker/price",

  COINBASE: "https://api.coinbase.com/v2/prices",

  COINGECKO: "https://api.coingecko.com/api/v3/simple/price",
} as const;

// Currency Symbols mapping for CoinGecko
export const COINGECKO_IDS = {
  ETH: "ethereum",
  BTC: "bitcoin",
  APT: "aptos",
  BNB: "binancecoin",
  SOL: "solana",
  ADA: "cardano",
  DOT: "polkadot",
  LINK: "chainlink",
  USDC: "usd-coin",
  USDT: "tether",
} as const;

// Currency Symbols mapping for Binance
export const SYMBOLS_BINANCE = {
  ETH: "ETHUSDT",
  BTC: "BTCUSDT",
  APT: "APTUSDT",
  BNB: "BNBUSDT",
  SOL: "SOLUSDT",
  ADA: "ADAUSDT",
  DOT: "DOTUSDT",
  LINK: "LINKUSDT",
} as const;

// Currency Symbols mapping for Coinbase
export const SYMBOLS_COINBASE = {
  ETH: "ETH-USDT",
  BTC: "BTC-USDT",
  APT: "APT-USDT",
  BNB: "BNB-USDT",
  SOL: "SOL-USDT",
  ADA: "ADA-USDT",
  DOT: "DOT-USDT",
  LINK: "LINK-USDT",
} as const;

export const WHITELIST_DOMAINS = [""];

export const WEBSITE_DOMAIN =
  env.NODE_ENV === "production"
    ? env.WEBSITE_DOMAIN_PRODUCTION
    : env.WEBSITE_DOMAIN_DEVELOPMENT;
