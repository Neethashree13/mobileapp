import { dbQuery, usePostgreSQL, dbPool } from "../config/database";
import { DB_STATE } from "../config/dbState";
import { ProductRepository } from "./product.repository";
import { CouponRepository } from "./coupon.repository";

export interface CartItem {
  product: {
    id: string;
    name: string;
    category?: string;
    price: number;
    originalPrice?: number;
    unit?: string;
    image?: string;
    rating?: number;
    reviewsCount?: number;
    calories?: number;
    protein?: number;
    isOrganic?: boolean;
    isHealthy?: boolean;
    ecoScore?: string;
    carbonEmission?: number;
    inventory?: number;
    deliveryTimeMins?: number;
    description?: string;
  };
  quantity: number;
  addedBy?: string;
  isSavedForLater?: boolean;
}

export interface CartSummary {
  items: CartItem[];
  savedForLater: CartItem[];
  itemCount: number;
  subtotal: number;
  originalSubtotal: number;
  savings: number;
  freeDeliveryThreshold: number;
  amountForFreeDelivery: number;
  deliveryFee: number;
  tax: number;
  platformFee: number;
  packingCharges: number;
  appliedCoupon?: {
    code: string;
    discountAmount: number;
  };
  total: number;
  estimatedDeliveryTime: string;
  stockValidation: {
    productId: string;
    productName: string;
    requestedQuantity: number;
    availableStock: number;
    isAvailable: boolean;
  }[];
  isCartValid: boolean;
}

const DEFAULT_USER_ID = "6ba7b810-9dad-11d1-80b4-00c04fd430c8";

export class CartRepository {
  static async get(userId: string = DEFAULT_USER_ID): Promise<CartItem[]> {
    if (usePostgreSQL) {
      try {
        const { rows } = await dbQuery(`
          SELECT c.quantity, c.added_by as "addedBy", c.is_saved_for_later as "isSavedForLater",
                 p.id as "prod_id", p.name as "prod_name", p.category_id as "prod_category", p.price as "prod_price", p.original_price as "prod_orig_price", p.unit as "prod_unit", p.image_url as "prod_image", p.rating as "prod_rating", p.reviews_count as "prod_reviewsCount", p.calories as "prod_calories", p.protein_g as "prod_protein", p.is_organic as "prod_isOrganic", p.is_healthy as "prod_isHealthy", p.eco_score as "prod_ecoScore", p.carbon_emission_kg as "prod_carbonEmission", p.inventory_count as "prod_inventory", p.delivery_time_mins as "prod_deliveryTimeMins", p.description as "prod_description"
          FROM cart_items c JOIN products p ON c.product_id = p.id
          WHERE c.user_id = $1
        `, [userId]);
        return rows.map((r) => ({
          product: {
            id: r.prod_id,
            name: r.prod_name,
            category: r.prod_category,
            price: Number(r.prod_price),
            originalPrice: r.prod_orig_price ? Number(r.prod_orig_price) : undefined,
            unit: r.prod_unit,
            image: r.prod_image,
            rating: Number(r.prod_rating),
            reviewsCount: Number(r.prod_reviewsCount),
            calories: Number(r.prod_calories),
            protein: Number(r.prod_protein),
            isOrganic: r.prod_isOrganic,
            isHealthy: r.prod_isHealthy,
            ecoScore: r.prod_ecoScore,
            carbonEmission: Number(r.prod_carbonEmission),
            inventory: Number(r.prod_inventory),
            deliveryTimeMins: Number(r.prod_deliveryTimeMins),
            description: r.prod_description,
          },
          quantity: r.quantity,
          addedBy: r.addedBy,
          isSavedForLater: Boolean(r.isSavedForLater),
        }));
      } catch (e) {
        console.warn("Error fetching cart from PostgreSQL:", e);
      }
    }
    return DB_STATE.cart as unknown as CartItem[];
  }

  static async addItem(
    userId: string = DEFAULT_USER_ID,
    productId: string,
    quantity: number = 1,
    addedBy: string = "Self"
  ): Promise<CartItem[]> {
    const product = await ProductRepository.findById(productId);
    if (!product) {
      throw new Error(`Product with ID ${productId} not found`);
    }

    if (usePostgreSQL) {
      await dbQuery(`
        INSERT INTO cart_items (user_id, product_id, quantity, added_by, is_saved_for_later)
        VALUES ($1, $2, $3, $4, false)
        ON CONFLICT (user_id, product_id)
        DO UPDATE SET quantity = cart_items.quantity + $3, is_saved_for_later = false
      `, [userId, productId, quantity, addedBy]);
      return this.get(userId);
    }

    const existing = DB_STATE.cart.find((item) => item.product.id === productId);
    if (existing) {
      existing.quantity += quantity;
      (existing as any).isSavedForLater = false;
    } else {
      DB_STATE.cart.push({
        product,
        quantity,
        addedBy,
        isSavedForLater: false,
      } as any);
    }
    return DB_STATE.cart as unknown as CartItem[];
  }

  static async updateItem(
    userId: string = DEFAULT_USER_ID,
    productId: string,
    quantity: number
  ): Promise<CartItem[]> {
    if (quantity <= 0) {
      return this.removeItem(userId, productId);
    }

    if (usePostgreSQL) {
      await dbQuery(`
        UPDATE cart_items SET quantity = $1, updated_at = CURRENT_TIMESTAMP
        WHERE user_id = $2 AND product_id = $3
      `, [quantity, userId, productId]);
      return this.get(userId);
    }

    const item = DB_STATE.cart.find((i) => i.product.id === productId);
    if (item) {
      item.quantity = quantity;
    }
    return DB_STATE.cart as unknown as CartItem[];
  }

  static async removeItem(
    userId: string = DEFAULT_USER_ID,
    productId: string
  ): Promise<CartItem[]> {
    if (usePostgreSQL) {
      await dbQuery(`
        DELETE FROM cart_items WHERE user_id = $1 AND product_id = $2
      `, [userId, productId]);
      return this.get(userId);
    }

    const idx = DB_STATE.cart.findIndex((i) => i.product.id === productId);
    if (idx !== -1) {
      DB_STATE.cart.splice(idx, 1);
    }
    return DB_STATE.cart as unknown as CartItem[];
  }

  static async toggleSaveForLater(
    userId: string = DEFAULT_USER_ID,
    productId: string,
    isSavedForLater: boolean
  ): Promise<CartItem[]> {
    if (usePostgreSQL) {
      await dbQuery(`
        UPDATE cart_items SET is_saved_for_later = $1, updated_at = CURRENT_TIMESTAMP
        WHERE user_id = $2 AND product_id = $3
      `, [isSavedForLater, userId, productId]);
      return this.get(userId);
    }

    const item = DB_STATE.cart.find((i) => i.product.id === productId);
    if (item) {
      (item as any).isSavedForLater = isSavedForLater;
    }
    return DB_STATE.cart as unknown as CartItem[];
  }

  static async getSummary(
    userId: string = DEFAULT_USER_ID,
    couponCode?: string
  ): Promise<CartSummary> {
    const allItems = await this.get(userId);
    const activeItems = allItems.filter((i) => !i.isSavedForLater);
    const savedForLater = allItems.filter((i) => i.isSavedForLater);

    let subtotal = 0;
    let originalSubtotal = 0;
    let itemCount = 0;

    const stockValidation: CartSummary["stockValidation"] = [];
    let isCartValid = true;

    for (const item of activeItems) {
      const p = item.product;
      const qty = item.quantity;

      subtotal += p.price * qty;
      originalSubtotal += (p.originalPrice || p.price) * qty;
      itemCount += qty;

      const isAvailable = (p.inventory || 0) >= qty;
      if (!isAvailable) isCartValid = false;

      stockValidation.push({
        productId: p.id,
        productName: p.name,
        requestedQuantity: qty,
        availableStock: p.inventory || 0,
        isAvailable,
      });
    }

    const savings = Math.max(0, originalSubtotal - subtotal);
    const freeDeliveryThreshold = 199;
    const amountForFreeDelivery = Math.max(0, freeDeliveryThreshold - subtotal);
    const deliveryFee = subtotal > 0 && subtotal < freeDeliveryThreshold ? 25 : 0;
    const tax = subtotal > 0 ? Math.round(subtotal * 0.05 * 100) / 100 : 0; // 5% GST
    const platformFee = subtotal > 0 ? 5 : 0;
    const packingCharges = subtotal > 0 ? 10 : 0;

    let appliedCouponInfo: CartSummary["appliedCoupon"] = undefined;
    let couponDiscount = 0;

    if (couponCode && subtotal > 0) {
      const couponRes = await CouponRepository.findActiveByCode(couponCode);
      if (couponRes) {
        if (!couponRes.min_order_value || subtotal >= couponRes.min_order_value) {
          if (couponRes.discount_type === "percentage") {
            couponDiscount = (subtotal * couponRes.discount_value) / 100;
            if (couponRes.max_discount && couponDiscount > couponRes.max_discount) {
              couponDiscount = couponRes.max_discount;
            }
          } else {
            couponDiscount = couponRes.discount_value;
          }
          if (couponDiscount > subtotal) couponDiscount = subtotal;
          appliedCouponInfo = {
            code: couponRes.code,
            discountAmount: couponDiscount,
          };
        }
      }
    }

    const total = Math.max(
      0,
      subtotal - couponDiscount + deliveryFee + tax + platformFee + packingCharges
    );

    return {
      items: activeItems,
      savedForLater,
      itemCount,
      subtotal: Math.round(subtotal * 100) / 100,
      originalSubtotal: Math.round(originalSubtotal * 100) / 100,
      savings: Math.round(savings * 100) / 100,
      freeDeliveryThreshold,
      amountForFreeDelivery: Math.round(amountForFreeDelivery * 100) / 100,
      deliveryFee,
      tax,
      platformFee,
      packingCharges,
      appliedCoupon: appliedCouponInfo,
      total: Math.round(total * 100) / 100,
      estimatedDeliveryTime: "8 - 12 Mins",
      stockValidation,
      isCartValid,
    };
  }

  static async sync(cart: CartItem[], userId: string = DEFAULT_USER_ID): Promise<void> {
    if (usePostgreSQL && dbPool) {
      const client = await dbPool.connect();
      try {
        await client.query("BEGIN");
        await client.query("DELETE FROM cart_items WHERE user_id = $1", [userId]);
        for (const item of cart) {
          await client.query(`
            INSERT INTO cart_items (user_id, product_id, quantity, added_by, is_saved_for_later)
            VALUES ($1, $2, $3, $4, $5)
            ON CONFLICT(user_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity, is_saved_for_later = EXCLUDED.is_saved_for_later
          `, [
            userId,
            item.product.id,
            item.quantity,
            item.addedBy || "Self",
            Boolean((item as any).isSavedForLater),
          ]);
        }
        await client.query("COMMIT");
      } catch (txnErr) {
        await client.query("ROLLBACK");
        throw txnErr;
      } finally {
        client.release();
      }
    } else {
      DB_STATE.cart = cart as any;
    }
  }
}

