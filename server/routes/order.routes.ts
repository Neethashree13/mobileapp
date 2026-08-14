import { Router } from "express";
import * as orderController from "../controllers/order.controller";
import { checkDbConnection, requireAuth } from "../middleware/dbCheck";

const router = Router();

router.use(checkDbConnection);
router.use(requireAuth);

router.get("/", orderController.getOrders);
router.get("/active", orderController.getActiveOrder);
router.get("/:id", orderController.getOrderById);
router.post("/", orderController.placeOrder);
router.delete("/:id", orderController.deleteOrder);

router.patch("/:id/cancel", orderController.cancelOrder);
router.post("/:id/cancel", orderController.cancelOrder);
router.put("/:id/cancel", orderController.cancelOrder);

router.patch("/:id/modify", orderController.modifyOrder);
router.post("/:id/modify", orderController.modifyOrder);

router.post("/:id/repeat", orderController.repeatOrder);
router.post("/:id/reorder", orderController.repeatOrder);
router.put("/:id/reorder", orderController.repeatOrder);

router.get("/:id/timeline", orderController.getOrderTimeline);
router.get("/:id/tracking", orderController.getOrderTimeline);
router.get("/:id/invoice", orderController.getOrderInvoice);
router.get("/:id/eligibility", orderController.getOrderEligibility);

router.put("/:id/status", orderController.updateOrderStatus);
router.patch("/:id/status", orderController.updateOrderStatus);
router.post("/:id/status", orderController.updateOrderStatus);

router.post("/clear", orderController.clearActiveOrder);

export default router;
