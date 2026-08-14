import { Request, Response, NextFunction } from "express";
import { AuthService } from "../services/auth.service";
import { AuthRepository } from "../repositories/auth.repository";
import { hashPassword } from "../utils/auth";
import { logger } from "../utils/logger";
import { AuthenticatedRequest } from "../middleware/auth.middleware";

/**
 * Register User Controller
 */
export async function register(req: Request, res: Response, next: NextFunction) {
  const { email, password, firstName, lastName, phone, role, acceptTerms, rememberMe } = req.body;
  try {
    let passwordHash: string | undefined;
    if (password) {
      passwordHash = await hashPassword(password);
    }

    const ipAddress = req.ip || "127.0.0.1";
    const deviceInfo = req.get("User-Agent") || "Unknown Device";

    const result = await AuthService.registerWithEmailPassword(
      email,
      passwordHash,
      firstName,
      lastName,
      phone,
      role || "USER",
      rememberMe || false,
      ipAddress,
      deviceInfo
    );

    res.status(201).json({
      success: true,
      message: "User account created successfully",
      ...result,
    });
  } catch (error: any) {
    logger.error(`[AUTH CONTROLLER] Registration error: ${error.message}`);
    next(error);
  }
}

/**
 * Login Controller (Email/Phone & Password or Firebase payload)
 */
export async function login(req: Request, res: Response, next: NextFunction) {
  const { email, phone, password, firebaseUid, firstName, lastName, phoneNumber, profilePhoto, rememberMe, deviceInfo, ipAddress } = req.body;
  try {
    const resolvedIp = ipAddress || req.ip || "127.0.0.1";
    const resolvedDevice = deviceInfo || req.get("User-Agent") || "Unknown Device";

    // Support backward compatibility with Firebase payload
    if (firebaseUid) {
      const result = await AuthService.handleFirebaseLogin(
        firebaseUid,
        email || "arav@example.com",
        firstName,
        lastName,
        phoneNumber,
        profilePhoto,
        resolvedIp,
        resolvedDevice
      );
      res.json({ success: true, ...result });
      return;
    }

    if (!email && !phone) {
      res.status(400).json({ error: "Email or phone is required for login" });
      return;
    }

    const result = await AuthService.loginWithEmailPassword(
      email,
      phone,
      password,
      rememberMe || false,
      resolvedIp,
      resolvedDevice
    );

    res.json({
      success: true,
      message: "Login successful",
      ...result,
    });
  } catch (error: any) {
    logger.warn(`[AUTH CONTROLLER] Login failed: ${error.message}`);
    res.status(401).json({ error: error.message });
  }
}

/**
 * Google Single Sign-On Controller
 */
export async function loginWithGoogle(req: Request, res: Response, next: NextFunction) {
  const { firebaseUid, email, firstName, lastName, phoneNumber, profilePhoto, rememberMe, device_name } = req.body;
  try {
    const ipAddress = req.ip || "127.0.0.1";
    const deviceInfo = device_name || req.get("User-Agent") || "Unknown Device";

    const result = await AuthService.loginWithGoogle(
      firebaseUid,
      email,
      firstName,
      lastName,
      phoneNumber,
      profilePhoto,
      rememberMe || false,
      ipAddress,
      deviceInfo
    );

    res.json({
      success: true,
      message: "Google OAuth sign in successful",
      ...result,
    });
  } catch (error: any) {
    logger.error(`[AUTH CONTROLLER] Google login error: ${error.message}`);
    next(error);
  }
}

/**
 * Send Phone OTP Controller
 */
export async function sendOtp(req: Request, res: Response, next: NextFunction) {
  const { phone } = req.body;
  try {
    const result = await AuthService.sendOTP(phone);
    res.json(result);
  } catch (error: any) {
    logger.error(`[AUTH CONTROLLER] Send OTP error: ${error.message}`);
    next(error);
  }
}

/**
 * Verify Phone OTP Controller
 */
export async function verifyOtp(req: Request, res: Response, next: NextFunction) {
  const { phone, otp, rememberMe, device_name } = req.body;
  try {
    const ipAddress = req.ip || "127.0.0.1";
    const deviceInfo = device_name || req.get("User-Agent") || "Unknown Device";

    const result = await AuthService.verifyOTP(phone, otp, rememberMe || false, ipAddress, deviceInfo);
    res.json({
      success: true,
      message: "Phone OTP verification successful",
      ...result,
    });
  } catch (error: any) {
    logger.warn(`[AUTH CONTROLLER] Verify OTP failed: ${error.message}`);
    res.status(400).json({ error: error.message });
  }
}

/**
 * Forgot Password Controller
 */
export async function forgotPassword(req: Request, res: Response, next: NextFunction) {
  const { email } = req.body;
  try {
    const result = await AuthService.forgotPassword(email);
    res.json(result);
  } catch (error: any) {
    next(error);
  }
}

/**
 * Reset Password Controller
 */
export async function resetPassword(req: Request, res: Response, next: NextFunction) {
  const { email, otp, newPassword } = req.body;
  try {
    const passwordHash = await hashPassword(newPassword);
    const result = await AuthService.resetPassword(email, otp, passwordHash);
    res.json(result);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * Refresh Token Rotation Controller
 */
export async function refresh(req: Request, res: Response, next: NextFunction) {
  const { refreshToken } = req.body;
  try {
    if (!refreshToken) {
      res.status(400).json({ error: "Refresh token is required" });
      return;
    }

    const ipAddress = req.ip || "127.0.0.1";
    const deviceInfo = req.get("User-Agent") || "Unknown Device";

    const result = await AuthService.refresh(refreshToken, ipAddress, deviceInfo);
    res.json({
      success: true,
      message: "Token pair rotated successfully",
      ...result,
    });
  } catch (error: any) {
    res.status(401).json({ error: error.message });
  }
}

/**
 * Logout Controller
 */
export async function logout(req: Request, res: Response, next: NextFunction) {
  const { refreshToken } = req.body;
  const authHeader = req.headers.authorization;
  const accessToken = authHeader && authHeader.startsWith("Bearer ") ? authHeader.split("Bearer ")[1] : undefined;

  try {
    await AuthService.logout(refreshToken, accessToken, (req as AuthenticatedRequest).user?.id);
    res.json({
      success: true,
      message: "Logged out successfully and session revoked",
    });
  } catch (error: any) {
    next(error);
  }
}

/**
 * Get Profile Controller
 */
export async function getProfile(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const userId = req.user?.id;
    if (!userId) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    const profile = await AuthRepository.findById(userId);
    if (!profile) {
      res.status(404).json({ error: "User profile not found" });
      return;
    }

    if (profile.passwordHash) {
      delete profile.passwordHash;
    }

    res.json({
      success: true,
      user: profile,
    });
  } catch (error: any) {
    next(error);
  }
}

/**
 * Update Profile Controller
 */
export async function updateProfile(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  const { firstName, lastName, phoneNumber, profilePhoto, gender } = req.body;
  try {
    const userId = req.user?.id;
    if (!userId) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    const user = await AuthRepository.findById(userId);
    if (!user) {
      res.status(404).json({ error: "User profile not found" });
      return;
    }

    // Direct database update
    const { dbQuery, usePostgreSQL } = await import("../config/database");
    if (usePostgreSQL) {
      await dbQuery(`
        UPDATE users SET
          first_name = COALESCE($1, first_name),
          last_name = COALESCE($2, last_name),
          phone = COALESCE($3, phone),
          phone_number = COALESCE($3, phone_number),
          profile_photo = COALESCE($4, profile_photo),
          profile_image = COALESCE($4, profile_image),
          gender = COALESCE($5, gender),
          updated_at = CURRENT_TIMESTAMP
        WHERE id = $6
      `, [firstName, lastName, phoneNumber, profilePhoto, gender, userId]);
    } else {
      if (firstName) user.firstName = firstName;
      if (lastName) user.lastName = lastName;
      if (phoneNumber) {
        user.phone = phoneNumber;
        user.phoneNumber = phoneNumber;
      }
      if (profilePhoto) {
        user.profilePhoto = profilePhoto;
        user.profileImage = profilePhoto;
      }
      if (gender) user.gender = gender;
    }

    const updated = await AuthRepository.findById(userId);
    if (updated && updated.passwordHash) {
      delete updated.passwordHash;
    }

    res.json({
      success: true,
      message: "Profile updated successfully",
      profile: updated,
      user: updated,
    });
  } catch (error: any) {
    next(error);
  }
}

/**
 * Delete Account Controller
 */
export async function deleteAccount(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const userId = req.user?.id;
    if (!userId) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    await AuthService.deleteAccount(userId);
    res.json({
      success: true,
      message: "Your FlashCart account has been deleted.",
    });
  } catch (error: any) {
    next(error);
  }
}
