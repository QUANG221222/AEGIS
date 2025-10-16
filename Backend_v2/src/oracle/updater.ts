import { TYPE_ARGS, CURRENCIES } from "../utils/constants";
import { getCleanPriceForCurrency } from "./priceFeed";
import { checkOracleExists, initOracleForCurrency } from "./init";
import { cedra, account, ORACLE_ADDRESS } from "../utils/cedraClient";

export async function updateOracleForCurrency(currency: string) {
  try {
    const price = await getCleanPriceForCurrency(currency);
    console.log(`🔄 Fetched ${currency} price: $${price}`);

    try {
      const exists = await checkOracleExists(currency);
      if (!exists) {
        console.log(`Oracle for ${currency} does not exist. Initializing...`);
        await initOracleForCurrency(currency);
      } else {
        console.log(`Oracle for ${currency} exists. Proceeding to update...`);
      }
    } catch (error) {
      console.error("Error checking Oracle existence:", error);
    }

    // Send transaction to update oracle prices
    const transaction = await cedra.transaction.build.simple({
      sender: account.accountAddress,
      data: {
        function:
          `${ORACLE_ADDRESS}::oracle::update_price` as `${string}::${string}::${string}`,
        typeArguments: [TYPE_ARGS[currency as keyof typeof TYPE_ARGS]],
        functionArguments: [
          Math.floor(price * 1e6), // Change to integer with 6 decimals
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

export async function updateOracleForManyCurrency(currencies: string[]) {
  for (const currency of currencies) {
    try {
      await updateOracleForCurrency(currency);
    } catch (error) {
      console.error(`❌ Failed to update oracle for ${currency}:`, error);
    }
  }
}

export async function updateAllOracleCurrencies() {
  const currencies = Object.keys(CURRENCIES);
  await updateOracleForManyCurrency(currencies);
}
