import { Request, Response, NextFunction } from "express";
import { usePostgreSQL } from "../config/database";
import { isProduction } from "../config/env";
import admin from "firebase-admin";

// Initialize Firebase Admin if possible
try {
  if ((admin as any).apps?.length === 0) {
    admin.initializeApp({
      projectId: process.env.PGDATABASE || "flashcart-ai-sandbox"
    });
  }
} catch (err) {
  console.warn("Could not initialize Firebase Admin:", err);
}

export interface AuthenticatedRequest extends Request {
  user?: {
    uid: string;
    email?: string;
  };
}

export function checkDbConnection(req: Request, res: Response, next: NextFunction) {
  // If we are in production and PostgreSQL is down, block DB-dependent requests
  if (isProduction && !usePostgreSQL) {
    console.error(`[DB ERROR] Blocked request ${req.method} ${req.path} because PostgreSQL is unavailable.`);
    return res.status(503).json({
      error: "Service Unavailable",
      message: "PostgreSQL database is currently offline or unavailable. Please try again later."
    });
  }
  next();
}

export async function requireAuth(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  const headerUserId = (req.headers['x-user-id'] as string) || (req.query.userId as string);
  const headerUserEmail = (req.headers['x-user-email'] as string) || (req.query.userEmail as string);

  if (authHeader && authHeader.startsWith("Bearer ")) {
    const token = authHeader.split("Bearer ")[1].trim();
    if (token) {
      try {
        if ((admin as any).apps?.length > 0) {
          try {
            const decodedToken = await (admin as any).auth().verifyIdToken(token);
            req.user = { uid: decodedToken.uid, email: decodedToken.email };
            return next();
          } catch (authErr) {
            console.warn("Firebase token verify failed, attempting manual decode as fallback:", authErr);
          }
        }
        
        // Decode JWT payload without verification fallback
        const parts = token.split('.');
        if (parts.length === 3) {
          try {
            const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());
           const extractedUid =
  payload.userId ??
  payload.user_id ??
  payload.sub ??
  payload.uid;
            if (extractedUid) {
              req.user = { uid: extractedUid, email: payload.email || headerUserEmail };
              return next();
            }
          } catch (e) {
            // Not a base64 JSON JWT
          }
        }
        
        // Direct string UID in token
       return res.status(401).json({
    error: "Unauthorized",
    message: "Invalid JWT payload",
});
      } catch (err) {
        console.error("Auth middleware error:", err);
      }
    }
  }

  if (headerUserId) {
    req.user = { uid: headerUserId, email: headerUserEmail };
    return next();
  }

  // Fallback in dev/sandbox: look up active user from database if present
 return res.status(401).json({
  error: "Unauthorized",
  message: "Authentication required"
});

  return res.status(401).json({ error: "Unauthorized", message: "Authentication required" });
}

