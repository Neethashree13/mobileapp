import { Request, Response, NextFunction } from "express";
import { logger } from "../utils/logger";
import { isProduction } from "../config/env";

export function errorHandler(
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
): void {
  logger.error(`[ErrorHandler] Captured error: ${err.message || err}`, {
    stack: err.stack,
    url: req.url,
    method: req.method,
  });

  const statusCode = err.statusCode || 500;
  const message = isProduction && statusCode === 500
    ? "An unexpected internal server error occurred"
    : err.message || "Internal Server Error";

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(isProduction ? {} : { stack: err.stack }),
  });
}
