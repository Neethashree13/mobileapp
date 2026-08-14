import { dbQuery, usePostgreSQL } from "../config/database";
import { DB_STATE } from "../config/dbState";

export interface NotificationRecord {
  id: string;
  userId: string;
  role: string;
  title: string;
  body: string;
  category: string;
  channel: string;
  read: boolean;
  metadata?: any;
  createdAt: string;
}

export interface NotificationPreferencesRecord {
  id?: string;
  userId: string;
  role: string;
  emailEnabled: boolean;
  smsEnabled: boolean;
  pushEnabled: boolean;
  inAppEnabled: boolean;
  categories: Record<string, boolean>;
  updatedAt?: string;
}

export interface NotificationTemplateRecord {
  id?: string;
  code: string;
  title: string;
  bodyTemplate: string;
  category: string;
  channels: string[];
  isActive: boolean;
  createdAt?: string;
}

export class NotificationRepository {
  // Get Notifications
  static async getUserNotifications(
    userId: string = "u1",
    role: string = "CUSTOMER",
    category?: string,
    unreadOnly?: boolean
  ): Promise<NotificationRecord[]> {
    if (usePostgreSQL) {
      try {
        let sql = `SELECT id, user_id, role, title, body, category, channel, read, metadata, created_at FROM notifications WHERE (user_id = $1 OR user_id = 'ALL' OR role = $2)`;
        const params: any[] = [userId, role];

        if (category && category !== "ALL") {
          params.push(category);
          sql += ` AND category = $${params.length}`;
        }
        if (unreadOnly) {
          sql += ` AND read = false`;
        }

        sql += ` ORDER BY created_at DESC LIMIT 50`;

        const res = await dbQuery(sql, params);
        return res.rows.map((row: any) => ({
          id: row.id,
          userId: row.user_id,
          role: row.role,
          title: row.title,
          body: row.body,
          category: row.category,
          channel: row.channel,
          read: row.read,
          metadata: row.metadata,
          createdAt: row.created_at,
        }));
      } catch (err) {
        console.warn("Error fetching notifications from DB:", err);
      }
    }

    let list = (DB_STATE.notifications || []).filter(
      (n: any) => n.userId === userId || n.userId === "ALL" || n.role === role
    );

    if (category && category !== "ALL") {
      list = list.filter((n: any) => n.category === category);
    }
    if (unreadOnly) {
      list = list.filter((n: any) => !n.read);
    }

    return list.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }

  // Get Unread Count
  static async getUnreadCount(userId: string = "u1", role: string = "CUSTOMER"): Promise<number> {
    if (usePostgreSQL) {
      try {
        const res = await dbQuery(
          `SELECT COUNT(*) FROM notifications WHERE (user_id = $1 OR user_id = 'ALL' OR role = $2) AND read = false`,
          [userId, role]
        );
        return parseInt(res.rows[0].count, 10);
      } catch (err) {
        console.warn("Error counting unread notifications from DB:", err);
      }
    }

    return (DB_STATE.notifications || []).filter(
      (n: any) => (n.userId === userId || n.userId === "ALL" || n.role === role) && !n.read
    ).length;
  }

  // Mark single as read
  static async markAsRead(notificationId: string, userId: string = "u1"): Promise<boolean> {
    if (usePostgreSQL) {
      try {
        await dbQuery(`UPDATE notifications SET read = true WHERE id = $1`, [notificationId]);
        return true;
      } catch (err) {
        console.warn("Error marking notification read in DB:", err);
      }
    }

    const item = (DB_STATE.notifications || []).find((n: any) => n.id === notificationId);
    if (item) {
      item.read = true;
      return true;
    }
    return false;
  }

  // Mark all as read
  static async markAllAsRead(userId: string = "u1", role: string = "CUSTOMER"): Promise<number> {
    if (usePostgreSQL) {
      try {
        const res = await dbQuery(
          `UPDATE notifications SET read = true WHERE (user_id = $1 OR user_id = 'ALL' OR role = $2) AND read = false RETURNING id`,
          [userId, role]
        );
        return res.rowCount || 0;
      } catch (err) {
        console.warn("Error marking all read in DB:", err);
      }
    }

    let count = 0;
    (DB_STATE.notifications || []).forEach((n: any) => {
      if ((n.userId === userId || n.userId === "ALL" || n.role === role) && !n.read) {
        n.read = true;
        count++;
      }
    });
    return count;
  }

  // Delete single notification
  static async deleteNotification(notificationId: string, userId: string = "u1"): Promise<boolean> {
    if (usePostgreSQL) {
      try {
        await dbQuery(`DELETE FROM notifications WHERE id = $1`, [notificationId]);
        return true;
      } catch (err) {
        console.warn("Error deleting notification from DB:", err);
      }
    }

    const initialLen = (DB_STATE.notifications || []).length;
    DB_STATE.notifications = (DB_STATE.notifications || []).filter((n: any) => n.id !== notificationId);
    return DB_STATE.notifications.length < initialLen;
  }

  // Create notification
  static async createNotification(data: {
    userId: string;
    role?: string;
    title: string;
    body: string;
    category?: string;
    channel?: string;
    metadata?: any;
  }): Promise<NotificationRecord> {
    const role = data.role || "CUSTOMER";
    const category = data.category || "ORDER";
    const channel = data.channel || "IN_APP";

    if (usePostgreSQL) {
      try {
        const res = await dbQuery(
          `INSERT INTO notifications (user_id, role, title, body, category, channel, metadata)
           VALUES ($1, $2, $3, $4, $5, $6, $7)
           RETURNING id, user_id, role, title, body, category, channel, read, metadata, created_at`,
          [data.userId, role, data.title, data.body, category, channel, data.metadata ? JSON.stringify(data.metadata) : null]
        );
        const row = res.rows[0];
        return {
          id: row.id,
          userId: row.user_id,
          role: row.role,
          title: row.title,
          body: row.body,
          category: row.category,
          channel: row.channel,
          read: row.read,
          metadata: row.metadata,
          createdAt: row.created_at,
        };
      } catch (err) {
        console.warn("Error creating notification in DB:", err);
      }
    }

    const record: NotificationRecord = {
      id: `n_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
      userId: data.userId,
      role,
      title: data.title,
      body: data.body,
      category,
      channel,
      read: false,
      metadata: data.metadata || {},
      createdAt: new Date().toISOString(),
    };
    DB_STATE.notifications.unshift(record);
    return record;
  }

  // Get User Preferences
  static async getPreferences(userId: string = "u1", role: string = "CUSTOMER"): Promise<NotificationPreferencesRecord> {
    const defaultPrefs: NotificationPreferencesRecord = {
      userId,
      role,
      emailEnabled: true,
      smsEnabled: true,
      pushEnabled: true,
      inAppEnabled: true,
      categories: { ORDER: true, WALLET: true, PROMO: true, SYSTEM: true, DELIVERY: true, INVENTORY: true },
    };

    if (usePostgreSQL) {
      try {
        const res = await dbQuery(
          `SELECT id, user_id, role, email_enabled, sms_enabled, push_enabled, in_app_enabled, categories, updated_at
           FROM notification_preferences WHERE user_id = $1 LIMIT 1`,
          [userId]
        );
        if (res.rows.length > 0) {
          const row = res.rows[0];
          return {
            id: row.id,
            userId: row.user_id,
            role: row.role,
            emailEnabled: row.email_enabled,
            smsEnabled: row.sms_enabled,
            pushEnabled: row.push_enabled,
            inAppEnabled: row.in_app_enabled,
            categories: row.categories || defaultPrefs.categories,
            updatedAt: row.updated_at,
          };
        }
      } catch (err) {
        console.warn("Error fetching notification preferences from DB:", err);
      }
    }

    const memPref = (DB_STATE.notificationPreferences || []).find((p: any) => p.userId === userId);
    if (memPref) return memPref;

    return defaultPrefs;
  }

  // Upsert User Preferences
  static async upsertPreferences(
    userId: string = "u1",
    prefs: Partial<NotificationPreferencesRecord>,
    role: string = "CUSTOMER"
  ): Promise<NotificationPreferencesRecord> {
    const current = await this.getPreferences(userId, role);
    const updated: NotificationPreferencesRecord = {
      ...current,
      ...prefs,
      userId,
      role,
      categories: { ...current.categories, ...(prefs.categories || {}) },
      updatedAt: new Date().toISOString(),
    };

    if (usePostgreSQL) {
      try {
        await dbQuery(
          `INSERT INTO notification_preferences (user_id, role, email_enabled, sms_enabled, push_enabled, in_app_enabled, categories, updated_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP)
           ON CONFLICT (user_id) DO UPDATE SET
             email_enabled = EXCLUDED.email_enabled,
             sms_enabled = EXCLUDED.sms_enabled,
             push_enabled = EXCLUDED.push_enabled,
             in_app_enabled = EXCLUDED.in_app_enabled,
             categories = EXCLUDED.categories,
             updated_at = CURRENT_TIMESTAMP`,
          [
            userId,
            role,
            updated.emailEnabled,
            updated.smsEnabled,
            updated.pushEnabled,
            updated.inAppEnabled,
            JSON.stringify(updated.categories),
          ]
        );
      } catch (err) {
        console.warn("Error saving notification preferences in DB:", err);
      }
    }

    const existingIdx = (DB_STATE.notificationPreferences || []).findIndex((p: any) => p.userId === userId);
    if (existingIdx >= 0) {
      DB_STATE.notificationPreferences[existingIdx] = updated;
    } else {
      DB_STATE.notificationPreferences.push(updated);
    }

    return updated;
  }

  // Get Template by Code
  static async getTemplateByCode(code: string): Promise<NotificationTemplateRecord | null> {
    if (usePostgreSQL) {
      try {
        const res = await dbQuery(
          `SELECT id, code, title, body_template, category, channels, is_active FROM notification_templates WHERE code = $1 LIMIT 1`,
          [code]
        );
        if (res.rows.length > 0) {
          const row = res.rows[0];
          return {
            id: row.id,
            code: row.code,
            title: row.title,
            bodyTemplate: row.body_template,
            category: row.category,
            channels: row.channels || ["IN_APP", "PUSH", "EMAIL", "SMS"],
            isActive: row.is_active,
          };
        }
      } catch (err) {
        console.warn("Error fetching notification template from DB:", err);
      }
    }

    const t = (DB_STATE.notificationTemplates || []).find((tpl: any) => tpl.code === code);
    return t || null;
  }

  // Get All Templates
  static async getAllTemplates(): Promise<NotificationTemplateRecord[]> {
    if (usePostgreSQL) {
      try {
        const res = await dbQuery(`SELECT id, code, title, body_template, category, channels, is_active FROM notification_templates ORDER BY code ASC`);
        return res.rows.map((row: any) => ({
          id: row.id,
          code: row.code,
          title: row.title,
          bodyTemplate: row.body_template,
          category: row.category,
          channels: row.channels || ["IN_APP", "PUSH", "EMAIL", "SMS"],
          isActive: row.is_active,
        }));
      } catch (err) {
        console.warn("Error fetching notification templates from DB:", err);
      }
    }

    return DB_STATE.notificationTemplates || [];
  }

  // Log Notification Delivery
  static async logNotificationSend(data: {
    notificationId?: string;
    channel: string;
    recipient: string;
    status: string;
    errorMessage?: string;
  }): Promise<void> {
    if (usePostgreSQL) {
      try {
        await dbQuery(
          `INSERT INTO notification_logs (notification_id, channel, recipient, status, error_message)
           VALUES ($1, $2, $3, $4, $5)`,
          [data.notificationId || null, data.channel, data.recipient, data.status, data.errorMessage || null]
        );
      } catch (err) {
        console.warn("Error logging notification dispatch in DB:", err);
      }
    }

    DB_STATE.notificationLogs.push({
      id: `log_${Date.now()}`,
      notificationId: data.notificationId,
      channel: data.channel,
      recipient: data.recipient,
      status: data.status,
      errorMessage: data.errorMessage,
      createdAt: new Date().toISOString(),
    });
  }

  // Get Dispatch Logs
  static async getNotificationLogs(limit: number = 50): Promise<any[]> {
    if (usePostgreSQL) {
      try {
        const res = await dbQuery(
          `SELECT id, notification_id, channel, recipient, status, retry_count, error_message, created_at
           FROM notification_logs ORDER BY created_at DESC LIMIT $1`,
          [limit]
        );
        return res.rows.map((r: any) => ({
          id: r.id,
          notificationId: r.notification_id,
          channel: r.channel,
          recipient: r.recipient,
          status: r.status,
          retryCount: r.retry_count,
          errorMessage: r.error_message,
          createdAt: r.created_at,
        }));
      } catch (err) {
        console.warn("Error fetching notification logs from DB:", err);
      }
    }

    return (DB_STATE.notificationLogs || []).slice(-limit).reverse();
  }
}
