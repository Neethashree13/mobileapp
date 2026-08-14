import { ProductService } from "../services/product.service";
import { CartService } from "../services/cart.service";
import { CouponService } from "../services/coupon.service";
import { DeliveryService } from "../services/delivery.service";

describe("FlashCart Backend Service Layer Tests", () => {
  beforeEach(() => {
    // Reset DB_STATE mocks if needed
  });

  test("ProductService should retrieve product list and category filters", async () => {
    const dashboard = await ProductService.getDashboardData();
    expect(dashboard).toBeDefined();
    expect(Array.isArray(dashboard.products)).toBe(true);
    expect(dashboard.products.length).toBeGreaterThan(0);
    expect(dashboard.products[0]).toHaveProperty("id");
    expect(dashboard.products[0]).toHaveProperty("name");
    expect(dashboard.products[0]).toHaveProperty("price");
  });

  test("CartService should allow cart state synchronization and retrieval", async () => {
    const sampleCart = [
      {
        product: {
          id: "p1",
          name: "Organic Fresh Bananas",
          category: "veggies",
          price: 69,
          unit: "1 bunch of 5-6 pcs",
          image: "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=120",
          rating: 4.8,
          reviewsCount: 240,
          calories: 105,
          protein: 1.3,
          ecoScore: "A" as const,
          carbonEmission: 0.15,
          inventory: 45,
          deliveryTimeMins: 9,
        },
        quantity: 3,
        addedBy: "Self",
      },
    ];

    const synced = await CartService.syncCart(sampleCart);
    expect(synced).toBeDefined();
    expect(synced.length).toBe(1);
    expect(synced[0].quantity).toBe(3);
    expect(synced[0].product.id).toBe("p1");

    const retrieved = await CartService.getCart();
    expect(retrieved.length).toBe(1);
    expect(retrieved[0].quantity).toBe(3);
  });

  test("CouponService should validate active discount coupons", async () => {
    // FLASH50 validation
    const resultValid = await CouponService.validateCoupon("FLASH50", 400);
    expect(resultValid.valid).toBe(true);
    expect(resultValid.discount).toBe(50);

    // Invalid coupon check
    const resultInvalid = await CouponService.validateCoupon("NOTREAL", 100);
    expect(resultInvalid.valid).toBe(false);
    expect(resultInvalid.discount).toBe(0);
  });

  test("DeliveryService should track live rider status updates", async () => {
    const riderState = await DeliveryService.getRiderState();
    expect(riderState).toBeDefined();
    expect(riderState).toHaveProperty("id");
    expect(riderState).toHaveProperty("name");
    expect(riderState.name).toBe("Suresh Kumar");
    expect(riderState).toHaveProperty("lat");
    expect(riderState).toHaveProperty("lng");
  });
});
