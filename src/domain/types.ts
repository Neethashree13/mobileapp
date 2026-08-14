/**
 * FlashCart AI Common Types & Base Entity Contract
 */

export interface BaseDomainModel {
  /** Unique primary identifier (UUID v4) */
  id: string;
  /** ISO 8601 creation timestamp */
  createdAt: string;
  /** ISO 8601 last updated timestamp */
  updatedAt: string;
  /** Soft delete marker */
  isDeleted: boolean;
  /** ISO 8601 deletion timestamp (if soft-deleted) */
  deletedAt?: string | null;
}

export interface ValidationResult {
  isValid: boolean;
  errors: string[];
}

export interface PaginationParams {
  page: number;
  limit: number;
  search?: string;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
  timestamp: string;
}

export interface GeoLocation {
  lat: number;
  lng: number;
  addressString?: string;
}
