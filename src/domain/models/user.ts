/**
 * User & Profile Domain Models
 */

import { BaseDomainModel, GeoLocation } from '../types';
import { UserRole } from '../enums';

export interface Address extends BaseDomainModel {
  userId: string;
  label: 'Home' | 'Work' | 'Other';
  addressLine1: string;
  addressLine2?: string;
  landmark?: string;
  city: string;
  state: string;
  postalCode: string;
  country: string;
  geo: GeoLocation;
  isDefault: boolean;
  contactName: string;
  contactPhone: string;
}

export interface UserProfile extends BaseDomainModel {
  userId: string;
  firstName: string;
  lastName: string;
  avatarUrl?: string;
  dateOfBirth?: string;
  gender?: 'MALE' | 'FEMALE' | 'OTHER' | 'PREFER_NOT_TO_SAY';
  dietaryPreferences?: string[];
  allergies?: string[];
  preferredLanguage?: string;
}

export interface User extends BaseDomainModel {
  email: string;
  phone: string;
  role: UserRole;
  isEmailVerified: boolean;
  isPhoneVerified: boolean;
  profile?: UserProfile;
  addresses: Address[];
  defaultAddressId?: string;
  referralCode: string;
  referredByCode?: string;
}
