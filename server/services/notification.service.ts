import { NotificationRepository, NotificationRecord, NotificationPreferencesRecord } from "../repositories/notification.repository";
import { SocketService } from "./socket.service";
import { logger } from "../utils/logger";

export interface SendNotificationOptions {
  userId: string;
  role?: "CUSTOMER" | "RIDER" | "STORE_MANAGER" | "ADMIN";
  templateCode?: string;
  title?: string;
  body?: string;
  category?: "ORDER" | "WALLET" | "PROMO" | "DELIVERY" | "INVENTORY" | "SYSTEM" | "SECURITY";
  params?: Record<string, any>;
  channels?: ("IN_APP" | "PUSH" | "EMAIL" | "SMS")[];
  metadata?: any;
  recipientEmail?: string;
  recipientPhone?: string;
  isEmergency?: boolean;
}

export class NotificationService {
  // Helper to replace {{key}} placeholders in template strings
  private static renderTemplate(str: string, params: Record<string, any> = {}): string {
    return str.replace(/\{\{\s*(\w+)\s*\}\}/g, (_, key) => {
      return params[key] !== undefined ? String(params[key]) : `{{${key}}}`;
    });
  }

  // Master send notification handler across channels
  static async send(options: SendNotificationOptions): Promise<NotificationRecord | null> {
    const userId = options.userId || "u1";
    const role = options.role || "CUSTOMER";
    const category = options.category || "ORDER";
    const params = options.params || {};

    let title = options.title || "";
    let body = options.body || "";
    let allowedChannels = options.channels || ["IN_APP", "PUSH", "EMAIL", "SMS"];

    // 1. Resolve template if code provided
    if (options.templateCode) {
      const tpl = await NotificationRepository.getTemplateByCode(options.templateCode);
      if (tpl && tpl.isActive) {
        title = title || this.renderTemplate(tpl.title, params);
        body = body || this.renderTemplate(tpl.bodyTemplate, params);
        if (!options.channels && tpl.channels) {
          allowedChannels = tpl.channels as any;
        }
      }
    }

    if (!title || !body) {
      title = title || "FlashCart Alert 🔔";
      body = body || "You have a new update on FlashCart.";
    }

    // 2. Check user notification preferences
    const prefs = await NotificationRepository.getPreferences(userId, role);
    if (prefs) {
      // Category filter check
      if (prefs.categories && prefs.categories[category] === false && !options.isEmergency) {
        logger.info(`Notification blocked for ${userId} because category ${category} is disabled in preferences`);
        return null;
      }
    }

    // 3. Create In-App Notification Record if IN_APP channel active
    let notificationRecord: NotificationRecord | null = null;
    if (allowedChannels.includes("IN_APP") && (!prefs || prefs.inAppEnabled || options.isEmergency)) {
      notificationRecord = await NotificationRepository.createNotification({
        userId,
        role,
        title,
        body,
        category,
        channel: "IN_APP",
        metadata: options.metadata || {},
      });
    }

    // 4. Dispatch FCM Push Notification
    if (allowedChannels.includes("PUSH") && (!prefs || prefs.pushEnabled || options.isEmergency)) {
      await this.dispatchPushNotification({
        userId,
        role,
        title,
        body,
        category,
        metadata: options.metadata,
        isEmergency: options.isEmergency,
      });
    }

    // 5. Dispatch Email
    if (allowedChannels.includes("EMAIL") && (!prefs || prefs.emailEnabled || options.isEmergency)) {
      const emailRecipient = options.recipientEmail || `${userId}@flashcart.ai`;
      await this.dispatchEmailNotification({
        recipient: emailRecipient,
        title,
        body,
        category,
      });
    }

    // 6. Dispatch SMS
    if (allowedChannels.includes("SMS") && (!prefs || prefs.smsEnabled || options.isEmergency)) {
      const phoneRecipient = options.recipientPhone || "+91 98765 43210";
      await this.dispatchSmsNotification({
        recipient: phoneRecipient,
        title,
        body,
      });
    }

    // 7. Real-Time Socket.IO Notification Dispatch
    const unreadCount = await NotificationRepository.getUnreadCount(userId, role);
    
    SocketService.emitToAll("notification.created", {
      notification: notificationRecord || {
        id: `n_rt_${Date.now()}`,
        userId,
        role,
        title,
        body,
        category,
        read: false,
        metadata: options.metadata || {},
        createdAt: new Date().toISOString(),
      },
      unreadCount,
    });

    // Domain Specific Socket Events as requested
    if (category === "ORDER") {
      SocketService.emitToAll("order.updated", {
        userId,
        orderId: options.metadata?.orderId,
        title,
        body,
      });
    } else if (category === "WALLET") {
      SocketService.emitToAll("wallet.updated", {
        userId,
        balance: options.metadata?.newBalance,
        title,
        body,
      });
    } else if (category === "DELIVERY") {
      SocketService.emitToAll("delivery.updated", {
        orderId: options.metadata?.orderId,
        riderId: options.metadata?.riderId,
        title,
        body,
      });
    }

    return notificationRecord;
  }

  // FCM Push Notification Handler
  private static async dispatchPushNotification(payload: {
    userId: string;
    role: string;
    title: string;
    body: string;
    category: string;
    metadata?: any;
    isEmergency?: boolean;
  }) {
    try {
      // Simulate Firebase Cloud Messaging dispatch
      logger.info(`[FCM Push] Sent to user ${payload.userId} (${payload.role}): ${payload.title} - ${payload.body}`);
      
      await NotificationRepository.logNotificationSend({
        channel: "PUSH",
        recipient: `fcm_token_${payload.userId}`,
        status: "DELIVERED",
      });
    } catch (err: any) {
      logger.error(`Error sending push notification to ${payload.userId}:`, err);
      await NotificationRepository.logNotificationSend({
        channel: "PUSH",
        recipient: `fcm_token_${payload.userId}`,
        status: "FAILED",
        errorMessage: err.message || "FCM Gateway error",
      });
    }
  }

  // Email Notification Handler
  private static async dispatchEmailNotification(payload: {
    recipient: string;
    title: string;
    body: string;
    category: string;
  }) {
    try {
      logger.info(`[Email Service] Delivered email to ${payload.recipient}: Subject: "${payload.title}"`);
      await NotificationRepository.logNotificationSend({
        channel: "EMAIL",
        recipient: payload.recipient,
        status: "DELIVERED",
      });
    } catch (err: any) {
      logger.error(`Error sending email to ${payload.recipient}:`, err);
      await NotificationRepository.logNotificationSend({
        channel: "EMAIL",
        recipient: payload.recipient,
        status: "FAILED",
        errorMessage: err.message || "SMTP Connection timeout",
      });
    }
  }

  // SMS Notification Handler
  private static async dispatchSmsNotification(payload: {
    recipient: string;
    title: string;
    body: string;
  }) {
    try {
      logger.info(`[SMS Gateway] Sent SMS to ${payload.recipient}: "${payload.title}: ${payload.body}"`);
      await NotificationRepository.logNotificationSend({
        channel: "SMS",
        recipient: payload.recipient,
        status: "DELIVERED",
      });
    } catch (err: any) {
      logger.error(`Error sending SMS to ${payload.recipient}:`, err);
      await NotificationRepository.logNotificationSend({
        channel: "SMS",
        recipient: payload.recipient,
        status: "FAILED",
        errorMessage: err.message || "SMS Gateway timeout",
      });
    }
  }

  // Broadcast / Emergency Campaign
  static async broadcast(options: {
    targetRole?: "CUSTOMER" | "RIDER" | "STORE_MANAGER" | "ADMIN" | "ALL";
    title: string;
    body: string;
    category?: "ORDER" | "WALLET" | "PROMO" | "DELIVERY" | "INVENTORY" | "SYSTEM" | "SECURITY";
    channels?: ("IN_APP" | "PUSH" | "EMAIL" | "SMS")[];
    isEmergency?: boolean;
    metadata?: any;
  }) {
    const roleTarget = options.targetRole || "ALL";
    const title = options.title;
    const body = options.body;
    const category = options.category || "PROMO";

    // Create broadcast record
    const record = await NotificationRepository.createNotification({
      userId: "ALL",
      role: roleTarget,
      title,
      body,
      category,
      channel: "IN_APP",
      metadata: options.metadata || { isEmergency: options.isEmergency },
    });

    // Real-Time Socket Emission
    SocketService.emitToAll("notification.created", {
      notification: record,
      isBroadcast: true,
      isEmergency: options.isEmergency,
    });

    if (options.isEmergency) {
      SocketService.emitToAll("emergency.alert", {
        title,
        body,
        targetRole: roleTarget,
        timestamp: new Date().toISOString(),
      });
    }

    await NotificationRepository.logNotificationSend({
      channel: "BROADCAST",
      recipient: `ROLE_${roleTarget}`,
      status: "DELIVERED",
    });

    return record;
  }

  // Public Query APIs
  static async getUserNotifications(userId: string, role?: string, category?: string, unreadOnly?: boolean) {
    return NotificationRepository.getUserNotifications(userId, role, category, unreadOnly);
  }

  static async getUnreadNotifications(userId: string, role?: string) {
    const list = await NotificationRepository.getUserNotifications(userId, role, undefined, true);
    const count = await NotificationRepository.getUnreadCount(userId, role);
    return { notifications: list, unreadCount: count };
  }

  static async markAsRead(notificationId: string, userId: string) {
    const success = await NotificationRepository.markAsRead(notificationId, userId);
    if (success) {
      SocketService.emitToAll("notification.read", {
        notificationId,
        userId,
      });
    }
    return success;
  }

  static async markAllAsRead(userId: string, role?: string) {
    const count = await NotificationRepository.markAllAsRead(userId, role);
    SocketService.emitToAll("notification.read", {
      userId,
      markedAll: true,
      count,
    });
    return count;
  }

  static async deleteNotification(notificationId: string, userId: string) {
    const deleted = await NotificationRepository.deleteNotification(notificationId, userId);
    if (deleted) {
      SocketService.emitToAll("notification.deleted", {
        notificationId,
        userId,
      });
    }
    return deleted;
  }

  static async getPreferences(userId: string, role?: string) {
    return NotificationRepository.getPreferences(userId, role);
  }

  static async updatePreferences(userId: string, prefs: Partial<NotificationPreferencesRecord>, role?: string) {
    return NotificationRepository.upsertPreferences(userId, prefs, role);
  }

  static async getTemplates() {
    return NotificationRepository.getAllTemplates();
  }

  static async getLogs(limit: number = 50) {
    return NotificationRepository.getNotificationLogs(limit);
  }
}
