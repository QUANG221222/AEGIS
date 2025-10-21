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

// Oracle account
const PRIVATE_KEY = env.ORACLE_PRIVATE_KEY;
const oraclePrivateKey = new Ed25519PrivateKey(PRIVATE_KEY);
const oracle = Account.fromPrivateKey({ privateKey: oraclePrivateKey });

// Pool account
const POOL_PRIVATE_KEY = env.POOL_PRIVATE_KEY;
const poolPrivateKey = new Ed25519PrivateKey(POOL_PRIVATE_KEY);
const pool = Account.fromPrivateKey({ privateKey: poolPrivateKey });

// Oracle address
const ORACLE_ADDRESS = env.ORACLE_ADDRESS;

// Pool address
const POOL_ADDRESS = env.POOL_ADDRESS;

export { cedra, oracle, pool, ORACLE_ADDRESS, POOL_ADDRESS };
