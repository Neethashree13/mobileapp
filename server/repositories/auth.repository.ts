import { dbQuery, usePostgreSQL } from "../config/database";
import { DB_STATE } from "../config/dbState";
import { logger } from "../utils/logger";

export interface CreateUserData {
  email?: string;
  phone?: string;
  passwordHash?: string;
  firstName: string;
  lastName?: string;
  role?: string;
  firebaseUid?: string;
  profilePhoto?: string;
  gender?: string;
  authProvider?: string;
}

export interface CreateSessionData {
  deviceId?: string;
  deviceName?: string;
  refreshToken: string;
  ipAddress?: string;
  isRememberMe?: boolean;
  expiresAt: Date;
}

export class AuthRepository {
  /**
   * Find user by Email
   */
  static async findByEmail(email: string): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, email, phone, phone_number as "phoneNumber", password_hash as "passwordHash",
               first_name as "firstName", last_name as "lastName", role, auth_provider as "authProvider",
               firebase_uid as "firebaseUid", profile_photo as "profilePhoto", profile_image as "profileImage",
               gender, is_verified as "isVerified", is_active as "isActive", wallet_balance as "walletBalance",
               streak_count as "streakCount", last_login as "lastLogin", created_at as "createdAt"
        FROM users WHERE email = $1 LIMIT 1
      `, [email]);
      return rows[0] || null;
    }
    const user = (DB_STATE as any).users?.find((u: any) => u.email === email);
    return user || null;
  }

  /**
   * Find user by Phone
   */
  static async findByPhone(phone: string): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, email, phone, phone_number as "phoneNumber", password_hash as "passwordHash",
               first_name as "firstName", last_name as "lastName", role, auth_provider as "authProvider",
               firebase_uid as "firebaseUid", profile_photo as "profilePhoto", profile_image as "profileImage",
               gender, is_verified as "isVerified", is_active as "isActive", wallet_balance as "walletBalance",
               streak_count as "streakCount", last_login as "lastLogin", created_at as "createdAt"
        FROM users WHERE phone = $1 OR phone_number = $1 LIMIT 1
      `, [phone]);
      return rows[0] || null;
    }
    const user = (DB_STATE as any).users?.find((u: any) => u.phone === phone || u.phoneNumber === phone);
    return user || null;
  }

  /**
   * Find user by ID
   */
  static async findById(id: string): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, email, phone, phone_number as "phoneNumber", password_hash as "passwordHash",
               first_name as "firstName", last_name as "lastName", role, auth_provider as "authProvider",
               firebase_uid as "firebaseUid", profile_photo as "profilePhoto", profile_image as "profileImage",
               gender, is_verified as "isVerified", is_active as "isActive", wallet_balance as "walletBalance",
               streak_count as "streakCount", last_login as "lastLogin", created_at as "createdAt"
        FROM users WHERE id = $1 LIMIT 1
      `, [id]);
      return rows[0] || null;
    }
    const user = (DB_STATE as any).users?.find((u: any) => u.id === id);
    return user || null;
  }

  /**
   * Find user by Firebase Uid
   */
  static async findByFirebaseUid(firebaseUid: string): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, email, phone, phone_number as "phoneNumber", password_hash as "passwordHash",
               first_name as "firstName", last_name as "lastName", role, auth_provider as "authProvider",
               firebase_uid as "firebaseUid", profile_photo as "profilePhoto", profile_image as "profileImage",
               gender, is_verified as "isVerified", is_active as "isActive", wallet_balance as "walletBalance",
               streak_count as "streakCount", last_login as "lastLogin", created_at as "createdAt"
        FROM users WHERE firebase_uid = $1 LIMIT 1
      `, [firebaseUid]);
      return rows[0] || null;
    }
    const user = (DB_STATE as any).users?.find((u: any) => u.firebaseUid === firebaseUid);
    return user || null;
  }

  /**
   * Create User Record
   */
  static async createUser(data: CreateUserData): Promise<any> {
    const role = data.role || "USER";
    const authProvider = data.authProvider || (data.firebaseUid ? "GOOGLE" : data.phone && !data.email ? "OTP" : "LOCAL");

    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        INSERT INTO users (email, phone, phone_number, password_hash, first_name, last_name, role, auth_provider, firebase_uid, profile_photo, profile_image, gender, is_verified, is_active, wallet_balance, streak_count)
        VALUES ($1, $2, $2, $3, $4, $5, $6, $7, $8, $9, $9, $10, true, true, 1200.00, 1)
        RETURNING id, email, phone, phone_number as "phoneNumber", password_hash as "passwordHash",
                  first_name as "firstName", last_name as "lastName", role, auth_provider as "authProvider",
                  firebase_uid as "firebaseUid", profile_photo as "profilePhoto", profile_image as "profileImage",
                  gender, is_verified as "isVerified", is_active as "isActive", wallet_balance as "walletBalance",
                  streak_count as "streakCount", last_login as "lastLogin", created_at as "createdAt"
      `, [
        data.email || null,
        data.phone || null,
        data.passwordHash || null,
        data.firstName,
        data.lastName || "",
        role,
        authProvider,
        data.firebaseUid || null,
        data.profilePhoto || null,
        data.gender || "unspecified",
      ]);
      return rows[0];
    }

    if (!(DB_STATE as any).users) {
      (DB_STATE as any).users = [];
    }

    const newUser = {
      id: "u_" + Math.random().toString(36).substring(2, 9),
      email: data.email || null,
      phone: data.phone || null,
      phoneNumber: data.phone || null,
      passwordHash: data.passwordHash || null,
      firstName: data.firstName,
      lastName: data.lastName || "",
      role,
      authProvider,
      firebaseUid: data.firebaseUid || null,
      profilePhoto: data.profilePhoto || null,
      profileImage: data.profilePhoto || null,
      gender: data.gender || "unspecified",
      isVerified: true,
      isActive: true,
      walletBalance: 1200.00,
      streakCount: 1,
      lastLogin: new Date().toISOString(),
      createdAt: new Date().toISOString(),
    };

    (DB_STATE as any).users.push(newUser);
    return newUser;
  }

  /**
   * Create Active User Session with Refresh Token
   */
  static async createSession(userId: string, data: CreateSessionData): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        INSERT INTO user_sessions (user_id, device_id, device_name, refresh_token, ip_address, is_remember_me, expires_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id, user_id as "userId", device_id as "deviceId", device_name as "deviceName",
                  refresh_token as "refreshToken", ip_address as "ipAddress", is_remember_me as "isRememberMe",
                  expires_at as "expiresAt", login_time as "loginTime"
      `, [
        userId,
        data.deviceId || null,
        data.deviceName || null,
        data.refreshToken,
        data.ipAddress || null,
        data.isRememberMe || false,
        data.expiresAt,
      ]);
      return rows[0];
    }

    if (!(DB_STATE as any).sessions) {
      (DB_STATE as any).sessions = [];
    }

    const newSession = {
      id: "sess_" + Math.random().toString(36).substring(2, 9),
      userId,
      deviceId: data.deviceId || null,
      deviceName: data.deviceName || null,
      refreshToken: data.refreshToken,
      ipAddress: data.ipAddress || null,
      isRememberMe: data.isRememberMe || false,
      expiresAt: data.expiresAt.toISOString(),
      loginTime: new Date().toISOString(),
    };

    (DB_STATE as any).sessions.push(newSession);
    return newSession;
  }

  /**
   * Find Session by Refresh Token
   */
  static async findSessionByRefreshToken(refreshToken: string): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, user_id as "userId", device_id as "deviceId", device_name as "deviceName",
               refresh_token as "refreshToken", ip_address as "ipAddress", is_remember_me as "isRememberMe",
               expires_at as "expiresAt", login_time as "loginTime"
        FROM user_sessions WHERE refresh_token = $1 AND logout_time IS NULL LIMIT 1
      `, [refreshToken]);
      return rows[0] || null;
    }

    const sessions = (DB_STATE as any).sessions || [];
    return sessions.find((s: any) => s.refreshToken === refreshToken && !s.logoutTime) || null;
  }

  /**
   * Invalidate Session (Logout)
   */
  static async invalidateSession(refreshToken: string): Promise<void> {
    if (usePostgreSQL) {
      await dbQuery("UPDATE user_sessions SET logout_time = CURRENT_TIMESTAMP WHERE refresh_token = $1", [refreshToken]);
      return;
    }

    const sessions = (DB_STATE as any).sessions || [];
    const item = sessions.find((s: any) => s.refreshToken === refreshToken);
    if (item) {
      item.logoutTime = new Date().toISOString();
    }
  }

  /**
   * Save OTP Request
   */
  static async createOTP(phone: string, otp: string, expiresAt: Date): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        INSERT INTO otp_verifications (phone, otp, expires_at, verified)
        VALUES ($1, $2, $3, false)
        RETURNING id, phone, otp, expires_at as "expiresAt", verified, created_at as "createdAt"
      `, [phone, otp, expiresAt]);
      return rows[0];
    }

    if (!(DB_STATE as any).otps) {
      (DB_STATE as any).otps = [];
    }

    const newOtp = {
      id: "otp_" + Math.random().toString(36).substring(2, 9),
      phone,
      otp,
      expiresAt: expiresAt.toISOString(),
      verified: false,
      createdAt: new Date().toISOString(),
    };

    (DB_STATE as any).otps.push(newOtp);
    return newOtp;
  }

  /**
   * Find latest unverified OTP
   */
  static async findLatestOTP(phone: string): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, phone, otp, expires_at as "expiresAt", verified, created_at as "createdAt"
        FROM otp_verifications WHERE phone = $1 AND verified = false
        ORDER BY created_at DESC LIMIT 1
      `, [phone]);
      return rows[0] || null;
    }

    const otps = (DB_STATE as any).otps || [];
    const filtered = otps.filter((o: any) => o.phone === phone && !o.verified);
    if (filtered.length === 0) return null;
    return filtered[filtered.length - 1];
  }

  /**
   * Mark OTP Verified
   */
  static async markOTPVerified(id: string): Promise<void> {
    if (usePostgreSQL) {
      await dbQuery("UPDATE otp_verifications SET verified = true WHERE id = $1", [id]);
      return;
    }

    const otps = (DB_STATE as any).otps || [];
    const item = otps.find((o: any) => o.id === id);
    if (item) item.verified = true;
  }

  /**
   * Log Audit Action
   */
  static async createAuditLog(userId: string | null, action: string, details: string, ipAddress?: string): Promise<void> {
    logger.info(`[AUDIT LOG] User: ${userId || "Anonymous"} | Action: ${action} | Details: ${details}`);
    if (usePostgreSQL) {
      try {
        await dbQuery(`
  INSERT INTO audit_logs 
  (
    table_name,
    record_id,
    user_id,
    action,
    details,
    ip_address
  )
  VALUES
  (
    $1,$2,$3,$4,$5,$6
  )
`,
[
  "users",
  userId,
  userId,
  action,
  details,
  ipAddress || null
]);
      } catch (err) {
        logger.warn("Failed to persist audit log into database:", err);
      }
    }
  }

  /**
   * Update User Password
   */
  static async updatePassword(userId: string, passwordHash: string): Promise<void> {
    if (usePostgreSQL) {
      await dbQuery("UPDATE users SET password_hash = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2", [passwordHash, userId]);
      return;
    }

    const memoryUser = (DB_STATE as any).users?.find((u: any) => u.id === userId);
    if (memoryUser) {
      memoryUser.passwordHash = passwordHash;
    }
  }

  /**
   * Delete User
   */
  static async deleteUser(userId: string): Promise<void> {
    if (usePostgreSQL) {
      await dbQuery("DELETE FROM users WHERE id = $1", [userId]);
      return;
    }

    const users = (DB_STATE as any).users || [];
    (DB_STATE as any).users = users.filter((u: any) => u.id !== userId);
  }
}
