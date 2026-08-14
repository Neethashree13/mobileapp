// import { Request, Response, NextFunction } from "express";
// import { verifyAccessToken } from "../utils/auth";
// import admin from "firebase-admin";

// export interface AuthenticatedRequest extends Request {
//   user?: {
//     id: string;
//     uid: string; // compatibility field
//     email?: string;
//     role?: string;
//   };
// }

// /**
//  * Standard Authentication Middleware
//  * Supports custom signed JWTs and Firebase ID tokens.
//  */
// export async function requireUser(req: AuthenticatedRequest, res: Response, next: NextFunction) {
//   const authHeader = req.headers.authorization;
//   if (!authHeader || !authHeader.startsWith("Bearer ")) {
//     // For non-production sandbox testing convenience, fallback to mock user
//     if (process.env.NODE_ENV !== "production") {
//       req.user = { id: "u1", uid: "FBAUTH_UID_9921", email: "arav@example.com", role: "user" };
//       return next();
//     }
//     return res.status(401).json({ error: "Unauthorized", message: "Bearer token required" });
//   }

//   const token = authHeader.split("Bearer ")[1];

//   try {
//     // Strategy 1: Attempt to verify token as local custom access token
//     try {
//       const decoded = verifyAccessToken(token);
//       req.user = {
//         id: decoded.userId,
//         uid: decoded.userId,
//         email: decoded.email,
//         role: decoded.role || "user",
//       };
//       return next();
//     } catch (localJwtErr) {
//       // Local verification failed, continue to Firebase/fallback verification
//     }

//     // Strategy 2: Attempt Firebase verification if initialized
//     if ((admin as any).apps?.length > 0) {
//       try {
//         const decodedToken = await (admin as any).auth().verifyIdToken(token);
//         req.user = {
//           id: decodedToken.uid,
//           uid: decodedToken.uid,
//           email: decodedToken.email,
//           role: "user",
//         };
//         return next();
//       } catch (fbErr) {
//         // Firebase verification failed, continue
//       }
//     }

//     // Strategy 3: Handle raw JWT base64 fallback in dev environments, or token strings
//     const parts = token.split(".");
//     if (parts.length === 3) {
//       try {
//         const payload = JSON.parse(Buffer.from(parts[1], "base64").toString());
//         const uid = payload.userId || payload.user_id || payload.sub || token;
//         req.user = {
//           id: uid,
//           uid: uid,
//           email: payload.email || "arav@example.com",
//           role: payload.role || "user",
//         };
//         return next();
//       } catch (jsonErr) {
//         // Ignore JSON parsing errors
//       }
//     }

//     // Dev environment fallback for raw string tokens (e.g., using test-uid as token)
//     if (process.env.NODE_ENV !== "production") {
//       req.user = {
//         id: token,
//         uid: token,
//         email: `${token}@example.com`,
//         role: "user",
//       };
//       return next();
//     }

//     return res.status(401).json({ error: "Unauthorized", message: "Invalid or expired session token" });
//   } catch (err: any) {
//     console.error("Auth middleware global catch:", err);
//     return res.status(401).json({ error: "Unauthorized", message: "Authentication validation failed" });
//   }
// }

import { Request, Response, NextFunction } from "express";
import { authenticateJWT, AuthenticatedRequest } from "./auth.middleware";

export type { AuthenticatedRequest };
export { authenticateJWT };
export const requireUser = authenticateJWT;


