import { Request, Response, NextFunction } from "express";
import { CartService } from "../services/cart.service";
import { isProduction } from "../config/env";
import { usePostgreSQL } from "../config/database";

function getUserId(req: Request): string {
  return (
    (req as any).user?.uid ||
    (req as any).user?.id ||
    ""
  );
}

export async function getCart(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      return res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
    }

    const userId = getUserId(req);
    const couponCode = req.query.couponCode as string | undefined;

    const summary = await CartService.getCartSummary(userId, couponCode);

    res.json(summary);
  } catch (error) {
    next(error);
  }
}

export async function addItem(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      return res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
    }

    const userId = getUserId(req);

    const {
      productId,
      quantity = 1,
      addedBy = "Self",
    } = req.body;

    const cart = await CartService.addItem(
      productId,
      Number(quantity),
      addedBy,
      userId
    );

    const summary = await CartService.getCartSummary(userId);

    res.json({
      status: "success",
      items: cart,
      summary,
    });
  } catch (error) {
    next(error);
  }
}

export async function updateItem(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      return res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
    }

    const userId = getUserId(req);

    const { id } = req.params;
    const { quantity } = req.body;

    const cart = await CartService.updateItemQuantity(
      id,
      Number(quantity),
      userId
    );

    const summary = await CartService.getCartSummary(userId);

    res.json({
      status: "success",
      items: cart,
      summary,
    });
  } catch (error) {
    next(error);
  }
}

export async function removeItem(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      return res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
    }

    const userId = getUserId(req);

    const { id } = req.params;

    const cart = await CartService.removeItem(id, userId);

    const summary = await CartService.getCartSummary(userId);

    res.json({
      status: "success",
      items: cart,
      summary,
    });
  } catch (error) {
    next(error);
  }
}

export async function saveForLater(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      return res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
    }

    const userId = getUserId(req);

    const {
      productId,
      isSavedForLater = true,
    } = req.body;

    const cart = await CartService.toggleSaveForLater(
      productId,
      Boolean(isSavedForLater),
      userId
    );

    const summary = await CartService.getCartSummary(userId);

    res.json({
      status: "success",
      items: cart,
      summary,
    });
  } catch (error) {
    next(error);
  }
}

export async function getCheckoutSummary(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      return res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
    }

    const userId = getUserId(req);

    const couponCode = req.query.couponCode as string | undefined;

    const summary = await CartService.getCartSummary(
      userId,
      couponCode
    );

    res.json(summary);
  } catch (error) {
    next(error);
  }
}

export async function validateCheckout(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      return res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
    }

    const userId = getUserId(req);

    const {
      couponCode,
      storeId = "s1",
    } = req.body;

    const result = await CartService.validateAndReserveCheckout(
      userId,
      couponCode,
      storeId
    );

    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function syncCart(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      return res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
    }

    const userId = getUserId(req);

    const { cart = [] } = req.body;

    const syncedCart = await CartService.syncCart(
      cart,
      userId
    );

    res.json({
      status: "success",
      count: syncedCart.length,
      cart: syncedCart,
    });
  } catch (error) {
    next(error);
  }
}