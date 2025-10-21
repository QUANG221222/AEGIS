/**
 * Initialization for Oracle Module
 * Sets up necessary configurations and connections
 */
import { cedra, oracle, ORACLE_ADDRESS } from "../utils/cedraClient";
import { TYPE_ARGS } from "../utils/constants";
import { getCleanPriceForCurrency } from "./priceFeed";

// Use this function 1 time to initialize the Oracle contract on-chain
export async function initOracleForCurrency(currency: string): Promise<void> {
  try {
    console.log("🔧 Initializing Oracle contract...");

    const transaction = await cedra.transaction.build.simple({
      sender: oracle.accountAddress,
      data: {
        function:
          `${ORACLE_ADDRESS}::oracle::init_price_feed` as `${string}::${string}::${string}`,
        typeArguments: [TYPE_ARGS[currency as keyof typeof TYPE_ARGS]],
        functionArguments: [await getCleanPriceForCurrency(currency)], // Initial price with 8 decimals
      },
    });

    const pendingTransaction = await cedra.transaction.signAndSubmitTransaction(
      {
        signer: oracle,
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

export async function checkOracleExists(currency: string): Promise<boolean> {
  try {
    // Call a view function or query the resource to check if the oracle exists
    const result = await cedra.view({
      payload: {
        function: `${ORACLE_ADDRESS}::oracle::price_exists`,
        typeArguments: [TYPE_ARGS[currency as keyof typeof TYPE_ARGS]],
        functionArguments: [oracle.accountAddress],
      },
    });
    // Assuming the view returns [boolean]
    return result[0] as boolean;
  } catch (error) {
    console.error("Error checking Oracle existence:", error);
    throw error;
  }
}
