import { NextFunction, Request, Response } from "express";
import ApiError from "../utils/ApiError";
import { StatusCodes } from "http-status-codes";
import { poolService } from "../services/pool.service";
import { env } from "../configs/environment";

interface CreatePoolRequest {
  currency: string;
  curatorAddress: string;
}

interface CreatePoolResponse {
  message: string;
  data: any;
}

const getPoolStats = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const result = await poolService.getAllPoolStats();
    res
      .status(StatusCodes.OK)
      .json({ message: "Pool stats retrieved successfully", data: result });
  } catch (error: any) {
    next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message));
  }
};

const createNew = async (
  req: Request<{}, {}, CreatePoolRequest, {}>,
  res: Response<CreatePoolResponse>,
  next: NextFunction
): Promise<void> => {
  try {
    const curatorAddress =
      req.body.curatorAddress || req.headers["curator-address"];
    if (!curatorAddress || curatorAddress !== env.POOL_ADDRESS) {
      return next(
        new ApiError(
          StatusCodes.UNAUTHORIZED,
          "Unauthorized: Invalid curator address"
        )
      );
    }
    await poolService.createPoolForCurrency(req.body.currency);
    res.status(StatusCodes.CREATED).json({
      message: `Pool for ${req.body.currency} created successfully`,
      data: { currency: req.body.currency, curatorAddress },
    });
  } catch (error: any) {
    next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message));
  }
};

const getPoolStatsForCurrency = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const currency = req.params.currency;
    const result = await poolService.getPoolStatsForCurrency(currency);
    if (!result) {
      next(new ApiError(StatusCodes.NOT_FOUND, "Pool not found"));
      return;
    }
    res.status(StatusCodes.OK).json({
      message: `Pool stats of ${currency} retrieved successfully`,
      data: result,
    });
  } catch (error: any) {
    next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message));
  }
};

export const poolController = {
  getPoolStats,
  createNew,
  getPoolStatsForCurrency,
};
