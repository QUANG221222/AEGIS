import { env } from "../configs/environment";
import {
  Account,
  Cedra,
  CedraConfig,
  Ed25519PrivateKey,
  Network,
} from "@cedra-labs/ts-sdk";

const config = new CedraConfig({
  network: env.NODE_ENV === "production" ? Network.MAINNET : Network.TESTNET,
});
const cedra = new Cedra(config);

// Config wallet - demo private key, change in production
const PRIVATE_KEY = env.ORACLE_PRIVATE_KEY;
const privateKey = new Ed25519PrivateKey(PRIVATE_KEY);
const account = Account.fromPrivateKey({ privateKey });

// Oracle address
const ORACLE_ADDRESS = env.ORACLE_ADDRESS;

export { cedra, account, ORACLE_ADDRESS };
