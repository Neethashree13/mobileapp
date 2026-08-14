// Redis & In-Memory Cache and Optimistic Lock Service
import { logger } from "./logger";

interface MemoryStoreItem {
  value: any;
  expiresAt?: number;
}

interface StockReservation {
  id: string;
  userId: string;
  storeId: string;
  productId: string;
  variantId?: string;
  quantity: number;
  reservedAt: number;
  expiresAt: number;
}

class RedisCacheService {
  private memoryStore: Map<string, MemoryStoreItem> = new Map();
  private reservations: Map<string, StockReservation> = new Map(); // key: userId_productId

  constructor() {
    // Cleanup expired keys periodically
    setInterval(() => this.cleanupExpired(), 30000);
  }

  private cleanupExpired() {
    const now = Date.now();
    for (const [key, item] of this.memoryStore.entries()) {
      if (item.expiresAt && item.expiresAt < now) {
        this.memoryStore.delete(key);
      }
    }
    for (const [key, res] of this.reservations.entries()) {
      if (res.expiresAt < now) {
        this.reservations.delete(key);
        logger.info(`Stock reservation expired and auto-released for key ${key}`);
      }
    }
  }

  // Get key
  async get<T>(key: string): Promise<T | null> {
    const item = this.memoryStore.get(key);
    if (!item) return null;
    if (item.expiresAt && item.expiresAt < Date.now()) {
      this.memoryStore.delete(key);
      return null;
    }
    return item.value as T;
  }

  // Set key with optional TTL in seconds
  async set(key: string, value: any, ttlSeconds?: number): Promise<void> {
    const expiresAt = ttlSeconds ? Date.now() + ttlSeconds * 1000 : undefined;
    this.memoryStore.set(key, { value, expiresAt });
  }

  // Delete key
  async del(key: string): Promise<void> {
    this.memoryStore.delete(key);
  }

  // Inventory Lock / Reservation for 10 minutes (600s)
  async reserveInventory(
    userId: string,
    storeId: string,
    productId: string,
    quantity: number,
    availableStock: number,
    ttlSeconds: number = 600
  ): Promise<{ success: boolean; reservedQuantity: number; remainingStock: number; message?: string }> {
    const key = `${userId}_${productId}`;
    const now = Date.now();

    // Check existing active reservations for this product across all users
    let totalActiveReserved = 0;
    for (const [resKey, res] of this.reservations.entries()) {
      if (res.productId === productId && res.expiresAt > now) {
        if (resKey !== key) {
          totalActiveReserved += res.quantity;
        }
      }
    }

    const effectiveStock = availableStock - totalActiveReserved;
    if (quantity > effectiveStock) {
      return {
        success: false,
        reservedQuantity: 0,
        remainingStock: Math.max(0, effectiveStock),
        message: `Insufficient stock for ${productId}. Requested ${quantity}, available ${effectiveStock} after active locks.`
      };
    }

    const reservation: StockReservation = {
      id: `res_${now}_${Math.random().toString(36).substring(2, 7)}`,
      userId,
      storeId,
      productId,
      quantity,
      reservedAt: now,
      expiresAt: now + ttlSeconds * 1000,
    };

    this.reservations.set(key, reservation);
    logger.info(`Locked ${quantity} units of ${productId} for user ${userId} until ${new Date(reservation.expiresAt).toISOString()}`);

    return {
      success: true,
      reservedQuantity: quantity,
      remainingStock: effectiveStock - quantity,
    };
  }

  // Release user stock reservation
  async releaseReservation(userId: string, productId: string): Promise<void> {
    const key = `${userId}_${productId}`;
    this.reservations.delete(key);
  }

  // Clear all user reservations
  async clearUserReservations(userId: string): Promise<void> {
    for (const [key, res] of this.reservations.entries()) {
      if (res.userId === userId) {
        this.reservations.delete(key);
      }
    }
  }

  // Get active reservations for Store Manager view
  async getActiveReservations(storeId?: string): Promise<StockReservation[]> {
    const now = Date.now();
    const result: StockReservation[] = [];
    for (const res of this.reservations.values()) {
      if (res.expiresAt > now) {
        if (!storeId || res.storeId === storeId) {
          result.push(res);
        }
      }
    }
    return result;
  }
}

export const redisCache = new RedisCacheService();
