import { Request, Response, NextFunction } from "express";
import { NotificationService } from "../services/notification.service";

export async function getNotifications(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = (req.query.userId as string) || "u1";
    const role = (req.query.role as string) || "CUSTOMER";
    const category = req.query.category as string;
    const unreadOnly = req.query.unreadOnly === "true";

    const list = await NotificationService.getUserNotifications(userId, role, category, unreadOnly);
    res.json(list);
  } catch (error) {
    next(error);
  }
}

export async function getUnreadNotifications(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = (req.query.userId as string) || "u1";
    const role = (req.query.role as string) || "CUSTOMER";

    const result = await NotificationService.getUnreadNotifications(userId, role);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function markAsRead(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const userId = (req.body.userId as string) || "u1";

    const success = await NotificationService.markAsRead(id, userId);
    if (!success) {
      res.status(404).json({ error: "Notification not found" });
      return;
    }
    res.json({ success: true, notificationId: id });
  } catch (error) {
    next(error);
  }
}

export async function markAllAsRead(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = (req.body.userId as string) || "u1";
    const role = (req.body.role as string) || "CUSTOMER";

    const count = await NotificationService.markAllAsRead(userId, role);
    res.json({ success: true, countMarked: count });
  } catch (error) {
    next(error);
  }
}

export async function deleteNotification(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const userId = (req.query.userId as string) || "u1";

    const deleted = await NotificationService.deleteNotification(id, userId);
    res.json({ success: deleted, notificationId: id });
  } catch (error) {
    next(error);
  }
}

export async function getPreferences(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = (req.query.userId as string) || "u1";
    const role = (req.query.role as string) || "CUSTOMER";

    const prefs = await NotificationService.getPreferences(userId, role);
    res.json(prefs);
  } catch (error) {
    next(error);
  }
}

export async function updatePreferences(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = (req.body.userId as string) || "u1";
    const role = (req.body.role as string) || "CUSTOMER";

    const updated = await NotificationService.updatePreferences(userId, req.body, role);
    res.json(updated);
  } catch (error) {
    next(error);
  }
}

export async function sendTestNotification(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId, role, templateCode, title, body, category, channels, metadata } = req.body;

    const notification = await NotificationService.send({
      userId: userId || "u1",
      role: role || "CUSTOMER",
      templateCode,
      title: title || "Test Notification 🧪",
      body: body || "This is a real-time multi-channel notification test from FlashCart.",
      category: category || "SYSTEM",
      channels: channels || ["IN_APP", "PUSH", "EMAIL", "SMS"],
      metadata: metadata || { testTime: new Date().toISOString() },
    });

    res.json({ success: true, notification });
  } catch (error) {
    next(error);
  }
}

export async function broadcastNotification(req: Request, res: Response, next: NextFunction) {
  try {
    const { targetRole, title, body, category, channels, isEmergency, metadata } = req.body;

    const broadcast = await NotificationService.broadcast({
      targetRole: targetRole || "ALL",
      title: title || "FlashCart System Broadcast 📢",
      body: body || "System maintenance scheduled tonight at 2:00 AM IST.",
      category: category || "SYSTEM",
      channels: channels || ["IN_APP", "PUSH"],
      isEmergency: Boolean(isEmergency),
      metadata,
    });

    res.json({ success: true, broadcast });
  } catch (error) {
    next(error);
  }
}

export async function getTemplates(req: Request, res: Response, next: NextFunction) {
  try {
    const templates = await NotificationService.getTemplates();
    res.json(templates);
  } catch (error) {
    next(error);
  }
}

export async function getLogs(req: Request, res: Response, next: NextFunction) {
  try {
    const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 50;
    const logs = await NotificationService.getLogs(limit);
    res.json(logs);
  } catch (error) {
    next(error);
  }
}
