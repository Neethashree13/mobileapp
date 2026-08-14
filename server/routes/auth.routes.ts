import { Router } from "express";
import rateLimit from "express-rate-limit";
import * as authController from "../controllers/auth.controller";
import { authenticateJWT } from "../middleware/auth.middleware";
import { requireRole } from "../middleware/rbac.middleware";
import { validateBody } from "../validators/request.validators";
import {
  registerSchema,
  loginSchema,
  googleLoginSchema,
  sendOtpSchema,
  verifyOtpSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  refreshTokenSchema,
  logoutSchema,
} from "../validators/auth.validator";
import { profileUpdateSchema } from "../validators/request.validators";

const router = Router();

// Strict Rate Limiter for Authentication Endpoints (Brute-force protection)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 30, // Limit each IP to 30 requests per window for sensitive auth endpoints
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many authentication attempts. Please try again in 15 minutes." },
});

// 1. Credentials Signup / Registration
router.post(
  "/register",
  authLimiter,
  validateBody(registerSchema),
  authController.register
);

// 2. Email/Phone Password Login
router.post(
  "/login",
  authLimiter,
  validateBody(loginSchema),
  authController.login
);

// 3. Google Sign-In Single Sign-On
router.post(
  "/google",
  authLimiter,
  validateBody(googleLoginSchema),
  authController.loginWithGoogle
);

// 4. Send SMS OTP
router.post(
  "/send-otp",
  authLimiter,
  validateBody(sendOtpSchema),
  authController.sendOtp
);

// 5. Verify SMS OTP and Login
router.post(
  "/verify-otp",
  authLimiter,
  validateBody(verifyOtpSchema),
  authController.verifyOtp
);

// 6. Initiate Password Reset (Forgot Password)
router.post(
  "/forgot-password",
  authLimiter,
  validateBody(forgotPasswordSchema),
  authController.forgotPassword
);

// 7. Complete Password Reset
router.post(
  "/reset-password",
  authLimiter,
  validateBody(resetPasswordSchema),
  authController.resetPassword
);

// 8. Refresh Token Rotation
router.post(
  "/refresh",
  validateBody(refreshTokenSchema),
  authController.refresh
);

// 9. Logout and Revoke Active Session
router.post(
  "/logout",
  validateBody(logoutSchema),
  authController.logout
);

// 10. Fetch Profile
router.get(
  "/profile",
  authenticateJWT,
  authController.getProfile
);

// 11. Update Profile
router.put(
  "/profile",
  authenticateJWT,
  validateBody(profileUpdateSchema),
  authController.updateProfile
);

// Compatibility Alias for Mobile Profile Update
router.post(
  "/profile/update",
  authenticateJWT,
  validateBody(profileUpdateSchema),
  authController.updateProfile
);

// 12. Delete Account
router.delete(
  "/delete-account",
  authenticateJWT,
  authController.deleteAccount
);

// 13. Admin-Only Identity System Status
router.get(
  "/admin/audit-logs",
  authenticateJWT,
  requireRole("ADMIN", "SUPER_ADMIN"),
  async (req, res, next) => {
    try {
      const { dbQuery, usePostgreSQL } = await import("../config/database");
      if (usePostgreSQL) {
        const { rows } = await dbQuery("SELECT * FROM audit_logs ORDER BY created_at DESC LIMIT 50");
        res.json({ success: true, auditLogs: rows });
      } else {
        res.json({ success: true, auditLogs: [] });
      }
    } catch (e) {
      next(e);
    }
  }
);

export default router;
