/**
 * Shopping, Cart, Coupon & Offer Domain Models
 */

import { BaseDomainModel } from '../types';
import { Product } from './catalog';
import { CouponType } from '../enums';

export interface CartItem {
  id?: string;
  productId?: string;
  product: Product;
  quantity: number;
  addedBy?: string; // For group ordering
  unitPrice?: number;
  totalPrice?: number;
  isSavedForLater?: boolean;
}

export interface Cart extends Partial<BaseDomainModel> {
  id: string;
  userId: string;
  items: CartItem[];
  subtotal: number;
  deliveryFee: number;
  discountAmount: number;
  taxAmount: number;
  totalAmount: number;
  appliedCouponCode?: string;
  familyShareId?: string;
}

export interface Wishlist extends Partial<BaseDomainModel> {
  id: string;
  userId: string;
  productIds: string[];
  products?: Product[];
}

export interface Coupon extends Partial<BaseDomainModel> {
  id: string;
  code: string;
  title: string;
  description: string;
  type: CouponType;
  discountValue: number;
  minOrderAmount: number;
  maxDiscountAmount?: number;
  validFrom: string;
  validUntil: string;
  usageLimitPerUser?: number;
  totalUsageLimit?: number;
  timesUsed?: number;
  isActive: boolean;
}

export interface Offer extends Partial<BaseDomainModel> {
  id: string;
  title: string;
  subtitle: string;
  imageUrl: string;
  discountPercentage: number;
  categorySlug?: string;
  productId?: string;
  validUntil: string;
  isActive: boolean;
}

export interface Banner extends Partial<BaseDomainModel> {
  id: string;
  title: string;
  imageUrl: string;
  targetType: 'CATEGORY' | 'PRODUCT' | 'URL' | 'OFFER';
  targetValue: string;
  displayOrder: number;
  isActive: boolean;
}
