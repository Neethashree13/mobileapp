import { dbQuery, usePostgreSQL } from "../config/database";
import { DB_STATE } from "../config/dbState";

export interface UserProfile {
  id: string;
  firebaseUid: string;
  email: string;
  firstName: string;
  lastName: string;
  phoneNumber: string;
  walletBalance: number;
  streakCount: number;
  profilePhoto?: string;
  profileImage?: string;
  gender?: string;
  bio?: string;
  lastLogin?: string;
  completionPercentage?: number;
  referralCode?: string;
  isVerified?: boolean;
  isActive?: boolean;
}

export interface Address {
  id?: string;
  user_id?: string;
  title: string;
  addressLine1: string;
  addressLine2?: string;
  houseNo?: string;
  apartment?: string;
  street?: string;
  landmark?: string;
  city: string;
  state: string;
  country?: string;
  postalCode: string;
  pincode?: string;
  latitude: number;
  longitude: number;
  isDefault: boolean;
  createdAt?: string;
  updatedAt?: string;
  lastUsedAt?: string;
}

export interface UserPreferences {
  emailNotifications: boolean;
  pushNotifications: boolean;
  smsNotifications: boolean;
  promotionalAlerts: boolean;
  orderUpdates: boolean;
  deliveryAlerts: boolean;
  language: string;
  dietary: string[];
  shareDataWithPartners: boolean;
  personalizedAds: boolean;
  locationTracking: boolean;
}

export interface UserSettings {
  isDarkMode: boolean;
  biometricsEnabled: boolean;
  cacheSizeMb: number;
}

export interface ReferralInfo {
  referralCode: string;
  referralLink: string;
  totalReferrals: number;
  totalEarnings: number;
  rewardPoints: number;
}

export interface ActivityLogEntry {
  id: string;
  actionType: string;
  details: string;
  createdAt: string;
}

export interface SearchHistoryEntry {
  id: string;
  query: string;
  mood: string;
  createdAt: string;
}

export interface LoginHistoryEntry {
  id: string;
  loginTime: string;
  ipAddress: string;
  deviceInfo: string;
  status: string;
}

export class UserRepository {
  static async registerOrGet(
    firebaseUid: string,
    email: string,
    firstName?: string,
    lastName?: string,
    phoneNumber?: string,
    profilePhoto?: string
  ): Promise<any> {

    console.log("firebaseUid:", firebaseUid);
console.log("firebaseUid length:", firebaseUid?.length);
    if (usePostgreSQL) {
      const check = await dbQuery(`
        SELECT id, firebase_uid as "firebaseUid", email, first_name as "firstName", last_name as "lastName", 
               phone_number as "phoneNumber", wallet_balance as "walletBalance", streak_count as "streakCount", 
               profile_photo as "profilePhoto", profile_image as "profileImage", gender, last_login as "lastLogin" 
        FROM users WHERE firebase_uid = $1
      `, [firebaseUid]);
      
      if (check.rows.length === 0) {
        const insertRes = await dbQuery(`
          INSERT INTO users (firebase_uid, email, first_name, last_name, phone_number, profile_photo, profile_image, last_login, wallet_balance, streak_count)
          VALUES ($1, $2, $3, $4, $5, $6, $6, CURRENT_TIMESTAMP, 1200.00, 1) 
          RETURNING id, firebase_uid as "firebaseUid", email, first_name as "firstName", last_name as "lastName", 
                    phone_number as "phoneNumber", wallet_balance as "walletBalance", streak_count as "streakCount", 
                    profile_photo as "profilePhoto", profile_image as "profileImage", gender, last_login as "lastLogin"
        `, [firebaseUid, email, firstName || "", lastName || "", phoneNumber || "", profilePhoto || null]);
        return insertRes.rows[0];
      } else {
        const updateRes = await dbQuery(`
          UPDATE users 
          SET email = $1, 
              first_name = COALESCE($2, first_name), 
              last_name = COALESCE($3, last_name), 
              phone_number = COALESCE($4, phone_number),
              profile_photo = COALESCE($5, profile_photo),
              profile_image = COALESCE($5, profile_image),
              last_login = CURRENT_TIMESTAMP
          WHERE firebase_uid = $6
          RETURNING id, firebase_uid as "firebaseUid", email, first_name as "firstName", last_name as "lastName", 
                    phone_number as "phoneNumber", wallet_balance as "walletBalance", streak_count as "streakCount", 
                    profile_photo as "profilePhoto", profile_image as "profileImage", gender, last_login as "lastLogin"
        `, [email, firstName || null, lastName || null, phoneNumber || null, profilePhoto || null, firebaseUid]);
        return updateRes.rows[0];
      }
    }
    return {
      id: "u1",
      firebaseUid,
      email,
      firstName: firstName || "Arav",
      lastName: lastName || "Sharma",
      phoneNumber: phoneNumber || "+91 98765 43210",
      profilePhoto: profilePhoto || "",
      profileImage: profilePhoto || "",
      gender: "unspecified",
      lastLogin: new Date().toISOString(),
      walletBalance: 1200.00,
      streakCount: 1,
    };
  }

  static async logLogin(
    userId: string,
    ipAddress: string,
    deviceInfo: string
  ): Promise<void> {
    if (usePostgreSQL) {
      const userRes = await dbQuery("SELECT id FROM users WHERE firebase_uid = $1 OR id = $2", [userId, userId]);
      if (userRes.rows.length > 0) {
        const realId = userRes.rows[0].id;
        await dbQuery(`
          INSERT INTO login_history (user_id, ip_address, device_info, status)
          VALUES ($1, $2, $3, 'success')
        `, [realId, ipAddress, deviceInfo]);
      }
    }
  }

  static async getProfile(firebaseUid: string = "", email?: string): Promise<UserProfile> {
    let profileData: any = null;
    let addressCount = 0;

    if (usePostgreSQL) {
      let { rows } = await dbQuery(`
        SELECT id, firebase_uid as "firebaseUid", email, first_name as "firstName", last_name as "lastName", 
               phone_number as "phoneNumber", phone, wallet_balance as "walletBalance", streak_count as "streakCount", 
               profile_photo as "profilePhoto", profile_image as "profileImage", gender, is_verified as "isVerified", 
               is_active as "isActive", last_login as "lastLogin"
        FROM users WHERE firebase_uid = $1 OR id::text = $1 LIMIT 1
      `, [firebaseUid]);
      
      if (rows.length === 0) {
        const resolvedEmail = email || `${firebaseUid}@example.com`;
        const emailPrefix = resolvedEmail.split('@')[0];
        const firstName = emailPrefix.charAt(0).toUpperCase() + emailPrefix.slice(1);
        await this.registerOrGet(firebaseUid, resolvedEmail, firstName, "User");
        const res = await dbQuery(`
          SELECT id, firebase_uid as "firebaseUid", email, first_name as "firstName", last_name as "lastName", 
                 phone_number as "phoneNumber", phone, wallet_balance as "walletBalance", streak_count as "streakCount", 
                 profile_photo as "profilePhoto", profile_image as "profileImage", gender, is_verified as "isVerified", 
                 is_active as "isActive", last_login as "lastLogin"
          FROM users WHERE firebase_uid = $1 OR id::text = $1 LIMIT 1
        `, [firebaseUid]);
        rows = res.rows;
      }

      if (rows.length > 0) {
        profileData = rows[0];
        if (!profileData.firstName) {
          const emailPrefix = (profileData.email || "User").split("@")[0];
          profileData.firstName = emailPrefix.charAt(0).toUpperCase() + emailPrefix.slice(1);
        }
        if (!profileData.lastName) {
          profileData.lastName = "";
        }
        profileData.phoneNumber = profileData.phoneNumber || profileData.phone || "";
        profileData.walletBalance = Number(profileData.walletBalance || 0);

        // Fetch address count for completion percentage
        const addrRes = await dbQuery("SELECT COUNT(*) as count FROM addresses WHERE user_id = $1", [profileData.id]);
        addressCount = parseInt(addrRes.rows[0]?.count || "0", 10);
      }
    }

    if (!profileData) {
      profileData = {
        id: "u1",
        firebaseUid: firebaseUid,
        email: email || `${firebaseUid}@example.com`,
        firstName: email ? email.split('@')[0] : "Customer",
        lastName: "",
        phoneNumber: "",
        walletBalance: DB_STATE.walletBalance || 0.0,
        streakCount: 5,
        profilePhoto: (DB_STATE as any).profilePhoto || "",
        profileImage: (DB_STATE as any).profilePhoto || "",
        gender: "unspecified",
        bio: "Avid quick-commerce shopper",
        isVerified: true,
        isActive: true,
        lastLogin: new Date().toISOString(),
      };
      addressCount = DB_STATE.addresses ? DB_STATE.addresses.length : 1;
    }

    // Calculate completion percentage:
    // Name (20%), Email (20%), Phone (20%), Photo (20%), Address (20%)
    let completion = 0;
    if (profileData.firstName && profileData.firstName.trim().length > 0) completion += 20;
    if (profileData.email && profileData.email.includes("@")) completion += 20;
    if (profileData.phoneNumber && profileData.phoneNumber.trim().length >= 5) completion += 20;
    if (profileData.profilePhoto || profileData.profileImage) completion += 20;
    if (addressCount > 0) completion += 20;

    const referralCode = "FLASH" + (profileData.firstName || "USER").toUpperCase() + "99";

    return {
      ...profileData,
      completionPercentage: completion,
      referralCode,
    };
  }

  static async updateProfile(
    firebaseUid: string,
    data: {
      firstName?: string;
      lastName?: string;
      phoneNumber?: string;
      gender?: string;
      bio?: string;
      profilePhoto?: string;
    }
  ): Promise<void> {
    if (usePostgreSQL) {
      await dbQuery(`
        UPDATE users SET 
          first_name = COALESCE($1, first_name), 
          last_name = COALESCE($2, last_name), 
          phone_number = COALESCE($3, phone_number),
          phone = COALESCE($3, phone),
          gender = COALESCE($4, gender),
          profile_photo = COALESCE($5, profile_photo),
          profile_image = COALESCE($5, profile_image)
        WHERE firebase_uid = $6 OR id::text = $6
      `, [data.firstName, data.lastName, data.phoneNumber, data.gender, data.profilePhoto, firebaseUid]);
    } else {
      if (data.firstName) (DB_STATE as any).customerName = data.firstName + " " + (data.lastName || "");
      if (data.profilePhoto) (DB_STATE as any).profilePhoto = data.profilePhoto;
    }
  }

  static async updateProfilePhoto(firebaseUid: string, photoUrl: string): Promise<string> {
    if (usePostgreSQL) {
      await dbQuery(`
        UPDATE users SET profile_photo = $1, profile_image = $1 WHERE firebase_uid = $2 OR id::text = $2
      `, [photoUrl, firebaseUid]);
    } else {
      (DB_STATE as any).profilePhoto = photoUrl;
    }
    return photoUrl;
  }

  static async getAddresses(firebaseUid: string = ""): Promise<Address[]> {
    if (usePostgreSQL) {
      let userRes = await dbQuery("SELECT id FROM users WHERE firebase_uid = $1 OR id::text = $1 LIMIT 1", [firebaseUid]);
      let userId = userRes.rows[0]?.id;
      if (!userId) {
        const anyUser = await dbQuery("SELECT id FROM users LIMIT 1");
        userId = anyUser.rows[0]?.id;
      }
      if (!userId) {
        return [];
      }
      const { rows } = await dbQuery(`
        SELECT id, title, address_line_1 as "addressLine1", address_line_2 as "addressLine2", 
               house_no as "houseNo", apartment, street, landmark, city, state, country, 
               postal_code as "postalCode", pincode, latitude, longitude, is_default as "isDefault",
               created_at as "createdAt", updated_at as "updatedAt"
        FROM addresses WHERE user_id = $1
        ORDER BY is_default DESC, updated_at DESC
      `, [userId]);
      return rows.map((r) => ({
        ...r,
        postalCode: r.postalCode || r.pincode || "",
        latitude: Number(r.latitude),
        longitude: Number(r.longitude),
      }));
    }
    return DB_STATE.addresses as Address[];
  }

  static async addAddress(firebaseUid: string, addr: Address): Promise<Address> {
    const newId = "ad_" + Math.random().toString(36).substring(2, 9);
    if (usePostgreSQL) {
      let userRes = await dbQuery("SELECT id FROM users WHERE firebase_uid = $1 OR id::text = $1 LIMIT 1", [firebaseUid]);
      let userId = userRes.rows[0]?.id;
      if (!userId) {
        const anyUser = await dbQuery("SELECT id FROM users LIMIT 1");
        if (anyUser.rows.length > 0) {
          userId = anyUser.rows[0].id;
          await dbQuery("UPDATE users SET firebase_uid = $1 WHERE id = $2 AND (firebase_uid IS NULL OR firebase_uid = '')", [firebaseUid, userId]);
        } else {
          const createRes = await dbQuery("INSERT INTO users (email, first_name, firebase_uid) VALUES ($1, $2, $3) RETURNING id", ["user@flashcart.ai", "Valued Customer", firebaseUid]);
          userId = createRes.rows[0]?.id;
        }
      }

      if (addr.isDefault) {
        await dbQuery("UPDATE addresses SET is_default = false WHERE user_id = $1", [userId]);
      }

      const pCode = addr.postalCode || addr.pincode || "560102";
      const insertRes = await dbQuery(`
        INSERT INTO addresses (user_id, title, address_line_1, address_line_2, house_no, apartment, street, landmark, city, state, country, postal_code, pincode, latitude, longitude, is_default)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
        RETURNING id, title, address_line_1 as "addressLine1", address_line_2 as "addressLine2", house_no as "houseNo", apartment, street, landmark, city, state, postal_code as "postalCode", latitude, longitude, is_default as "isDefault"
      `, [
        userId,
        addr.title || "Home",
        addr.addressLine1 || "Default Address Line 1",
        addr.addressLine2 || "",
        addr.houseNo || "",
        addr.apartment || "",
        addr.street || "",
        addr.landmark || "",
        addr.city || "Bangalore",
        addr.state || "Karnataka",
        addr.country || "India",
        pCode,
        pCode,
        Number(addr.latitude || 12.9279),
        Number(addr.longitude || 77.6250),
        addr.isDefault || false,
      ]);

      const inserted = insertRes.rows[0];
      return {
        ...inserted,
        latitude: Number(inserted.latitude),
        longitude: Number(inserted.longitude),
      };
    }

    if (addr.isDefault) {
      DB_STATE.addresses = DB_STATE.addresses.map((a: any) => ({ ...a, isDefault: false }));
    }

    const newAddr: Address = {
      id: newId,
      title: addr.title || "Home",
      addressLine1: addr.addressLine1,
      addressLine2: addr.addressLine2 || "",
      landmark: addr.landmark || "",
      city: addr.city,
      state: addr.state,
      country: addr.country || "India",
      postalCode: addr.postalCode || "560102",
      latitude: addr.latitude || 12.9279,
      longitude: addr.longitude || 77.6250,
      isDefault: addr.isDefault || false,
    };
    DB_STATE.addresses.push(newAddr as any);
    return newAddr;
  }

  static async updateAddress(firebaseUid: string, addressId: string, addr: Address): Promise<Address> {
    if (usePostgreSQL) {
      const userRes = await dbQuery("SELECT id FROM users WHERE firebase_uid = $1 OR id::text = $1 LIMIT 1", [firebaseUid]);
      const userId = userRes.rows[0]?.id;

      if (addr.isDefault) {
        await dbQuery("UPDATE addresses SET is_default = false WHERE user_id = $1", [userId]);
      }

      await dbQuery(`
        UPDATE addresses SET
          title = COALESCE($1, title),
          address_line_1 = COALESCE($2, address_line_1),
          address_line_2 = COALESCE($3, address_line_2),
          landmark = COALESCE($4, landmark),
          city = COALESCE($5, city),
          state = COALESCE($6, state),
          postal_code = COALESCE($7, postal_code),
          pincode = COALESCE($7, pincode),
          latitude = COALESCE($8, latitude),
          longitude = COALESCE($9, longitude),
          is_default = COALESCE($10, is_default),
          updated_at = CURRENT_TIMESTAMP
        WHERE id::text = $11 AND user_id = $12
      `, [
        addr.title, addr.addressLine1, addr.addressLine2, addr.landmark, addr.city, addr.state,
        addr.postalCode, addr.latitude, addr.longitude, addr.isDefault, addressId, userId
      ]);

      return {
        ...addr,
        id: addressId,
      };
    }

    DB_STATE.addresses = DB_STATE.addresses.map((a: any) => {
      if (a.id === addressId) {
        return { ...a, ...addr };
      }
      if (addr.isDefault) return { ...a, isDefault: false };
      return a;
    });

    return { ...addr, id: addressId };
  }

  static async deleteAddress(firebaseUid: string, addressId: string): Promise<void> {
    if (usePostgreSQL) {
      await dbQuery(`
        DELETE FROM addresses WHERE id::text = $1 AND user_id IN (SELECT id FROM users WHERE firebase_uid = $2 OR id::text = $2)
      `, [addressId, firebaseUid]);
      return;
    }
    DB_STATE.addresses = DB_STATE.addresses.filter((a: any) => a.id !== addressId);
  }

  static async setDefaultAddress(firebaseUid: string, addressId: string): Promise<void> {
    if (usePostgreSQL) {
      const userRes = await dbQuery("SELECT id FROM users WHERE firebase_uid = $1 OR id::text = $1 LIMIT 1", [firebaseUid]);
      const userId = userRes.rows[0]?.id;
      if (userId) {
        await dbQuery("UPDATE addresses SET is_default = false WHERE user_id = $1", [userId]);
        await dbQuery("UPDATE addresses SET is_default = true WHERE id::text = $2 AND user_id = $1", [userId, addressId]);
      }
      return;
    }
    DB_STATE.addresses = DB_STATE.addresses.map((a: any) => ({
      ...a,
      isDefault: a.id === addressId,
    }));
  }

  static async getRecentlyUsedAddresses(firebaseUid: string = ""): Promise<Address[]> {
    const addresses = await this.getAddresses(firebaseUid);
    return addresses.slice(0, 3);
  }

  static async getPreferences(firebaseUid: string = ""): Promise<UserPreferences> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT email_notifications as "emailNotifications", push_notifications as "pushNotifications",
               sms_notifications as "smsNotifications", promotional_alerts as "promotionalAlerts",
               order_updates as "orderUpdates", delivery_alerts as "deliveryAlerts", language,
               dietary, share_data_with_partners as "shareDataWithPartners",
               personalized_ads as "personalizedAds", location_tracking as "locationTracking"
        FROM user_preferences WHERE user_id IN (SELECT id FROM users WHERE firebase_uid = $1 OR id = $1) LIMIT 1
      `, [firebaseUid]);
      
      if (rows.length > 0) return rows[0];
    }

    if ((DB_STATE as any).userPreferences) {
      return (DB_STATE as any).userPreferences;
    }

    const defaultPrefs: UserPreferences = {
      emailNotifications: true,
      pushNotifications: true,
      smsNotifications: false,
      promotionalAlerts: true,
      orderUpdates: true,
      deliveryAlerts: true,
      language: "English (US)",
      dietary: ["Vegetarian", "Gluten-Free"],
      shareDataWithPartners: false,
      personalizedAds: true,
      locationTracking: true,
    };
    (DB_STATE as any).userPreferences = defaultPrefs;
    return defaultPrefs;
  }

  static async updatePreferences(firebaseUid: string, prefs: Partial<UserPreferences>): Promise<UserPreferences> {
    const current = await this.getPreferences(firebaseUid);
    const updated = { ...current, ...prefs };

    if (usePostgreSQL) {
      const userRes = await dbQuery("SELECT id FROM users WHERE firebase_uid = $1 OR id::text = $1 LIMIT 1", [firebaseUid]);
      const userId = userRes.rows[0]?.id;
      if (userId) {
        await dbQuery(`
          INSERT INTO user_preferences (user_id, email_notifications, push_notifications, sms_notifications, promotional_alerts, order_updates, delivery_alerts, language, dietary, share_data_with_partners, personalized_ads, location_tracking)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
          ON CONFLICT (user_id) DO UPDATE SET
            email_notifications = $2, push_notifications = $3, sms_notifications = $4,
            promotional_alerts = $5, order_updates = $6, delivery_alerts = $7,
            language = $8, dietary = $9, share_data_with_partners = $10,
            personalized_ads = $11, location_tracking = $12, updated_at = CURRENT_TIMESTAMP
        `, [
          userId, updated.emailNotifications, updated.pushNotifications, updated.smsNotifications,
          updated.promotionalAlerts, updated.orderUpdates, updated.deliveryAlerts, updated.language,
          updated.dietary, updated.shareDataWithPartners, updated.personalizedAds, updated.locationTracking
        ]);
      }
    }

    (DB_STATE as any).userPreferences = updated;
    return updated;
  }

  static async getSettings(firebaseUid: string = ""): Promise<UserSettings> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT is_dark_mode as "isDarkMode", biometrics_enabled as "biometricsEnabled", cache_size_mb as "cacheSizeMb"
        FROM user_settings WHERE user_id IN (SELECT id FROM users WHERE firebase_uid = $1 OR id::text = $1) LIMIT 1
      `, [firebaseUid]);
      if (rows.length > 0) return rows[0];
    }

    if ((DB_STATE as any).userSettings) {
      return (DB_STATE as any).userSettings;
    }

    const defaultSettings: UserSettings = {
      isDarkMode: false,
      biometricsEnabled: true,
      cacheSizeMb: 42,
    };
    (DB_STATE as any).userSettings = defaultSettings;
    return defaultSettings;
  }

  static async updateSettings(firebaseUid: string, settings: Partial<UserSettings>): Promise<UserSettings> {
    const current = await this.getSettings(firebaseUid);
    const updated = { ...current, ...settings };

    if (usePostgreSQL) {
      const userRes = await dbQuery("SELECT id FROM users WHERE firebase_uid = $1 OR id::text = $1 LIMIT 1", [firebaseUid]);
      const userId = userRes.rows[0]?.id;
      if (userId) {
        await dbQuery(`
          INSERT INTO user_settings (user_id, is_dark_mode, biometrics_enabled, cache_size_mb)
          VALUES ($1, $2, $3, $4)
          ON CONFLICT (user_id) DO UPDATE SET
            is_dark_mode = $2, biometrics_enabled = $3, cache_size_mb = $4, updated_at = CURRENT_TIMESTAMP
        `, [userId, updated.isDarkMode, updated.biometricsEnabled, updated.cacheSizeMb]);
      }
    }

    (DB_STATE as any).userSettings = updated;
    return updated;
  }

  static async deleteAccount(firebaseUid: string): Promise<void> {
    if (usePostgreSQL) {
      await dbQuery("DELETE FROM users WHERE firebase_uid = $1 OR id::text = $1", [firebaseUid]);
    } else {
      const users = (DB_STATE as any).users || [];
      (DB_STATE as any).users = users.filter((u: any) => u.firebaseUid !== firebaseUid && u.id !== firebaseUid);
    }
  }

  static async deactivateAccount(firebaseUid: string): Promise<void> {
    if (usePostgreSQL) {
      await dbQuery("UPDATE users SET is_active = false WHERE firebase_uid = $1 OR id::text = $1", [firebaseUid]);
    } else {
      const user = (DB_STATE as any).users?.find((u: any) => u.firebaseUid === firebaseUid);
      if (user) user.isActive = false;
    }
  }

  static async getActivityHistory(firebaseUid: string = ""): Promise<ActivityLogEntry[]> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, action_type as "actionType", details, created_at as "createdAt"
        FROM activity_logs WHERE user_id IN (SELECT id FROM users WHERE firebase_uid = $1 OR id::text = $1)
        ORDER BY created_at DESC LIMIT 30
      `, [firebaseUid]);
      return rows;
    }

    return [
      { id: "act_1", actionType: "login", details: "Logged in via Google Auth", createdAt: new Date().toISOString() },
      { id: "act_2", actionType: "address_add", details: "Saved Home Address in Harlur, Bengaluru", createdAt: new Date(Date.now() - 3600000).toISOString() },
      { id: "act_3", actionType: "profile_update", details: "Updated profile phone number", createdAt: new Date(Date.now() - 86400000).toISOString() },
    ];
  }

  static async getReferralInfo(firebaseUid: string = ""): Promise<ReferralInfo> {
    const profile = await this.getProfile(firebaseUid);
    const code = profile.referralCode || "FLASHARAV99";
    return {
      referralCode: code,
      referralLink: `https://flashcart.ai/ref/${code}`,
      totalReferrals: 8,
      totalEarnings: 400.0,
      rewardPoints: 1200,
    };
  }

  static async addSearchHistory(firebaseUid: string, query: string, mood?: string): Promise<void> {
    if (usePostgreSQL) {
      const userRes = await dbQuery("SELECT id FROM users WHERE firebase_uid = $1 OR id::text = $1", [firebaseUid]);
      if (userRes.rows.length > 0) {
        const userId = userRes.rows[0].id;
        await dbQuery(`
          INSERT INTO search_history (user_id, query_text, mood_tag)
          VALUES ($1, $2, $3)
        `, [userId, query, mood || ""]);
      }
    }
  }

  static async getSearchHistory(firebaseUid: string = ""): Promise<SearchHistoryEntry[]> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, query_text as "query", mood_tag as "mood", created_at as "createdAt"
        FROM search_history WHERE user_id IN (SELECT id FROM users WHERE firebase_uid = $1 OR id::text = $1) ORDER BY created_at DESC LIMIT 20
      `, [firebaseUid]);
      return rows;
    }
    return [
      { id: "sh1", query: "English Cucumber", mood: "Gym", createdAt: new Date().toISOString() },
      { id: "sh2", query: "Fresh Paneer", mood: "Lazy", createdAt: new Date().toISOString() },
    ];
  }

  static async getLoginHistory(firebaseUid: string = ""): Promise<LoginHistoryEntry[]> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, login_time as "loginTime", ip_address as "ipAddress", device_info as "deviceInfo", status
        FROM login_history WHERE user_id IN (SELECT id FROM users WHERE firebase_uid = $1 OR id::text = $1) ORDER BY login_time DESC LIMIT 20
      `, [firebaseUid]);
      return rows;
    }
    return [
      {
        id: "lh1",
        loginTime: new Date().toISOString(),
        ipAddress: "127.0.0.1",
        deviceInfo: "Sandbox iPhone Simulator",
        status: "success",
      },
    ];
  }

  static async getWalletBalance(firebaseUid: string = ""): Promise<number> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery("SELECT wallet_balance as balance FROM users WHERE firebase_uid = $1 OR id::text = $1", [firebaseUid]);
      if (rows.length > 0) {
        return Number(rows[0].balance);
      }
    }
    return DB_STATE.walletBalance;
  }

  static async updateWalletBalance(firebaseUid: string, amount: number): Promise<number> {
    if (usePostgreSQL) {
      await dbQuery("UPDATE users SET wallet_balance = wallet_balance + $1 WHERE firebase_uid = $2 OR id::text = $2", [amount, firebaseUid]);
      return this.getWalletBalance(firebaseUid);
    }
    DB_STATE.walletBalance += amount;
    return DB_STATE.walletBalance;
  }

  static async findByEmail(email: string): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, firebase_uid as "firebaseUid", email, password_hash as "passwordHash", 
               first_name as "firstName", last_name as "lastName", phone as "phone", 
               phone_number as "phoneNumber", wallet_balance as "walletBalance", 
               streak_count as "streakCount", profile_image as "profileImage", 
               profile_photo as "profilePhoto", gender, is_verified as "isVerified", 
               is_active as "isActive", last_login as "lastLogin"
        FROM users WHERE email = $1 LIMIT 1
      `, [email]);
      return rows[0] || null;
    }
    const user = (DB_STATE as any).users?.find((u: any) => u.email === email);
    return user || null;
  }

  static async findByPhone(phone: string): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, firebase_uid as "firebaseUid", email, password_hash as "passwordHash", 
               first_name as "firstName", last_name as "lastName", phone as "phone", 
               phone_number as "phoneNumber", wallet_balance as "walletBalance", 
               streak_count as "streakCount", profile_image as "profileImage", 
               profile_photo as "profilePhoto", gender, is_verified as "isVerified", 
               is_active as "isActive", last_login as "lastLogin"
        FROM users WHERE phone = $1 OR phone_number = $1 LIMIT 1
      `, [phone]);
      return rows[0] || null;
    }
    const user = (DB_STATE as any).users?.find((u: any) => u.phone === phone || u.phoneNumber === phone);
    return user || null;
  }

  static async findById(id: string): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, firebase_uid as "firebaseUid", email, password_hash as "passwordHash", 
               first_name as "firstName", last_name as "lastName", phone as "phone", 
               phone_number as "phoneNumber", wallet_balance as "walletBalance", 
               streak_count as "streakCount", profile_image as "profileImage", 
               profile_photo as "profilePhoto", gender, is_verified as "isVerified", 
               is_active as "isActive", last_login as "lastLogin"
        FROM users WHERE id = $1 LIMIT 1
      `, [id]);
      return rows[0] || null;
    }
    const user = (DB_STATE as any).users?.find((u: any) => u.id === id);
    return user || null;
  }

  static async findByFirebaseUid(firebaseUid: string): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, firebase_uid as "firebaseUid", email, password_hash as "passwordHash", 
               first_name as "firstName", last_name as "lastName", phone as "phone", 
               phone_number as "phoneNumber", wallet_balance as "walletBalance", 
               streak_count as "streakCount", profile_image as "profileImage", 
               profile_photo as "profilePhoto", gender, is_verified as "isVerified", 
               is_active as "isActive", last_login as "lastLogin"
        FROM users WHERE firebase_uid = $1 LIMIT 1
      `, [firebaseUid]);
      return rows[0] || null;
    }
    const user = (DB_STATE as any).users?.find((u: any) => u.firebaseUid === firebaseUid);
    return user || null;
  }

  static async createUser(data: {
    email?: string;
    phone?: string;
    passwordHash?: string;
    firstName: string;
    lastName?: string;
    firebaseUid?: string;
    profilePhoto?: string;
    gender?: string;
  }): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        INSERT INTO users (email, phone, phone_number, password_hash, first_name, last_name, firebase_uid, profile_photo, profile_image, gender, is_verified, is_active, wallet_balance, streak_count)
        VALUES ($1, $2, $2, $3, $4, $5, $6, $7, $7, $8, true, true, 1200.00, 1)
        RETURNING id, firebase_uid as "firebaseUid", email, first_name as "firstName", last_name as "lastName", 
                  phone as "phone", phone_number as "phoneNumber", wallet_balance as "walletBalance", 
                  streak_count as "streakCount", profile_image as "profileImage", profile_photo as "profilePhoto", 
                  gender, is_verified as "isVerified", is_active as "isActive", last_login as "lastLogin"
      `, [
        data.email || null,
        data.phone || null,
        data.passwordHash || null,
        data.firstName,
        data.lastName || "",
        data.firebaseUid || null,
        data.profilePhoto || null,
        data.gender || "unspecified"
      ]);
      return rows[0];
    }
    if (!(DB_STATE as any).users) {
      (DB_STATE as any).users = [];
    }
    const newUser = {
      id: "u_" + Math.random().toString(36).substring(2, 9),
      firebaseUid: data.firebaseUid || "",
      email: data.email || "",
      passwordHash: data.passwordHash || "",
      firstName: data.firstName,
      lastName: data.lastName || "",
      phone: data.phone || "",
      phoneNumber: data.phone || "",
      profileImage: data.profilePhoto || "",
      profilePhoto: data.profilePhoto || "",
      gender: data.gender || "unspecified",
      isVerified: true,
      isActive: true,
      walletBalance: 1200.00,
      streakCount: 1,
      lastLogin: new Date().toISOString(),
    };
    (DB_STATE as any).users.push(newUser);
    return newUser;
  }

  static async createOTP(phone: string, otp: string, expiresAt: Date): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        INSERT INTO otp_verifications (phone, otp, expires_at, verified)
        VALUES ($1, $2, $3, false)
        RETURNING id, phone, otp, expires_at as "expiresAt", verified, created_at as "createdAt"
      `, [phone, otp, expiresAt]);
      return rows[0];
    }
    if (!(DB_STATE as any).otps) {
      (DB_STATE as any).otps = [];
    }
    const newOtp = {
      id: "otp_" + Math.random().toString(36).substring(2, 9),
      phone,
      otp,
      expiresAt: expiresAt.toISOString(),
      verified: false,
      createdAt: new Date().toISOString(),
    };
    (DB_STATE as any).otps.push(newOtp);
    return newOtp;
  }

  static async findLatestOTP(phone: string): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, phone, otp, expires_at as "expiresAt", verified, created_at as "createdAt"
        FROM otp_verifications 
        WHERE phone = $1 AND verified = false
        ORDER BY created_at DESC LIMIT 1
      `, [phone]);
      return rows[0] || null;
    }
    const otps = (DB_STATE as any).otps || [];
    const filtered = otps.filter((o: any) => o.phone === phone && !o.verified);
    if (filtered.length === 0) return null;
    return filtered[filtered.length - 1];
  }

  static async markOTPVerified(id: string): Promise<void> {
    if (usePostgreSQL) {
      await dbQuery("UPDATE otp_verifications SET verified = true WHERE id = $1", [id]);
      return;
    }
    const otps = (DB_STATE as any).otps || [];
    const item = otps.find((o: any) => o.id === id);
    if (item) item.verified = true;
  }

  static async createSession(userId: string, data: {
    deviceId?: string;
    deviceName?: string;
    firebaseToken?: string;
    refreshToken: string;
    ipAddress?: string;
  }): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        INSERT INTO user_sessions (user_id, device_id, device_name, firebase_token, refresh_token, ip_address)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id, user_id as "userId", device_id as "deviceId", device_name as "deviceName", 
                  firebase_token as "firebaseToken", refresh_token as "refreshToken", ip_address as "ipAddress", 
                  login_time as "loginTime"
      `, [userId, data.deviceId || null, data.deviceName || null, data.firebaseToken || null, data.refreshToken, data.ipAddress || null]);
      return rows[0];
    }
    if (!(DB_STATE as any).sessions) {
      (DB_STATE as any).sessions = [];
    }
    const newSession = {
      id: "sess_" + Math.random().toString(36).substring(2, 9),
      userId,
      deviceId: data.deviceId || "",
      deviceName: data.deviceName || "",
      firebaseToken: data.firebaseToken || "",
      refreshToken: data.refreshToken,
      ipAddress: data.ipAddress || "",
      loginTime: new Date().toISOString(),
    };
    (DB_STATE as any).sessions.push(newSession);
    return newSession;
  }

  static async findSessionByRefreshToken(refreshToken: string): Promise<any> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, user_id as "userId", device_id as "deviceId", device_name as "deviceName", 
               firebase_token as "firebaseToken", refresh_token as "refreshToken", ip_address as "ipAddress", 
               login_time as "loginTime"
        FROM user_sessions WHERE refresh_token = $1 AND logout_time IS NULL LIMIT 1
      `, [refreshToken]);
      return rows[0] || null;
    }
    const sessions = (DB_STATE as any).sessions || [];
    return sessions.find((s: any) => s.refreshToken === refreshToken && !s.logoutTime) || null;
  }

  static async invalidateSession(refreshToken: string): Promise<void> {
    if (usePostgreSQL) {
      await dbQuery("UPDATE user_sessions SET logout_time = CURRENT_TIMESTAMP WHERE refresh_token = $1", [refreshToken]);
      return;
    }
    const sessions = (DB_STATE as any).sessions || [];
    const item = sessions.find((s: any) => s.refreshToken === refreshToken);
    if (item) item.logoutTime = new Date().toISOString();
  }

  static async deleteUser(userId: string): Promise<void> {
    if (usePostgreSQL) {
      await dbQuery("DELETE FROM users WHERE id = $1", [userId]);
      return;
    }
    const users = (DB_STATE as any).users || [];
    (DB_STATE as any).users = users.filter((u: any) => u.id !== userId);
  }
}
