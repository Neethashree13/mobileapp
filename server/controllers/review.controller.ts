import { Request, Response, NextFunction } from "express";
import { ReviewService } from "../services/review.service";
import { isProduction } from "../config/env";
import { usePostgreSQL } from "../config/database";

export async function getReviews(req: Request, res: Response, next: NextFunction) {
  const { productId } = req.query;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const reviews = await ReviewService.getProductReviews(productId ? String(productId) : "p1");
    res.json(reviews);
  } catch (error) {
    next(error);
  }
}

export async function addReview(req: Request, res: Response, next: NextFunction) {
  const { productId, rating, comment, userName } = req.body;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const review = await ReviewService.addProductReview(
      productId,
      userName || "Arav",
      Number(rating || 5),
      comment || ""
    );
    res.json(review);
  } catch (error) {
    next(error);
  }
}
