import express from "express";
import { poolController } from "../../controllers/pool.controller";
import { poolValidation } from "../../validations/pool.validation";
const Router = express.Router();

Router.route("/")
  .get(poolController.getPoolStats)
  .post(poolValidation.createNew, poolController.createNew);

Router.route("/:currency").get(poolController.getPoolStatsForCurrency);

export const poolRouter = Router;
