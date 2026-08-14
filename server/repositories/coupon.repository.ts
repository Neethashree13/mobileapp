import { dbQuery, usePostgreSQL } from "../config/database";

export interface Coupon {
  id: string;
  code: string;
  discount_type: string;
  discount_value: number;
  max_discount?: number;
  min_order_value?: number;
  expires_at: string;
  is_active: boolean;
}

const MEMORY_COUPONS: Coupon[] = [
  {
    id: "c1",
    code: "FLASH50",
    discount_type: "flat_rate",
    discount_value: 50,
    min_order_value: 199,
    expires_at: new Date(Date.now() + 1000 * 60 * 60 * 24 * 30).toISOString(),
    is_active: true,
  },
  {
    id: "c2",
    code: "WELCOME20",
    discount_type: "percentage",
    discount_value: 20,
    max_discount: 100,
    min_order_value: 299,
    expires_at: new Date(Date.now() + 1000 * 60 * 60 * 24 * 60).toISOString(),
    is_active: true,
  },
  {
    id: "c3",
    code: "FREESHIP",
    discount_type: "flat_rate",
    discount_value: 25,
    min_order_value: 149,
    expires_at: new Date(Date.now() + 1000 * 60 * 60 * 24 * 15).toISOString(),
    is_active: true,
  },
];

export class CouponRepository {
  static async getAll(): Promise<Coupon[]> {
    if (usePostgreSQL) {
      try {
        const { rows } = await dbQuery("SELECT * FROM coupons ORDER BY expires_at DESC");
        return rows.map((r) => ({
          id: r.id,
          code: r.code,
          discount_type: r.discount_type,
          discount_value: Number(r.discount_value),
          max_discount: r.max_discount ? Number(r.max_discount) : undefined,
          min_order_value: r.min_order_value ? Number(r.min_order_value) : undefined,
          expires_at: r.expires_at,
          is_active: r.is_active,
        }));
      } catch (err) {
        console.warn("Coupon getAll query error:", err);
      }
    }
    return MEMORY_COUPONS;
  }

  static async findActiveByCode(code: string): Promise<Coupon | null> {
    const formattedCode = code.trim().toUpperCase();
    if (usePostgreSQL) {
      try {
        const { rows } = await dbQuery(
          "SELECT * FROM coupons WHERE UPPER(code) = $1 AND is_active = true AND expires_at > CURRENT_TIMESTAMP",
          [formattedCode]
        );
        if (rows.length === 0) return null;
        const r = rows[0];
        return {
          id: r.id,
          code: r.code,
          discount_type: r.discount_type,
          discount_value: Number(r.discount_value),
          max_discount: r.max_discount ? Number(r.max_discount) : undefined,
          min_order_value: r.min_order_value ? Number(r.min_order_value) : undefined,
          expires_at: r.expires_at,
          is_active: r.is_active,
        };
      } catch (err) {
        console.warn("Coupon findActiveByCode error:", err);
      }
    }

    const found = MEMORY_COUPONS.find(
      (c) => c.code.toUpperCase() === formattedCode && c.is_active && new Date(c.expires_at) > new Date()
    );
    return found || null;
  }

  static async create(coupon: Omit<Coupon, "id">): Promise<Coupon> {
    const formattedCode = coupon.code.trim().toUpperCase();
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        INSERT INTO coupons (code, discount_type, discount_value, max_discount, min_order_value, expires_at, is_active)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING *
      `, [
        formattedCode,
        coupon.discount_type,
        coupon.discount_value,
        coupon.max_discount || null,
        coupon.min_order_value || 0,
        coupon.expires_at,
        coupon.is_active ?? true,
      ]);
      const r = rows[0];
      return {
        id: r.id,
        code: r.code,
        discount_type: r.discount_type,
        discount_value: Number(r.discount_value),
        max_discount: r.max_discount ? Number(r.max_discount) : undefined,
        min_order_value: r.min_order_value ? Number(r.min_order_value) : undefined,
        expires_at: r.expires_at,
        is_active: r.is_active,
      };
    }

    const newCoupon: Coupon = {
      id: `c_${Date.now()}`,
      code: formattedCode,
      ...coupon,
    };
    MEMORY_COUPONS.push(newCoupon);
    return newCoupon;
  }

  static async update(id: string, coupon: Partial<Coupon>): Promise<Coupon | null> {
    if (usePostgreSQL) {
      const updates: string[] = [];
      const values: any[] = [];
      let i = 1;

      if (coupon.code !== undefined) {
        updates.push(`code = $${i++}`);
        values.push(coupon.code.trim().toUpperCase());
      }
      if (coupon.discount_type !== undefined) {
        updates.push(`discount_type = $${i++}`);
        values.push(coupon.discount_type);
      }
      if (coupon.discount_value !== undefined) {
        updates.push(`discount_value = $${i++}`);
        values.push(coupon.discount_value);
      }
      if (coupon.max_discount !== undefined) {
        updates.push(`max_discount = $${i++}`);
        values.push(coupon.max_discount);
      }
      if (coupon.min_order_value !== undefined) {
        updates.push(`min_order_value = $${i++}`);
        values.push(coupon.min_order_value);
      }
      if (coupon.expires_at !== undefined) {
        updates.push(`expires_at = $${i++}`);
        values.push(coupon.expires_at);
      }
      if (coupon.is_active !== undefined) {
        updates.push(`is_active = $${i++}`);
        values.push(coupon.is_active);
      }

      if (updates.length === 0) return null;

      values.push(id);
      const { rows } = await dbQuery(`
        UPDATE coupons SET ${updates.join(", ")}
        WHERE id = $${i}
        RETURNING *
      `, values);

      if (rows.length === 0) return null;
      const r = rows[0];
      return {
        id: r.id,
        code: r.code,
        discount_type: r.discount_type,
        discount_value: Number(r.discount_value),
        max_discount: r.max_discount ? Number(r.max_discount) : undefined,
        min_order_value: r.min_order_value ? Number(r.min_order_value) : undefined,
        expires_at: r.expires_at,
        is_active: r.is_active,
      };
    }

    const index = MEMORY_COUPONS.findIndex((c) => c.id === id);
    if (index === -1) return null;
    MEMORY_COUPONS[index] = { ...MEMORY_COUPONS[index], ...coupon };
    return MEMORY_COUPONS[index];
  }

  static async delete(id: string): Promise<boolean> {
    if (usePostgreSQL) {
      const { rowCount } = await dbQuery("DELETE FROM coupons WHERE id = $1", [id]);
      return (rowCount || 0) > 0;
    }
    const idx = MEMORY_COUPONS.findIndex((c) => c.id === id);
    if (idx !== -1) {
      MEMORY_COUPONS.splice(idx, 1);
      return true;
    }
    return false;
  }
}

