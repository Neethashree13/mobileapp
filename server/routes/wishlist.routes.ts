import { Router } from "express";
import * as wishlistController from "../controllers/wishlist.controller";
import { checkDbConnection } from "../middleware/dbCheck";
import { authenticateJWT } from "../middleware/auth.middleware";

const router = Router();

router.get("/", authenticateJWT, checkDbConnection, wishlistController.getWishlist);

router.post("/items", authenticateJWT, checkDbConnection, wishlistController.addItem);

router.delete("/items/:id", authenticateJWT, checkDbConnection, wishlistController.deleteItem);

router.post("/toggle", authenticateJWT, checkDbConnection, wishlistController.toggleWishlist);

router.post("/", authenticateJWT, checkDbConnection, wishlistController.toggleWishlist);

export default router;