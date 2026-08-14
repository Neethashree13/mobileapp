import { Response, NextFunction } from "express";
import { AuthenticatedRequest } from "./auth";
import { logger } from "../utils/logger";

/**
 * Role-Based Access Control (RBAC) Middleware
 * Restricts endpoint execution based on user role.
 *
 * @param allowedRoles Array of acceptable roles (e.g., ['ADMIN', 'SUPER_ADMIN'])
 */
export function requireRole(...allowedRoles: string[]) {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      res.status(401).json({
        error: "Unauthorized",
        message: "Authentication is required to access this resource",
      });
      return;
    }

    const userRole = (req.user.role || "USER").toUpperCase();
    const normalizedAllowedRoles = allowedRoles.map((r) => r.toUpperCase());

    // SUPER_ADMIN override or explicit role match
    if (userRole === "SUPER_ADMIN" || normalizedAllowedRoles.includes(userRole)) {
      return next();
    }

    logger.warn(`[RBAC] Access denied for user ${req.user.id} with role ${userRole}. Required: ${allowedRoles.join(", ")}`);

    res.status(403).json({
      error: "Forbidden",
      message: `Access denied. Insufficient permissions for role '${userRole}'. Required: [${allowedRoles.join(", ")}]`,
    });
  };
}
