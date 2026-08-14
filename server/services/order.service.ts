import { OrderRepository, Order, OrderItem, buildTimeline } from "../repositories/order.repository";
import { UserRepository } from "../repositories/user.repository";
import { ActivityRepository } from "../repositories/activity.repository";
import { CartRepository } from "../repositories/cart.repository";
import { SocketService } from "./socket.service";
import { NotificationService } from "./notification.service";

export class OrderService {
  static async getOrders(userId?: string, filters?: { status?: string; search?: string }): Promise<Order[]> {
    return OrderRepository.getAll(userId, filters);
  }

  static async getOrderById(userId: string | undefined, orderId: string): Promise<Order | null> {
    return OrderRepository.getById(userId, orderId);
  }

  static async getActiveOrder(userId?: string): Promise<Order | null> {
    return OrderRepository.getActive(userId);
  }

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
    const order = await OrderRepository.create(userId, {
      items,
      subtotal,
      deliveryFee,
      discount: options?.discount || 0,
      total,
      paymentMethod,
      deliveryAddress: options?.deliveryAddress,
      notes: options?.notes,
      isGift: options?.isGift,
      giftMessage: options?.giftMessage,
      scheduledTime: options?.scheduledTime
    });

    const user = await UserRepository.getProfile(userId);
    await ActivityRepository.log(
      user.id,
      "order_placed",
      `Successfully placed order ${order.id} for total ₹${total} using ${paymentMethod}`
    );

    // Notify WebSockets about order creation
    SocketService.emitToAll("order_placed", {
      orderId: order.id,
      total: order.total,
      status: order.status,
      itemsCount: items.reduce((acc, it) => acc + it.quantity, 0),
      createdAt: order.createdAt,
    });

    // Module 8 Notification Platform Dispatch
    await NotificationService.send({
      userId: user.id || "u1",
      role: "CUSTOMER",
      templateCode: "ORDER_PLACED",
      category: "ORDER",
      params: {
        orderId: order.id,
        amount: total,
        storeName: "Koramangala Dark Store",
      },
      metadata: { orderId: order.id, total, status: order.status },
    });

    // Notify Store Manager
    await NotificationService.send({
      userId: "store1",
      role: "STORE_MANAGER",
      templateCode: "STORE_NEW_ORDER",
      category: "INVENTORY",
      params: {
        orderId: order.id,
        itemCount: items.length,
      },
      metadata: { orderId: order.id },
    });

    return order;
  }

  static async cancelOrder(userId: string, orderId: string, reason?: string): Promise<{ success: boolean; message: string }> {
    const res = await OrderRepository.cancel(userId, orderId, reason);
    const user = await UserRepository.getProfile(userId);
    await ActivityRepository.log(user.id, "order_cancelled", `Cancelled order ${orderId}: ${reason || 'Customer request'}`);

    SocketService.emitToAll("order_cancelled", {
      orderId,
      message: `Order ${orderId} was cancelled.`,
    });

    await NotificationService.send({
      userId: user.id || "u1",
      role: "CUSTOMER",
      title: "Order Cancelled ❌",
      body: `Your order #${orderId} was cancelled. Reason: ${reason || 'Customer request'}. Any paid amount will be refunded to your wallet.`,
      category: "ORDER",
      metadata: { orderId, reason },
    });

    return res;
  }

  static async modifyOrder(userId: string, orderId: string, updateData: { deliveryAddress?: string; notes?: string }): Promise<Order | null> {
    const order = await OrderRepository.modify(userId, orderId, updateData);
    if (order) {
      SocketService.emitToAll("order_updated", {
        orderId: order.id,
        deliveryAddress: order.deliveryAddress,
        notes: order.notes
      });
    }
    return order;
  }

  static async repeatOrder(userId: string, orderId: string): Promise<{ success: boolean; itemsAdded: number }> {
    const order = await OrderRepository.getById(userId, orderId);
    if (!order) throw new Error("Original order not found");

    let count = 0;
    for (const item of order.items) {
      await CartRepository.addItem(userId, item.product.id, item.quantity, item.addedBy || "Self");
      count += item.quantity;
    }

    return { success: true, itemsAdded: count };
  }

  static async getOrderTimeline(userId: string, orderId: string) {
    const order = await OrderRepository.getById(userId, orderId);
    if (!order) throw new Error("Order not found");
    return order.timeline || buildTimeline(order.status);
  }

  static async getOrderInvoice(userId: string, orderId: string) {
    const order = await OrderRepository.getById(userId, orderId);
    if (!order) throw new Error("Order not found");

    return {
      invoiceNumber: order.invoiceNumber || `INV-${order.id}`,
      invoiceDate: new Date(order.createdAt).toLocaleDateString(),
      seller: {
        name: "FLASHCART AI INC.",
        address: "HQ Central Hub, Koramangala 3rd Sector, Bangalore",
        gstin: "29AABCX9481A1Z0"
      },
      customer: {
        name: order.customerName || "Arav Sharma",
        email: order.customerEmail || "arav@flashcart.ai",
        address: order.deliveryAddress
      },
      items: order.items.map(i => ({
        id: i.product.id,
        name: i.product.name,
        quantity: i.quantity,
        unitPrice: i.product.price,
        totalPrice: i.quantity * i.product.price
      })),
      subtotal: order.subtotal,
      tax: order.tax,
      discount: order.discount,
      deliveryFee: order.deliveryFee,
      platformFee: order.platformFee,
      packingCharge: order.packingCharge,
      grandTotal: order.total,
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus
    };
  }

  static async getOrderEligibility(userId: string, orderId: string) {
    const order = await OrderRepository.getById(userId, orderId);
    if (!order) throw new Error("Order not found");

    const st = order.status.toUpperCase();
    const canCancel = ['PLACED', 'CONFIRMED', 'PICKING'].includes(st);
    const canReturn = st === 'DELIVERED';
    const canRefund = ['CANCELLED', 'RETURNED'].includes(st) || st === 'DELIVERED';

    return {
      orderId: order.id,
      status: order.status,
      canCancel,
      canReturn,
      canRefund,
      returnWindowExpiryDays: 3,
      cancellationPolicy: "Full refund to original payment source before item packing."
    };
  }

  static async updateOrderStatus(userId: string | undefined, orderId: string, newStatus: string, notes?: string): Promise<Order | null> {
    const updated = await OrderRepository.updateStatus(orderId, newStatus, notes);
    if (updated) {
      SocketService.emitToAll("order_status_changed", {
        orderId: updated.id,
        status: updated.status,
        trackingStep: updated.trackingStep,
        updatedAt: new Date().toISOString()
      });
    }
    return updated;
  }

  static async deleteOrder(userId: string, orderId: string): Promise<{ success: boolean; message: string }> {
    const res = await OrderRepository.delete(userId, orderId);
    SocketService.emitToAll("order_deleted", { orderId });
    return res;
  }

  static async cancelActiveOrder(userId: string): Promise<void> {
    const active = await OrderRepository.getActive(userId);
    if (active) {
      await this.cancelOrder(userId, active.id, "Active order cleared");
    } else {
      await OrderRepository.clearActive();
    }
  }
}
