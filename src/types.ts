/**
 * FlashCart AI Global App Types
 * Re-exports from Domain Layer for legacy component compatibility.
 */

export * from './domain';

// Backward compatibility alias definitions for existing UI components
import { Product as DomainProduct, CartItem as DomainCartItem, Order as DomainOrder } from './domain';

export type Product = DomainProduct;
export type CartItem = DomainCartItem;
export type Order = DomainOrder;

export interface MealPlan {
  diet: string;
  cuisine: string;
  targetCalories: number;
  budget: number;
  meals: {
    breakfast: { name: string; ingredients: { name: string; quantity: string; category: string; priceEstimate: number }[] };
    lunch: { name: string; ingredients: { name: string; quantity: string; category: string; priceEstimate: number }[] };
    dinner: { name: string; ingredients: { name: string; quantity: string; category: string; priceEstimate: number }[] };
  };
}

export interface DriverState {
  id: string;
  name: string;
  phone: string;
  avatar: string;
  lat: number;
  lng: number;
  bearing: number;
  status: 'assigned' | 'at_store' | 'picked_up' | 'near_delivery' | 'delivered';
  rating: number;
  riderCameraUrl?: string;
}

export interface FamilyMember {
  id: string;
  name: string;
  avatar: string;
  role: 'Parent' | 'Kid' | 'Spouse';
  allowanceRemaining?: number;
}

export type AppRole = 'customer' | 'rider' | 'store' | 'admin';
