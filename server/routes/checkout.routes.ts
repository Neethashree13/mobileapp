import { Router } from "express";
import * as cartController from "../controllers/cart.controller";
import { checkDbConnection } from "../middleware/dbCheck";

const router = Router();

router.get("/summary", checkDbConnection, cartController.getCheckoutSummary);
router.post("/validate", checkDbConnection, cartController.validateCheckout);

export default router;
