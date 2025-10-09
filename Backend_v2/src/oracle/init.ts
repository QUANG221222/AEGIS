/**
 * Initialization for Oracle Module
 * Sets up necessary configurations and connections
 */
import { g } from "@cedra-labs/ts-sdk/dist/common/accountAddress-BAdPmRqc";
import { cedra, account, ORACLE_ADDRESS } from "../utils/cedraClient";
import { TYPE_ARGS } from "../utils/constants";
import { getCleanPriceForCurrency } from "./priceFeed";

// Use this function 1 time to initialize the Oracle contract on-chain
export async function initOracleForCurrency(currency: string): Promise<void> {
  try {
    console.log("🔧 Initializing Oracle contract...");

    const transaction = await cedra.transaction.build.simple({
      sender: account.accountAddress,
      data: {
        function:
          `${ORACLE_ADDRESS}::oracle::init_price_feed` as `${string}::${string}::${string}`,
        typeArguments: [TYPE_ARGS[currency as keyof typeof TYPE_ARGS]],
        functionArguments: [await getCleanPriceForCurrency(currency)], // Initial price with 8 decimals
      },
    });

    const pendingTransaction = await cedra.transaction.signAndSubmitTransaction(
      {
        signer: account,
        transaction,
      }
    );

    console.log("✅ Oracle initialized successfully!");
    console.log(`🔗 Init transaction hash: ${pendingTransaction.hash}`);
    console.log("=================================");
  } catch (error) {
    console.error("Error initializing Oracle:", error);
    throw error;
  }
}
