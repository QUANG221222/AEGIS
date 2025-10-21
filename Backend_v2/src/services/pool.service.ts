import { cedra, pool } from "../utils/cedraClient";
import { env } from "../configs/environment";
import { TYPE_ARGS } from "../utils/constants";
import { PoolStatsResponse } from "../types/pool";
import ApiError from "../utils/ApiError";
import { StatusCodes } from "http-status-codes";

const checkPoolExists = async (currency: string): Promise<boolean> => {
  try {
    const exitPool = await cedra.view({
      payload: {
        function: `${env.POOL_ADDRESS}::pool::pool_exists`,
        typeArguments: [TYPE_ARGS[currency as keyof typeof TYPE_ARGS]],
        functionArguments: [env.POOL_ADDRESS],
      },
    });
    return exitPool[0] as boolean;
  } catch (error: any) {
    throw error;
  }
};

const createPoolForCurrency = async (currency: string): Promise<void> => {
  try {
    if (await checkPoolExists(currency)) {
      throw new ApiError(
        StatusCodes.CONFLICT,
        `Pool for ${currency} already exists.`
      );
    }

    if (!TYPE_ARGS[currency as keyof typeof TYPE_ARGS]) {
      throw new ApiError(
        StatusCodes.BAD_REQUEST,
        `Unsupported currency: ${currency}.`
      );
    }

    const transaction = await cedra.transaction.build.simple({
      sender: env.POOL_ADDRESS,
      data: {
        function:
          `${env.POOL_ADDRESS}::pool_manager::create_pool` as `${string}::${string}::${string}`,
        typeArguments: [TYPE_ARGS[currency as keyof typeof TYPE_ARGS]],
        functionArguments: [],
      },
    });

    const pendingTransaction = await cedra.transaction.signAndSubmitTransaction(
      {
        signer: pool,
        transaction,
      }
    );
    console.log(`✅ Pool for ${currency} created successfully!`);
    console.log(`🔗 Create Pool transaction hash: ${pendingTransaction.hash}`);
    console.log("=================================");
  } catch (error) {
    throw error;
  }
};

const getPoolStatsForCurrency = async (currency: string): Promise<any> => {
  try {
    const exitPool = await checkPoolExists(currency);

    if (!exitPool) {
      throw new ApiError(
        StatusCodes.NOT_FOUND,
        `Pool for ${currency} does not exist.`
      );
    }

    const stats = await cedra.view({
      payload: {
        function: `${env.POOL_ADDRESS}::pool::get_pool_stats`,
        typeArguments: [TYPE_ARGS[currency as keyof typeof TYPE_ARGS]],
        functionArguments: [env.POOL_ADDRESS],
      },
    });
    return stats;
  } catch (error: any) {
    throw error;
  }
};

const getAllPoolStats = async (): Promise<PoolStatsResponse> => {
  try {
    const allStats: Record<string, any> = {};
    for (const currency of Object.keys(TYPE_ARGS)) {
      const stats = await getPoolStatsForCurrency(currency);
      allStats[currency] = stats;
    }
    return {
      data: Object.entries(allStats).map(([currency, stats]) => ({
        currency,
        totalSupplied: stats[0], // total_supply
        totalBorrowed: stats[1], // total_borrowed
      })),
    };
  } catch (error) {
    throw error;
  }
};

export const poolService = {
  getAllPoolStats,
  checkPoolExists,
  getPoolStatsForCurrency,
  createPoolForCurrency,
};
