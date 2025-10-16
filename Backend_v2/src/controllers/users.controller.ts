import { Request, Response, NextFunction } from "express";
import { StatusCodes } from "http-status-codes";
import ApiError from "../utils/ApiError";
import { userService } from "../services/users.service";
import { BalanceResponse } from "../types/users";

const getBalance = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { address } = req.params;
    const balance = await userService.getBalance(address);
    res.status(StatusCodes.OK).json({ address, balance } as BalanceResponse);
  } catch (error: any) {
    next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message));
  }
};

export const userController = { getBalance };
