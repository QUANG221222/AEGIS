import express from "express";
import { userController } from "../../controllers/users.controller";
const Router = express.Router();

Router.get("/getBalance/:address", userController.getBalance);

export const userRouter = Router;
