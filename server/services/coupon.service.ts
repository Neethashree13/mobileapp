import { CouponRepository, Coupon } from "../repositories/coupon.repository";

export class CouponService {
  static async getAllCoupons(): Promise<Coupon[]> {
    return CouponRepository.getAll();
  }

  static async validateCoupon(
    code: string,
    subtotal: number
  ): Promise<{ valid: boolean; discount: number; coupon?: Coupon; reason?: string }> {
    if (!code) {
      return { valid: false, discount: 0, reason: "Coupon code is required" };
    }

    const coupon = await CouponRepository.findActiveByCode(code.trim().toUpperCase());
    if (!coupon) {
      return { valid: false, discount: 0, reason: "Coupon is invalid or has expired" };
    }

    if (coupon.min_order_value && subtotal < coupon.min_order_value) {
      return {
        valid: false,
        discount: 0,
        coupon,
        reason: `Minimum order value of ₹${coupon.min_order_value} required for this coupon`,
      };
    }

    let discountAmount = 0;
    if (coupon.discount_type === "percentage") {
      discountAmount = (subtotal * coupon.discount_value) / 100;
      if (coupon.max_discount && discountAmount > coupon.max_discount) {
        discountAmount = coupon.max_discount;
      }
    } else {
      discountAmount = coupon.discount_value;
    }

    if (discountAmount > subtotal) {
      discountAmount = subtotal;
    }

    return {
      valid: true,
      discount: Math.round(discountAmount * 100) / 100,
      coupon,
    };
  }

  static async createCoupon(data: Omit<Coupon, "id">): Promise<Coupon> {
    return CouponRepository.create(data);
  }

  static async updateCoupon(id: string, data: Partial<Coupon>): Promise<Coupon | null> {
    return CouponRepository.update(id, data);
  }

  static async deleteCoupon(id: string): Promise<boolean> {
    return CouponRepository.delete(id);
  }
}

