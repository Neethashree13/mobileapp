import { Router } from "express";
import * as cartController from "../controllers/cart.controller";
import { checkDbConnection, requireAuth } from "../middleware/dbCheck";
import {
  validateBody,
  cartSyncSchema,
} from "../validators/request.validators";

const router = Router();

// Get Cart
router.get(
  "/",
  checkDbConnection,
  requireAuth,
  cartController.getCart
);

// Add Item
router.post(
  "/items",
  checkDbConnection,
  requireAuth,
  cartController.addItem
);

// Update Item Quantity
router.put(
  "/items/:id",
  checkDbConnection,
  requireAuth,
  cartController.updateItem
);

// Remove Item
router.delete(
  "/items/:id",
  checkDbConnection,
  requireAuth,
  cartController.removeItem
);

// Save For Later
router.post(
  "/save-for-later",
  checkDbConnection,
  requireAuth,
  cartController.saveForLater
);

// Sync Cart
router.post(
  "/sync",
  checkDbConnection,
  requireAuth,
  (req, res, next) => {
    const bodyToValidate = req.body.cart || req.body;

    validateBody(cartSyncSchema)(
      {
        ...req,
        body: bodyToValidate,
      } as any,
      res,
      next
    );
  },
  cartController.syncCart
);

export default router;