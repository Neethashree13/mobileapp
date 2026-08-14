/**
 * Subscription & Analytics Domain Models
 */

import { BaseDomainModel } from '../types';
import { SubscriptionStatus } from '../enums';

export interface Subscription extends BaseDomainModel {
  userId: string;
  planName: 'FLASH_PASS_MONTHLY' | 'FLASH_PASS_ANNUAL' | 'FAMILY_ULTIMATE';
  price: number;
  billingCycle: 'MONTHLY' | 'ANNUAL';
  status: SubscriptionStatus;
  startDate: string;
  nextBillingDate: string;
  freeDeliveryEligible: boolean;
  cashbackMultiplier: number;
  autoRenew: boolean;
}

export interface AnalyticsEvent extends BaseDomainModel {
  userId?: string;
  sessionId?: string;
  eventType: string; // e.g. 'PRODUCT_VIEW', 'ADD_TO_CART', 'CHECKOUT_START'
  screenName: string;
  payload?: Record<string, unknown>;
  deviceType: 'WEB' | 'FLUTTER_CUSTOMER' | 'FLUTTER_RIDER' | 'STORE_APP';
}

export interface AnalyticsSummary {
  date: string;
  totalOrders: number;
  totalRevenue: number;
  averageOrderValue: number;
  activeUsersCount: number;
  topCategories: { categoryName: string; orderCount: number }[];
  deliveryOntimeRate: number;
}
