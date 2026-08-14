import { dbQuery, usePostgreSQL } from "../config/database";
import { DB_STATE } from "../config/dbState";

export interface Category {
  id: string;
  name: string;
  icon: string;
  color: string;
  imageUrl?: string;
  isActive?: boolean;
}

export interface Brand {
  id: string;
  name: string;
  slug: string;
  logoUrl?: string;
  description?: string;
  isFeatured?: boolean;
}

export interface ProductVariant {
  id: string;
  productId: string;
  sku: string;
  name: string;
  attributeValues?: any;
  price: number;
  originalPrice?: number;
  inventoryCount: number;
  isDefault: boolean;
}

export interface Product {
  id: string;
  name: string;
  slug?: string;
  category: string;
  subcategoryId?: string;
  brandId?: string;
  price: number;
  originalPrice?: number;
  unit: string;
  image: string;
  rating: number;
  reviewsCount: number;
  calories: number;
  protein: number;
  isOrganic: boolean;
  isHealthy: boolean;
  isFeatured?: boolean;
  isTrending?: boolean;
  isBestSeller?: boolean;
  isFlashDeal?: boolean;
  ecoScore: any;
  carbonEmission: number;
  inventory: number;
  deliveryTimeMins: number;
  description: string;
  variants?: ProductVariant[];
}

export interface StockMovement {
  id?: string;
  storeId: string;
  productId: string;
  variantId?: string;
  movementType: string; // 'receive', 'move', 'damage', 'expired', 'adjustment', 'cycle_count'
  quantity: number;
  reason?: string;
  notes?: string;
  createdBy?: string;
  createdAt?: string;
}

export class ProductRepository {
  static async getCategories(): Promise<Category[]> {
    if (usePostgreSQL) {
      try {
        const { rows } = await dbQuery("SELECT id, name, icon_name as icon, color_hex as color, image_url as \"imageUrl\", is_active as \"isActive\" FROM categories WHERE is_active = true ORDER BY sort_order ASC, name ASC");
        if (rows.length > 0) return rows;
      } catch (e) {
        console.warn("Categories fetch error, falling back", e);
      }
    }
    return [
      { id: "veggies", name: "Fresh Vegetables", icon: "Utensils", color: "#4ADE80" },
      { id: "dairy", name: "Dairy & Milk", icon: "ShoppingBag", color: "#60A5FA" },
      { id: "bakery", name: "Bakery & Bread", icon: "Sparkles", color: "#FBBF24" },
      { id: "snacks", name: "Munchies & Snacks", icon: "Smile", color: "#F87171" },
      { id: "beverages", name: "Cold Beverages", icon: "Flame", color: "#A78BFA" },
      { id: "pantry", name: "Kitchen Pantry", icon: "Activity", color: "#FB7185" },
      { id: "medicine", name: "Pharmacy & Wellness", icon: "Zap", color: "#2DD4BF" },
      { id: "baby", name: "Baby Care Essentials", icon: "Heart", color: "#34D399" },
    ];
  }

  static async getBrands(): Promise<Brand[]> {
    if (usePostgreSQL) {
      try {
        const { rows } = await dbQuery("SELECT id, name, slug, logo_url as \"logoUrl\", description, is_featured as \"isFeatured\" FROM brands WHERE is_active = true ORDER BY name ASC");
        return rows;
      } catch (e) {
        console.warn("Brands fetch error:", e);
      }
    }
    return [
      { id: "b1", name: "Organic India", slug: "organic-india", isFeatured: true },
      { id: "b2", name: "Amul", slug: "amul", isFeatured: true },
      { id: "b3", name: "Britannia", slug: "britannia", isFeatured: true },
      { id: "b4", name: "Nestle", slug: "nestle", isFeatured: false },
      { id: "b5", name: "Catch", slug: "catch", isFeatured: false }
    ];
  }

  static async createCategory(category: { id: string; name: string; icon: string; color: string }): Promise<Category> {
    if (usePostgreSQL) {
      await dbQuery(
        "INSERT INTO categories (id, name, icon_name, color_hex) VALUES ($1, $2, $3, $4) ON CONFLICT (id) DO UPDATE SET name = $2, icon_name = $3, color_hex = $4",
        [category.id, category.name, category.icon, category.color]
      );
    }
    return category;
  }

  static async createBrand(brand: { id: string; name: string; slug: string; description?: string }): Promise<Brand> {
    if (usePostgreSQL) {
      await dbQuery(
        "INSERT INTO brands (id, name, slug, description) VALUES ($1, $2, $3, $4) ON CONFLICT (id) DO UPDATE SET name = $2, description = $4",
        [brand.id, brand.name, brand.slug, brand.description || null]
      );
    }
    return brand;
  }

  static async getAll(filters?: {
    category?: string;
    brandId?: string;
    query?: string;
    minPrice?: number;
    maxPrice?: number;
    isOrganic?: boolean;
    isHealthy?: boolean;
    isFeatured?: boolean;
    isTrending?: boolean;
    isBestSeller?: boolean;
    isFlashDeal?: boolean;
    sortBy?: string;
    page?: number;
    limit?: number;
  }): Promise<{ products: Product[]; total: number; page: number; limit: number }> {
    const page = filters?.page || 1;
    const limit = filters?.limit || 50;
    const offset = (page - 1) * limit;

    if (usePostgreSQL) {
      let whereClauses: string[] = [];
      let params: any[] = [];
      let paramIdx = 1;

      if (filters?.category) {
        whereClauses.push(`category_id = $${paramIdx++}`);
        params.push(filters.category);
      }
      if (filters?.brandId) {
        whereClauses.push(`brand_id = $${paramIdx++}`);
        params.push(filters.brandId);
      }
      if (filters?.query) {
        whereClauses.push(`(name ILIKE $${paramIdx} OR description ILIKE $${paramIdx})`);
        params.push(`%${filters.query}%`);
        paramIdx++;
      }
      if (filters?.minPrice !== undefined) {
        whereClauses.push(`price >= $${paramIdx++}`);
        params.push(filters.minPrice);
      }
      if (filters?.maxPrice !== undefined) {
        whereClauses.push(`price <= $${paramIdx++}`);
        params.push(filters.maxPrice);
      }
      if (filters?.isOrganic) {
        whereClauses.push(`is_organic = true`);
      }
      if (filters?.isHealthy) {
        whereClauses.push(`is_healthy = true`);
      }
      if (filters?.isFeatured) {
        whereClauses.push(`is_featured = true`);
      }
      if (filters?.isTrending) {
        whereClauses.push(`is_trending = true`);
      }
      if (filters?.isBestSeller) {
        whereClauses.push(`is_best_seller = true`);
      }
      if (filters?.isFlashDeal) {
        whereClauses.push(`is_flash_deal = true`);
      }

      const whereSql = whereClauses.length > 0 ? `WHERE ${whereClauses.join(" AND ")}` : "";

      let orderBySql = "ORDER BY id ASC";
      if (filters?.sortBy === "price_asc") orderBySql = "ORDER BY price ASC";
      if (filters?.sortBy === "price_desc") orderBySql = "ORDER BY price DESC";
      if (filters?.sortBy === "rating") orderBySql = "ORDER BY rating DESC";
      if (filters?.sortBy === "newest") orderBySql = "ORDER BY created_at DESC";

      const countRes = await dbQuery(`SELECT COUNT(*) FROM products ${whereSql}`, params);
      const total = parseInt(countRes.rows[0].count, 10);

      const queryParams = [...params, limit, offset];
      const dataRes = await dbQuery(`
        SELECT id, name, slug, category_id as category, subcategory_id as "subcategoryId", brand_id as "brandId", price, original_price as "originalPrice", unit, image_url as image, rating, reviews_count as "reviewsCount", calories, protein_g as protein, is_organic as "isOrganic", is_healthy as "isHealthy", is_featured as "isFeatured", is_trending as "isTrending", is_best_seller as "isBestSeller", is_flash_deal as "isFlashDeal", eco_score as "ecoScore", carbon_emission_kg as "carbonEmission", inventory_count as inventory, delivery_time_mins as "deliveryTimeMins", description
        FROM products
        ${whereSql}
        ${orderBySql}
        LIMIT $${paramIdx++} OFFSET $${paramIdx++}
      `, queryParams);

      const products = dataRes.rows.map((r) => ({
        ...r,
        price: Number(r.price),
        originalPrice: r.originalPrice ? Number(r.originalPrice) : undefined,
        rating: Number(r.rating),
        protein: Number(r.protein),
        carbonEmission: Number(r.carbonEmission),
        inventory: Number(r.inventory),
        deliveryTimeMins: Number(r.deliveryTimeMins),
      }));

      return { products, total, page, limit };
    }

    let items = [...DB_STATE.products] as unknown as Product[];
    if (filters?.category) items = items.filter((p) => p.category === filters.category);
    if (filters?.query) {
      const q = filters.query.toLowerCase();
      items = items.filter((p) => p.name.toLowerCase().includes(q) || (p.description || "").toLowerCase().includes(q));
    }
    if (filters?.isOrganic) items = items.filter((p) => p.isOrganic);
    if (filters?.isHealthy) items = items.filter((p) => p.isHealthy);

    const total = items.length;
    const paginated = items.slice(offset, offset + limit);
    return { products: paginated, total, page, limit };
  }

  static async search(query: string): Promise<Product[]> {
    const res = await this.getAll({ query });
    return res.products;
  }

  static async findById(id: string): Promise<Product | null> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, name, slug, category_id as category, subcategory_id as "subcategoryId", brand_id as "brandId", price, original_price as "originalPrice", unit, image_url as image, rating, reviews_count as "reviewsCount", calories, protein_g as protein, is_organic as "isOrganic", is_healthy as "isHealthy", is_featured as "isFeatured", is_trending as "isTrending", is_best_seller as "isBestSeller", is_flash_deal as "isFlashDeal", eco_score as "ecoScore", carbon_emission_kg as "carbonEmission", inventory_count as inventory, delivery_time_mins as "deliveryTimeMins", description
        FROM products WHERE id = $1
      `, [id]);
      if (rows.length === 0) return null;
      const r = rows[0];

      // Fetch variants if available
      const varRes = await dbQuery(`
        SELECT id, product_id as "productId", sku, name, attribute_values as "attributeValues", price, original_price as "originalPrice", inventory_count as "inventoryCount", is_default as "isDefault"
        FROM product_variants WHERE product_id = $1
      `, [id]);

      const variants: ProductVariant[] = varRes.rows.map((v) => ({
        ...v,
        price: Number(v.price),
        originalPrice: v.originalPrice ? Number(v.originalPrice) : undefined,
        inventoryCount: Number(v.inventoryCount),
      }));

      return {
        ...r,
        price: Number(r.price),
        originalPrice: r.originalPrice ? Number(r.originalPrice) : undefined,
        rating: Number(r.rating),
        protein: Number(r.protein),
        carbonEmission: Number(r.carbonEmission),
        inventory: Number(r.inventory),
        deliveryTimeMins: Number(r.deliveryTimeMins),
        variants,
      };
    }
    const found = DB_STATE.products.find((p) => p.id === id);
    return found ? (found as unknown as Product) : null;
  }

  static async createProduct(prod: Partial<Product>): Promise<Product> {
    const id = prod.id || `p_${Date.now()}`;
    if (usePostgreSQL) {
      await dbQuery(`
        INSERT INTO products (
          id, name, slug, category_id, subcategory_id, brand_id, price, original_price, unit, image_url,
          rating, reviews_count, calories, protein_g, is_organic, is_healthy, is_featured, is_trending,
          is_best_seller, is_flash_deal, eco_score, carbon_emission_kg, inventory_count, delivery_time_mins, description
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
          $11, $12, $13, $14, $15, $16, $17, $18,
          $19, $20, $21, $22, $23, $24, $25
        ) ON CONFLICT (id) DO UPDATE SET
          name = $2, price = $7, original_price = $8, unit = $9, image_url = $10, inventory_count = $23, description = $25
      `, [
        id, prod.name, prod.slug || prod.name?.toLowerCase().replace(/\s+/g, '-'), prod.category || 'veggies',
        prod.subcategoryId || null, prod.brandId || null, prod.price || 0, prod.originalPrice || null,
        prod.unit || '1 pc', prod.image || 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=120',
        prod.rating || 5.0, prod.reviewsCount || 0, prod.calories || 0, prod.protein || 0,
        prod.isOrganic || false, prod.isHealthy || false, prod.isFeatured || false, prod.isTrending || false,
        prod.isBestSeller || false, prod.isFlashDeal || false, prod.ecoScore || 'B', prod.carbonEmission || 0,
        prod.inventory || 100, prod.deliveryTimeMins || 10, prod.description || ''
      ]);
      const created = await this.findById(id);
      return created!;
    }

    const newProd: Product = {
      id,
      name: prod.name || "New Product",
      category: prod.category || "veggies",
      price: prod.price || 0,
      originalPrice: prod.originalPrice,
      unit: prod.unit || "1 pc",
      image: prod.image || "https://images.unsplash.com/photo-1542838132-92c53300491e?w=120",
      rating: 5.0,
      reviewsCount: 0,
      calories: prod.calories || 0,
      protein: prod.protein || 0,
      isOrganic: prod.isOrganic || false,
      isHealthy: prod.isHealthy || false,
      ecoScore: (prod.ecoScore as any) || "B",
      carbonEmission: prod.carbonEmission || 0,
      inventory: prod.inventory || 50,
      deliveryTimeMins: 10,
      description: prod.description || "",
    };
    DB_STATE.products.push(newProd as any);
    return newProd;
  }

  static async update(id: string, price?: number, inventory?: number, details?: Partial<Product>): Promise<Product | null> {
    if (usePostgreSQL) {
      if (details) {
        await dbQuery(`
          UPDATE products SET
            name = COALESCE($1, name),
            price = COALESCE($2, price),
            inventory_count = COALESCE($3, inventory_count),
            unit = COALESCE($4, unit),
            image_url = COALESCE($5, image_url),
            description = COALESCE($6, description),
            category_id = COALESCE($7, category_id)
          WHERE id = $8
        `, [
          details.name || null,
          price !== undefined ? Number(price) : details.price !== undefined ? Number(details.price) : null,
          inventory !== undefined ? Number(inventory) : details.inventory !== undefined ? Number(details.inventory) : null,
          details.unit || null,
          details.image || null,
          details.description || null,
          details.category || null,
          id
        ]);
      } else {
        await dbQuery(
          "UPDATE products SET price = COALESCE($1, price), inventory_count = COALESCE($2, inventory_count) WHERE id = $3",
          [price !== undefined ? Number(price) : null, inventory !== undefined ? Number(inventory) : null, id]
        );
      }
      return this.findById(id);
    }
    const item = DB_STATE.products.find((p) => p.id === id);
    if (item) {
      if (price !== undefined) item.price = Number(price);
      if (inventory !== undefined) item.inventory = Number(inventory);
      if (details?.name) item.name = details.name;
      if (details?.description) item.description = details.description;
      if (details?.unit) item.unit = details.unit;
      return item as unknown as Product;
    }
    return null;
  }

  static async deleteProduct(id: string): Promise<boolean> {
    if (usePostgreSQL) {
      await dbQuery("DELETE FROM products WHERE id = $1", [id]);
      return true;
    }
    const index = DB_STATE.products.findIndex((p) => p.id === id);
    if (index !== -1) {
      DB_STATE.products.splice(index, 1);
      return true;
    }
    return false;
  }

  // Stock Movement & Inventory
  static async recordStockMovement(movement: StockMovement): Promise<void> {
    const storeId = movement.storeId || 's1';
    if (usePostgreSQL) {
      await dbQuery(`
        INSERT INTO stock_movements (store_id, product_id, variant_id, movement_type, quantity, reason, notes, created_by)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      `, [
        storeId, movement.productId, movement.variantId || null, movement.movementType,
        movement.quantity, movement.reason || '', movement.notes || '', movement.createdBy || 'Store Manager'
      ]);

      // Adjust main product inventory or store_inventory
      if (movement.movementType === 'receive' || movement.movementType === 'adjustment') {
        await dbQuery("UPDATE products SET inventory_count = inventory_count + $1 WHERE id = $2", [movement.quantity, movement.productId]);
      } else if (['damage', 'expired', 'move'].includes(movement.movementType)) {
        await dbQuery("UPDATE products SET inventory_count = GREATEST(0, inventory_count - $1) WHERE id = $2", [Math.abs(movement.quantity), movement.productId]);
      } else if (movement.movementType === 'cycle_count') {
        await dbQuery("UPDATE products SET inventory_count = $1 WHERE id = $2", [movement.quantity, movement.productId]);
      }
    } else {
      const prod = DB_STATE.products.find((p) => p.id === movement.productId);
      if (prod) {
        if (movement.movementType === 'receive') prod.inventory += movement.quantity;
        else if (['damage', 'expired', 'move'].includes(movement.movementType)) prod.inventory = Math.max(0, prod.inventory - movement.quantity);
        else if (movement.movementType === 'cycle_count') prod.inventory = movement.quantity;
      }
    }
  }

  static async getStockMovements(storeId: string = 's1'): Promise<any[]> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT sm.id, sm.store_id as "storeId", sm.product_id as "productId", p.name as "productName", sm.movement_type as "movementType", sm.quantity, sm.reason, sm.notes, sm.created_by as "createdBy", sm.created_at as "createdAt"
        FROM stock_movements sm
        LEFT JOIN products p ON sm.product_id = p.id
        WHERE sm.store_id = $1 ORDER BY sm.created_at DESC LIMIT 50
      `, [storeId]);
      return rows;
    }
    return [];
  }

  static async getLowStockAlerts(storeId: string = 's1', threshold: number = 15): Promise<Product[]> {
    const all = await this.getAll();
    return all.products.filter((p) => p.inventory <= threshold);
  }

  // Recently Viewed Products
  static async addRecentlyViewed(userId: string, productId: string): Promise<void> {
    if (usePostgreSQL) {
      try {
        await dbQuery(`
          INSERT INTO recently_viewed_products (user_id, product_id, viewed_at)
          VALUES ($1, $2, CURRENT_TIMESTAMP)
          ON CONFLICT (user_id, product_id) DO UPDATE SET viewed_at = CURRENT_TIMESTAMP
        `, [userId, productId]);
      } catch (e) {
        console.warn("Could not save recently viewed:", e);
      }
    }
  }

  static async getRecentlyViewed(userId: string): Promise<Product[]> {
    if (usePostgreSQL) {
      try {
        const { rows } = await dbQuery(`
          SELECT p.id, p.name, p.category_id as category, p.price, p.original_price as "originalPrice", p.unit, p.image_url as image, p.rating, p.reviews_count as "reviewsCount", p.calories, p.protein_g as protein, p.is_organic as "isOrganic", p.is_healthy as "isHealthy", p.eco_score as "ecoScore", p.carbon_emission_kg as "carbonEmission", p.inventory_count as inventory, p.delivery_time_mins as "deliveryTimeMins", p.description
          FROM recently_viewed_products r
          JOIN products p ON r.product_id = p.id
          WHERE r.user_id = $1
          ORDER BY r.viewed_at DESC LIMIT 10
        `, [userId]);
        return rows.map((r) => ({
          ...r,
          price: Number(r.price),
          originalPrice: r.originalPrice ? Number(r.originalPrice) : undefined,
          rating: Number(r.rating),
          protein: Number(r.protein),
          carbonEmission: Number(r.carbonEmission),
          inventory: Number(r.inventory),
          deliveryTimeMins: Number(r.deliveryTimeMins),
        }));
      } catch (e) {
        console.warn("Error getting recently viewed", e);
      }
    }
    return (await this.getAll()).products.slice(0, 5);
  }
}

