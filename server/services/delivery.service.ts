import { DeliveryRepository, RiderState, DarkStore, DeliveryTrackingRecord } from "../repositories/delivery.repository";
import { ActivityRepository } from "../repositories/activity.repository";
import { SocketService } from "./socket.service";
import { NotificationService } from "./notification.service";

export class DeliveryService {
  static async getDarkStores(): Promise<DarkStore[]> {
    return DeliveryRepository.getDarkStores();
  }

  static async getNearestDarkStore(lat: number, lng: number) {
    return DeliveryRepository.getNearestDarkStore(lat, lng);
  }

  static async getRiders(filter?: { storeId?: string; isOnline?: boolean }): Promise<RiderState[]> {
    return DeliveryRepository.getRiders(filter);
  }

  static async updateRiderStatus(riderId: string, isOnline: boolean, currentStoreId?: string): Promise<RiderState | null> {
    const updated = await DeliveryRepository.updateRiderStatus(riderId, isOnline, currentStoreId);
    if (updated) {
      SocketService.emitToAll("admin.delivery.updated", {
        type: "RIDER_STATUS",
        riderId,
        isOnline,
        status: updated.status
      });
    }
    return updated;
  }

  static async getRiderState(): Promise<RiderState> {
    return DeliveryRepository.getRiderState();
  }

  static async updateRiderLocation(lat: number, lng: number, bearing: number, riderId: string = "r1"): Promise<RiderState> {
    const updated = await DeliveryRepository.updateRiderLocation(lat, lng, bearing, riderId);
    
    // Broadcast location telemetry with required socket events
    SocketService.emitToAll("rider.location.updated", {
      riderId,
      lat,
      lng,
      bearing,
      status: updated.status,
    });

    SocketService.emitToAll("rider_location", {
      riderId,
      lat,
      lng,
      bearing,
      status: updated.status,
    });

    return updated;
  }

  static async getDeliveryByOrderId(orderId: string): Promise<DeliveryTrackingRecord | null> {
    let delivery = await DeliveryRepository.getDeliveryByOrderId(orderId);
    if (!delivery) {
      delivery = await DeliveryRepository.createDeliveryForOrder(orderId);
    }
    return delivery;
  }

  static async assignRider(orderId: string, targetRiderId?: string, isManual: boolean = false): Promise<DeliveryTrackingRecord | null> {
    const delivery = await DeliveryRepository.assignRider(orderId, targetRiderId, isManual);
    if (delivery) {
      await ActivityRepository.log("delivery_system", "rider_assigned", `Rider ${delivery.riderName} assigned to order #${orderId}`);
      
      // Emit real-time events
      SocketService.emitToAll("rider.assigned", {
        orderId,
        riderId: delivery.riderId,
        riderName: delivery.riderName,
        riderPhone: delivery.riderPhone,
        riderAvatar: delivery.riderAvatar,
        status: delivery.status,
      });

      SocketService.emitToAll("customer.order.updated", {
        orderId,
        status: "accepted",
        trackingStep: 2,
        deliveryStatus: "RIDER_ASSIGNED",
        rider: {
          id: delivery.riderId,
          name: delivery.riderName,
          phone: delivery.riderPhone,
          avatar: delivery.riderAvatar,
        }
      });

      SocketService.emitToAll("admin.delivery.updated", {
        type: "ASSIGNMENT",
        orderId,
        riderId: delivery.riderId,
        status: "RIDER_ASSIGNED"
      });

      // Notification for Customer
      await NotificationService.send({
        userId: "u1",
        role: "CUSTOMER",
        templateCode: "RIDER_ASSIGNED",
        category: "DELIVERY",
        params: {
          riderName: delivery.riderName,
          vehicleNumber: "KA-01-EQ-9041",
          orderId,
        },
        metadata: { orderId, riderId: delivery.riderId },
      });

      // Notification for Rider
      await NotificationService.send({
        userId: delivery.riderId || "r1",
        role: "RIDER",
        templateCode: "NEW_DELIVERY_REQUEST",
        category: "DELIVERY",
        params: {
          orderId,
          storeName: "Koramangala Dark Store",
          distance: delivery.distanceKm || 2.4,
        },
        metadata: { orderId, distance: delivery.distanceKm },
      });
    }
    return delivery;
  }

  static async acceptDelivery(orderId: string, riderId: string): Promise<DeliveryTrackingRecord | null> {
    const delivery = await DeliveryRepository.acceptDelivery(orderId, riderId);
    if (delivery) {
      SocketService.emitToAll("rider.accepted", {
        orderId,
        riderId,
        status: delivery.status
      });

      SocketService.emitToAll("customer.order.updated", {
        orderId,
        deliveryStatus: "RIDER_ACCEPTED"
      });
    }
    return delivery;
  }

  static async rejectDelivery(orderId: string, riderId: string, reason?: string): Promise<DeliveryTrackingRecord | null> {
    const delivery = await DeliveryRepository.rejectDelivery(orderId, riderId, reason);
    if (delivery) {
      SocketService.emitToAll("rider.rejected", {
        orderId,
        riderId,
        reason,
        status: delivery.status
      });

      SocketService.emitToAll("admin.delivery.updated", {
        type: "REJECTION",
        orderId,
        riderId,
        reason
      });
    }
    return delivery;
  }

  static async advanceStep(trackingStep: number, status: string, estTime?: string, orderId?: string): Promise<any> {
    const res = await DeliveryRepository.advanceStep(trackingStep, status, estTime, orderId);
    const targetOrderId = orderId || "FC-8821";
    
    await ActivityRepository.log(
      "delivery_system",
      "delivery_status_update",
      `Order #${targetOrderId} progress advanced to step ${trackingStep} (${status})`
    );

    // Broadcast status change across all socket listeners
    SocketService.emitToAll("customer.order.updated", {
      orderId: targetOrderId,
      trackingStep,
      status,
      estimatedDeliveryTime: estTime || "9 Mins",
    });

    SocketService.emitToAll("order_status", {
      orderId: targetOrderId,
      trackingStep,
      status,
      estimatedDeliveryTime: estTime || "9 Mins",
    });

    if (trackingStep === 3) {
      SocketService.emitToAll("store.order.ready", {
        orderId: targetOrderId,
        status: "PICKED_UP"
      });

      await NotificationService.send({
        userId: "u1",
        role: "CUSTOMER",
        templateCode: "OUT_FOR_DELIVERY",
        category: "DELIVERY",
        params: {
          orderId: targetOrderId,
          riderName: "Suresh Kumar",
          eta: estTime ? parseInt(estTime) || 8 : 8,
        },
        metadata: { orderId: targetOrderId },
      });
    }

    if (trackingStep === 4) {
      await NotificationService.send({
        userId: "u1",
        role: "CUSTOMER",
        templateCode: "RIDER_NEARBY",
        category: "DELIVERY",
        params: {
          riderName: "Suresh Kumar",
          otpCode: "4932",
        },
        metadata: { orderId: targetOrderId, otpCode: "4932" },
      });
    }

    if (trackingStep === 5) {
      SocketService.emitToAll("delivery.completed", {
        orderId: targetOrderId,
        status: "DELIVERED"
      });

      await NotificationService.send({
        userId: "u1",
        role: "CUSTOMER",
        templateCode: "DELIVERED",
        category: "ORDER",
        params: {
          orderId: targetOrderId,
        },
        metadata: { orderId: targetOrderId },
      });
    }

    return res;
  }

  static async completeDelivery(orderId: string, proofPhotoUrl?: string, signatureUrl?: string): Promise<DeliveryTrackingRecord | null> {
    const delivery = await DeliveryRepository.completeDelivery(orderId, proofPhotoUrl, signatureUrl);
    if (delivery) {
      await ActivityRepository.log("delivery_system", "delivery_completed", `Order #${orderId} successfully delivered`);

      SocketService.emitToAll("delivery.completed", {
        orderId,
        status: "DELIVERED",
        proofPhotoUrl,
        signatureUrl
      });

      SocketService.emitToAll("customer.order.updated", {
        orderId,
        trackingStep: 5,
        status: "delivered",
        deliveryStatus: "DELIVERED"
      });

      SocketService.emitToAll("admin.delivery.updated", {
        type: "COMPLETED",
        orderId,
        status: "DELIVERED"
      });
    }
    return delivery;
  }

  static async recordGpsTelemetry(riderId: string, deliveryId: string | null, lat: number, lng: number, bearing?: number, speed?: number, battery?: number) {
    await DeliveryRepository.recordGpsTelemetry(riderId, deliveryId, lat, lng, bearing || 0, speed || 0, battery || 100);
    
    SocketService.emitToAll("rider.location.updated", {
      riderId,
      deliveryId,
      lat,
      lng,
      bearing,
      speed,
      battery
    });
  }

  static async getAuditLogs(orderId: string): Promise<any[]> {
    return DeliveryRepository.getAuditLogs(orderId);
  }
}
