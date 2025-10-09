import { TYPE_ARGS } from "../utils/constants";
import { getCleanPriceForCurrency } from "./priceFeed";
import { cedra, account, ORACLE_ADDRESS } from "../utils/cedraClient";

export async function updateOracleForCurrency(currency: string) {
  try {
    const price = await getCleanPriceForCurrency(currency);
    console.log(`🔄 Fetched ${currency} price: $${price}`);

    // Send transaction to update oracle prices
    const transaction = await cedra.transaction.build.simple({
      sender: account.accountAddress,
      data: {
        function:
          `${ORACLE_ADDRESS}::oracle::update_price` as `${string}::${string}::${string}`,
        typeArguments: [TYPE_ARGS[currency as keyof typeof TYPE_ARGS]],
        functionArguments: [
          Math.floor(price * 1e8), // Change to integer with 8 decimals
        ],
      },
    });

    const pendingTransaction = await cedra.transaction.signAndSubmitTransaction(
      {
        signer: account,
        transaction,
      }
    );
    console.log(`🔗 Transaction hash: ${pendingTransaction.hash}`);
  } catch (error) {
    console.error("❌ Oracle update failed:", error);
    if (error instanceof Error && error.message.includes("module_not_found")) {
      console.log(
        "⚠️  Contract oracle has not been deployed at address:",
        ORACLE_ADDRESS
      );
      console.log("🔧 Please deploy the contract before running the oracle!");
    }
    throw error;
  }
}
