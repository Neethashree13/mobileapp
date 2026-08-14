import { Router } from "express";
import * as couponController from "../controllers/coupon.controller";
import { checkDbConnection } from "../middleware/dbCheck";

const router = Router();

router.get("/", checkDbConnection, couponController.getAllCoupons);
router.post("/validate", checkDbConnection, couponController.validateCoupon);
router.post("/apply", checkDbConnection, couponController.applyCoupon);
router.delete("/remove", checkDbConnection, couponController.removeCoupon);

export default router;

