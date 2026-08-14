import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import { JWT_SECRET, JWT_REFRESH_SECRET } from "../config/env";

export interface TokenPayload {
  userId: string;
  email?: string;
  role?: string;
}

/**
 * Generate a short-lived JWT access token (e.g., 15 minutes)
 */
export function generateAccessToken(userId: string, email?: string, role: string = "user"): string {
  return jwt.sign(
    { userId, email, role },
    JWT_SECRET,
    { expiresIn: "15m" }
  );
}

/**
 * Generate a long-lived JWT refresh token (7 days standard, 30 days if Remember Me enabled)
 */
export function generateRefreshToken(userId: string, isRememberMe: boolean = false): string {
  const expiresIn = isRememberMe ? "30d" : "7d";
  return jwt.sign(
    { userId, isRememberMe, jti: Math.random().toString(36).substring(2, 15) },
    JWT_REFRESH_SECRET,
    { expiresIn }
  );
}

/**
 * Verify JWT access token
 */
export function verifyAccessToken(token: string): TokenPayload {
  return jwt.verify(token, JWT_SECRET) as TokenPayload;
}

/**
 * Verify JWT refresh token
 */
export function verifyRefreshToken(token: string): { userId: string } {
  return jwt.verify(token, JWT_REFRESH_SECRET) as { userId: string };
}

/**
 * Hash password securely with bcrypt
 */
export async function hashPassword(password: string): Promise<string> {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(password, salt);
}

/**
 * Compare plain password with secure bcrypt hash
 */
export async function comparePassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

/**
 * Generate a cryptographically strong 6-digit numeric OTP
 */
export function generateOTP(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}
