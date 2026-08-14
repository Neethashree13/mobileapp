// import { z } from "zod";
// import { Request, Response, NextFunction } from "express";

// export const profileUpdateSchema = z.object({
//   firstName: z.string().min(1, "First name cannot be empty").optional(),
//   lastName: z.string().min(1, "Last name cannot be empty").optional(),
//   phoneNumber: z.string().min(5, "Phone number is too short").optional(),
//   gender: z.string().optional(),
//   bio: z.string().optional(),
//   profilePhoto: z.string().optional(),
// });

// export const photoUploadSchema = z.object({
//   photoUrl: z.string().optional(),
//   photoBase64: z.string().optional(),
// });

// export const addressSchema = z.object({
//   title: z.string().optional().default("Home"),
//   addressLine1: z.string().optional().default(""),
//   addressLine2: z.string().optional().default(""),
//   houseNo: z.string().optional().default(""),
//   apartment: z.string().optional().default(""),
//   street: z.string().optional().default(""),
//   landmark: z.string().optional().default(""),
//   city: z.string().optional().default("Bangalore"),
//   state: z.string().optional().default("Karnataka"),
//   country: z.string().optional().default("India"),
//   postalCode: z.string().optional().default("560102"),
//   pincode: z.string().optional().default("560102"),
//   latitude: z.number().optional().default(12.9279),
//   longitude: z.number().optional().default(77.6250),
//   isDefault: z.boolean().optional().default(false),
// });

// export const preferencesSchema = z.object({
//   emailNotifications: z.boolean().optional(),
//   pushNotifications: z.boolean().optional(),
//   smsNotifications: z.boolean().optional(),
//   promotionalAlerts: z.boolean().optional(),
//   orderUpdates: z.boolean().optional(),
//   deliveryAlerts: z.boolean().optional(),
//   language: z.string().optional(),
//   dietary: z.array(z.string()).optional(),
//   shareDataWithPartners: z.boolean().optional(),
//   personalizedAds: z.boolean().optional(),
//   locationTracking: z.boolean().optional(),
// });

// export const settingsSchema = z.object({
//   isDarkMode: z.boolean().optional(),
//   biometricsEnabled: z.boolean().optional(),
//   cacheSizeMb: z.number().optional(),
// });

// export const reverseGeocodeSchema = z.object({
//   latitude: z.number(),
//   longitude: z.number(),
// });

// export const cartItemSchema = z.object({
//   product: z.object({
//     id: z.string(),
//     name: z.string(),
//     price: z.number().positive(),
//   }),
//   quantity: z.number().int().positive(),
//   addedBy: z.string().optional(),
// });

// export const cartSyncSchema = z.array(cartItemSchema);

// export const orderPlacementSchema = z.object({
//   paymentMethod: z.string().min(1, "Payment method is required"),
//   items: z.array(cartItemSchema),
// });

// export const reviewSchema = z.object({
//   productId: z.string().min(1, "Product ID is required"),
//   userName: z.string().min(1, "Name is required"),
//   rating: z.number().min(1).max(5),
//   comment: z.string().min(3, "Comment must be at least 3 characters"),
// });

// export const searchSchema = z.object({
//   query: z.string().min(1, "Search query is required"),
//   mood: z.string().optional(),
// });

// export const aiChatSchema = z.object({
//   message: z.string().min(1, "Message is required"),
//   history: z.array(z.object({
//     role: z.enum(["user", "model"]),
//     parts: z.array(z.object({ text: z.string() })),
//   })).optional(),
// });

// // Authentication Schemas
// export const registerSchema = z.object({
//   email: z.string().email("Invalid email format").optional(),
//   phone: z.string().min(10, "Phone number must be at least 10 characters").optional(),
//   password: z.string().min(6, "Password must be at least 6 characters").optional(),
//   firstName: z.string().min(1, "First name is required"),
//   lastName: z.string().optional(),
//   acceptTerms: z.boolean().optional(),
// });

// export const loginSchema = z.object({
//   email: z.string().email("Invalid email format").optional(),
//   phone: z.string().optional(),
//   password: z.string().min(6, "Password is too short").optional(),
//   firebaseUid: z.string().optional(),
// });

// export const sendOtpSchema = z.object({
//   phone: z.string().min(10, "Phone number must be at least 10 digits"),
// });

// export const verifyOtpSchema = z.object({
//   phone: z.string().min(10, "Phone number must be at least 10 digits"),
//   otp: z.string().length(6, "OTP must be exactly 6 digits"),
//   device_id: z.string().optional(),
//   device_name: z.string().optional(),
// });

// export const googleLoginSchema = z.object({
//   firebaseUid: z.string().min(1, "Firebase Uid is required"),
//   email: z.string().email("Invalid email format"),
//   firstName: z.string().optional(),
//   lastName: z.string().optional(),
//   phoneNumber: z.string().optional(),
//   profilePhoto: z.string().optional(),
//   device_id: z.string().optional(),
//   device_name: z.string().optional(),
// });

// export const forgotPasswordSchema = z.object({
//   email: z.string().email("Invalid email format"),
// });

// export const resetPasswordSchema = z.object({
//   email: z.string().email("Invalid email format"),
//   otp: z.string().min(4, "Invalid OTP code"),
//   newPassword: z.string().min(6, "Password must be at least 6 characters"),
// });

// // Middleware factory for validation
// export function validateBody(schema: z.ZodSchema) {
//   return (req: Request, res: Response, next: NextFunction) => {
//     const result = schema.safeParse(req.body);
//     if (!result.success) {
//       res.status(400).json({
//         error: "Validation failed",
//         details: result.error.issues.map((e) => ({
//           field: e.path.join("."),
//           message: e.message,
//         })),
//       });
//       return;
//     }
//     // Assign validated data back to body
//     req.body = result.data;
//     next();
//   };
// }


import { z } from "zod";
import { Request, Response, NextFunction } from "express";

export const profileUpdateSchema = z.object({
  firstName: z.string().min(1, "First name cannot be empty").optional(),
  lastName: z.string().min(1, "Last name cannot be empty").optional(),
  phoneNumber: z.string().min(5, "Phone number is too short").optional(),
  gender: z.string().optional(),
  bio: z.string().optional(),
  profilePhoto: z.string().optional(),
});

export const photoUploadSchema = z.object({
  photoUrl: z.string().optional(),
  photoBase64: z.string().optional(),
});

export const addressSchema = z.object({
  title: z.string().nullable().optional().default("Home"),
  addressLine1: z.string().nullable().optional().default(""),
  addressLine2: z.string().nullable().optional().default(""),
  houseNo: z.string().nullable().optional().default(""),
  apartment: z.string().nullable().optional().default(""),
  street: z.string().nullable().optional().default(""),
  landmark: z.string().nullable().optional().default(""),
  city: z.string().nullable().optional().default("Bangalore"),
  state: z.string().nullable().optional().default("Karnataka"),
  country: z.string().nullable().optional().default("India"),
  postalCode: z.string().nullable().optional().default("560102"),
  pincode: z.string().nullable().optional().default("560102"),
  latitude: z.union([z.number(), z.string().transform(v => parseFloat(v))]).nullable().optional().default(12.9279),
  longitude: z.union([z.number(), z.string().transform(v => parseFloat(v))]).nullable().optional().default(77.6250),
  isDefault: z.union([z.boolean(), z.string().transform(v => v === "true")]).nullable().optional().default(false),
});

export const preferencesSchema = z.object({
  emailNotifications: z.boolean().optional(),
  pushNotifications: z.boolean().optional(),
  smsNotifications: z.boolean().optional(),
  promotionalAlerts: z.boolean().optional(),
  orderUpdates: z.boolean().optional(),
  deliveryAlerts: z.boolean().optional(),
  language: z.string().optional(),
  dietary: z.array(z.string()).optional(),
  shareDataWithPartners: z.boolean().optional(),
  personalizedAds: z.boolean().optional(),
  locationTracking: z.boolean().optional(),
});

export const settingsSchema = z.object({
  isDarkMode: z.boolean().optional(),
  biometricsEnabled: z.boolean().optional(),
  cacheSizeMb: z.number().optional(),
});

export const reverseGeocodeSchema = z.object({
  latitude: z.number(),
  longitude: z.number(),
});

export const cartItemSchema = z.object({
  product: z.object({
    id: z.string(),
    name: z.string(),
    price: z.number().positive(),
  }),
  quantity: z.number().int().positive(),
  addedBy: z.string().optional(),
});

export const cartSyncSchema = z.array(cartItemSchema);

export const orderPlacementSchema = z.object({
  paymentMethod: z.string().min(1, "Payment method is required"),
  items: z.array(cartItemSchema),
});

export const reviewSchema = z.object({
  productId: z.string().min(1, "Product ID is required"),
  userName: z.string().min(1, "Name is required"),
  rating: z.number().min(1).max(5),
  comment: z.string().min(3, "Comment must be at least 3 characters"),
});

export const searchSchema = z.object({
  query: z.string().min(1, "Search query is required"),
  mood: z.string().optional(),
});

export const aiChatSchema = z.object({
  message: z.string().min(1, "Message is required"),
  history: z.array(z.object({
    role: z.enum(["user", "model"]),
    parts: z.array(z.object({ text: z.string() })),
  })).optional(),
});

// Authentication Schemas
export const registerSchema = z.object({
  email: z.string().email("Invalid email format").optional(),
  phone: z.string().min(10, "Phone number must be at least 10 characters").optional(),
  password: z.string().min(6, "Password must be at least 6 characters").optional(),
  firstName: z.string().min(1, "First name is required"),
  lastName: z.string().optional(),
  acceptTerms: z.boolean().optional(),
});

export const loginSchema = z.object({
  email: z.string().email("Invalid email format").optional(),
  phone: z.string().optional(),
  password: z.string().min(6, "Password is too short").optional(),
  firebaseUid: z.string().optional(),
});

export const sendOtpSchema = z.object({
  phone: z.string().min(10, "Phone number must be at least 10 digits"),
});

export const verifyOtpSchema = z.object({
  phone: z.string().min(10, "Phone number must be at least 10 digits"),
  otp: z.string().length(6, "OTP must be exactly 6 digits"),
  device_id: z.string().optional(),
  device_name: z.string().optional(),
});

export const googleLoginSchema = z.object({
  firebaseUid: z.string().min(1, "Firebase Uid is required"),
  email: z.string().email("Invalid email format"),
  firstName: z.string().optional(),
  lastName: z.string().optional(),
  phoneNumber: z.string().optional(),
  profilePhoto: z.string().optional(),
  device_id: z.string().optional(),
  device_name: z.string().optional(),
});

export const forgotPasswordSchema = z.object({
  email: z.string().email("Invalid email format"),
});

export const resetPasswordSchema = z.object({
  email: z.string().email("Invalid email format"),
  otp: z.string().min(4, "Invalid OTP code"),
  newPassword: z.string().min(6, "Password must be at least 6 characters"),
});

// Middleware factory for validation
export function validateBody(schema: z.ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      res.status(400).json({
        error: "Validation failed",
        details: result.error.issues.map((e) => ({
          field: e.path.join("."),
          message: e.message,
        })),
      });
      return;
    }
    // Assign validated data back to body
    req.body = result.data;
    next();
  };
}
