/**
 * Product Catalog Domain Models
 */

import { BaseDomainModel } from '../types';
import { EcoScore } from '../enums';

export interface Category extends Partial<BaseDomainModel> {
  id: string;
  name: string;
  slug?: string;
  icon: string;
  color: string;
  description?: string;
  parentId?: string;
  displayOrder?: number;
}

export interface Brand extends Partial<BaseDomainModel> {
  id: string;
  name: string;
  slug?: string;
  logoUrl?: string;
  description?: string;
  website?: string;
  isVerified?: boolean;
}

export interface ProductVariant extends Partial<BaseDomainModel> {
  id: string;
  productId: string;
  sku: string;
  name: string;
  unit: string; // e.g., '500g', '1L', 'Pack of 6'
  price: number;
  originalPrice?: number;
  inStock: boolean;
  inventoryQuantity: number;
  isDefault: boolean;
  attributes?: Record<string, string>;
}

export interface Product extends Partial<BaseDomainModel> {
  id: string;
  name: string;
  slug?: string;
  description?: string;
  categoryId?: string;
  categoryName?: string;
  category?: string; // Legacy field alias
  brandId?: string;
  brandName?: string;
  brand?: string; // Legacy field alias
  price: number; // in INR (₹)
  originalPrice?: number;
  unit: string;
  imageUrl?: string;
  image?: string; // Legacy field alias
  additionalImages?: string[];
  rating: number;
  reviewsCount: number;
  calories: number;
  protein: number; // in grams
  fatGrams?: number;
  carbsGrams?: number;
  fiberGrams?: number;
  isOrganic?: boolean;
  isHealthy?: boolean;
  ecoScore: EcoScore | 'A' | 'B' | 'C' | 'D';
  carbonEmission: number; // in kg CO2 per unit
  inventoryQuantity?: number;
  inventory?: number; // Legacy field alias
  badge?: string;
  deliveryTimeMins: number;
  variants?: ProductVariant[];
  tags?: string[];
}
