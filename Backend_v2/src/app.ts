import express from "express";
import { env } from "./configs/environment";
import { APIs_V1 } from "./routes/v1/index.routes";
import {
  getCleanPriceForCurrency,
  getPriceInBinance,
  getPriceInCoinGecko,
  getPriceInCoinbase,
} from "./oracle/priceFeed";
import { cedra } from "./utils/cedraClient";
import { errorHandlingMiddleware } from "./middlewares/errorHandling.middleware";
import cors from "cors";
import { corsOptions } from "./configs/cors";

const app = express();

app.use(express.json());

app.use(cors(corsOptions));

app.use(errorHandlingMiddleware);

app.use("/v1", APIs_V1);

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
