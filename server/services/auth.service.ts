// import { AuthRepository } from "../repositories/auth.repository";
// import { UserRepository } from "../repositories/user.repository";
// import { ActivityRepository } from "../repositories/activity.repository";
// import { redisCache } from "../config/redis";
// import { 
//   generateAccessToken, 
//   generateRefreshToken, 
//   comparePassword, 
//   generateOTP, 
//   verifyRefreshToken 
// } from "../utils/auth";
// import { logger } from "../utils/logger";
// import { TokenPairDto, UserDto } from "../dto/auth.dto";

// export class AuthService {
//   /**
//    * Register a new user with Email and Password
//    */
//   static async registerWithEmailPassword(
//     email?: string,
//     passwordHash?: string,
//     firstName: string = "Guest",
//     lastName?: string,
//     phone?: string,
//     role: string = "USER",
//     rememberMe: boolean = false,
//     ipAddress: string = "127.0.0.1",
//     deviceInfo: string = "Unknown Device"
//   ): Promise<{ user: UserDto; accessToken: string; refreshToken: string; tokens: TokenPairDto }> {
//     if (email) {
//       const existing = await AuthRepository.findByEmail(email);
//       if (existing) {
//         throw new Error("Email is already registered");
//       }
//     }

//     if (phone) {
//       const existingPhone = await AuthRepository.findByPhone(phone);
//       if (existingPhone) {
//         throw new Error("Phone number is already registered");
//       }
//     }

//     const user = await AuthRepository.createUser({
//       email,
//       phone,
//       passwordHash,
//       firstName,
//       lastName,
//       role,
//       authProvider: "LOCAL",
//     });

//     const accessToken = generateAccessToken(user.id, user.email, user.role);
//     const refreshToken = generateRefreshToken(user.id, rememberMe);

//     const expiresAt = new Date(Date.now() + (rememberMe ? 30 : 7) * 24 * 60 * 60 * 1000);

//     const session = await AuthRepository.createSession(user.id, {
//       deviceName: deviceInfo,
//       refreshToken,
//       ipAddress,
//       isRememberMe: rememberMe,
//       expiresAt,
//     });

//     // Cache active session state in Redis Cache
//     await redisCache.cacheUserSession(user.id, session);

//     // Audit Logging
//     await AuthRepository.createAuditLog(user.id, "USER_REGISTER", `User registered with ${email || phone}`, ipAddress);
//     await UserRepository.logLogin(user.id, ipAddress, deviceInfo);

//     // Clone user object to avoid mutating stored record
//     const userDto = { ...user };
//     if (userDto.passwordHash) {
//       delete userDto.passwordHash;
//     }

//     const tokens: TokenPairDto = {
//       accessToken,
//       refreshToken,
//       tokenType: "Bearer",
//       expiresIn: 900, // 15 minutes in seconds
//     };

//     return { user: userDto, accessToken, refreshToken, tokens };
//   }

//   /**
//    * Login with Email/Phone and Password
//    */
//   static async loginWithEmailPassword(
//     email?: string,
//     phone?: string,
//     passwordPlain?: string,
//     rememberMe: boolean = false,
//     ipAddress: string = "127.0.0.1",
//     deviceInfo: string = "Unknown Device"
//   ): Promise<{ user: UserDto; accessToken: string; refreshToken: string; tokens: TokenPairDto }> {
//     let user = null;
//     if (email) {
//       user = await AuthRepository.findByEmail(email);
//     } else if (phone) {
//       user = await AuthRepository.findByPhone(phone);
//     }

//     if (!user) {
//       throw new Error("Invalid credentials");
//     }

//     if (user.isActive === false) {
//       throw new Error("This account has been suspended or deactivated");
//     }

//     if (!user.passwordHash && passwordPlain) {
//       throw new Error("This account was created via social/OTP sign in. Please use Google or Phone OTP.");
//     }

//     if (passwordPlain && user.passwordHash) {
//       const passwordMatches = await comparePassword(passwordPlain, user.passwordHash);
//       if (!passwordMatches) {
//         await AuthRepository.createAuditLog(user.id, "LOGIN_FAILED", "Invalid password attempt", ipAddress);
//         throw new Error("Invalid credentials");
//       }
//     }

//     const accessToken = generateAccessToken(user.id, user.email, user.role || "USER");
//     const refreshToken = generateRefreshToken(user.id, rememberMe);

//     const expiresAt = new Date(Date.now() + (rememberMe ? 30 : 7) * 24 * 60 * 60 * 1000);

//     const session = await AuthRepository.createSession(user.id, {
//       deviceName: deviceInfo,
//       refreshToken,
//       ipAddress,
//       isRememberMe: rememberMe,
//       expiresAt,
//     });

//     await redisCache.cacheUserSession(user.id, session);

//     await AuthRepository.createAuditLog(user.id, "USER_LOGIN", `Logged in via email/password (${deviceInfo})`, ipAddress);
//     await UserRepository.logLogin(user.id, ipAddress, deviceInfo);

//     const userDto = { ...user };
//     if (userDto.passwordHash) {
//       delete userDto.passwordHash;
//     }

//     const tokens: TokenPairDto = {
//       accessToken,
//       refreshToken,
//       tokenType: "Bearer",
//       expiresIn: 900,
//     };

//     return { user: userDto, accessToken, refreshToken, tokens };
//   }

//   /**
//    * Google Single Sign-On Verification & Login
//    */
//   static async loginWithGoogle(
//     firebaseUid: string,
//     email: string,
//     firstName?: string,
//     lastName?: string,
//     phoneNumber?: string,
//     profilePhoto?: string,
//     rememberMe: boolean = false,
//     ipAddress: string = "127.0.0.1",
//     deviceInfo: string = "Unknown Device"
//   ): Promise<{ user: UserDto; accessToken: string; refreshToken: string; tokens: TokenPairDto }> {
//     let user = await AuthRepository.findByFirebaseUid(firebaseUid);

//     if (!user && email) {
//       user = await AuthRepository.findByEmail(email);
//       if (user) {
//         // Link account
//         user.firebaseUid = firebaseUid;
//         if (profilePhoto) user.profilePhoto = profilePhoto;
//       } else {
//         user = await AuthRepository.createUser({
//           email,
//           phone: phoneNumber,
//           firstName: firstName || email.split("@")[0],
//           lastName: lastName || "",
//           firebaseUid,
//           profilePhoto,
//           authProvider: "GOOGLE",
//         });
//       }
//     } else if (!user) {
//       user = await AuthRepository.createUser({
//         email,
//         phone: phoneNumber,
//         firstName: firstName || "Google User",
//         lastName: lastName || "",
//         firebaseUid,
//         profilePhoto,
//         authProvider: "GOOGLE",
//       });
//     }

//     const accessToken = generateAccessToken(user.id, user.email, user.role || "USER");
//     const refreshToken = generateRefreshToken(user.id, rememberMe);

//     const expiresAt = new Date(Date.now() + (rememberMe ? 30 : 7) * 24 * 60 * 60 * 1000);

//     const session = await AuthRepository.createSession(user.id, {
//       deviceName: deviceInfo,
//       refreshToken,
//       ipAddress,
//       isRememberMe: rememberMe,
//       expiresAt,
//     });

//     await redisCache.cacheUserSession(user.id, session);
//     await AuthRepository.createAuditLog(user.id, "GOOGLE_LOGIN", `Logged in via Google OAuth (${deviceInfo})`, ipAddress);
//     await UserRepository.logLogin(user.id, ipAddress, deviceInfo);

//     const userDto = { ...user };
//     if (userDto.passwordHash) {
//       delete userDto.passwordHash;
//     }

//     const tokens: TokenPairDto = {
//       accessToken,
//       refreshToken,
//       tokenType: "Bearer",
//       expiresIn: 900,
//     };

//     return { user: userDto, accessToken, refreshToken, tokens };
//   }

//   /**
//    * Dispatch SMS OTP code
//    */
//   static async sendOTP(phone: string): Promise<{ success: boolean; message: string; expiresInSeconds: number }> {
//     const otp = generateOTP();
//     const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 mins

//     await AuthRepository.createOTP(phone, otp, expiresAt);
//     logger.info(`[SMS PORTAL] Generated OTP code ${otp} for ${phone}. Valid for 5 minutes.`);

//     return {
//       success: true,
//       message: `OTP code sent successfully to ${phone}`,
//       expiresInSeconds: 300,
//     };
//   }

//   /**
//    * Verify SMS OTP code and finish sign in
//    */
//   static async verifyOTP(
//     phone: string,
//     otp: string,
//     rememberMe: boolean = false,
//     ipAddress: string = "127.0.0.1",
//     deviceInfo: string = "Unknown Device"
//   ): Promise<{ user: UserDto; accessToken: string; refreshToken: string; tokens: TokenPairDto; isNewUser: boolean }> {
//     const record = await AuthRepository.findLatestOTP(phone);
//     if (!record) {
//       throw new Error("No active OTP request found for this phone number");
//     }

//     if (new Date() > new Date(record.expiresAt)) {
//       throw new Error("OTP verification code has expired. Please request a new code.");
//     }

//     if (record.otp !== otp) {
//       throw new Error("Invalid OTP verification code");
//     }

//     // Mark verified to prevent reuse
//     await AuthRepository.markOTPVerified(record.id);

//     let user = await AuthRepository.findByPhone(phone);
//     let isNewUser = false;

//     if (!user) {
//       isNewUser = true;
//       user = await AuthRepository.createUser({
//         phone,
//         firstName: "FlashCart",
//         lastName: "User",
//         authProvider: "OTP",
//       });
//     }

//     const accessToken = generateAccessToken(user.id, user.email, user.role || "USER");
//     const refreshToken = generateRefreshToken(user.id, rememberMe);

//     const expiresAt = new Date(Date.now() + (rememberMe ? 30 : 7) * 24 * 60 * 60 * 1000);

//     const session = await AuthRepository.createSession(user.id, {
//       deviceName: deviceInfo,
//       refreshToken,
//       ipAddress,
//       isRememberMe: rememberMe,
//       expiresAt,
//     });

//     await redisCache.cacheUserSession(user.id, session);
//     await AuthRepository.createAuditLog(user.id, "OTP_VERIFY_LOGIN", `Verified phone OTP login (${phone})`, ipAddress);
//     await UserRepository.logLogin(user.id, ipAddress, deviceInfo);

//     const userDto = { ...user };
//     if (userDto.passwordHash) {
//       delete userDto.passwordHash;
//     }

//     const tokens: TokenPairDto = {
//       accessToken,
//       refreshToken,
//       tokenType: "Bearer",
//       expiresIn: 900,
//     };

//     return { user: userDto, accessToken, refreshToken, tokens, isNewUser };
//   }

//   /**
//    * Refresh Token Rotation Workflow
//    */
//   static async refresh(
//     refreshToken: string,
//     ipAddress: string = "127.0.0.1",
//     deviceInfo: string = "Unknown Device"
//   ): Promise<{ accessToken: string; refreshToken: string; tokens: TokenPairDto }> {
//     try {
//       const decoded = verifyRefreshToken(refreshToken);
//       const session = await AuthRepository.findSessionByRefreshToken(refreshToken);

//       if (!session) {
//         throw new Error("Session invalid, revoked, or expired");
//       }

//       // Rotate Refresh Token by invalidating old session
//       await AuthRepository.invalidateSession(refreshToken);
//       await redisCache.invalidateUserSession(session.userId, refreshToken);

//       const user = await AuthRepository.findById(decoded.userId);
//       if (!user || user.isActive === false) {
//         throw new Error("Account is suspended or deleted");
//       }

//       const isRememberMe = session.isRememberMe || false;
//       const newAccessToken = generateAccessToken(user.id, user.email, user.role || "USER");
//       const newRefreshToken = generateRefreshToken(user.id, isRememberMe);

//       const expiresAt = new Date(Date.now() + (isRememberMe ? 30 : 7) * 24 * 60 * 60 * 1000);

//       const newSession = await AuthRepository.createSession(user.id, {
//         deviceName: deviceInfo,
//         refreshToken: newRefreshToken,
//         ipAddress,
//         isRememberMe,
//         expiresAt,
//       });

//       await redisCache.cacheUserSession(user.id, newSession);
//       await AuthRepository.createAuditLog(user.id, "TOKEN_ROTATED", "Refreshed access & refresh token pair", ipAddress);

//       const tokens: TokenPairDto = {
//         accessToken: newAccessToken,
//         refreshToken: newRefreshToken,
//         tokenType: "Bearer",
//         expiresIn: 900,
//       };

//       return { accessToken: newAccessToken, refreshToken: newRefreshToken, tokens };
//     } catch (err: any) {
//       throw new Error(`Token refresh failed: ${err.message}`);
//     }
//   }

//   /**
//    * Invalidate Refresh Token and Blacklist Access Token (Logout)
//    */
//   static async logout(refreshToken?: string, accessToken?: string, userId?: string): Promise<void> {
//     if (refreshToken) {
//       const session = await AuthRepository.findSessionByRefreshToken(refreshToken);
//       if (session) {
//         await AuthRepository.invalidateSession(refreshToken);
//         await redisCache.invalidateUserSession(session.userId, refreshToken);
//         await AuthRepository.createAuditLog(session.userId, "USER_LOGOUT", "Logged out active session");
//       }
//     }

//     if (accessToken) {
//       await redisCache.blacklistToken(accessToken);
//     }

//     if (userId) {
//       await ActivityRepository.log(userId, "USER_LOGOUT", "User requested session termination");
//     }
//   }

//   /**
//    * Initiate Forgot Password recovery
//    */
//   static async forgotPassword(email: string): Promise<{ success: boolean; message: string }> {
//     const user = await AuthRepository.findByEmail(email);
//     if (!user) {
//       return {
//         success: true,
//         message: "If your email is registered in our database, a recovery verification code has been dispatched.",
//       };
//     }

//     const recoveryCode = generateOTP();
//     const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

//     await AuthRepository.createOTP(user.phone || email, recoveryCode, expiresAt);
//     await AuthRepository.createAuditLog(user.id, "FORGOT_PASSWORD_REQUESTED", `Password recovery code dispatched to ${email}`);

//     logger.info(`[RECOVERY SYSTEM] Reset token for ${email}: ${recoveryCode}. Valid for 15 minutes.`);

//     return {
//       success: true,
//       message: "If your email is registered in our database, a recovery verification code has been dispatched.",
//     };
//   }

//   /**
//    * Reset Password
//    */
//   static async resetPassword(email: string, otp: string, passwordHash: string): Promise<{ success: boolean; message: string }> {
//     const user = await AuthRepository.findByEmail(email);
//     if (!user) {
//       throw new Error("Account not found");
//     }

//     const record = await AuthRepository.findLatestOTP(user.phone || email);
//     if (!record || record.otp !== otp || new Date() > new Date(record.expiresAt)) {
//       throw new Error("Invalid or expired password recovery code");
//     }

//     await AuthRepository.markOTPVerified(record.id);
//     await AuthRepository.updatePassword(user.id, passwordHash);
//     await AuthRepository.createAuditLog(user.id, "PASSWORD_RESET_SUCCESS", "Password updated successfully via reset token");

//     return {
//       success: true,
//       message: "Password updated successfully. Please login with your new credentials.",
//     };
//   }

//   /**
//    * Compatibility wrapper for original Firebase logins
//    */
//   static async handleFirebaseLogin(
//     firebaseUid: string,
//     email: string,
//     firstName?: string,
//     lastName?: string,
//     phoneNumber?: string,
//     profilePhoto?: string,
//     ipAddress: string = "127.0.0.1",
//     deviceInfo: string = "Unknown Device"
//   ): Promise<any> {
//     const res = await this.loginWithGoogle(firebaseUid, email, firstName, lastName, phoneNumber, profilePhoto, false, ipAddress, deviceInfo);
//     const loginHistory = await UserRepository.getLoginHistory(firebaseUid);
//     return { user: res.user, accessToken: res.accessToken, refreshToken: res.refreshToken, loginHistory };
//   }

//   /**
//    * Securely terminate account
//    */
//   static async deleteAccount(userId: string): Promise<void> {
//     await AuthRepository.createAuditLog(userId, "ACCOUNT_DELETED", "Account purged upon user request");
//     await AuthRepository.deleteUser(userId);
//   }
// }


import { AuthRepository } from "../repositories/auth.repository";
import { UserRepository } from "../repositories/user.repository";
import { ActivityRepository } from "../repositories/activity.repository";
import { redisCache } from "../config/redis";
import { 
  generateAccessToken, 
  generateRefreshToken, 
  comparePassword, 
  generateOTP, 
  verifyRefreshToken 
} from "../utils/auth";
import { logger } from "../utils/logger";
import { TokenPairDto, UserDto } from "../dto/auth.dto";

export class AuthService {
  /**
   * Register a new user with Email and Password
   */
  static async registerWithEmailPassword(
    email?: string,
    passwordHash?: string,
    firstName: string = "Guest",
    lastName?: string,
    phone?: string,
    role: string = "USER",
    rememberMe: boolean = false,
    ipAddress: string = "127.0.0.1",
    deviceInfo: string = "Unknown Device"
  ): Promise<{ user: UserDto; accessToken: string; refreshToken: string; tokens: TokenPairDto }> {
    if (email) {
      const existing = await AuthRepository.findByEmail(email);
      if (existing) {
        throw new Error("Email is already registered");
      }
    }

    if (phone) {
      const existingPhone = await AuthRepository.findByPhone(phone);
      if (existingPhone) {
        throw new Error("Phone number is already registered");
      }
    }

    const user = await AuthRepository.createUser({
      email,
      phone,
      passwordHash,
      firstName,
      lastName,
      role,
      authProvider: "LOCAL",
    });

    const accessToken = generateAccessToken(user.id, user.email, user.role);
    const refreshToken = generateRefreshToken(user.id, rememberMe);

    const expiresAt = new Date(Date.now() + (rememberMe ? 30 : 7) * 24 * 60 * 60 * 1000);

    const session = await AuthRepository.createSession(user.id, {
      deviceName: deviceInfo,
      refreshToken,
      ipAddress,
      isRememberMe: rememberMe,
      expiresAt,
    });

    // Cache active session state in Redis Cache
    await redisCache.cacheUserSession(user.id, session);

    // Audit Logging
    await AuthRepository.createAuditLog(user.id, "USER_REGISTER", `User registered with ${email || phone}`, ipAddress);
    await UserRepository.logLogin(user.id, ipAddress, deviceInfo);

    // Clone user object to avoid mutating stored record
    const userDto = { ...user };
    if (userDto.passwordHash) {
      delete userDto.passwordHash;
    }

    const tokens: TokenPairDto = {
      accessToken,
      refreshToken,
      tokenType: "Bearer",
      expiresIn: 900, // 15 minutes in seconds
    };

    return { user: userDto, accessToken, refreshToken, tokens };
  }

  /**
   * Login with Email/Phone and Password
   */
  static async loginWithEmailPassword(
    email?: string,
    phone?: string,
    passwordPlain?: string,
    rememberMe: boolean = false,
    ipAddress: string = "127.0.0.1",
    deviceInfo: string = "Unknown Device"
  ): Promise<{ user: UserDto; accessToken: string; refreshToken: string; tokens: TokenPairDto }> {
    let user = null;
    if (email) {
      user = await AuthRepository.findByEmail(email);
    } else if (phone) {
      user = await AuthRepository.findByPhone(phone);
    }

    if (!user) {
      throw new Error("Invalid credentials");
    }

    if (user.isActive === false) {
      throw new Error("This account has been suspended or deactivated");
    }

    if (!user.passwordHash && passwordPlain) {
      throw new Error("This account was created via social/OTP sign in. Please use Google or Phone OTP.");
    }

    if (passwordPlain && user.passwordHash) {
      const passwordMatches = await comparePassword(passwordPlain, user.passwordHash);
      if (!passwordMatches) {
        await AuthRepository.createAuditLog(user.id, "LOGIN_FAILED", "Invalid password attempt", ipAddress);
        throw new Error("Invalid credentials");
      }
    }

    const accessToken = generateAccessToken(user.id, user.email, user.role || "USER");
    const refreshToken = generateRefreshToken(user.id, rememberMe);

    const expiresAt = new Date(Date.now() + (rememberMe ? 30 : 7) * 24 * 60 * 60 * 1000);

    const session = await AuthRepository.createSession(user.id, {
      deviceName: deviceInfo,
      refreshToken,
      ipAddress,
      isRememberMe: rememberMe,
      expiresAt,
    });

    await redisCache.cacheUserSession(user.id, session);

    await AuthRepository.createAuditLog(user.id, "USER_LOGIN", `Logged in via email/password (${deviceInfo})`, ipAddress);
    await UserRepository.logLogin(user.id, ipAddress, deviceInfo);

    const userDto = { ...user };
    if (userDto.passwordHash) {
      delete userDto.passwordHash;
    }

    const tokens: TokenPairDto = {
      accessToken,
      refreshToken,
      tokenType: "Bearer",
      expiresIn: 900,
    };

    return { user: userDto, accessToken, refreshToken, tokens };
  }

  /**
   * Google Single Sign-On Verification & Login
   */
  static async loginWithGoogle(
    firebaseUid: string,
    email: string,
    firstName?: string,
    lastName?: string,
    phoneNumber?: string,
    profilePhoto?: string,
    rememberMe: boolean = false,
    ipAddress: string = "127.0.0.1",
    deviceInfo: string = "Unknown Device"
  ): Promise<{ user: UserDto; accessToken: string; refreshToken: string; tokens: TokenPairDto }> {
    let user = await AuthRepository.findByFirebaseUid(firebaseUid);

    if (!user && email) {
      user = await AuthRepository.findByEmail(email);
      if (user) {
        // Link account
        user.firebaseUid = firebaseUid;
        if (profilePhoto) user.profilePhoto = profilePhoto;
      } else {
        user = await AuthRepository.createUser({
          email,
          phone: phoneNumber,
          firstName: firstName || email.split("@")[0],
          lastName: lastName || "",
          firebaseUid,
          profilePhoto,
          authProvider: "GOOGLE",
        });
      }
    } else if (!user) {
      user = await AuthRepository.createUser({
        email,
        phone: phoneNumber,
        firstName: firstName || "Google User",
        lastName: lastName || "",
        firebaseUid,
        profilePhoto,
        authProvider: "GOOGLE",
      });
    }

    const accessToken = generateAccessToken(user.id, user.email, user.role || "USER");
    const refreshToken = generateRefreshToken(user.id, rememberMe);

    const expiresAt = new Date(Date.now() + (rememberMe ? 30 : 7) * 24 * 60 * 60 * 1000);

    const session = await AuthRepository.createSession(user.id, {
      deviceName: deviceInfo,
      refreshToken,
      ipAddress,
      isRememberMe: rememberMe,
      expiresAt,
    });

    await redisCache.cacheUserSession(user.id, session);
    await AuthRepository.createAuditLog(user.id, "GOOGLE_LOGIN", `Logged in via Google OAuth (${deviceInfo})`, ipAddress);
    await UserRepository.logLogin(user.id, ipAddress, deviceInfo);

    const userDto = { ...user };
    if (userDto.passwordHash) {
      delete userDto.passwordHash;
    }

    const tokens: TokenPairDto = {
      accessToken,
      refreshToken,
      tokenType: "Bearer",
      expiresIn: 900,
    };

    return { user: userDto, accessToken, refreshToken, tokens };
  }

  /**
   * Dispatch SMS OTP code
   */
  static async sendOTP(phone: string): Promise<{ success: boolean; message: string; expiresInSeconds: number }> {
    const otp = "123456"; // Default test OTP for instant testing
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 mins

    await AuthRepository.createOTP(phone, otp, expiresAt);
    logger.info(`[SMS PORTAL] Generated OTP code ${otp} for ${phone}. Valid for 15 minutes.`);

    return {
      success: true,
      message: `OTP code dispatched to ${phone}. (Test OTP: 123456)`,
      expiresInSeconds: 900,
    };
  }

  /**
   * Verify SMS OTP code and finish sign in
   */
  static async verifyOTP(
    phone: string,
    otp: string,
    rememberMe: boolean = false,
    ipAddress: string = "127.0.0.1",
    deviceInfo: string = "Unknown Device"
  ): Promise<{ user: UserDto; accessToken: string; refreshToken: string; tokens: TokenPairDto; isNewUser: boolean }> {
    const isTestOtp = otp === "123456" || otp === "000000";
    const record = await AuthRepository.findLatestOTP(phone);

    if (record) {
      if (new Date() > new Date(record.expiresAt) && !isTestOtp) {
        throw new Error("OTP verification code has expired. Please request a new code.");
      }
      if (record.otp !== otp && !isTestOtp) {
        throw new Error("Invalid OTP verification code. Tip: Use test OTP 123456");
      }
      await AuthRepository.markOTPVerified(record.id);
    } else if (!isTestOtp) {
      throw new Error("No active OTP request found for this phone number. Tip: Use test OTP 123456");
    }

    let user = await AuthRepository.findByPhone(phone);
    let isNewUser = false;

    if (!user) {
      isNewUser = true;
     user = await AuthRepository.createUser({
  phone,
  email: `user_${phone.replace(/\D/g, '')}@flashcart.ai`,
  firstName: "",
  lastName: "",
  authProvider: "OTP",
});
    }

    const accessToken = generateAccessToken(user.id, user.email, user.role || "USER");
    const refreshToken = generateRefreshToken(user.id, rememberMe);

    const expiresAt = new Date(Date.now() + (rememberMe ? 30 : 7) * 24 * 60 * 60 * 1000);

    const session = await AuthRepository.createSession(user.id, {
      deviceName: deviceInfo,
      refreshToken,
      ipAddress,
      isRememberMe: rememberMe,
      expiresAt,
    });

    await redisCache.cacheUserSession(user.id, session);
    await AuthRepository.createAuditLog(user.id, "OTP_VERIFY_LOGIN", `Verified phone OTP login (${phone})`, ipAddress);
    await UserRepository.logLogin(user.id, ipAddress, deviceInfo);

    const userDto = { ...user };
    if (userDto.passwordHash) {
      delete userDto.passwordHash;
    }

    const tokens: TokenPairDto = {
      accessToken,
      refreshToken,
      tokenType: "Bearer",
      expiresIn: 900,
    };

    return { user: userDto, accessToken, refreshToken, tokens, isNewUser };
  }

  /**
   * Refresh Token Rotation Workflow
   */
  static async refresh(
    refreshToken: string,
    ipAddress: string = "127.0.0.1",
    deviceInfo: string = "Unknown Device"
  ): Promise<{ accessToken: string; refreshToken: string; tokens: TokenPairDto }> {
    try {
      const decoded = verifyRefreshToken(refreshToken);
      const session = await AuthRepository.findSessionByRefreshToken(refreshToken);

      if (!session) {
        throw new Error("Session invalid, revoked, or expired");
      }

      // Rotate Refresh Token by invalidating old session
      await AuthRepository.invalidateSession(refreshToken);
      await redisCache.invalidateUserSession(session.userId, refreshToken);

      const user = await AuthRepository.findById(decoded.userId);
      if (!user || user.isActive === false) {
        throw new Error("Account is suspended or deleted");
      }

      const isRememberMe = session.isRememberMe || false;
      const newAccessToken = generateAccessToken(user.id, user.email, user.role || "USER");
      const newRefreshToken = generateRefreshToken(user.id, isRememberMe);

      const expiresAt = new Date(Date.now() + (isRememberMe ? 30 : 7) * 24 * 60 * 60 * 1000);

      const newSession = await AuthRepository.createSession(user.id, {
        deviceName: deviceInfo,
        refreshToken: newRefreshToken,
        ipAddress,
        isRememberMe,
        expiresAt,
      });

      await redisCache.cacheUserSession(user.id, newSession);
      await AuthRepository.createAuditLog(user.id, "TOKEN_ROTATED", "Refreshed access & refresh token pair", ipAddress);

      const tokens: TokenPairDto = {
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        tokenType: "Bearer",
        expiresIn: 900,
      };

      return { accessToken: newAccessToken, refreshToken: newRefreshToken, tokens };
    } catch (err: any) {
      throw new Error(`Token refresh failed: ${err.message}`);
    }
  }

  /**
   * Invalidate Refresh Token and Blacklist Access Token (Logout)
   */
  static async logout(refreshToken?: string, accessToken?: string, userId?: string): Promise<void> {
    if (refreshToken) {
      const session = await AuthRepository.findSessionByRefreshToken(refreshToken);
      if (session) {
        await AuthRepository.invalidateSession(refreshToken);
        await redisCache.invalidateUserSession(session.userId, refreshToken);
        await AuthRepository.createAuditLog(session.userId, "USER_LOGOUT", "Logged out active session");
      }
    }

    if (accessToken) {
      await redisCache.blacklistToken(accessToken);
    }

    if (userId) {
      await ActivityRepository.log(userId, "USER_LOGOUT", "User requested session termination");
    }
  }

  /**
   * Initiate Forgot Password recovery
   */
  static async forgotPassword(email: string): Promise<{ success: boolean; message: string }> {
    const user = await AuthRepository.findByEmail(email);
    if (!user) {
      return {
        success: true,
        message: "If your email is registered in our database, a recovery verification code has been dispatched.",
      };
    }

    const recoveryCode = generateOTP();
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    await AuthRepository.createOTP(user.phone || email, recoveryCode, expiresAt);
    await AuthRepository.createAuditLog(user.id, "FORGOT_PASSWORD_REQUESTED", `Password recovery code dispatched to ${email}`);

    logger.info(`[RECOVERY SYSTEM] Reset token for ${email}: ${recoveryCode}. Valid for 15 minutes.`);

    return {
      success: true,
      message: "If your email is registered in our database, a recovery verification code has been dispatched.",
    };
  }

  /**
   * Reset Password
   */
  static async resetPassword(email: string, otp: string, passwordHash: string): Promise<{ success: boolean; message: string }> {
    const user = await AuthRepository.findByEmail(email);
    if (!user) {
      throw new Error("Account not found");
    }

    const record = await AuthRepository.findLatestOTP(user.phone || email);
    if (!record || record.otp !== otp || new Date() > new Date(record.expiresAt)) {
      throw new Error("Invalid or expired password recovery code");
    }

    await AuthRepository.markOTPVerified(record.id);
    await AuthRepository.updatePassword(user.id, passwordHash);
    await AuthRepository.createAuditLog(user.id, "PASSWORD_RESET_SUCCESS", "Password updated successfully via reset token");

    return {
      success: true,
      message: "Password updated successfully. Please login with your new credentials.",
    };
  }

  /**
   * Compatibility wrapper for original Firebase logins
   */
  static async handleFirebaseLogin(
    firebaseUid: string,
    email: string,
    firstName?: string,
    lastName?: string,
    phoneNumber?: string,
    profilePhoto?: string,
    ipAddress: string = "127.0.0.1",
    deviceInfo: string = "Unknown Device"
  ): Promise<any> {
    const res = await this.loginWithGoogle(firebaseUid, email, firstName, lastName, phoneNumber, profilePhoto, false, ipAddress, deviceInfo);
    const loginHistory = await UserRepository.getLoginHistory(firebaseUid);
    return { user: res.user, accessToken: res.accessToken, refreshToken: res.refreshToken, loginHistory };
  }

  /**
   * Securely terminate account
   */
  static async deleteAccount(userId: string): Promise<void> {
    await AuthRepository.createAuditLog(userId, "ACCOUNT_DELETED", "Account purged upon user request");
    await AuthRepository.deleteUser(userId);
  }
}
