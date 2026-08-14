export interface UserDto {
  id: string;
  email?: string | null;
  phone?: string | null;
  phoneNumber?: string | null;
  firstName: string;
  lastName?: string | null;
  role: "USER" | "ADMIN" | "SUPER_ADMIN" | "DELIVERY_PARTNER" | string;
  authProvider: "LOCAL" | "GOOGLE" | "OTP" | "FIREBASE" | string;
  firebaseUid?: string | null;
  profilePhoto?: string | null;
  profileImage?: string | null;
  gender?: string | null;
  walletBalance: number;
  streakCount: number;
  isVerified: boolean;
  isActive: boolean;
  lastLogin?: string | Date | null;
  createdAt?: string | Date;
  updatedAt?: string | Date;
}

export interface TokenPairDto {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number; // in seconds
}

export interface LoginResponseDto {
  success: boolean;
  message: string;
  user: UserDto;
  tokens: TokenPairDto;
  loginHistory?: any[];
}

export interface RegisterResponseDto {
  success: boolean;
  message: string;
  user: UserDto;
  tokens: TokenPairDto;
}

export interface OtpResponseDto {
  success: boolean;
  message: string;
  expiresInSeconds?: number;
}

export interface VerifyOtpResponseDto {
  success: boolean;
  message: string;
  user: UserDto;
  tokens: TokenPairDto;
  isNewUser: boolean;
}

export interface RefreshTokenResponseDto {
  success: boolean;
  tokens: TokenPairDto;
}

export interface LogoutResponseDto {
  success: boolean;
  message: string;
}

export interface PasswordResetResponseDto {
  success: boolean;
  message: string;
}

export interface UserSessionDto {
  id: string;
  userId: string;
  deviceId?: string | null;
  deviceName?: string | null;
  ipAddress?: string | null;
  isRememberMe: boolean;
  loginTime: string | Date;
  expiresAt: string | Date;
}

export interface AuditLogDto {
  id: string;
  userId?: string | null;
  action: string;
  details: string;
  ipAddress?: string | null;
  createdAt: string | Date;
}
