import express from "express";
import { env } from "./config/environment";
import {
  getCleanPriceForCurrency,
  getPriceInBinance,
  getPriceInCoinGecko,
  getPriceInCoinbase,
} from "./oracle/priceFeed";

const app = express();

app.use(express.json());

// // Tạo async function để gọi getPriceInBinance
// async function testPrice() {
//   try {
//     const price = await getCleanPriceForCurrency("SOL");
//     console.log("SOL", price, "USD");
//   } catch (error) {
//     console.error("Error fetching SOL", "USD price:", error);
//   }
// }

// // Gọi function
// testPrice();

if (env.NODE_ENV === "development") {
  app.listen(Number(env.LOCAL_APP_PORT), String(env.LOCAL_APP_HOST), () => {
    console.log(
      `LOCAL DEV: Hello, Server is running at http://${env.LOCAL_APP_HOST}:${env.LOCAL_APP_PORT}`
    );
  });
} else {
  app.listen(Number(process.env.PORT), () => {
    console.log(
      `PRODUCTION: Hello, Backend Server is running successfully at Port: ${process.env.PORT}`
    );
  });
}
