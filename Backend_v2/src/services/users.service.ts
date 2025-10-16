import { cedra } from "../utils/cedraClient";

const getBalance = async (address: string): Promise<number> => {
  try {
    const balance = await cedra.getAccountCoinAmount({
      accountAddress: address,
      coinType: "0x1::cedra_coin::CedraCoin",
    });
    return balance;
  } catch (error: any) {
    throw error;
  }
};

export const userService = {
  getBalance,
};
