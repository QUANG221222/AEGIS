import "dotenv/config";

export const env = {
  LOCAL_APP_PORT: process.env.LOCAL_APP_PORT || 8080,
  LOCAL_APP_HOST: process.env.LOCAL_APP_HOST || "http://localhost",
  POOL_ADDRESS: process.env.POOL_ADDRESS || "",
  POOL_PRIVATE_KEY: process.env.POOL_PRIVATE_KEY || "",
  ORACLE_ADDRESS: process.env.ORACLE_ADDRESS || "",
  ORACLE_PRIVATE_KEY: process.env.ORACLE_PRIVATE_KEY || "",
  NODE_ENV: process.env.NODE_ENV || "",
};
