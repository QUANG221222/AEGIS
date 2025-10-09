import cron from "node-cron";
// import { updateOracle } from "./updater";

// Chạy mỗi phút (*/1 * * * * = every 1 minute)
cron.schedule("*/1 * * * *", async () => {
  console.log(`[${new Date().toISOString()}] Running Oracle update...`);
  //   await updateOracle();
});
console.log("🔁 Oracle scheduler started — updating every 1 minute");
