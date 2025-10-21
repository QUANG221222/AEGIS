import { poolService } from "../services/pool.service";

(async () => {
  const exists = await poolService.getAllPoolStats();
  console.log("All pool stats:", exists);

  //   const stats = await poolService.getPoolStatsForCurrency("ETH");
  //   console.log("Pool ETH stats:", stats);
})();
