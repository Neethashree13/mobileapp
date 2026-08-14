import { Request, Response, NextFunction } from "express";
import { verifyAccessToken } from "../utils/auth";
import { redisCache } from "../config/redis";
import admin from "firebase-admin";

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    uid: string;
    email?: string;
    role: string;
  };
}

/**
 * Express Middleware verifying JWT Access Token with Redis Blacklist Check
 */
export async function authenticateJWT(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    if (process.env.NODE_ENV === "test") {
      req.user = { id: "test-user-id", uid: "test-user-id", email: "test@flashcart.ai", role: "USER" };
      return next();
    }
    res.status(401).json({ error: "Unauthorized", message: "Bearer JWT token required in Authorization header" });
    return;
  }

  const token = authHeader.split("Bearer ")[1];

  try {
    // 1. Check if token is blacklisted in Redis Session Cache
    const isBlacklisted = await redisCache.isTokenBlacklisted(token);
    if (isBlacklisted) {
      res.status(401).json({ error: "Unauthorized", message: "Token has been revoked or logged out" });
      return;
    }

    // 2. Verify custom JWT signature & expiration
    try {
     const decoded = verifyAccessToken(token);

console.log("JWT decoded:", decoded);
console.log("Decoded userId:", decoded.userId);

req.user = {
  id: decoded.userId,
  uid: decoded.userId,
  email: decoded.email,
  role: decoded.role || "USER",
};

return next();
    } catch (jwtErr) {
  console.error("JWT VERIFY FAILED");
  console.error(jwtErr);
}

    // 3. Optional Firebase Auth ID token verification
    if ((admin as any).apps?.length > 0) {
      try {
        const decodedToken = await (admin as any).auth().verifyIdToken(token);
        req.user = {
          id: decodedToken.uid,
          uid: decodedToken.uid,
          email: decodedToken.email,
          role: "USER",
        };
        return next();
      } catch (fbErr) {
        // Continue
      }
    }

    // 4. Test environment fallback parsing
    if (process.env.NODE_ENV === "test" || process.env.NODE_ENV === "development") {
      const parts = token.split(".");
      if (parts.length === 3) {
        try {
          const payload = JSON.parse(Buffer.from(parts[1], "base64").toString());
          req.user = {
            id: payload.userId || payload.sub || token,
            uid: payload.userId || payload.sub || token,
            email: payload.email || "test@flashcart.ai",
            role: payload.role || "USER",
          };
          return next();
        } catch (e) {}
      }

      req.user = {
        id: token,
        uid: token,
        email: `${token}@flashcart.ai`,
        role: "USER",
      };
      return next();
    }

    res.status(401).json({ error: "Unauthorized", message: "Invalid or expired session access token" });
  } catch (err: any) {
    res.status(401).json({ error: "Unauthorized", message: "Token verification failed" });
  }
}
