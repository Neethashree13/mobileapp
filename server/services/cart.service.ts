import { CartRepository, CartItem, CartSummary } from "../repositories/cart.repository";
import { UserRepository } from "../repositories/user.repository";
import { ActivityRepository } from "../repositories/activity.repository";
import { redisCache } from "../utils/redis";

const DEFAULT_USER_ID = "6ba7b810-9dad-11d1-80b4-00c04fd430c8";

export class CartService {
  static async getCart(userId: string = DEFAULT_USER_ID): Promise<CartItem[]> {
    return CartRepository.get(userId);
  }

  static async addItem(
    productId: string,
    quantity: number = 1,
    addedBy: string = "Self",
    userId: string = DEFAULT_USER_ID
  ): Promise<CartItem[]> {
    const updated = await CartRepository.addItem(userId, productId, quantity, addedBy);
    await ActivityRepository.log(userId, "cart_add_item", `Added product ${productId} (qty: ${quantity}) to cart`);
    return updated;
  }

  static async updateItemQuantity(
    productId: string,
    quantity: number,
    userId: string = DEFAULT_USER_ID
  ): Promise<CartItem[]> {
    const updated = await CartRepository.updateItem(userId, productId, quantity);
    await ActivityRepository.log(userId, "cart_update_item", `Updated product ${productId} quantity to ${quantity}`);
    return updated;
  }

  static async removeItem(
    productId: string,
    userId: string = DEFAULT_USER_ID
  ): Promise<CartItem[]> {
    const updated = await CartRepository.removeItem(userId, productId);
    await ActivityRepository.log(userId, "cart_remove_item", `Removed product ${productId} from cart`);
    return updated;
  }

  static async toggleSaveForLater(
    productId: string,
    isSavedForLater: boolean,
    userId: string = DEFAULT_USER_ID
  ): Promise<CartItem[]> {
    const updated = await CartRepository.toggleSaveForLater(userId, productId, isSavedForLater);
    await ActivityRepository.log(
      userId,
      "cart_save_for_later",
      `${isSavedForLater ? "Saved for later" : "Moved to active cart"} product ${productId}`
    );
    return updated;
  }

  static async getCartSummary(
    userId: string = DEFAULT_USER_ID,
    couponCode?: string
  ): Promise<CartSummary> {
    return CartRepository.getSummary(userId, couponCode);
  }

  static async validateAndReserveCheckout(
    userId: string = DEFAULT_USER_ID,
    couponCode?: string,
    storeId: string = "s1"
  ): Promise<{
    valid: boolean;
    errors: string[];
    summary: CartSummary;
    reservations: any[];
  }> {
    const summary = await CartRepository.getSummary(userId, couponCode);
    const errors: string[] = [];
    const reservations: any[] = [];

    if (summary.items.length === 0) {
      errors.push("Cart is empty");
    }

    for (const item of summary.items) {
      const p = item.product;
      const res = await redisCache.reserveInventory(
        userId,
        storeId,
        p.id,
        item.quantity,
        p.inventory || 0,
        600 // 10 minutes TTL
      );

      if (!res.success) {
        errors.push(res.message || `Insufficient inventory for ${p.name}`);
      } else {
        reservations.push({
          productId: p.id,
          productName: p.name,
          quantity: item.quantity,
          storeId,
          expiresInSeconds: 600,
        });
      }
    }

    const valid = errors.length === 0;
    if (valid) {
      await ActivityRepository.log(
        userId,
        "checkout_validate",
        `Validated cart and reserved stock for ${summary.items.length} items (Total: ₹${summary.total})`
      );
    }

    return {
      valid,
      errors,
      summary,
      reservations,
    };
  }

  static async syncCart(items: CartItem[], userId: string = DEFAULT_USER_ID): Promise<CartItem[]> {
    await CartRepository.sync(items, userId);
    const user = await UserRepository.getProfile();
    await ActivityRepository.log(
      user.id,
      "cart_sync",
      `Synchronized cart. Now containing ${items.length} distinct item types.`
    );
    return CartRepository.get(userId);
  }
}

