import { WishlistRepository } from "../repositories/wishlist.repository";
import { UserRepository } from "../repositories/user.repository";
import { ActivityRepository } from "../repositories/activity.repository";
import { Product } from "../repositories/product.repository";

export class WishlistService {
  static async getWishlist(userId?: string): Promise<string[]> {
    return WishlistRepository.get(userId);
  }

  static async getWishlistProducts(userId?: string): Promise<Product[]> {
    return WishlistRepository.getProducts(userId);
  }

  static async addToWishlist(productId: string, userId?: string): Promise<string[]> {
    const updated = await WishlistRepository.add(productId, userId);
    await ActivityRepository.log(
      userId || "system",
      "wishlist_add",
      `Added product ${productId} to wishlist`
    );
    return updated;
  }

  static async removeFromWishlist(productId: string, userId?: string): Promise<string[]> {
    const updated = await WishlistRepository.remove(productId, userId);
    await ActivityRepository.log(
      userId || "system",
      "wishlist_remove",
      `Removed product ${productId} from wishlist`
    );
    return updated;
  }

  static async toggleWishlist(productId: string, userId?: string): Promise<string[]> {
    const updated = await WishlistRepository.toggle(productId, userId);
    const isAdded = updated.includes(productId);
    await ActivityRepository.log(
      userId || "system",
      "wishlist_toggle",
      `${isAdded ? "Added" : "Removed"} product ${productId} to/from wishlist`
    );
    return updated;
  }
}

