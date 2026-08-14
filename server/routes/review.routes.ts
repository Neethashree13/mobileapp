import { Router } from "express";
import * as reviewController from "../controllers/review.controller";
import { checkDbConnection } from "../middleware/dbCheck";
import { validateBody, reviewSchema } from "../validators/request.validators";

const router = Router();

router.get("/", checkDbConnection, reviewController.getReviews);
router.post("/add", checkDbConnection, validateBody(reviewSchema), reviewController.addReview);

export default router;
