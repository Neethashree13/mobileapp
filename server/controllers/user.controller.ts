import { Request, Response, NextFunction } from "express";
import { UserService } from "../services/user.service";
import { isProduction } from "../config/env";
import { usePostgreSQL } from "../config/database";

function getUserIdFromReq(req: Request): string {
  console.log("req.user =", (req as any).user);
 
  console.log("req.headers.authorization =", req.headers.authorization);

  return (
    (req as any).user?.uid ||
    (req as any).user?.id ||
    (req.query.userId as string) ||
    (req.headers["x-user-id"] as string) ||
    ""
  );
}

function getUserEmailFromReq(req: Request): string | undefined {
  return (req as any).user?.email;
}

export async function getProfile(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const email = getUserEmailFromReq(req);
    const profile = await UserService.getUserProfile(uid, email);
    res.json({ success: true, profile });
  } catch (error) {
    next(error);
  }
}

export async function updateProfile(req: Request, res: Response, next: NextFunction) {
  const { firstName, lastName, phoneNumber, gender, bio, profilePhoto } = req.body;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const updated = await UserService.updateUserProfile(uid, {
      firstName,
      lastName,
      phoneNumber,
      gender,
      bio,
      profilePhoto,
    });
    res.json({ success: true, profile: updated });
  } catch (error) {
    next(error);
  }
}

export async function uploadProfilePhoto(req: Request, res: Response, next: NextFunction) {
  const { photoUrl, photoBase64 } = req.body;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const finalPhoto = photoUrl || photoBase64 || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop";
    const profile = await UserService.updateProfilePhoto(uid, finalPhoto);
    res.json({ success: true, photoUrl: finalPhoto, profile });
  } catch (error) {
    next(error);
  }
}

export async function getAddresses(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const addresses = await UserService.getUserAddresses(uid);
    res.json({ success: true, addresses });
  } catch (error) {
    next(error);
  }
}

export async function addAddress(req: Request, res: Response, next: NextFunction) {
  const { title, addressLine1, addressLine2, houseNo, apartment, street, landmark, city, state, country, postalCode, pincode, latitude, longitude, isDefault } = req.body;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const newAddr = await UserService.addUserAddress(uid, {
      title,
      addressLine1,
      addressLine2,
      houseNo,
      apartment,
      street,
      landmark,
      city,
      state,
      country,
      postalCode: postalCode || pincode || "560102",
      latitude: Number(latitude || 12.9279),
      longitude: Number(longitude || 77.6250),
      isDefault: Boolean(isDefault),
    });
    res.json({ success: true, address: newAddr });
  } catch (error) {
    next(error);
  }
}

export async function updateAddress(req: Request, res: Response, next: NextFunction) {
  const addressId = req.params.id;
  const { title, addressLine1, addressLine2, houseNo, apartment, street, landmark, city, state, country, postalCode, pincode, latitude, longitude, isDefault } = req.body;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const updated = await UserService.updateUserAddress(uid, addressId, {
      title,
      addressLine1,
      addressLine2,
      houseNo,
      apartment,
      street,
      landmark,
      city,
      state,
      country,
      postalCode: postalCode || pincode || "560102",
      latitude: Number(latitude || 12.9279),
      longitude: Number(longitude || 77.6250),
      isDefault: Boolean(isDefault),
    });
    res.json({ success: true, address: updated });
  } catch (error) {
    next(error);
  }
}

export async function deleteAddress(req: Request, res: Response, next: NextFunction) {
  const addressId = req.params.id;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    await UserService.deleteUserAddress(uid, addressId);
    res.json({ success: true, message: "Address deleted successfully" });
  } catch (error) {
    next(error);
  }
}

export async function setDefaultAddress(req: Request, res: Response, next: NextFunction) {
  const addressId = req.params.id;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const addresses = await UserService.setDefaultUserAddress(uid, addressId);
    res.json({ success: true, addresses });
  } catch (error) {
    next(error);
  }
}

export async function getRecentlyUsedAddresses(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const addresses = await UserService.getRecentlyUsedAddresses(uid);
    res.json({ success: true, addresses });
  } catch (error) {
    next(error);
  }
}

export async function reverseGeocode(req: Request, res: Response, next: NextFunction) {
  const lat = Number(req.body.latitude || req.query.lat || 12.9279);
  const lng = Number(req.body.longitude || req.query.lng || 77.6250);
  try {
    const address = await UserService.reverseGeocode(lat, lng);
    res.json({ success: true, address });
  } catch (error) {
    next(error);
  }
}

export async function getPreferences(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const preferences = await UserService.getUserPreferences(uid);
    res.json({ success: true, preferences });
  } catch (error) {
    next(error);
  }
}

export async function updatePreferences(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const preferences = await UserService.updateUserPreferences(uid, req.body);
    res.json({ success: true, preferences });
  } catch (error) {
    next(error);
  }
}

export async function getSettings(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const settings = await UserService.getUserSettings(uid);
    res.json({ success: true, settings });
  } catch (error) {
    next(error);
  }
}

export async function updateSettings(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const settings = await UserService.updateUserSettings(uid, req.body);
    res.json({ success: true, settings });
  } catch (error) {
    next(error);
  }
}

export async function deleteAccount(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    await UserService.deleteUserAccount(uid);
    res.json({ success: true, message: "Account deleted successfully" });
  } catch (error) {
    next(error);
  }
}

export async function deactivateAccount(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    await UserService.deactivateUserAccount(uid);
    res.json({ success: true, message: "Account deactivated successfully" });
  } catch (error) {
    next(error);
  }
}

export async function getActivityHistory(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const history = await UserService.getActivityHistory(uid);
    res.json({ success: true, history });
  } catch (error) {
    next(error);
  }
}

export async function getReferralInfo(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const referral = await UserService.getReferralInfo(uid);
    res.json({ success: true, referral });
  } catch (error) {
    next(error);
  }
}

export async function getSearchHistory(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const history = await UserService.getSearchHistory(uid);
    res.json({ success: true, history });
  } catch (error) {
    next(error);
  }
}

export async function getLoginHistory(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const uid = getUserIdFromReq(req);
    const history = await UserService.getLoginHistory(uid);
    res.json({ success: true, history });
  } catch (error) {
    next(error);
  }
}
