import { z } from "zod";

export const registerSchema = z.object({
  email: z.string().email("Invalid email format").optional(),
  phone: z.string().min(10, "Phone number must be at least 10 digits").optional(),
  password: z.string().min(6, "Password must be at least 6 characters").optional(),
  firstName: z.string().min(1, "First name is required"),
  lastName: z.string().optional(),
  role: z.enum(["USER", "ADMIN", "SUPER_ADMIN", "DELIVERY_PARTNER"]).optional().default("USER"),
  acceptTerms: z.boolean().optional(),
  rememberMe: z.boolean().optional().default(false),
}).refine(data => data.email || data.phone, {
  message: "Either email or phone number is required for registration",
  path: ["email"],
});

export const loginSchema = z.object({
  email: z.string().email("Invalid email format").optional(),
  phone: z.string().optional(),
  password: z.string().min(6, "Password must be at least 6 characters").optional(),
  firebaseUid: z.string().optional(),
  rememberMe: z.boolean().optional().default(false),
});

export const googleLoginSchema = z.object({
  firebaseUid: z.string().min(1, "Google Firebase UID is required"),
  email: z.string().email("Invalid Google email address"),
  firstName: z.string().optional(),
  lastName: z.string().optional(),
  phoneNumber: z.string().optional(),
  profilePhoto: z.string().optional(),
  device_id: z.string().optional(),
  device_name: z.string().optional(),
  rememberMe: z.boolean().optional().default(false),
});

export const sendOtpSchema = z.object({
  phone: z.string().min(10, "Phone number must be at least 10 digits"),
});

export const verifyOtpSchema = z.object({
  phone: z.string().min(10, "Phone number must be at least 10 digits"),
  otp: z.string().length(6, "OTP code must be exactly 6 digits"),
  device_id: z.string().optional(),
  device_name: z.string().optional(),
  rememberMe: z.boolean().optional().default(false),
});

export const forgotPasswordSchema = z.object({
  email: z.string().email("Invalid email format"),
});

export const resetPasswordSchema = z.object({
  email: z.string().email("Invalid email format"),
  otp: z.string().min(4, "Invalid recovery OTP code"),
  newPassword: z.string().min(6, "New password must be at least 6 characters"),
});

export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, "Refresh token is required"),
});

export const logoutSchema = z.object({
  refreshToken: z.string().optional(),
});
