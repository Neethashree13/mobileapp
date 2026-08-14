import { Router } from "express";
import * as notificationController from "../controllers/notification.controller";
import { checkDbConnection } from "../middleware/dbCheck";

const router = Router();

router.get("/", checkDbConnection, notificationController.getNotifications);
router.get("/unread", checkDbConnection, notificationController.getUnreadNotifications);
router.patch("/read-all", checkDbConnection, notificationController.markAllAsRead);
router.patch("/:id/read", checkDbConnection, notificationController.markAsRead);
router.delete("/:id", checkDbConnection, notificationController.deleteNotification);

router.get("/preferences", checkDbConnection, notificationController.getPreferences);
router.put("/preferences", checkDbConnection, notificationController.updatePreferences);

router.post("/test", checkDbConnection, notificationController.sendTestNotification);
router.post("/broadcast", checkDbConnection, notificationController.broadcastNotification);
router.get("/templates", checkDbConnection, notificationController.getTemplates);
router.get("/logs", checkDbConnection, notificationController.getLogs);

export default router;
