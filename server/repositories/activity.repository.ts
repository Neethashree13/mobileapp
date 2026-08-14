import { dbQuery, usePostgreSQL, dbPool } from "../config/database";
import { logger } from "../utils/logger";

export interface ActivityLog {
  id: string;
  actionType: string;
  details: string;
  createdAt: string;
}

export class ActivityRepository {
  static async log(userId: string | null, actionType: string, details: string): Promise<void> {
    logger.info(`[ACTIVITY LOG] User: ${userId || "Anonymous"}, Action: ${actionType}, Details: ${details}`);
    if (dbPool && usePostgreSQL) {
      try {
        let actualUserId: string | null = userId;
        if (userId && userId.startsWith("FBAUTH_UID")) {
          const userRes = await dbPool.query("SELECT id FROM users WHERE firebase_uid = $1", [userId]);
          if (userRes.rows.length > 0) {
            actualUserId = userRes.rows[0].id;
          } else {
            actualUserId = null;
          }
        } else if (userId === "u1") {
          actualUserId = "6ba7b810-9dad-11d1-80b4-00c04fd430c8";
        }
        await dbPool.query(
          "INSERT INTO activity_logs (user_id, action_type, details) VALUES ($1, $2, $3)",
          [actualUserId, actionType, details]
        );
      } catch (err) {
        logger.warn("Could not log activity in database:", err);
      }
    }
  }

  static async getAll(): Promise<ActivityLog[]> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, action_type as "actionType", details, created_at as "createdAt"
        FROM activity_logs ORDER BY created_at DESC LIMIT 40
      `);
      return rows;
    }
    return [
      {
        id: "al1",
        actionType: "system_boot",
        details: "FlashCart backend sandbox booted",
        createdAt: new Date().toISOString(),
      },
    ];
  }
}
