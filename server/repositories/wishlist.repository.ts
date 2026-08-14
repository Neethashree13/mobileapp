import { dbQuery, usePostgreSQL } from "../config/database";
import { DB_STATE } from "../config/dbState";
import { ProductRepository, Product } from "./product.repository";

const DEFAULT_USER_ID = "6ba7b810-9dad-11d1-80b4-00c04fd430c8";

export class WishlistRepository {
  static async get(userId: string = DEFAULT_USER_ID): Promise<string[]> {
    if (usePostgreSQL) {
      try {
        const { rows } = await dbQuery(
          "SELECT product_id as id FROM wishlists WHERE user_id = $1",
          [userId]
        );
        return rows.map((r) => r.id);
      } catch (err) {
        console.warn("Wishlist query error:", err);
      }
    }
    return DB_STATE.wishlist;
  }

  static async getProducts(userId: string = DEFAULT_USER_ID): Promise<Product[]> {
    const ids = await this.get(userId);
    if (ids.length === 0) return [];

    if (usePostgreSQL) {
      try {
        const { rows } = await dbQuery(`
          SELECT p.id, p.name, p.category_id as category, p.price, p.original_price as "originalPrice",
                 p.unit, p.image_url as image, p.rating, p.reviews_count as "reviewsCount",
                 p.calories, p.protein_g as protein, p.is_organic as "isOrganic",
                 p.is_healthy as "isHealthy", p.eco_score as "ecoScore",
                 p.carbon_emission_kg as "carbonEmission", p.inventory_count as inventory,
                 p.delivery_time_mins as "deliveryTimeMins", p.description
          FROM wishlists w
          JOIN products p ON w.product_id = p.id
          WHERE w.user_id = $1
        `, [userId]);
        return rows.map((r) => ({
          id: r.id,
          name: r.name,
          category: r.category,
          price: Number(r.price),
          originalPrice: r.originalPrice ? Number(r.originalPrice) : undefined,
          unit: r.unit,
          image: r.image,
          rating: Number(r.rating),
          reviewsCount: Number(r.reviewsCount),
          calories: Number(r.calories),
          protein: Number(r.protein),
          isOrganic: Boolean(r.isOrganic),
          isHealthy: Boolean(r.isHealthy),
          ecoScore: r.ecoScore,
          carbonEmission: Number(r.carbonEmission),
          inventory: Number(r.inventory),
          deliveryTimeMins: Number(r.deliveryTimeMins),
          description: r.description,
        }));
      } catch (err) {
        console.warn("Wishlist product join error:", err);
      }
    }

    const products: Product[] = [];
    for (const id of ids) {
      const p = await ProductRepository.findById(id);
      if (p) products.push(p);
    }
    return products;
  }

  static async add(productId: string, userId: string = DEFAULT_USER_ID): Promise<string[]> {
    if (usePostgreSQL) {
      await dbQuery(
        "INSERT INTO wishlists (user_id, product_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
        [userId, productId]
      );
      return this.get(userId);
    }
    if (!DB_STATE.wishlist.includes(productId)) {
      DB_STATE.wishlist.push(productId);
    }
    return DB_STATE.wishlist;
  }

  static async remove(productId: string, userId: string = DEFAULT_USER_ID): Promise<string[]> {
    if (usePostgreSQL) {
      await dbQuery(
        "DELETE FROM wishlists WHERE user_id = $1 AND product_id = $2",
        [userId, productId]
      );
      return this.get(userId);
    }
    const index = DB_STATE.wishlist.indexOf(productId);
    if (index > -1) {
      DB_STATE.wishlist.splice(index, 1);
    }
    return DB_STATE.wishlist;
  }

  static async toggle(productId: string, userId: string = DEFAULT_USER_ID): Promise<string[]> {
    const list = await this.get(userId);
    if (list.includes(productId)) {
      return this.remove(productId, userId);
    } else {
      return this.add(productId, userId);
    }
  }
}

