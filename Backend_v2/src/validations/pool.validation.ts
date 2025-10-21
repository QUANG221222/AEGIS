import { Request, Response, NextFunction } from "express";
import {
  CURATOR_ADDRESS_RULE,
  CURATOR_ADDRESS_RULE_MESSAGE,
} from "../utils/validator";
import { CURRENCIES } from "../utils/constants";
import Joi from "joi";
import { StatusCodes } from "http-status-codes";
import ApiError from "../utils/ApiError";

const createNew = async (req: Request, res: Response, next: NextFunction) => {
  const correctCondition = Joi.object({
    curatorAddress: Joi.string()
      .required()
      .pattern(CURATOR_ADDRESS_RULE)
      .messages({
        "string.pattern.base": CURATOR_ADDRESS_RULE_MESSAGE,
      }),
    currency: Joi.string()
      .required()
      .valid(...Object.values(CURRENCIES)),
  });
  try {
    await correctCondition.validateAsync(req.body, { abortEarly: false });
    next();
  } catch (error: any) {
    next(new ApiError(StatusCodes.UNPROCESSABLE_ENTITY, error.message));
  }
};
export const poolValidation = {
  createNew,
};
