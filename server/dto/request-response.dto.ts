import { Product } from "../repositories/product.repository";
import { UserProfile, Address, SearchHistoryEntry, LoginHistoryEntry } from "../repositories/user.repository";
import { CartItem } from "../repositories/cart.repository";
import { Order } from "../repositories/order.repository";
import { RiderState } from "../repositories/delivery.repository";
import { Review } from "../repositories/review.repository";

// Generic standard response envelope DTO
export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  error?: string;
}

// Auth DTOs
export interface LoginResponseDto {
  user: UserProfile;
  loginHistory: LoginHistoryEntry[];
}

// Product list DTOs
export interface ProductListResponseDto {
  categories: any[];
  products: Product[];
}

// Order placement request DTO
export interface OrderPlacementRequestDto {
  paymentMethod: string;
  items: CartItem[];
}

// Payment view DTO
export interface PaymentHistoryResponseDto {
  walletBalance: number;
  payments: any[];
}

// Delivery updates DTO
export interface LiveDeliveryUpdateDto {
  activeOrder: Order | null;
  riderState: RiderState | null;
}
