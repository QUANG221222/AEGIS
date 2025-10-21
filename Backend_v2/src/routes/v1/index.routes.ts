import express from "express";
import { userRouter } from "./users.routes";
import { poolRouter } from "./pool.routes";
const Router = express.Router();

Router.use("/users", userRouter);

Router.use("/pool", poolRouter);

export const APIs_V1 = Router;
