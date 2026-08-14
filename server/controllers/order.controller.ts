import { Request, Response, NextFunction } from "express";
import { OrderService } from "../services/order.service";
import { UserService } from "../services/user.service";
import { isProduction } from "../config/env";
import { usePostgreSQL } from "../config/database";

function getUserIdFromReq(req: Request): string {
  return (
    (req as any).user?.uid ||
    (req as any).user?.id ||
    (req.headers['x-user-id'] as string) ||
    (req.headers['x-user-email'] as string) ||
    (req.query.userId as string) ||
    (req.body?.userId as string) 
  );
}

export async function getOrders(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = getUserIdFromReq(req);
    const status = req.query.status as string;
    const search = req.query.search as string;
    const orders = await OrderService.getOrders(userId, { status, search });
    res.json(orders);
  } catch (error) {
    next(error);
  }
}

export async function getOrderById(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = getUserIdFromReq(req);
    const orderId = req.params.id;
    const order = await OrderService.getOrderById(userId, orderId);
    if (!order) {
      res.status(404).json({ error: "Order not found" });
      return;
    }
    res.json(order);
  } catch (error) {
    next(error);
  }
}

export async function getActiveOrder(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = getUserIdFromReq(req);
    const order = await OrderService.getActiveOrder(userId);
    res.json(order);
  } catch (error) {
    next(error);
  }
}

export async function placeOrder(req: Request, res: Response, next: NextFunction) {
  const { items, subtotal, deliveryFee, discount, total, paymentMethod, deliveryAddress, notes, isGift, giftMessage, scheduledTime } = req.body;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }

    const userId = getUserIdFromReq(req);

    if (items && Array.isArray(items)) {
      for (const item of items) {
        const qty = item.quantity ?? 1;
        const price = item.price ?? item.product?.price ?? 0;
        if (qty <= 0) {
          res.status(400).json({ error: "Item quantity must be greater than 0" });
          return;
        }
        if (price < 0) {
          res.status(400).json({ error: "Item price cannot be negative" });
          return;
        }
      }
    }

    const normalizedItems = (items || []).map((it: any) => {
      if (it.product) return it;
      return {
        product: {
          id: it.productId || "p-unknown",
          name: it.productName || "Item",
          price: Number(it.price || 0),
          unit: it.unit || "1 unit",
          image: it.image || "",
        },
        quantity: Number(it.quantity || 1),
      };
    });

    let addressStr = "";
    if (typeof deliveryAddress === "string") {
      addressStr = deliveryAddress;
    } else if (deliveryAddress && typeof deliveryAddress === "object") {
      addressStr = `${deliveryAddress.house || deliveryAddress.addressLine1 || ""}, ${deliveryAddress.street || deliveryAddress.addressLine2 || ""}, ${deliveryAddress.city || "Bangalore"}`;
    }

    const calcSubtotal = subtotal || normalizedItems.reduce((acc: number, it: any) => acc + (it.product.price * it.quantity), 0);
    const calcDeliveryFee = deliveryFee ?? 25;
    const calcTotal = total || (calcSubtotal + calcDeliveryFee - (discount || 0));

    const order = await OrderService.placeOrder(userId, normalizedItems, calcSubtotal, calcDeliveryFee, calcTotal, paymentMethod || "Wallet Pay", {
      deliveryAddress: addressStr,
      notes,
      isGift,
      giftMessage,
      scheduledTime,
      discount
    });

    console.log(`[OrderController] Order placed successfully: ${order.id} for user ${userId}`);
    const profile = await UserService.getUserProfile(userId);
    res.json({ status: "success", order, walletBalance: profile.walletBalance });
  } catch (error: any) {
    console.error("[OrderController] Error placing order:", error);
    if (error.message && error.message.includes("Insufficient")) {
      res.status(400).json({ error: error.message });
      return;
    }
    next(error);
  }
}

export async function deleteOrder(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = getUserIdFromReq(req);
    const orderId = req.params.id;
    console.log(`[OrderController] DELETE orderId: ${orderId} for user ${userId}`);
    const result = await OrderService.deleteOrder(userId, orderId);
    res.json(result);
  } catch (error: any) {
    console.error(`[OrderController] Error deleting order ${req.params.id}:`, error);
    res.status(400).json({ error: error.message || "Failed to delete order" });
  }
}

export async function cancelOrder(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = getUserIdFromReq(req);
    const orderId = req.params.id;
    const { reason } = req.body || {};
    const result = await OrderService.cancelOrder(userId, orderId, reason);
    res.json(result);
  } catch (error: any) {
    res.status(400).json({ error: error.message || "Failed to cancel order" });
  }
}

export async function modifyOrder(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = getUserIdFromReq(req);
    const orderId = req.params.id;
    const { deliveryAddress, notes } = req.body;
    const updated = await OrderService.modifyOrder(userId, orderId, { deliveryAddress, notes });
    res.json({ status: "success", order: updated });
  } catch (error: any) {
    res.status(400).json({ error: error.message || "Failed to modify order" });
  }
}

export async function repeatOrder(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = getUserIdFromReq(req);
    const orderId = req.params.id;
    const result = await OrderService.repeatOrder(userId, orderId);
    res.json(result);
  } catch (error: any) {
    res.status(400).json({ error: error.message || "Failed to repeat order" });
  }
}

export async function getOrderTimeline(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = getUserIdFromReq(req);
    const orderId = req.params.id;
    const timeline = await OrderService.getOrderTimeline(userId, orderId);
    res.json(timeline);
  } catch (error: any) {
    res.status(404).json({ error: error.message || "Order timeline not found" });
  }
}

export async function getOrderInvoice(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = getUserIdFromReq(req);
    const orderId = req.params.id;
    const invoice = await OrderService.getOrderInvoice(userId, orderId);
    res.json(invoice);
  } catch (error: any) {
    res.status(404).json({ error: error.message || "Order invoice not found" });
  }
}

export async function getOrderEligibility(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = getUserIdFromReq(req);
    const orderId = req.params.id;
    const eligibility = await OrderService.getOrderEligibility(userId, orderId);
    res.json(eligibility);
  } catch (error: any) {
    res.status(404).json({ error: error.message || "Order eligibility not found" });
  }
}

export async function updateOrderStatus(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = getUserIdFromReq(req);
    const orderId = req.params.id;
    const { status, notes } = req.body;
    if (!status) {
      res.status(400).json({ error: "Status is required" });
      return;
    }
    const updated = await OrderService.updateOrderStatus(userId, orderId, status, notes);
    res.json({ status: "success", order: updated });
  } catch (error: any) {
    res.status(400).json({ error: error.message || "Failed to update order status" });
  }
}

export async function clearActiveOrder(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = getUserIdFromReq(req);
    await OrderService.cancelActiveOrder(userId);
    res.json({ status: "success" });
  } catch (error) {
    next(error);
  }
}
