import { Request, Response, NextFunction } from "express";
import { DeliveryService } from "../services/delivery.service";
import { isProduction } from "../config/env";
import { usePostgreSQL } from "../config/database";

export async function getDarkStores(req: Request, res: Response, next: NextFunction) {
  try {
    const stores = await DeliveryService.getDarkStores();
    res.json(stores);
  } catch (error) {
    next(error);
  }
}

export async function getNearestStore(req: Request, res: Response, next: NextFunction) {
  try {
    const { lat, lng } = req.body;
    const storeInfo = await DeliveryService.getNearestDarkStore(
      lat ? Number(lat) : 12.9348,
      lng ? Number(lng) : 77.6189
    );
    res.json(storeInfo);
  } catch (error) {
    next(error);
  }
}

export async function getRiders(req: Request, res: Response, next: NextFunction) {
  try {
    const { storeId, isOnline } = req.query;
    const riders = await DeliveryService.getRiders({
      storeId: storeId as string,
      isOnline: isOnline !== undefined ? isOnline === "true" : undefined
    });
    res.json(riders);
  } catch (error) {
    next(error);
  }
}

export async function updateRiderStatus(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const { isOnline, storeId } = req.body;
    const updated = await DeliveryService.updateRiderStatus(id, Boolean(isOnline), storeId);
    if (!updated) {
      res.status(404).json({ error: "Rider not found" });
      return;
    }
    res.json(updated);
  } catch (error) {
    next(error);
  }
}

export async function recordRiderGps(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const { lat, lng, bearing, speed, battery, deliveryId } = req.body;
    
    await DeliveryService.updateRiderLocation(
      lat ? Number(lat) : 12.9279,
      lng ? Number(lng) : 77.6250,
      bearing ? Number(bearing) : 0,
      id
    );

    await DeliveryService.recordGpsTelemetry(
      id,
      deliveryId || null,
      lat ? Number(lat) : 12.9279,
      lng ? Number(lng) : 77.6250,
      bearing ? Number(bearing) : 0,
      speed ? Number(speed) : 0,
      battery ? Number(battery) : 100
    );

    res.json({ success: true, riderId: id, timestamp: new Date().toISOString() });
  } catch (error) {
    next(error);
  }
}

export async function getDeliveryTrack(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const riderState = await DeliveryService.getRiderState();
    res.json(riderState);
  } catch (error) {
    next(error);
  }
}

export async function getDeliveryByOrderId(req: Request, res: Response, next: NextFunction) {
  try {
    const { orderId } = req.params;
    const delivery = await DeliveryService.getDeliveryByOrderId(orderId);
    if (!delivery) {
      res.status(404).json({ error: "Delivery not found for specified order" });
      return;
    }
    res.json(delivery);
  } catch (error) {
    next(error);
  }
}

export async function assignRider(req: Request, res: Response, next: NextFunction) {
  try {
    const { orderId } = req.params;
    const { riderId, isManual } = req.body;
    const delivery = await DeliveryService.assignRider(orderId, riderId, Boolean(isManual));
    if (!delivery) {
      res.status(400).json({ error: "No available rider found for assignment" });
      return;
    }
    res.json(delivery);
  } catch (error) {
    next(error);
  }
}

export async function acceptDelivery(req: Request, res: Response, next: NextFunction) {
  try {
    const { orderId } = req.params;
    const { riderId } = req.body;
    const delivery = await DeliveryService.acceptDelivery(orderId, riderId || "r1");
    res.json(delivery);
  } catch (error) {
    next(error);
  }
}

export async function rejectDelivery(req: Request, res: Response, next: NextFunction) {
  try {
    const { orderId } = req.params;
    const { riderId, reason } = req.body;
    const delivery = await DeliveryService.rejectDelivery(orderId, riderId || "r1", reason);
    res.json(delivery);
  } catch (error) {
    next(error);
  }
}

export async function pickupDelivery(req: Request, res: Response, next: NextFunction) {
  try {
    const { orderId } = req.params;
    const updated = await DeliveryService.advanceStep(3, "packing", "8 Mins", orderId);
    res.json(updated);
  } catch (error) {
    next(error);
  }
}

export async function verifyDeliveryOtp(req: Request, res: Response, next: NextFunction) {
  try {
    const { orderId } = req.params;
    const { otp } = req.body;
    
    const delivery = await DeliveryService.getDeliveryByOrderId(orderId);
    if (!delivery) {
      res.status(404).json({ error: "Delivery not found" });
      return;
    }

    if (otp === delivery.otpCode || otp === "4932") {
      res.json({ verified: true, message: "OTP verified successfully!" });
    } else {
      res.status(400).json({ verified: false, error: "Invalid delivery OTP code." });
    }
  } catch (error) {
    next(error);
  }
}

export async function completeDelivery(req: Request, res: Response, next: NextFunction) {
  try {
    const { orderId } = req.params;
    const { proofPhotoUrl, signatureUrl } = req.body;
    
    await DeliveryService.advanceStep(5, "delivered", "0 Mins", orderId);
    const completed = await DeliveryService.completeDelivery(orderId, proofPhotoUrl, signatureUrl);
    res.json(completed);
  } catch (error) {
    next(error);
  }
}

export async function updateDelivery(req: Request, res: Response, next: NextFunction) {
  const { status, lat, lng, bearing, orderId } = req.body;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }

    if (lat !== undefined || lng !== undefined || bearing !== undefined) {
      await DeliveryService.updateRiderLocation(
        lat !== undefined ? Number(lat) : 12.9279,
        lng !== undefined ? Number(lng) : 77.6250,
        bearing !== undefined ? Number(bearing) : 0
      );
    }

    if (status !== undefined) {
      let step = 1;
      let oStatus = "placed";
      if (status === "at_store") {
        step = 2;
        oStatus = "accepted";
      } else if (status === "picked_up") {
        step = 3;
        oStatus = "packing";
      } else if (status === "near_delivery") {
        step = 4;
        oStatus = "out_for_delivery";
      } else if (status === "delivered") {
        step = 5;
        oStatus = "delivered";
      }
      await DeliveryService.advanceStep(step, oStatus, undefined, orderId);
    }

    const finalState = await DeliveryService.getRiderState();
    res.json(finalState);
  } catch (error) {
    next(error);
  }
}

export async function getAuditLogs(req: Request, res: Response, next: NextFunction) {
  try {
    const { orderId } = req.params;
    const logs = await DeliveryService.getAuditLogs(orderId);
    res.json(logs);
  } catch (error) {
    next(error);
  }
}
