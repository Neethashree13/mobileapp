import { dbQuery, usePostgreSQL } from "../config/database";
import { DB_STATE } from "../config/dbState";

export interface RiderState {
  id: string;
  name: string;
  phone: string;
  avatar: string;
  vehicleType?: string;
  vehicleNumber?: string;
  isOnline?: boolean;
  currentStoreId?: string;
  activeDeliveryId?: string | null;
  lat: number;
  lng: number;
  bearing: number;
  status: string;
  rating: number;
  totalTrips?: number;
  totalEarnings?: number;
}

export interface DarkStore {
  id: string;
  name: string;
  code: string;
  latitude: number;
  longitude: number;
  address: string;
  isActive: boolean;
}

export interface DeliveryTrackingRecord {
  id: string;
  orderId: string;
  storeId: string;
  riderId: string | null;
  riderName: string;
  riderPhone: string;
  riderAvatar: string;
  currentLatitude: number;
  currentLongitude: number;
  bearing: number;
  status: string;
  otpCode: string;
  proofPhotoUrl?: string | null;
  signatureUrl?: string | null;
  etaMins: number;
  distanceKm: number;
  deliveryFee: number;
  surgeMultiplier: number;
  failureReason?: string | null;
  createdAt: string;
  updatedAt: string;
}

export class DeliveryRepository {
  // Haversine distance helper (in Kilometers)
  public static calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Radius of Earth in km
    const dLat = (lat2 - lat1) * (Math.PI / 180);
    const dLon = (lon2 - lon1) * (Math.PI / 180);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * (Math.PI / 180)) *
        Math.cos(lat2 * (Math.PI / 180)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return Math.round(R * c * 100) / 100; // 2 decimal places
  }

  // Get Dark Stores
  static async getDarkStores(): Promise<DarkStore[]> {
    if (usePostgreSQL) {
      try {
        const res = await dbQuery("SELECT id, name, code, latitude, longitude, address, is_active FROM dark_stores WHERE is_active = true");
        return res.rows.map((row: any) => ({
          id: row.id,
          name: row.name,
          code: row.code,
          latitude: Number(row.latitude),
          longitude: Number(row.longitude),
          address: row.address,
          isActive: row.is_active,
        }));
      } catch (err) {
        console.warn("Error fetching dark stores from DB:", err);
      }
    }
    return DB_STATE.darkStores || [
      {
        id: "s1",
        name: "Koramangala Dark Store",
        code: "DS-BLR-01",
        latitude: 12.9279,
        longitude: 77.6250,
        address: "Block 3, Koramangala, Bangalore",
        isActive: true,
      }
    ];
  }

  // Get Nearest Dark Store for a customer coordinate
  static async getNearestDarkStore(lat: number, lng: number): Promise<{ store: DarkStore; distanceKm: number; etaMins: number; surgeMultiplier: number; deliveryFee: number }> {
    const stores = await this.getDarkStores();
    if (stores.length === 0) {
      const fallbackStore: DarkStore = {
        id: "s1",
        name: "Koramangala Dark Store",
        code: "DS-BLR-01",
        latitude: 12.9279,
        longitude: 77.6250,
        address: "Block 3, Koramangala, Bangalore",
        isActive: true,
      };
      return { store: fallbackStore, distanceKm: 2.1, etaMins: 9, surgeMultiplier: 1.0, deliveryFee: 35 };
    }

    let nearest = stores[0];
    let minDistance = this.calculateDistance(lat, lng, stores[0].latitude, stores[0].longitude);

    for (let i = 1; i < stores.length; i++) {
      const dist = this.calculateDistance(lat, lng, stores[i].latitude, stores[i].longitude);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = stores[i];
      }
    }

    // Dynamic ETA calculation: 5 mins base + 2.5 mins per km
    const etaMins = Math.max(7, Math.round(5 + minDistance * 2.5));

    // Peak hour surge logic (e.g. 7-10 PM or 12-2 PM)
    const currentHour = new Date().getHours();
    let surgeMultiplier = 1.0;
    if ((currentHour >= 12 && currentHour <= 14) || (currentHour >= 19 && currentHour <= 22)) {
      surgeMultiplier = 1.25;
    }

    const baseDeliveryFee = 35;
    const deliveryFee = Math.round(baseDeliveryFee * surgeMultiplier);

    return {
      store: nearest,
      distanceKm: minDistance,
      etaMins,
      surgeMultiplier,
      deliveryFee,
    };
  }

  // Get Riders list
  static async getRiders(filter?: { storeId?: string; isOnline?: boolean }): Promise<RiderState[]> {
    if (usePostgreSQL) {
      try {
        let sql = "SELECT id, name, phone, avatar, vehicle_type, vehicle_number, is_online, current_store_id, active_delivery_id, rating, total_trips, total_earnings, current_latitude, current_longitude, bearing FROM rider_availability WHERE 1=1";
        const params: any[] = [];
        if (filter?.storeId) {
          params.push(filter.storeId);
          sql += ` AND current_store_id = $${params.length}`;
        }
        if (filter?.isOnline !== undefined) {
          params.push(filter.isOnline);
          sql += ` AND is_online = $${params.length}`;
        }
        const res = await dbQuery(sql, params);
        return res.rows.map((r: any) => ({
          id: r.id,
          name: r.name,
          phone: r.phone,
          avatar: r.avatar,
          vehicleType: r.vehicle_type,
          vehicleNumber: r.vehicle_number,
          isOnline: r.is_online,
          currentStoreId: r.current_store_id,
          activeDeliveryId: r.active_delivery_id,
          lat: Number(r.current_latitude),
          lng: Number(r.current_longitude),
          bearing: Number(r.bearing || 0),
          status: r.active_delivery_id ? "In Delivery" : (r.is_online ? "Online" : "Offline"),
          rating: Number(r.rating || 4.95),
          totalTrips: Number(r.total_trips || 0),
          totalEarnings: Number(r.total_earnings || 0),
        }));
      } catch (err) {
        console.warn("Error fetching riders from DB:", err);
      }
    }

    let riders = DB_STATE.riders || [];
    if (filter?.storeId) {
      riders = riders.filter(r => r.currentStoreId === filter.storeId);
    }
    if (filter?.isOnline !== undefined) {
      riders = riders.filter(r => r.isOnline === filter.isOnline);
    }
    return riders.map(r => ({
      ...r,
      status: r.activeDeliveryId ? "In Delivery" : (r.isOnline ? "Online" : "Offline")
    }));
  }

  // Toggle Rider Online / Active status
  static async updateRiderStatus(riderId: string, isOnline: boolean, currentStoreId?: string): Promise<RiderState | null> {
    if (usePostgreSQL) {
      try {
        await dbQuery(
          "UPDATE rider_availability SET is_online = $1, current_store_id = COALESCE($2, current_store_id), updated_at = CURRENT_TIMESTAMP WHERE id = $3",
          [isOnline, currentStoreId || null, riderId]
        );
      } catch (err) {
        console.warn("Error updating rider status in DB:", err);
      }
    }

    const rider = DB_STATE.riders.find(r => r.id === riderId);
    if (rider) {
      rider.isOnline = isOnline;
      if (currentStoreId) rider.currentStoreId = currentStoreId;
      return {
        ...rider,
        status: rider.activeDeliveryId ? "In Delivery" : (rider.isOnline ? "Online" : "Offline")
      };
    }
    return null;
  }

  // Get single active rider state (backward compatibility)
  static async getRiderState(): Promise<RiderState> {
    const riders = await this.getRiders();
    if (riders.length > 0) {
      return riders[0];
    }
    return DB_STATE.riderState;
  }

  // Update Rider Location Stream
  static async updateRiderLocation(lat: number, lng: number, bearing: number, riderId: string = "r1"): Promise<RiderState> {
    if (usePostgreSQL) {
      try {
        await dbQuery(
          "UPDATE rider_availability SET current_latitude = $1, current_longitude = $2, bearing = $3, updated_at = CURRENT_TIMESTAMP WHERE id = $4",
          [lat, lng, bearing, riderId]
        );
        // Also update active delivery location if any
        const activeDel = await dbQuery("SELECT id, order_id FROM delivery_tracking WHERE rider_id = $1 AND status NOT IN ('DELIVERED', 'FAILED', 'CANCELLED') LIMIT 1", [riderId]);
        if (activeDel.rows.length > 0) {
          await dbQuery("UPDATE delivery_tracking SET current_latitude = $1, current_longitude = $2, bearing = $3, updated_at = CURRENT_TIMESTAMP WHERE id = $4", [lat, lng, bearing, activeDel.rows[0].id]);
        }
      } catch (err) {
        console.warn("Error updating rider location in DB:", err);
      }
    }

    const rider = DB_STATE.riders.find(r => r.id === riderId);
    if (rider) {
      rider.lat = lat;
      rider.lng = lng;
      rider.bearing = bearing;
    }
    DB_STATE.riderState.lat = lat;
    DB_STATE.riderState.lng = lng;
    DB_STATE.riderState.bearing = bearing;

    return (rider ? { ...rider, status: rider.activeDeliveryId ? "In Delivery" : (rider.isOnline ? "Online" : "Offline") } : DB_STATE.riderState);
  }

  // Get active delivery record for order or create default
  static async getDeliveryByOrderId(orderId: string): Promise<DeliveryTrackingRecord | null> {
    if (usePostgreSQL) {
      try {
        const res = await dbQuery("SELECT id, order_id, store_id, rider_id, rider_name, rider_phone, rider_avatar, current_latitude, current_longitude, bearing, status, otp_code, proof_photo_url, signature_url, eta_mins, distance_km, delivery_fee, surge_multiplier, failure_reason, created_at, updated_at FROM delivery_tracking WHERE order_id = $1 LIMIT 1", [orderId]);
        if (res.rows.length > 0) {
          const d = res.rows[0];
          return {
            id: d.id,
            orderId: d.order_id,
            storeId: d.store_id,
            riderId: d.rider_id,
            riderName: d.rider_name || 'Unassigned',
            riderPhone: d.rider_phone || '',
            riderAvatar: d.rider_avatar || 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120',
            currentLatitude: Number(d.current_latitude),
            currentLongitude: Number(d.current_longitude),
            bearing: Number(d.bearing || 0),
            status: d.status,
            otpCode: d.otp_code || '4932',
            proofPhotoUrl: d.proof_photo_url,
            signatureUrl: d.signature_url,
            etaMins: Number(d.eta_mins || 10),
            distanceKm: Number(d.distance_km || 2.4),
            deliveryFee: Number(d.delivery_fee || 35),
            surgeMultiplier: Number(d.surge_multiplier || 1.0),
            failureReason: d.failure_reason,
            createdAt: d.created_at,
            updatedAt: d.updated_at,
          };
        }
      } catch (err) {
        console.warn("Error fetching delivery tracking from DB:", err);
      }
    }

    const memoryDel = DB_STATE.deliveryTracking.find(d => d.orderId === orderId);
    if (memoryDel) return memoryDel;

    if (DB_STATE.activeOrder && DB_STATE.activeOrder.id === orderId) {
      return {
        id: "del_active_01",
        orderId: DB_STATE.activeOrder.id,
        storeId: "s1",
        riderId: "r1",
        riderName: "Suresh Kumar",
        riderPhone: "+91 98765 43210",
        riderAvatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120",
        currentLatitude: DB_STATE.riderState.lat,
        currentLongitude: DB_STATE.riderState.lng,
        bearing: DB_STATE.riderState.bearing,
        status: DB_STATE.riderState.status === "assigned" ? "RIDER_ASSIGNED" : DB_STATE.riderState.status.toUpperCase(),
        otpCode: "4932",
        etaMins: 9,
        distanceKm: 2.1,
        deliveryFee: 35,
        surgeMultiplier: 1.0,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
    }

    return null;
  }

  // Create or Initialize Delivery record for an order
  static async createDeliveryForOrder(orderId: string, storeId: string = "s1", customerLat: number = 12.9348, customerLng: number = 77.6189): Promise<DeliveryTrackingRecord> {
    const storeInfo = (await this.getDarkStores()).find(s => s.id === storeId) || {
      id: "s1",
      name: "Koramangala Dark Store",
      code: "DS-BLR-01",
      latitude: 12.9279,
      longitude: 77.6250,
      address: "Block 3, Koramangala, Bangalore",
      isActive: true
    };

    const dist = this.calculateDistance(customerLat, customerLng, storeInfo.latitude, storeInfo.longitude);
    const etaMins = Math.max(7, Math.round(5 + dist * 2.5));
    const otpCode = "4932"; // Standard 4-digit verification code

    if (usePostgreSQL) {
      try {
        const insertRes = await dbQuery(`
          INSERT INTO delivery_tracking (order_id, store_id, current_latitude, current_longitude, status, otp_code, eta_mins, distance_km, delivery_fee, surge_multiplier)
          VALUES ($1, $2, $3, $4, 'READY_FOR_PICKUP', $5, $6, $7, 35.00, 1.00)
          ON CONFLICT (order_id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP
          RETURNING id, order_id, store_id, rider_id, rider_name, rider_phone, rider_avatar, current_latitude, current_longitude, bearing, status, otp_code, eta_mins, distance_km, delivery_fee, surge_multiplier, created_at, updated_at
        `, [orderId, storeId, storeInfo.latitude, storeInfo.longitude, otpCode, etaMins, dist]);

        const d = insertRes.rows[0];
        return {
          id: d.id,
          orderId: d.order_id,
          storeId: d.store_id,
          riderId: d.rider_id,
          riderName: d.rider_name || 'Unassigned',
          riderPhone: d.rider_phone || '',
          riderAvatar: d.rider_avatar || 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120',
          currentLatitude: Number(d.current_latitude),
          currentLongitude: Number(d.current_longitude),
          bearing: Number(d.bearing || 0),
          status: d.status,
          otpCode: d.otp_code,
          etaMins: Number(d.eta_mins),
          distanceKm: Number(d.distance_km),
          deliveryFee: Number(d.delivery_fee),
          surgeMultiplier: Number(d.surge_multiplier),
          createdAt: d.created_at,
          updatedAt: d.updated_at
        };
      } catch (err) {
        console.warn("Error creating delivery_tracking record in DB:", err);
      }
    }

    const newRecord: DeliveryTrackingRecord = {
      id: `del_${Date.now()}`,
      orderId,
      storeId,
      riderId: null,
      riderName: 'Unassigned',
      riderPhone: '',
      riderAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120',
      currentLatitude: storeInfo.latitude,
      currentLongitude: storeInfo.longitude,
      bearing: 0,
      status: 'READY_FOR_PICKUP',
      otpCode,
      etaMins,
      distanceKm: dist,
      deliveryFee: 35,
      surgeMultiplier: 1.0,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    DB_STATE.deliveryTracking.push(newRecord);
    return newRecord;
  }

  // Assign Rider (Auto or Manual)
  static async assignRider(orderId: string, targetRiderId?: string, isManual: boolean = false): Promise<DeliveryTrackingRecord | null> {
    let delivery = await this.getDeliveryByOrderId(orderId);
    if (!delivery) {
      delivery = await this.createDeliveryForOrder(orderId);
    }

    // Select online rider
    const availableRiders = await this.getRiders({ storeId: delivery.storeId, isOnline: true });
    let selectedRider = targetRiderId ? availableRiders.find(r => r.id === targetRiderId) : availableRiders[0];
    
    if (!selectedRider) {
      // Fallback to r1
      const allRiders = await this.getRiders();
      selectedRider = allRiders.find(r => r.id === (targetRiderId || "r1")) || allRiders[0];
    }

    if (!selectedRider) return null;

    if (usePostgreSQL) {
      try {
        await dbQuery(`
          UPDATE delivery_tracking 
          SET rider_id = $1, rider_name = $2, rider_phone = $3, rider_avatar = $4, status = 'RIDER_ASSIGNED', updated_at = CURRENT_TIMESTAMP
          WHERE id = $5
        `, [selectedRider.id, selectedRider.name, selectedRider.phone, selectedRider.avatar, delivery.id]);

        await dbQuery(`
          UPDATE rider_availability SET active_delivery_id = $1 WHERE id = $2
        `, [delivery.id, selectedRider.id]);

        await dbQuery(`
          INSERT INTO delivery_assignments (delivery_id, order_id, rider_id, store_id, status, assignment_mode)
          VALUES ($1, $2, $3, $4, 'ASSIGNED', $5)
        `, [delivery.id, orderId, selectedRider.id, delivery.storeId, isManual ? 'MANUAL' : 'AUTO']);

        await dbQuery(`
          INSERT INTO delivery_audit_logs (delivery_id, order_id, actor_type, actor_id, event, previous_state, new_state)
          VALUES ($1, $2, $3, $4, 'RIDER_ASSIGNED', $5, 'RIDER_ASSIGNED')
        `, [delivery.id, orderId, isManual ? 'ADMIN' : 'SYSTEM', 'system_dispatcher', 'READY_FOR_PICKUP']);

        await dbQuery(`
          UPDATE orders SET status = 'accepted', tracking_step = 2 WHERE id = $1
        `, [orderId]);
      } catch (err) {
        console.warn("Error assigning rider in DB:", err);
      }
    }

    delivery.riderId = selectedRider.id;
    delivery.riderName = selectedRider.name;
    delivery.riderPhone = selectedRider.phone;
    delivery.riderAvatar = selectedRider.avatar;
    delivery.status = 'RIDER_ASSIGNED';
    delivery.updatedAt = new Date().toISOString();

    const memRider = DB_STATE.riders.find(r => r.id === selectedRider.id);
    if (memRider) memRider.activeDeliveryId = delivery.id;

    if (DB_STATE.activeOrder && DB_STATE.activeOrder.id === orderId) {
      DB_STATE.activeOrder.status = 'accepted';
      DB_STATE.activeOrder.trackingStep = 2;
    }
    DB_STATE.riderState.status = 'assigned';

    return delivery;
  }

  // Accept Delivery (Rider action)
  static async acceptDelivery(orderId: string, riderId: string): Promise<DeliveryTrackingRecord | null> {
    const delivery = await this.getDeliveryByOrderId(orderId);
    if (!delivery) return null;

    if (usePostgreSQL) {
      try {
        await dbQuery(`
          UPDATE delivery_tracking SET status = 'RIDER_ACCEPTED', updated_at = CURRENT_TIMESTAMP WHERE id = $1
        `, [delivery.id]);

        await dbQuery(`
          UPDATE delivery_assignments SET status = 'ACCEPTED', accepted_at = CURRENT_TIMESTAMP WHERE delivery_id = $1 AND rider_id = $2
        `, [delivery.id, riderId]);

        await dbQuery(`
          INSERT INTO delivery_audit_logs (delivery_id, order_id, actor_type, actor_id, event, previous_state, new_state)
          VALUES ($1, $2, 'RIDER', $3, 'RIDER_ACCEPTED', 'RIDER_ASSIGNED', 'RIDER_ACCEPTED')
        `, [delivery.id, orderId, riderId]);
      } catch (err) {
        console.warn("Error accepting delivery in DB:", err);
      }
    }

    delivery.status = 'RIDER_ACCEPTED';
    delivery.updatedAt = new Date().toISOString();
    return delivery;
  }

  // Reject Delivery (Rider action)
  static async rejectDelivery(orderId: string, riderId: string, reason?: string): Promise<DeliveryTrackingRecord | null> {
    const delivery = await this.getDeliveryByOrderId(orderId);
    if (!delivery) return null;

    if (usePostgreSQL) {
      try {
        await dbQuery(`
          UPDATE delivery_tracking SET status = 'RIDER_REJECTED', updated_at = CURRENT_TIMESTAMP WHERE id = $1
        `, [delivery.id]);

        await dbQuery(`
          UPDATE delivery_assignments SET status = 'REJECTED', rejected_at = CURRENT_TIMESTAMP, rejection_reason = $1 WHERE delivery_id = $2 AND rider_id = $3
        `, [reason || 'Rider busy', delivery.id, riderId]);

        await dbQuery(`
          UPDATE rider_availability SET active_delivery_id = NULL WHERE id = $1
        `, [riderId]);

        await dbQuery(`
          INSERT INTO delivery_audit_logs (delivery_id, order_id, actor_type, actor_id, event, previous_state, new_state)
          VALUES ($1, $2, 'RIDER', $3, 'RIDER_REJECTED', 'RIDER_ASSIGNED', 'RIDER_REJECTED')
        `, [delivery.id, orderId, riderId]);
      } catch (err) {
        console.warn("Error rejecting delivery in DB:", err);
      }
    }

    delivery.status = 'RIDER_REJECTED';
    delivery.updatedAt = new Date().toISOString();

    const memRider = DB_STATE.riders.find(r => r.id === riderId);
    if (memRider) memRider.activeDeliveryId = null;

    // Trigger auto-reassignment to next available rider
    setTimeout(() => {
      this.assignRider(orderId);
    }, 1000);

    return delivery;
  }

  // Advance delivery step & status
  static async advanceStep(trackingStep: number, status: string, estTime?: string, orderId?: string): Promise<any> {
    const targetOrderId = orderId || (DB_STATE.activeOrder ? DB_STATE.activeOrder.id : "FC-8821");

    let mappedDeliveryStatus = "RIDER_ASSIGNED";
    if (trackingStep === 2) mappedDeliveryStatus = "ARRIVED_AT_STORE";
    else if (trackingStep === 3) mappedDeliveryStatus = "PICKED_UP";
    else if (trackingStep === 4) mappedDeliveryStatus = "OUT_FOR_DELIVERY";
    else if (trackingStep === 5) mappedDeliveryStatus = "DELIVERED";

    if (usePostgreSQL) {
      try {
        await dbQuery(
          "UPDATE orders SET tracking_step = $1, status = $2, estimated_delivery_time = COALESCE($3, estimated_delivery_time) WHERE id = $4",
          [trackingStep, status, estTime || null, targetOrderId]
        );
        await dbQuery(
          "UPDATE delivery_tracking SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE order_id = $2",
          [mappedDeliveryStatus, targetOrderId]
        );
        if (trackingStep === 5) {
          // If delivered, clear active delivery on rider
          const del = await dbQuery("SELECT rider_id FROM delivery_tracking WHERE order_id = $1 LIMIT 1", [targetOrderId]);
          if (del.rows.length > 0 && del.rows[0].rider_id) {
            await dbQuery("UPDATE rider_availability SET active_delivery_id = NULL, total_trips = total_trips + 1, total_earnings = total_earnings + 60 WHERE id = $1", [del.rows[0].rider_id]);
          }
        }
      } catch (err) {
        console.warn("Error advancing step in DB:", err);
      }
    }

    if (DB_STATE.activeOrder && DB_STATE.activeOrder.id === targetOrderId) {
      DB_STATE.activeOrder.trackingStep = trackingStep;
      DB_STATE.activeOrder.status = status;
      if (estTime) DB_STATE.activeOrder.estimatedDeliveryTime = estTime;
    }

    const del = DB_STATE.deliveryTracking.find(d => d.orderId === targetOrderId);
    if (del) {
      del.status = mappedDeliveryStatus;
      del.updatedAt = new Date().toISOString();
    }

    DB_STATE.riderState.status = status;

    return {
      activeOrder: DB_STATE.activeOrder,
      riderState: DB_STATE.riderState,
      deliveryTracking: del
    };
  }

  // Complete Delivery with OTP & Proof
  static async completeDelivery(orderId: string, proofPhotoUrl?: string, signatureUrl?: string): Promise<DeliveryTrackingRecord | null> {
    const delivery = await this.getDeliveryByOrderId(orderId);
    if (!delivery) return null;

    if (usePostgreSQL) {
      try {
        await dbQuery(`
          UPDATE delivery_tracking 
          SET status = 'DELIVERED', proof_photo_url = $1, signature_url = $2, updated_at = CURRENT_TIMESTAMP 
          WHERE id = $3
        `, [proofPhotoUrl || null, signatureUrl || null, delivery.id]);

        await dbQuery(`
          UPDATE orders SET status = 'delivered', tracking_step = 5 WHERE id = $1
        `, [orderId]);

        if (delivery.riderId) {
          await dbQuery(`
            UPDATE rider_availability 
            SET active_delivery_id = NULL, total_trips = total_trips + 1, total_earnings = total_earnings + 60, updated_at = CURRENT_TIMESTAMP
            WHERE id = $1
          `, [delivery.riderId]);
        }

        await dbQuery(`
          INSERT INTO delivery_audit_logs (delivery_id, order_id, actor_type, actor_id, event, previous_state, new_state)
          VALUES ($1, $2, 'RIDER', $3, 'DELIVERY_COMPLETED', $4, 'DELIVERED')
        `, [delivery.id, orderId, delivery.riderId || 'r1', delivery.status]);
      } catch (err) {
        console.warn("Error completing delivery in DB:", err);
      }
    }

    delivery.status = 'DELIVERED';
    delivery.proofPhotoUrl = proofPhotoUrl;
    delivery.signatureUrl = signatureUrl;
    delivery.updatedAt = new Date().toISOString();

    if (DB_STATE.activeOrder && DB_STATE.activeOrder.id === orderId) {
      DB_STATE.activeOrder.status = 'delivered';
      DB_STATE.activeOrder.trackingStep = 5;
    }

    if (delivery.riderId) {
      const r = DB_STATE.riders.find(rd => rd.id === delivery.riderId);
      if (r) {
        r.activeDeliveryId = null;
        r.totalTrips = (r.totalTrips || 0) + 1;
        r.totalEarnings = (r.totalEarnings || 0) + 60;
      }
    }

    return delivery;
  }

  // Record GPS telemetry entry
  static async recordGpsTelemetry(riderId: string, deliveryId: string | null, lat: number, lng: number, bearing: number = 0, speed: number = 0, battery: number = 100): Promise<void> {
    if (usePostgreSQL) {
      try {
        await dbQuery(`
          INSERT INTO gps_location_history (delivery_id, rider_id, latitude, longitude, bearing, speed, battery_level)
          VALUES ($1, $2, $3, $4, $5, $6, $7)
        `, [deliveryId, riderId, lat, lng, bearing, speed, battery]);
      } catch (err) {
        console.warn("Error recording GPS telemetry in DB:", err);
      }
    }

    DB_STATE.gpsLocationHistory.push({
      id: `gps_${Date.now()}`,
      deliveryId,
      riderId,
      latitude: lat,
      longitude: lng,
      bearing,
      speed,
      batteryLevel: battery,
      recordedAt: new Date().toISOString()
    });
  }

  // Fetch Audit Logs for an order
  static async getAuditLogs(orderId: string): Promise<any[]> {
    if (usePostgreSQL) {
      try {
        const res = await dbQuery("SELECT id, delivery_id, order_id, actor_type, actor_id, event, previous_state, new_state, payload, created_at FROM delivery_audit_logs WHERE order_id = $1 ORDER BY created_at ASC", [orderId]);
        return res.rows.map((row: any) => ({
          id: row.id,
          deliveryId: row.delivery_id,
          orderId: row.order_id,
          actorType: row.actor_type,
          actorId: row.actor_id,
          event: row.event,
          previousState: row.previous_state,
          newState: row.new_state,
          payload: row.payload,
          createdAt: row.created_at,
        }));
      } catch (err) {
        console.warn("Error fetching audit logs from DB:", err);
      }
    }
    return DB_STATE.deliveryAuditLogs.filter((a: any) => a.orderId === orderId);
  }
}
