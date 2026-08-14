import { 
  UserRepository, 
  Address, 
  UserProfile, 
  UserPreferences, 
  UserSettings, 
  ReferralInfo, 
  ActivityLogEntry,
  SearchHistoryEntry, 
  LoginHistoryEntry 
} from "../repositories/user.repository";
import { ActivityRepository } from "../repositories/activity.repository";

export class UserService {
  static async getUserProfile(firebaseUid: string = "", email?: string): Promise<UserProfile> {
    return UserRepository.getProfile(firebaseUid, email);
  }

  static async updateUserProfile(
    firebaseUid: string,
    data: {
      firstName?: string;
      lastName?: string;
      phoneNumber?: string;
      gender?: string;
      bio?: string;
      profilePhoto?: string;
    }
  ): Promise<UserProfile> {
    await UserRepository.updateProfile(firebaseUid, data);
    const profile = await UserRepository.getProfile(firebaseUid);
    await ActivityRepository.log(profile.id, "update_profile", `Profile details updated for ${profile.email}`);
    return profile;
  }

  static async updateProfilePhoto(firebaseUid: string, photoUrl: string): Promise<UserProfile> {
    await UserRepository.updateProfilePhoto(firebaseUid, photoUrl);
    const profile = await UserRepository.getProfile(firebaseUid);
    await ActivityRepository.log(profile.id, "update_photo", `Profile photo updated`);
    return profile;
  }

  static async getUserAddresses(firebaseUid: string = ""): Promise<Address[]> {
    return UserRepository.getAddresses(firebaseUid);
  }

  static async addUserAddress(firebaseUid: string, address: Address): Promise<Address> {
    const newAddress = await UserRepository.addAddress(firebaseUid, address);
    const profile = await UserRepository.getProfile(firebaseUid);
    await ActivityRepository.log(profile.id, "add_address", `Added delivery address: ${address.title}`);
    return newAddress;
  }

  static async updateUserAddress(firebaseUid: string, addressId: string, address: Address): Promise<Address> {
    const updated = await UserRepository.updateAddress(firebaseUid, addressId, address);
    const profile = await UserRepository.getProfile(firebaseUid);
    await ActivityRepository.log(profile.id, "update_address", `Updated address: ${address.title || addressId}`);
    return updated;
  }

  static async deleteUserAddress(firebaseUid: string, addressId: string): Promise<void> {
    await UserRepository.deleteAddress(firebaseUid, addressId);
    const profile = await UserRepository.getProfile(firebaseUid);
    await ActivityRepository.log(profile.id, "delete_address", `Deleted address: ${addressId}`);
  }

  static async setDefaultUserAddress(firebaseUid: string, addressId: string): Promise<Address[]> {
    await UserRepository.setDefaultAddress(firebaseUid, addressId);
    return UserRepository.getAddresses(firebaseUid);
  }

  static async getRecentlyUsedAddresses(firebaseUid: string = ""): Promise<Address[]> {
    return UserRepository.getRecentlyUsedAddresses(firebaseUid);
  }

  static async reverseGeocode(latitude: number, longitude: number) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 3000);
      const response = await fetch(
        `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latitude}&lon=${longitude}`,
        {
          headers: { 'User-Agent': 'FlashCartAI/1.0 (contact@flashcart.ai)' },
          signal: controller.signal,
        }
      );
      clearTimeout(timeoutId);

      if (response.ok) {
        const data = await response.json();
        if (data && data.address) {
          const addr = data.address;
          const road = addr.road || addr.street || addr.suburb || addr.neighbourhood || addr.residential || "Koramangala 4th Block";
          const houseNo = addr.house_number || addr.building || "";
          const city = addr.city || addr.town || addr.village || addr.county || "Bengaluru";
          const state = addr.state || "Karnataka";
          const country = addr.country || "India";
          const postalCode = addr.postcode || "560102";
          const landmark = addr.amenity || addr.landmark || "";

          const addressLine1 = [houseNo, road].filter(Boolean).join(", ") || road;

          return {
            title: addr.suburb || addr.neighbourhood || city || "Current Location",
            addressLine1,
            addressLine2: landmark,
            houseNo,
            street: road,
            landmark,
            city,
            state,
            country,
            postalCode,
            latitude,
            longitude,
          };
        }
      }
    } catch (e) {
      console.warn("Reverse geocoding fetch fallback:", e);
    }

    return {
      title: "Current Location",
      addressLine1: "Koramangala 4th Block, 80 Feet Road",
      addressLine2: "",
      houseNo: "",
      street: "Koramangala 4th Block, 80 Feet Road",
      landmark: "",
      city: "Bengaluru",
      state: "Karnataka",
      country: "India",
      postalCode: "560102",
      latitude,
      longitude,
    };
  }

  static async getUserPreferences(firebaseUid: string = ""): Promise<UserPreferences> {
    return UserRepository.getPreferences(firebaseUid);
  }

  static async updateUserPreferences(firebaseUid: string, prefs: Partial<UserPreferences>): Promise<UserPreferences> {
    const updated = await UserRepository.updatePreferences(firebaseUid, prefs);
    const profile = await UserRepository.getProfile(firebaseUid);
    await ActivityRepository.log(profile.id, "update_preferences", `Notification/Dietary preferences updated`);
    return updated;
  }

  static async getUserSettings(firebaseUid: string = ""): Promise<UserSettings> {
    return UserRepository.getSettings(firebaseUid);
  }

  static async updateUserSettings(firebaseUid: string, settings: Partial<UserSettings>): Promise<UserSettings> {
    const updated = await UserRepository.updateSettings(firebaseUid, settings);
    const profile = await UserRepository.getProfile(firebaseUid);
    await ActivityRepository.log(profile.id, "update_settings", `Security & Theme settings updated`);
    return updated;
  }

  static async deleteUserAccount(firebaseUid: string): Promise<void> {
    const profile = await UserRepository.getProfile(firebaseUid);
    await ActivityRepository.log(profile.id, "delete_account", `Account deleted by user`);
    await UserRepository.deleteAccount(firebaseUid);
  }

  static async deactivateUserAccount(firebaseUid: string): Promise<void> {
    const profile = await UserRepository.getProfile(firebaseUid);
    await ActivityRepository.log(profile.id, "deactivate_account", `Account deactivated by user`);
    await UserRepository.deactivateAccount(firebaseUid);
  }

  static async getActivityHistory(firebaseUid: string = ""): Promise<ActivityLogEntry[]> {
    return UserRepository.getActivityHistory(firebaseUid);
  }

  static async getReferralInfo(firebaseUid: string = ""): Promise<ReferralInfo> {
    return UserRepository.getReferralInfo(firebaseUid);
  }

  static async getSearchHistory(firebaseUid: string = ""): Promise<SearchHistoryEntry[]> {
    return UserRepository.getSearchHistory(firebaseUid);
  }

  static async getLoginHistory(firebaseUid: string = ""): Promise<LoginHistoryEntry[]> {
    return UserRepository.getLoginHistory(firebaseUid);
  }
}
