import { Router } from "express";
import * as deliveryController from "../controllers/delivery.controller";
import { checkDbConnection } from "../middleware/dbCheck";

const router = Router();

// Store & Dispatch APIs
router.get("/stores", checkDbConnection, deliveryController.getDarkStores);
router.post("/dispatch/nearest-store", checkDbConnection, deliveryController.getNearestStore);

// Rider Management & Telemetry APIs
router.get("/riders", checkDbConnection, deliveryController.getRiders);
router.post("/riders/:id/status", checkDbConnection, deliveryController.updateRiderStatus);
router.post("/riders/:id/location", checkDbConnection, deliveryController.recordRiderGps);

// Order Delivery Tracking & Assignment APIs
router.get("/track", checkDbConnection, deliveryController.getDeliveryTrack);
router.get("/orders/:orderId", checkDbConnection, deliveryController.getDeliveryByOrderId);
router.get("/orders/:orderId/audit-logs", checkDbConnection, deliveryController.getAuditLogs);

router.post("/update", checkDbConnection, deliveryController.updateDelivery);
router.post("/orders/:orderId/assign", checkDbConnection, deliveryController.assignRider);
router.post("/orders/:orderId/accept", checkDbConnection, deliveryController.acceptDelivery);
router.post("/orders/:orderId/reject", checkDbConnection, deliveryController.rejectDelivery);
router.post("/orders/:orderId/pickup", checkDbConnection, deliveryController.pickupDelivery);
router.post("/orders/:orderId/verify-otp", checkDbConnection, deliveryController.verifyDeliveryOtp);
router.post("/orders/:orderId/complete", checkDbConnection, deliveryController.completeDelivery);

export default router;
