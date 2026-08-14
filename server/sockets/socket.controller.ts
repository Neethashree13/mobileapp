import { Server as SocketIOServer, Socket } from "socket.io";
import { logger } from "../utils/logger";
import { DeliveryService } from "../services/delivery.service";

export function setupSocketHandlers(io: SocketIOServer) {
  logger.info("Initializing Socket.IO event handlers...");

  io.on("connection", (socket: Socket) => {
    logger.info(`🔌 Socket connected: ${socket.id} (IP: ${socket.handshake.address})`);

    // Ping / Pong test
    socket.on("ping_test", (data) => {
      logger.info(`[Socket ping_test] received from ${socket.id}: ${JSON.stringify(data)}`);
      socket.emit("pong_test", { message: "pong", timestamp: new Date().toISOString() });
    });

    // Room joins
    socket.on("join_user_channel", (userId: string) => {
      const room = `user_${userId}`;
      socket.join(room);
      logger.info(`👤 Socket ${socket.id} joined room: ${room}`);
      socket.emit("channel_joined", { room, status: "active" });
    });

    socket.on("join_order_channel", (orderId: string) => {
      const room = `order_${orderId}`;
      socket.join(room);
      logger.info(`📦 Socket ${socket.id} joined room: ${room}`);
      socket.emit("channel_joined", { room, status: "active" });
    });

    socket.on("join_rider_channel", (riderId: string) => {
      const room = `rider_${riderId}`;
      socket.join(room);
      logger.info(`🛵 Socket ${socket.id} joined room: ${room}`);
      socket.emit("channel_joined", { room, status: "active" });
    });

    socket.on("join_store_channel", (storeId: string) => {
      const room = `store_${storeId}`;
      socket.join(room);
      logger.info(`🏬 Socket ${socket.id} joined room: ${room}`);
      socket.emit("channel_joined", { room, status: "active" });
    });

    socket.on("join_admin_channel", () => {
      socket.join("admin");
      logger.info(`🛠️ Socket ${socket.id} joined room: admin`);
      socket.emit("channel_joined", { room: "admin", status: "active" });
    });

    // Real-time telemetry streaming from rider
    socket.on("rider_live_location", async (data: { lat: number; lng: number; bearing: number; riderId?: string; deliveryId?: string }) => {
      const riderId = data.riderId || "r1";
      const updatedRiderState = await DeliveryService.updateRiderLocation(data.lat, data.lng, data.bearing, riderId);
      
      const payload = {
        riderId,
        deliveryId: data.deliveryId,
        lat: data.lat,
        lng: data.lng,
        bearing: data.bearing,
        status: updatedRiderState.status,
        timestamp: new Date().toISOString()
      };

      io.emit("rider.location.updated", payload);
      io.emit("rider_location", payload);
    });

    // Location update from customer app
    socket.on("customer_location_update", (data: { orderId: string; lat: number; lng: number }) => {
      io.emit("customer.location.updated", data);
    });

    // Rider status / assignment updates
    socket.on("rider_accept_order", async (data: { orderId: string; riderId: string }) => {
      await DeliveryService.acceptDelivery(data.orderId, data.riderId);
    });

    socket.on("rider_reject_order", async (data: { orderId: string; riderId: string; reason?: string }) => {
      await DeliveryService.rejectDelivery(data.orderId, data.riderId, data.reason);
    });

    socket.on("rider_pickup_order", async (data: { orderId: string }) => {
      await DeliveryService.advanceStep(3, "packing", "8 Mins", data.orderId);
    });

    socket.on("rider_complete_order", async (data: { orderId: string; proofPhotoUrl?: string; signatureUrl?: string }) => {
      await DeliveryService.completeDelivery(data.orderId, data.proofPhotoUrl, data.signatureUrl);
    });

    socket.on("disconnect", (reason) => {
      logger.info(`🔌 Socket disconnected: ${socket.id} (Reason: ${reason})`);
    });
  });
}
