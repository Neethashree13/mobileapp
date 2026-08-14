import { Router } from "express";
import * as adminController from "../controllers/admin.controller";
import * as couponController from "../controllers/coupon.controller";
import { checkDbConnection } from "../middleware/dbCheck";

const router = Router();

// Products Admin CRUD
router.post("/admin/products", checkDbConnection, adminController.createProduct);
router.put("/admin/products/:id", checkDbConnection, adminController.updateProductById);
router.delete("/admin/products/:id", checkDbConnection, adminController.deleteProductById);
router.post("/admin/products/update", checkDbConnection, adminController.updateProduct);
router.post("/admin/products/import", checkDbConnection, adminController.importProductsCSV);
router.get("/admin/products/export", checkDbConnection, adminController.exportProductsCSV);

// Categories & Brands Admin CRUD
router.post("/admin/categories", checkDbConnection, adminController.createCategory);
router.post("/admin/brands", checkDbConnection, adminController.createBrand);

// Coupons Admin CRUD
router.get("/admin/coupons", checkDbConnection, couponController.getAllCoupons);
router.post("/admin/coupons", checkDbConnection, couponController.createCoupon);
router.put("/admin/coupons/:id", checkDbConnection, couponController.updateCoupon);
router.delete("/admin/coupons/:id", checkDbConnection, couponController.deleteCoupon);

// System Logs & Sandbox Reset
router.get("/activity/logs", checkDbConnection, adminController.getActivityLogs);
router.post("/sandbox/reset", checkDbConnection, adminController.resetSandbox);

export default router;


