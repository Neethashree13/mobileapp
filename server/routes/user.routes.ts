import { Router } from "express";
import * as userController from "../controllers/user.controller";
import { checkDbConnection, requireAuth } from "../middleware/dbCheck";
import { 
  validateBody, 
  profileUpdateSchema, 
  photoUploadSchema,
  addressSchema, 
  preferencesSchema, 
  settingsSchema 
} from "../validators/request.validators";

const router = Router();

// 1. Profile Endpoints
router.get("/users/me/profile", checkDbConnection, requireAuth, userController.getProfile);
router.get("/users/profile", checkDbConnection, requireAuth, userController.getProfile);

router.put("/users/me/profile", checkDbConnection, requireAuth, validateBody(profileUpdateSchema), userController.updateProfile);
router.put("/users/profile", checkDbConnection, requireAuth, validateBody(profileUpdateSchema), userController.updateProfile);
router.post("/users/profile/update", checkDbConnection, requireAuth, validateBody(profileUpdateSchema), userController.updateProfile);

router.post("/users/me/profile/photo", checkDbConnection, requireAuth, validateBody(photoUploadSchema), userController.uploadProfilePhoto);
router.post("/users/profile/photo", checkDbConnection, requireAuth, validateBody(photoUploadSchema), userController.uploadProfilePhoto);

// 2. Address Endpoints
router.get("/users/me/addresses", checkDbConnection, requireAuth, userController.getAddresses);
router.get("/users/addresses", checkDbConnection, requireAuth, userController.getAddresses);

router.get("/users/me/addresses/recently-used", checkDbConnection, requireAuth, userController.getRecentlyUsedAddresses);
router.get("/users/addresses/recently-used", checkDbConnection, requireAuth, userController.getRecentlyUsedAddresses);

router.post("/users/me/addresses/reverse-geocode", checkDbConnection, requireAuth, userController.reverseGeocode);
router.get("/users/me/addresses/reverse-geocode", checkDbConnection, requireAuth, userController.reverseGeocode);

router.post("/users/me/addresses", checkDbConnection, requireAuth, validateBody(addressSchema), userController.addAddress);
router.post("/users/addresses", checkDbConnection, requireAuth, validateBody(addressSchema), userController.addAddress);

router.put("/users/me/addresses/:id", checkDbConnection, requireAuth, userController.updateAddress);
router.put("/users/addresses/:id", checkDbConnection, requireAuth, userController.updateAddress);

router.put("/users/me/addresses/:id/default", checkDbConnection, requireAuth, userController.setDefaultAddress);
router.put("/users/addresses/:id/default", checkDbConnection, requireAuth, userController.setDefaultAddress);

router.delete("/users/me/addresses/:id", checkDbConnection, requireAuth, userController.deleteAddress);
router.delete("/users/addresses/:id", checkDbConnection, requireAuth, userController.deleteAddress);

// 3. Preferences & Settings
router.get("/users/me/preferences", checkDbConnection, requireAuth, userController.getPreferences);
router.get("/users/preferences", checkDbConnection, requireAuth, userController.getPreferences);

router.put("/users/me/preferences", checkDbConnection, requireAuth, validateBody(preferencesSchema), userController.updatePreferences);
router.put("/users/preferences", checkDbConnection, requireAuth, validateBody(preferencesSchema), userController.updatePreferences);

router.get("/users/me/settings", checkDbConnection, requireAuth, userController.getSettings);
router.get("/users/settings", checkDbConnection, requireAuth, userController.getSettings);

router.put("/users/me/settings", checkDbConnection, requireAuth, validateBody(settingsSchema), userController.updateSettings);
router.put("/users/settings", checkDbConnection, requireAuth, validateBody(settingsSchema), userController.updateSettings);

// 4. Account Management
router.delete("/users/me", checkDbConnection, requireAuth, userController.deleteAccount);
router.delete("/users", checkDbConnection, requireAuth, userController.deleteAccount);

router.post("/users/me/deactivate", checkDbConnection, requireAuth, userController.deactivateAccount);
router.post("/users/deactivate", checkDbConnection, requireAuth, userController.deactivateAccount);

// 5. Activity & Referrals
router.get("/users/me/activity", checkDbConnection, requireAuth, userController.getActivityHistory);
router.get("/users/activity", checkDbConnection, requireAuth, userController.getActivityHistory);

router.get("/users/me/referral", checkDbConnection, requireAuth, userController.getReferralInfo);
router.get("/users/referral", checkDbConnection, requireAuth, userController.getReferralInfo);

router.get("/search/history", checkDbConnection, requireAuth, userController.getSearchHistory);
router.get("/login/history", checkDbConnection, requireAuth, userController.getLoginHistory);

export default router;
