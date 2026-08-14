import { dbPool, dbQuery, usePostgreSQL } from "../config/database";
import { DB_STATE } from "../config/dbState";

export interface OrderItem {
  product: {
    id: string;
    name: string;
    price: number;
    unit?: string;
    image?: string;
    rating?: number;
    reviewsCount?: number;
    calories?: number;
    protein?: number;
    ecoScore?: string;
    carbonEmission?: number;
    inventoryCount?: number;
    deliveryTimeMins?: number;
  };
  quantity: number;
  addedBy?: string;
}

export interface OrderTimelineEvent {
  status: string;
  title: string;
  timestamp: string;
  completed: boolean;
  notes?: string;
}

export interface Order {
  id: string;
  userId: string;
  items: OrderItem[];
  subtotal: number;
  deliveryFee: number;
  discount: number;
  tax: number;
  platformFee: number;
  packingCharge: number;
  total: number;
  status: string;
  createdAt: string;
  deliveryAddress: string;
  paymentMethod: string;
  paymentStatus: string;
  trackingStep: number;
  estimatedDeliveryTime: string;
  customerName?: string;
  customerEmail?: string;
  notes?: string;
  isGift?: boolean;
  giftMessage?: string;
  scheduledTime?: string;
  invoiceNumber?: string;
  timeline?: OrderTimelineEvent[];
}

/**
 * Normalize every order status before storing it in PostgreSQL.
 *
 * API/UI can send:
 * PLACED
 * placed
 * OUT_FOR_DELIVERY
 * OUT FOR DELIVERY
 *
 * Database always receives:
 * placed
 * out_for_delivery
 */
export function normalizeOrderStatus(status: string): string {
  const normalized = String(status || "")
    .trim()
    .toUpperCase()
    .replace(/\s+/g, "_");

  const statusMap: Record<string, string> = {
    PLACED: "placed",
    PENDING: "placed",

    CONFIRMED: "confirmed",
    ACCEPTED: "confirmed",

    PICKING: "picking",

    PACKING: "packing",
    PACKED: "packed",

    READY_FOR_PICKUP: "ready_for_pickup",

    OUT_FOR_DELIVERY: "out_for_delivery",

    DELIVERED: "delivered",

    CANCELLED: "cancelled",

    RETURNED: "returned",

    REFUNDED: "refunded",
  };

  return (
    statusMap[normalized] ||
    normalized.toLowerCase()
  );
}

/**
 * Convert an order status into the tracking step
 * used by the mobile application.
 */
export function getTrackingStepForStatus(
  status: string
): number {
  const s = String(status || "")
    .trim()
    .toUpperCase()
    .replace(/\s+/g, "_");

  switch (s) {
    case "PLACED":
    case "PENDING":
      return 1;

    case "CONFIRMED":
    case "ACCEPTED":
      return 2;

    case "PICKING":
      return 3;

    case "PACKING":
    case "PACKED":
      return 4;

    case "READY_FOR_PICKUP":
      return 5;

    case "OUT_FOR_DELIVERY":
      return 6;

    case "DELIVERED":
      return 7;

    default:
      return 0;
  }
}

/**
 * Build order timeline.
 */
export function buildTimeline(
  currentStatus: string,
  createdAtDateStr?: string
): OrderTimelineEvent[] {
  const normalizedStatus =
    normalizeOrderStatus(currentStatus);

  const currentStep =
    getTrackingStepForStatus(normalizedStatus);

  const now = new Date();

  const timeStr =
    createdAtDateStr ||
    now.toLocaleTimeString([], {
      hour: "2-digit",
      minute: "2-digit",
    });

  const steps = [
    {
      status: "placed",
      title: "Order Placed & Verified",
      notes: "Received by FlashCart AI Engine",
    },
    {
      status: "confirmed",
      title: "Order Confirmed",
      notes: "Inventory reserved & dark store notified",
    },
    {
      status: "picking",
      title: "Item Picking",
      notes: "Warehouse associate picking items from shelves",
    },
    {
      status: "packing",
      title: "Quality Check & Packing",
      notes: "Items sealed & eco-friendly packed",
    },
    {
      status: "ready_for_pickup",
      title: "Ready for Dispatch",
      notes: "Package staged at fulfillment dock",
    },
    {
      status: "out_for_delivery",
      title: "Out for Express Delivery",
      notes: "Assigned to Suresh Kumar (Elite Rider)",
    },
    {
      status: "delivered",
      title: "Package Delivered",
      notes: "Delivered securely to address",
    },
  ];

  return steps.map((step, index) => {
    const stepNumber = index + 1;

    return {
      status: step.status,
      title: step.title,
      timestamp:
        stepNumber <= currentStep
          ? timeStr
          : "Pending",
      completed:
        stepNumber <= currentStep,
      notes: step.notes,
    };
  });
}

export class OrderRepository {
  /**
   * Get orders belonging ONLY to the logged-in user.
   */
  static async getAll(
    userId: string,
    filters?: {
      status?: string;
      search?: string;
    }
  ): Promise<Order[]> {
    if (usePostgreSQL) {
      try {
        let query = `
          SELECT
            o.id,
            o.user_id AS "userId",
            o.status,
            o.subtotal,
            o.delivery_fee AS "deliveryFee",
            o.discount,
            o.total,
            o.payment_method AS "paymentMethod",
            o.payment_status AS "paymentStatus",
            o.tracking_step AS "trackingStep",
            o.estimated_delivery_time AS "estimatedDeliveryTime",
            o.created_at AS "createdAt",
            o.delivery_address_text AS "deliveryAddressText",
            CONCAT(
              u.first_name,
              ' ',
              u.last_name
            ) AS "customerName",
            u.email AS "customerEmail"
          FROM orders o
          LEFT JOIN users u
            ON o.user_id::text = u.id::text
          WHERE o.user_id::text = $1::text
        `;

        const params: any[] = [userId];

        /**
         * Status filter.
         *
         * Database status is lowercase,
         * but API may send uppercase.
         */
        if (
          filters?.status &&
          filters.status !== "All"
        ) {
          const normalizedStatus =
            normalizeOrderStatus(filters.status);

          query += `
            AND LOWER(o.status) = LOWER($${
              params.length + 1
            })
          `;

          params.push(normalizedStatus);
        }

        /**
         * Search by order ID or customer name.
         */
        if (filters?.search) {
          const paramIndex =
            params.length + 1;

          query += `
            AND (
              o.id ILIKE $${paramIndex}
              OR CONCAT(
                u.first_name,
                ' ',
                u.last_name
              ) ILIKE $${paramIndex}
            )
          `;

          params.push(
            `%${filters.search}%`
          );
        }

        query += `
          ORDER BY o.created_at DESC
        `;

        const { rows } =
          await dbQuery(query, params);

        const result: Order[] = [];

        for (const o of rows) {
          const itemRows =
            await dbQuery(
              `
                SELECT
                  oi.product_id AS id,
                  oi.product_name_snapshot AS name,
                  oi.price_snapshot AS price,
                  oi.quantity,
                  oi.added_by_member AS "addedBy",
                  p.image_url AS "imageUrl",
                  p.unit,
                  p.rating,
                  p.reviews_count AS "reviewsCount",
                  p.calories,
                  p.protein_g AS protein,
                  p.eco_score AS "ecoScore",
                  p.carbon_emission_kg AS "carbonEmission",
                  p.inventory_count AS inventory,
                  p.delivery_time_mins AS "deliveryTimeMins"
                FROM order_items oi
                LEFT JOIN products p
                  ON p.id = oi.product_id
                WHERE oi.order_id = $1
              `,
              [o.id]
            );

          const items: OrderItem[] =
            itemRows.rows.map(
              (item: any) => ({
                product: {
                  id: item.id,
                  name: item.name,
                  price: Number(
                    item.price || 0
                  ),
                  unit:
                    item.unit || "Unit",
                  image:
                    item.imageUrl || "",
                  rating: Number(
                    item.rating || 5
                  ),
                  reviewsCount: Number(
                    item.reviewsCount || 0
                  ),
                  calories: Number(
                    item.calories || 0
                  ),
                  protein: Number(
                    item.protein || 0
                  ),
                  ecoScore:
                    item.ecoScore || "A",
                  carbonEmission:
                    Number(
                      item.carbonEmission || 0
                    ),
                  inventoryCount:
                    Number(
                      item.inventory || 0
                    ),
                  deliveryTimeMins:
                    Number(
                      item.deliveryTimeMins || 9
                    ),
                },

                quantity: Number(
                  item.quantity || 0
                ),

                addedBy:
                  item.addedBy || "Self",
              })
            );

          const status =
            normalizeOrderStatus(
              o.status || "placed"
            );

          const subtotal = Number(
            o.subtotal || 0
          );

          const deliveryFee = Number(
            o.deliveryFee || 0
          );

          const discount = Number(
            o.discount || 0
          );

          const total = Number(
            o.total ||
              subtotal +
                deliveryFee -
                discount
          );

          const createdAt =
            new Date(o.createdAt);

          const createdTime =
            createdAt.toLocaleTimeString(
              [],
              {
                hour: "2-digit",
                minute: "2-digit",
              }
            );

          result.push({
            id: o.id,

            userId:
              o.userId || userId,

            items,

            subtotal,

            deliveryFee,

            discount,

            tax: Math.round(
              subtotal * 0.05
            ),

            platformFee: 5,

            packingCharge: 10,

            total,

            status,

            createdAt:
              createdAt.toISOString(),

            deliveryAddress:
              o.deliveryAddressText ||
              "Symphony Premium Apts, Koramangala 3rd Block, Bangalore",

            paymentMethod:
              o.paymentMethod ||
              "Wallet Pay",

            paymentStatus:
              o.paymentStatus ||
              "completed",

            trackingStep:
              getTrackingStepForStatus(
                status
              ),

            estimatedDeliveryTime:
              o.estimatedDeliveryTime ||
              "9 Mins",

            customerName:
              o.customerName ||
              "Arav Sharma",

            customerEmail:
              o.customerEmail ||
              "arav@flashcart.ai",

            invoiceNumber:
              `INV-${o.id}`,

            timeline:
              buildTimeline(
                status,
                createdTime
              ),
          });
        }

        return result;
      } catch (err) {
        console.error(
          "Error in OrderRepository.getAll from PostgreSQL:",
          err
        );

        throw err;
      }
    }

    /**
     * In-memory fallback.
     */
    const allOrders: Order[] = [
      ...(DB_STATE.orders || []),
    ];

    if (
      DB_STATE.activeOrder &&
      !allOrders.find(
        (o) =>
          o.id ===
          DB_STATE.activeOrder?.id
      )
    ) {
      allOrders.unshift(
        DB_STATE.activeOrder as Order
      );
    }

    let filteredOrders =
      allOrders.filter(
        (o) =>
          o.userId === userId
      );

    if (
      filters?.status &&
      filters.status !== "All"
    ) {
      const normalizedStatus =
        normalizeOrderStatus(
          filters.status
        );

      filteredOrders =
        filteredOrders.filter(
          (o) =>
            normalizeOrderStatus(
              o.status
            ) === normalizedStatus
        );
    }

    if (filters?.search) {
      const search =
        filters.search.toLowerCase();

      filteredOrders =
        filteredOrders.filter(
          (o) =>
            o.id
              .toLowerCase()
              .includes(search) ||
            o.customerName
              ?.toLowerCase()
              .includes(search)
        );
    }

    return filteredOrders;
  }

  /**
   * Alias used by controller/service.
   */
  static async getOrders(
    userId: string,
    filters?: {
      status?: string;
      search?: string;
    }
  ): Promise<Order[]> {
    return this.getAll(
      userId,
      filters
    );
  }

  /**
   * Get one order belonging to the user.
   */
  static async getById(
    userId: string,
    orderId: string
  ): Promise<Order | null> {
    const all =
      await this.getAll(userId);

    const found = all.find(
      (o) =>
        o.id === orderId &&
        o.userId === userId
    );

    if (found) {
      return found;
    }

    return null;
  }

  /**
   * Alias used by controller/service.
   */
  static async getOrderById(
    userId: string,
    orderId: string
  ): Promise<Order | null> {
    return this.getById(
      userId,
      orderId
    );
  }

  /**
   * Get current active order.
   */
  static async getActive(
    userId: string
  ): Promise<Order | null> {
    if (usePostgreSQL) {
      const all =
        await this.getAll(userId);

      const active =
        all.find(
          (order) =>
            ![
              "delivered",
              "cancelled",
              "returned",
              "refunded",
            ].includes(
              order.status.toLowerCase()
            )
        );

      return active || null;
    }

    if (
      DB_STATE.activeOrder &&
      DB_STATE.activeOrder.userId ===
        userId
    ) {
      return DB_STATE.activeOrder as Order;
    }

    return null;
  }

  /**
   * Alias used by controller/service.
   */
  static async getActiveOrder(
    userId: string
  ): Promise<Order | null> {
    return this.getActive(userId);
  }

  /**
   * Create/place an order.
   */
  static async create(
    userId: string,
    orderData: {
      items: OrderItem[];
      subtotal: number;
      deliveryFee: number;
      discount?: number;
      total: number;
      paymentMethod: string;
      deliveryAddress?: string;
      notes?: string;
      isGift?: boolean;
      giftMessage?: string;
      scheduledTime?: string;
    }
  ): Promise<Order> {
    const orderId =
      "FC-" +
      Math.random()
        .toString(36)
        .substring(2, 9)
        .toUpperCase();

    const subtotal =
      Number(orderData.subtotal) || 0;

    const deliveryFee =
      Number(orderData.deliveryFee) || 0;

    const discount =
      Number(orderData.discount) || 0;

    const tax =
      Math.round(subtotal * 0.05);

    const platformFee = 5;

    const packingCharge = 10;

    const total =
      Number(orderData.total) ||
      subtotal +
        deliveryFee -
        discount;

    const paymentMethod =
      orderData.paymentMethod ||
      "Wallet Pay";

    const addressStr =
      orderData.deliveryAddress ||
      "Symphony Premium Apts, Koramangala 3rd Block, Bangalore";

    if (usePostgreSQL && dbPool) {
      const client =
        await dbPool.connect();

      try {
        await client.query(
          "BEGIN"
        );

        /**
         * Verify wallet balance.
         */
        if (
          paymentMethod
            .toLowerCase()
            .includes("wallet")
        ) {
          const userRes =
            await client.query(
              `
                SELECT wallet_balance
                FROM users
                WHERE id::text = $1::text
              `,
              [userId]
            );

          if (
            userRes.rows.length === 0
          ) {
            throw new Error(
              "User not found"
            );
          }

          const balance =
            Number(
              userRes.rows[0]
                ?.wallet_balance || 0
            );

          if (balance < total) {
            throw new Error(
              "Insufficient wallet balance"
            );
          }

          await client.query(
            `
              UPDATE users
              SET wallet_balance =
                wallet_balance - $1
              WHERE id::text = $2::text
            `,
            [total, userId]
          );
        }

        /**
         * Find user's address.
         */
        const addrRes =
          await client.query(
            `
              SELECT id
              FROM addresses
              WHERE user_id::text =
                $1::text
              LIMIT 1
            `,
            [userId]
          );

        const addressId =
          addrRes.rows[0]?.id ||
          null;

        /**
         * IMPORTANT:
         * PostgreSQL receives LOWERCASE
         * "placed".
         */
        await client.query(
          `
            INSERT INTO orders (
              id,
              user_id,
              status,
              subtotal,
              delivery_fee,
              discount,
              total,
              delivery_address_id,
              delivery_address_text,
              payment_method,
              payment_status,
              tracking_step,
              estimated_delivery_time
            )
            VALUES (
              $1,
              $2,
              'placed',
              $3,
              $4,
              $5,
              $6,
              $7,
              $8,
              $9,
              'completed',
              1,
              '9 Mins'
            )
          `,
          [
            orderId,
            userId,
            subtotal,
            deliveryFee,
            discount,
            total,
            addressId,
            addressStr,
            paymentMethod,
          ]
        );

        /**
         * Add order items and reduce inventory.
         */
        for (
          const item of orderData.items
        ) {
          await client.query(
            `
              INSERT INTO order_items (
                order_id,
                product_id,
                product_name_snapshot,
                price_snapshot,
                quantity,
                added_by_member
              )
              VALUES (
                $1,
                $2,
                $3,
                $4,
                $5,
                $6
              )
            `,
            [
              orderId,
              item.product.id,
              item.product.name,
              item.product.price,
              item.quantity,
              item.addedBy ||
                "Self",
            ]
          );

          await client.query(
            `
              UPDATE products
              SET inventory_count =
                GREATEST(
                  0,
                  inventory_count - $1
                )
              WHERE id = $2
            `,
            [
              item.quantity,
              item.product.id,
            ]
          );
        }

        /**
         * Log payment.
         */
        await client.query(
          `
            INSERT INTO payments (
              order_id,
              user_id,
              amount,
              payment_method,
              status,
              transaction_id
            )
            VALUES (
              $1,
              $2,
              $3,
              $4,
              'completed',
              $5
            )
          `,
          [
            orderId,
            userId,
            total,
            paymentMethod,
            "TXN-" +
              Math.random()
                .toString(36)
                .substring(2, 8)
                .toUpperCase(),
          ]
        );

        /**
         * Assign delivery.
         */
        await client.query(
          `
            INSERT INTO deliveries (
              order_id,
              rider_name,
              rider_phone,
              current_latitude,
              current_longitude,
              status,
              rating
            )
            VALUES (
              $1,
              'Suresh Kumar',
              '+91 98765 43210',
              12.9279,
              77.6250,
              'assigned',
              4.95
            )
          `,
          [orderId]
        );

        /**
         * Empty cart.
         */
        await client.query(
          `
            DELETE FROM cart_items
            WHERE user_id::text =
              $1::text
          `,
          [userId]
        );

        await client.query(
          "COMMIT"
        );
      } catch (txnErr) {
        await client.query(
          "ROLLBACK"
        );

        console.error(
          "Order creation transaction failed:",
          txnErr
        );

        throw txnErr;
      } finally {
        client.release();
      }
    } else {
      /**
       * In-memory fallback.
       */
      if (
        paymentMethod
          .toLowerCase()
          .includes("wallet")
      ) {
        if (
          DB_STATE.walletBalance <
          total
        ) {
          throw new Error(
            "Insufficient wallet balance"
          );
        }

        DB_STATE.walletBalance -=
          total;
      }

      for (
        const item of orderData.items
      ) {
        const prod =
          DB_STATE.products.find(
            (p) =>
              p.id ===
              item.product.id
          );

        if (prod) {
          prod.inventory =
            Math.max(
              0,
              prod.inventory -
                item.quantity
            );
        }
      }

      DB_STATE.cart = [];
    }

    const createdAt =
      new Date();

    const createdTimeStr =
      createdAt.toLocaleTimeString(
        [],
        {
          hour: "2-digit",
          minute: "2-digit",
        }
      );

    const orderObj: Order = {
      id: orderId,

      userId,

      items:
        orderData.items,

      subtotal,

      deliveryFee,

      discount,

      tax,

      platformFee,

      packingCharge,

      total,

      status: "placed",

      createdAt:
        createdAt.toISOString(),

      deliveryAddress:
        addressStr,

      paymentMethod,

      paymentStatus:
        "completed",

      trackingStep: 1,

      estimatedDeliveryTime:
        "9 Mins",

      customerName:
        "Arav Sharma",

      customerEmail:
        "arav@flashcart.ai",

      notes:
        orderData.notes,

      isGift:
        orderData.isGift,

      giftMessage:
        orderData.giftMessage,

      scheduledTime:
        orderData.scheduledTime,

      invoiceNumber:
        `INV-${orderId}`,

      timeline:
        buildTimeline(
          "placed",
          createdTimeStr
        ),
    };

    DB_STATE.activeOrder =
      orderObj;

    if (!DB_STATE.orders) {
      DB_STATE.orders = [];
    }

    DB_STATE.orders.unshift(
      orderObj
    );

    return orderObj;
  }

  /**
   * Alias used by service/controller.
   */
  static async placeOrder(
    userId: string,
    items: OrderItem[],
    subtotal: number,
    deliveryFee: number,
    total: number,
    paymentMethod: string,
    options?: {
      deliveryAddress?: string;
      notes?: string;
      isGift?: boolean;
      giftMessage?: string;
      scheduledTime?: string;
      discount?: number;
    }
  ): Promise<Order> {
    return this.create(
      userId,
      {
        items,
        subtotal,
        deliveryFee,
        discount:
          options?.discount || 0,
        total,
        paymentMethod,
        deliveryAddress:
          options?.deliveryAddress,
        notes:
          options?.notes,
        isGift:
          options?.isGift,
        giftMessage:
          options?.giftMessage,
        scheduledTime:
          options?.scheduledTime,
      }
    );
  }

  /**
   * Update order status.
   */
  static async updateStatus(
    userId: string,
    orderId: string,
    status: string,
    notes?: string
  ): Promise<Order | null> {
    const normalizedStatus =
      normalizeOrderStatus(
        status
      );

    const trackingStep =
      getTrackingStepForStatus(
        normalizedStatus
      );

    if (usePostgreSQL) {
      await dbQuery(
        `
          UPDATE orders
          SET
            status = $1,
            tracking_step = $2,
            updated_at = NOW()
          WHERE id = $3
            AND user_id::text =
              $4::text
        `,
        [
          normalizedStatus,
          trackingStep,
          orderId,
          userId,
        ]
      );
    }

    const order =
      await this.getById(
        userId,
        orderId
      );

    if (order) {
      order.status =
        normalizedStatus;

      order.trackingStep =
        trackingStep;

      order.timeline =
        buildTimeline(
          normalizedStatus
        );

      if (notes) {
        order.notes = notes;
      }

      if (
        [
          "delivered",
          "cancelled",
          "returned",
          "refunded",
        ].includes(
          normalizedStatus
        )
      ) {
        if (
          DB_STATE.activeOrder &&
          DB_STATE.activeOrder
            .id === orderId
        ) {
          DB_STATE.activeOrder =
            null;
        }
      } else {
        DB_STATE.activeOrder =
          order;
      }
    }

    return order;
  }

  /**
   * Alias used by service/controller.
   */
  static async updateOrderStatus(
    userId: string,
    orderId: string,
    status: string,
    notes?: string
  ): Promise<Order | null> {
    return this.updateStatus(
      userId,
      orderId,
      status,
      notes
    );
  }

  /**
   * Cancel order.
   */
  static async cancel(
    userId: string,
    orderId: string,
    reason?: string
  ): Promise<{
    success: boolean;
    message: string;
  }> {
    const order =
      await this.getById(
        userId,
        orderId
      );

    if (!order) {
      throw new Error(
        "Order not found"
      );
    }

    if (
      [
        "delivered",
        "cancelled",
        "returned",
        "refunded",
      ].includes(
        order.status.toLowerCase()
      )
    ) {
      throw new Error(
        `Order cannot be cancelled in state ${order.status}`
      );
    }

    /**
     * Refund wallet.
     */
    if (
      order.paymentMethod
        .toLowerCase()
        .includes("wallet")
    ) {
      if (usePostgreSQL) {
        await dbQuery(
          `
            UPDATE users
            SET wallet_balance =
              wallet_balance + $1
            WHERE id::text =
              $2::text
          `,
          [
            order.total,
            userId,
          ]
        );
      } else {
        DB_STATE.walletBalance +=
          order.total;
      }
    }

    /**
     * Restock inventory.
     */
    for (
      const item of order.items
    ) {
      if (usePostgreSQL) {
        await dbQuery(
          `
            UPDATE products
            SET inventory_count =
              inventory_count + $1
            WHERE id = $2
          `,
          [
            item.quantity,
            item.product.id,
          ]
        );
      } else {
        const prod =
          DB_STATE.products.find(
            (p) =>
              p.id ===
              item.product.id
          );

        if (prod) {
          prod.inventory +=
            item.quantity;
        }
      }
    }

    await this.updateStatus(
      userId,
      orderId,
      "cancelled",
      reason ||
        "Cancelled by customer"
    );

    return {
      success: true,
      message:
        `Order ${orderId} cancelled successfully`,
    };
  }

  /**
   * Alias used by service/controller.
   */
  static async cancelOrder(
    userId: string,
    orderId: string,
    reason?: string
  ) {
    return this.cancel(
      userId,
      orderId,
      reason
    );
  }

  /**
   * Delete order.
   */
  static async delete(
    orderId: string
  ): Promise<{
    success: boolean;
    message: string;
  }> {
    if (usePostgreSQL) {
      try {
        await dbQuery(
          `
            DELETE FROM order_items
            WHERE order_id = $1
          `,
          [orderId]
        );

        await dbQuery(
          `
            DELETE FROM deliveries
            WHERE order_id = $1
          `,
          [orderId]
        );

        await dbQuery(
          `
            DELETE FROM payments
            WHERE order_id = $1
          `,
          [orderId]
        );

        await dbQuery(
          `
            DELETE FROM orders
            WHERE id = $1
          `,
          [orderId]
        );
      } catch (e) {
        console.error(
          "Error deleting order from PostgreSQL:",
          e
        );

        throw e;
      }
    }

    if (DB_STATE.orders) {
      DB_STATE.orders =
        DB_STATE.orders.filter(
          (o) =>
            o.id !== orderId
        );
    }

    if (
      DB_STATE.activeOrder &&
      DB_STATE.activeOrder.id ===
        orderId
    ) {
      DB_STATE.activeOrder =
        null;
    }

    return {
      success: true,
      message:
        `Order ${orderId} deleted successfully`,
    };
  }

  /**
   * Alias used by service/controller.
   */
  static async deleteOrder(
    userId: string,
    orderId: string
  ) {
    const order =
      await this.getById(
        userId,
        orderId
      );

    if (!order) {
      throw new Error(
        "Order not found"
      );
    }

    return this.delete(
      orderId
    );
  }

  /**
   * Modify order.
   */
  static async modify(
    userId: string,
    orderId: string,
    updateData: {
      deliveryAddress?: string;
      notes?: string;
    }
  ): Promise<Order | null> {
    const order =
      await this.getById(
        userId,
        orderId
      );

    if (!order) {
      throw new Error(
        "Order not found"
      );
    }

    if (
      [
        "packing",
        "ready_for_pickup",
        "out_for_delivery",
        "delivered",
        "cancelled",
      ].includes(
        order.status.toLowerCase()
      )
    ) {
      throw new Error(
        "Order cannot be modified after packing has started"
      );
    }

    if (
      updateData.deliveryAddress
    ) {
      order.deliveryAddress =
        updateData.deliveryAddress;
    }

    if (updateData.notes) {
      order.notes =
        updateData.notes;
    }

    if (usePostgreSQL) {
      await dbQuery(
        `
          UPDATE orders
          SET
            delivery_address_text =
              COALESCE(
                $1,
                delivery_address_text
              )
          WHERE id = $2
            AND user_id::text =
              $3::text
        `,
        [
          updateData.deliveryAddress ||
            null,
          orderId,
          userId,
        ]
      );
    }

    return order;
  }

  /**
   * Alias used by service/controller.
   */
  static async modifyOrder(
    userId: string,
    orderId: string,
    updateData: {
      deliveryAddress?: string;
      notes?: string;
    }
  ) {
    return this.modify(
      userId,
      orderId,
      updateData
    );
  }

  /**
   * Clear active order.
   */
  static async clearActive(): Promise<void> {
    DB_STATE.activeOrder =
      null;
  }

  /**
   * Alias.
   */
  static async cancelActiveOrder(
    userId: string
  ): Promise<void> {
    const active =
      await this.getActive(
        userId
      );

    if (active) {
      await this.cancel(
        userId,
        active.id,
        "Active order cancelled"
      );
    } else {
      DB_STATE.activeOrder =
        null;
    }
  }

  /**
   * Repeat order.
   */
  static async repeatOrder(
    userId: string,
    orderId: string
  ) {
    const order =
      await this.getById(
        userId,
        orderId
      );

    if (!order) {
      throw new Error(
        "Order not found"
      );
    }

    return {
      success: true,
      items: order.items,
      message:
        "Order items ready to reorder",
    };
  }

  /**
   * Order timeline.
   */
  static async getOrderTimeline(
    userId: string,
    orderId: string
  ) {
    const order =
      await this.getById(
        userId,
        orderId
      );

    if (!order) {
      throw new Error(
        "Order not found"
      );
    }

    return (
      order.timeline ||
      buildTimeline(
        order.status,
        new Date(
          order.createdAt
        ).toLocaleTimeString(
          [],
          {
            hour: "2-digit",
            minute: "2-digit",
          }
        )
      )
    );
  }

  /**
   * Invoice.
   */
  static async getOrderInvoice(
    userId: string,
    orderId: string
  ) {
    const order =
      await this.getById(
        userId,
        orderId
      );

    if (!order) {
      throw new Error(
        "Order not found"
      );
    }

    return {
      invoiceNumber:
        order.invoiceNumber ||
        `INV-${order.id}`,

      orderId:
        order.id,

      customerName:
        order.customerName,

      customerEmail:
        order.customerEmail,

      items:
        order.items,

      subtotal:
        order.subtotal,

      deliveryFee:
        order.deliveryFee,

      discount:
        order.discount,

      tax:
        order.tax,

      platformFee:
        order.platformFee,

      packingCharge:
        order.packingCharge,

      total:
        order.total,

      paymentMethod:
        order.paymentMethod,

      paymentStatus:
        order.paymentStatus,

      deliveryAddress:
        order.deliveryAddress,

      createdAt:
        order.createdAt,
    };
  }

  /**
   * Eligibility.
   */
  static async getOrderEligibility(
    userId: string,
    orderId: string
  ) {
    const order =
      await this.getById(
        userId,
        orderId
      );

    if (!order) {
      throw new Error(
        "Order not found"
      );
    }

    const status =
      order.status.toLowerCase();

    return {
      orderId,

      canCancel: ![
        "delivered",
        "cancelled",
        "returned",
        "refunded",
      ].includes(status),

      canModify: ![
        "packing",
        "ready_for_pickup",
        "out_for_delivery",
        "delivered",
        "cancelled",
      ].includes(status),

      canRepeat: true,
    };
  }
}