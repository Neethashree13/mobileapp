/**
 * Order, Delivery Partner & Order Tracking Models
 */

import { BaseDomainModel, GeoLocation } from '../types';
import { OrderStatus, DeliveryPartnerStatus, PaymentMethodType } from '../enums';
import { CartItem } from './shopping';

export interface OrderItem {
  id: string;
  orderId: string;
  productId: string;
  productName: string;
  productImage: string;
  unit: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}

export interface OrderStatusHistory {
  id: string;
  orderId: string;
  status: OrderStatus;
  note?: string;
  timestamp: string;
}

export interface DeliveryPartner extends BaseDomainModel {
  userId: string;
  name: string;
  phone: string;
  avatarUrl: string;
  vehicleType: 'BIKE' | 'SCOOTER' | 'EV' | 'BICYCLE';
  vehicleNumber: string;
  currentGeo: GeoLocation;
  status: DeliveryPartnerStatus;
  rating: number;
  totalDeliveriesCompleted: number;
  cameraLiveStreamUrl?: string;
}

export interface Order extends BaseDomainModel {
  orderNumber: string;
  userId: string;
  storeId: string;
  deliveryPartnerId?: string;
  deliveryPartner?: DeliveryPartner;
  items: CartItem[];
  subtotal: number;
  deliveryFee: number;
  discount: number;
  tax: number;
  total: number;
  status: OrderStatus;
  paymentMethod: PaymentMethodType;
  paymentStatus: string;
  deliveryAddress: string;
  deliveryGeo: GeoLocation;
  trackingStep: number; // 1-5
  estimatedDeliveryTime: string;
  actualDeliveryTime?: string;
  familyId?: string;
  statusHistory: OrderStatusHistory[];
}
