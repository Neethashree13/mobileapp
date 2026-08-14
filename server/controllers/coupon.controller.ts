import { Request, Response, NextFunction } from "express";
import { CouponService } from "../services/coupon.service";
import { CartService } from "../services/cart.service";
import { isProduction } from "../config/env";
import { usePostgreSQL } from "../config/database";

export async function getAllCoupons(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const coupons = await CouponService.getAllCoupons();
    res.json(coupons);
  } catch (error) {
    next(error);
  }
}

export async function validateCoupon(req: Request, res: Response, next: NextFunction) {
  const { code, orderValue, subtotal } = req.body;
  const val = Number(subtotal !== undefined ? subtotal : orderValue || 0);
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const result = await CouponService.validateCoupon(code, val);
    if (result.valid) {
      res.json({ isValid: true, discountAmount: result.discount, coupon: result.coupon });
    } else {
      res.json({ isValid: false, discountAmount: 0, reason: result.reason });
    }
  } catch (error) {
    next(error);
  }
}

export async function applyCoupon(req: Request, res: Response, next: NextFunction) {
  const { code, subtotal } = req.body;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const cartSummary = await CartService.getCartSummary("6ba7b810-9dad-11d1-80b4-00c04fd430c8", code);
    const effectiveSubtotal = Number(subtotal !== undefined ? subtotal : cartSummary.subtotal);
    const result = await CouponService.validateCoupon(code, effectiveSubtotal);

    if (!result.valid) {
      res.status(400).json({ status: "error", message: result.reason || "Invalid coupon" });
      return;
    }

    res.json({
      status: "success",
      appliedCode: code.toUpperCase(),
      discountAmount: result.discount,
      summary: cartSummary,
    });
  } catch (error) {
    next(error);
  }
}

export async function removeCoupon(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const cartSummary = await CartService.getCartSummary("6ba7b810-9dad-11d1-80b4-00c04fd430c8");
    res.json({ status: "success", message: "Coupon removed successfully", summary: cartSummary });
  } catch (error) {
    next(error);
  }
}

export async function createCoupon(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const coupon = await CouponService.createCoupon(req.body);
    res.status(201).json(coupon);
  } catch (error) {
    next(error);
  }
}

export async function updateCoupon(req: Request, res: Response, next: NextFunction) {
  const { id } = req.params;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const updated = await CouponService.updateCoupon(id, req.body);
    if (!updated) {
      res.status(404).json({ error: "Coupon not found" });
      return;
    }
    res.json(updated);
  } catch (error) {
    next(error);
  }
}

export async function deleteCoupon(req: Request, res: Response, next: NextFunction) {
  const { id } = req.params;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const success = await CouponService.deleteCoupon(id);
    if (!success) {
      res.status(404).json({ error: "Coupon not found" });
      return;
    }
    res.json({ status: "success", message: "Coupon deleted successfully" });
  } catch (error) {
    next(error);
  }
}

