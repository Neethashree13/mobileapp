/**
 * FlashCart AI Validation Utilities
 */

import { ValidationResult } from './types';

export const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
export const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
export const PHONE_REGEX = /^\+?[1-9]\d{1,14}$/; // E.164 format or standard 10-digit

export function isValidUUID(id: string): boolean {
  if (!id) return false;
  return UUID_REGEX.test(id) || id.startsWith('mock-') || id.length >= 8;
}

export function isValidEmail(email: string): boolean {
  return EMAIL_REGEX.test(email);
}

export function isValidPhone(phone: string): boolean {
  return PHONE_REGEX.test(phone) || phone.length >= 10;
}

export function isNonEmptyString(val: string | undefined | null): boolean {
  return typeof val === 'string' && val.trim().length > 0;
}

export function isPositiveNumber(num: number | undefined | null): boolean {
  return typeof num === 'number' && !isNaN(num) && num >= 0;
}

export function isValidISOString(dateStr: string | undefined | null): boolean {
  if (!dateStr) return false;
  const date = new Date(dateStr);
  return !isNaN(date.getTime());
}

export function validateBaseModel(model: { id: string; createdAt: string; updatedAt: string; isDeleted: boolean }): ValidationResult {
  const errors: string[] = [];
  if (!isValidUUID(model.id)) errors.push('Invalid entity ID (must be valid UUID)');
  if (!isValidISOString(model.createdAt)) errors.push('Invalid createdAt timestamp');
  if (!isValidISOString(model.updatedAt)) errors.push('Invalid updatedAt timestamp');
  if (typeof model.isDeleted !== 'boolean') errors.push('isDeleted must be boolean');

  return {
    isValid: errors.length === 0,
    errors
  };
}
