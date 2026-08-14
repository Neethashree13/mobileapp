import { Router } from "express";
import * as aiController from "../controllers/ai.controller";

const router = Router();

// 1. Conversational Shopping & Support Assistant
router.post("/chat", aiController.chat);
router.post("/assistant", aiController.assistant);

// 2. Recipe Assistant & Meal Planner
router.post("/recipe", aiController.recipe);
router.post("/recipe-helper", aiController.recipeHelper);
router.post("/meal-generator", aiController.mealGenerator);

// 3. Budget Planner
router.post("/budget", aiController.budget);

// 4. Pantry Intelligence
router.post("/pantry-scan", aiController.pantryScan);
router.post("/pantry-scanner", aiController.pantryScanner);

// 5. Image Search
router.post("/image-search", aiController.imageSearch);

// 6. Voice Shopping
router.post("/voice", aiController.voice);

// 7. Nutrition Coach
router.post("/nutrition", aiController.nutrition);

// 8. Smart Recommendations
router.get("/recommendations", aiController.recommendations);

// 9. History APIs
router.get("/history", aiController.getHistory);
router.delete("/history", aiController.clearHistory);

// 10. Admin & Store & Delivery AI Integrations
router.get("/analytics", aiController.analytics);
router.get("/demand-forecast", aiController.demandForecast);
router.get("/delivery-route", aiController.deliveryRoute);

export default router;
