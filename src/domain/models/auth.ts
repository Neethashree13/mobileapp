/**
 * Authentication Domain Models
 */

import { BaseDomainModel } from '../types';
import { AuthProviderType, UserRole } from '../enums';

export interface AuthCredentials {
  email?: string;
  phone?: string;
  password?: string;
  otp?: string;
  provider: AuthProviderType;
  providerToken?: string;
}

export interface AuthToken {
  accessToken: string;
  refreshToken: string;
  tokenType: 'Bearer';
  expiresInSeconds: number;
  issuedAt: string;
}

export interface AuthProvider extends BaseDomainModel {
  userId: string;
  providerType: AuthProviderType;
  providerSubjectId: string;
  emailLinked?: string;
  isPrimary: boolean;
}

export interface Session extends BaseDomainModel {
  userId: string;
  userRole: UserRole;
  token: AuthToken;
  ipAddress?: string;
  userAgent?: string;
  deviceId?: string;
  expiresAt: string;
  isActive: boolean;
}
