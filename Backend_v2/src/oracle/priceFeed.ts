import axios from "axios";
import {
  PRICE_API_ENDPOINTS,
  COINGECKO_IDS,
  SYMBOLS_BINANCE,
  SYMBOLS_COINBASE,
} from "../utils/constants";

interface BinanceResponse {
  price: string;
}

interface CoinbaseResponse {
  data: {
    amount: string;
  };
}

interface CoinGeckoResponse {
  [key: string]: {
    usd: number;
  };
}

async function getPriceInCoinGecko(currency: string): Promise<number> {
  const coinId = COINGECKO_IDS[currency as keyof typeof COINGECKO_IDS];
  if (!coinId) {
    throw new Error(`Unsupported currency for CoinGecko: ${currency}`);
  }
  const res = await axios.get<CoinGeckoResponse>(
    PRICE_API_ENDPOINTS.COINGECKO,
    {
      params: {
        ids: coinId,
        vs_currencies: "usd",
      },
    }
  );
  return res.data[coinId].usd;
}

async function getPriceInBinance(currency: string): Promise<number> {
  const symbol = SYMBOLS_BINANCE[currency as keyof typeof SYMBOLS_BINANCE];
  if (!symbol) {
    throw new Error(`Unsupported currency for Binance: ${currency}`);
  }
  const res = await axios.get<BinanceResponse>(PRICE_API_ENDPOINTS.BINANCE, {
    params: {
      symbol: symbol,
    },
  });
  return parseFloat(res.data.price);
}

async function getPriceInCoinbase(currency: string): Promise<number> {
  const symbol = SYMBOLS_COINBASE[currency as keyof typeof SYMBOLS_COINBASE];
  if (!symbol) {
    throw new Error(`Unsupported currency for Coinbase: ${currency}`);
  }
  const res = await axios.get<CoinbaseResponse>(
    `${PRICE_API_ENDPOINTS.COINBASE}/${symbol}/spot`
  );
  return parseFloat(res.data.data.amount); // Convert string to number
}

async function getCleanPriceForCurrency(currency: string): Promise<number> {
  try {
    const pricePromises = [
      getPriceInBinance(currency).catch((err) => {
        console.warn(`Binance failed for ${currency}:`, err.message);
        return null;
      }),
      getPriceInCoinbase(currency).catch((err) => {
        console.warn(`Coinbase failed for ${currency}:`, err.message);
        return null;
      }),
      getPriceInCoinGecko(currency).catch((err) => {
        console.warn(`CoinGecko failed for ${currency}:`, err.message);
        return null;
      }),
    ];

    const sources = await Promise.allSettled(pricePromises);
    const validPrices: number[] = [];

    sources.forEach((result, index) => {
      if (result.status === "fulfilled" && result.value !== null) {
        validPrices.push(result.value);
      }
    });

    if (validPrices.length === 0) {
      throw new Error(`No valid prices found for ${currency}`);
    }

    // Calculate median price to avoid outliers
    validPrices.sort((a, b) => a - b);
    const mid = Math.floor(validPrices.length / 2);
    const medianPrice =
      validPrices.length % 2 !== 0
        ? validPrices[mid]
        : (validPrices[mid - 1] + validPrices[mid]) / 2;

    // Log the actual price (not scaled)
    // console.log(
    //   `📊 ${currency} clean price from ${
    //     validPrices.length
    //   } sources: $${medianPrice.toFixed(4)}`
    // );

    // Return price scaled to 8 decimals for blockchain
    const scaledPrice = Math.round(medianPrice * 1e8);
    // console.log(`🔢 Scaled price for blockchain: ${scaledPrice}`);

    return scaledPrice;
  } catch (error) {
    console.error(`Error fetching price for ${currency}:`, error);
    throw error;
  }
}

export {
  getCleanPriceForCurrency,
  getPriceInBinance,
  getPriceInCoinbase,
  getPriceInCoinGecko,
};
