/**
 * Inventory, Store & Warehouse Domain Models
 */

import { BaseDomainModel, GeoLocation } from '../types';

export interface Warehouse extends BaseDomainModel {
  name: string;
  code: string;
  address: string;
  geo: GeoLocation;
  capacitySqFt: number;
  isActive: boolean;
  contactPhone: string;
}

export interface Store extends BaseDomainModel {
  warehouseId: string;
  name: string;
  code: string;
  address: string;
  geo: GeoLocation;
  operatingHours: string;
  isOpen: boolean;
  contactPhone: string;
  managerId?: string;
}

export interface StoreManager extends BaseDomainModel {
  userId: string;
  storeId: string;
  employeeCode: string;
  name: string;
  email: string;
  phone: string;
  permissions: string[];
  shiftStatus: 'ON_DUTY' | 'OFF_DUTY' | 'ON_LEAVE';
}

export interface Inventory extends BaseDomainModel {
  productId: string;
  variantId?: string;
  warehouseId?: string;
  storeId?: string;
  quantityOnHand: number;
  quantityReserved: number;
  reorderLevel: number;
  reorderQuantity: number;
  lastRestockedAt: string;
}
