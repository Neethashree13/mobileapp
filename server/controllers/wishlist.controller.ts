import { Request, Response, NextFunction } from "express";
import { WishlistService } from "../services/wishlist.service";
import { isProduction } from "../config/env";
import { usePostgreSQL } from "../config/database";


 type AuthRequest = Request & {
  user?: {
    uid: string;
    email: string;
  };
};

export async function getWishlist(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
  const userId = req.user!.uid;

const ids = await WishlistService.getWishlist(userId);
const products = await WishlistService.getWishlistProducts(userId);
    res.json({ wishlist: ids, items: products });
  } catch (error) {
    next(error);
  }
}

export async function addItem(req: AuthRequest, res: Response, next: NextFunction) {
  const { productId } = req.body;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
   const userId = req.user!.uid;

const updated = await WishlistService.addToWishlist(productId, userId);
const products = await WishlistService.getWishlistProducts(userId);
    res.json({ status: "success", wishlist: updated, items: products });
  } catch (error) {
    next(error);
  }
}

export async function deleteItem(req: AuthRequest, res: Response, next: NextFunction) {
  const { id } = req.params;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
   const userId = req.user!.uid;

const updated = await WishlistService.removeFromWishlist(id, userId);
const products = await WishlistService.getWishlistProducts(userId);
    res.json({ status: "success", wishlist: updated, items: products });
  } catch (error) {
    next(error);
  }
}

export async function toggleWishlist(req: AuthRequest, res: Response, next: NextFunction) {
  const { productId } = req.body;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const userId = req.user!.uid;

const updated = await WishlistService.toggleWishlist(productId, userId);
const products = await WishlistService.getWishlistProducts(userId);
    res.json({ status: "success", wishlist: updated, items: products });
  } catch (error) {
    next(error);
  }
}

