import cron from "node-cron";
import { updateAllOracleCurrencies } from "./updater";

// Chạy mỗi 30 giây (*/30 * * * * = every 30 seconds)
cron.schedule("*/30 * * * * *", async () => {
  console.log(`[${new Date().toISOString()}] Running Oracle update...`);
  await updateAllOracleCurrencies();
});
console.log("🔁 Oracle scheduler started — updating every 30 seconds");
