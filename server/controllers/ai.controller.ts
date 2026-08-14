import { Request, Response, NextFunction } from "express";
import { AiService } from "../services/ai.service";

// Chat & Shopping Assistant
export async function chat(req: Request, res: Response, next: NextFunction) {
  const { prompt, currentCart = [], conversationId, userContext } = req.body;
  const userId = (req as any).user?.id || req.body.userId || "u1";
  try {
    const result = await AiService.processChat(prompt, currentCart, userId, conversationId, userContext);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function assistant(req: Request, res: Response, next: NextFunction) {
  return chat(req, res, next);
}

// Recipe Assistant
export async function recipe(req: Request, res: Response, next: NextFunction) {
  const { recipeName, pantryItems = [] } = req.body;
  const userId = (req as any).user?.id || req.body.userId || "u1";
  try {
    const result = await AiService.generateRecipe(recipeName || "Special Grocery Dish", pantryItems, userId);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function recipeHelper(req: Request, res: Response, next: NextFunction) {
  return recipe(req, res, next);
}

export async function mealGenerator(req: Request, res: Response, next: NextFunction) {
  const { diet, calories, budget } = req.body;
  const userId = (req as any).user?.id || req.body.userId || "u1";
  try {
    const result = await AiService.processBudget(Number(budget || 1000), "weekly", 2, diet || "balanced", userId);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

// Budget Planner
export async function budget(req: Request, res: Response, next: NextFunction) {
  const { budgetLimit = 1000, period = "weekly", familySize = 2, dietPreferences = "balanced" } = req.body;
  const userId = (req as any).user?.id || req.body.userId || "u1";
  try {
    const result = await AiService.processBudget(Number(budgetLimit), period, Number(familySize), dietPreferences, userId);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

// Pantry Scan
export async function pantryScan(req: Request, res: Response, next: NextFunction) {
  const { imagePresetIndex, imageBase64 } = req.body;
  const userId = (req as any).user?.id || req.body.userId || "u1";
  try {
    const result = await AiService.scanPantry(
      imagePresetIndex !== undefined ? Number(imagePresetIndex) : undefined,
      imageBase64,
      userId
    );
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function pantryScanner(req: Request, res: Response, next: NextFunction) {
  return pantryScan(req, res, next);
}

// Image Search
export async function imageSearch(req: Request, res: Response, next: NextFunction) {
  const { imageBase64 } = req.body;
  const userId = (req as any).user?.id || req.body.userId || "u1";
  try {
    const result = await AiService.processImageSearch(imageBase64, userId);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

// Voice Shopping
export async function voice(req: Request, res: Response, next: NextFunction) {
  const { transcript, currentCart = [] } = req.body;
  const userId = (req as any).user?.id || req.body.userId || "u1";
  try {
    const result = await AiService.processVoice(transcript || "", currentCart, userId);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

// Nutrition Coach
export async function nutrition(req: Request, res: Response, next: NextFunction) {
  const { foodItems, query } = req.body;
  const userId = (req as any).user?.id || req.body.userId || "u1";
  try {
    const result = await AiService.processNutrition(foodItems || query, userId);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

// Recommendations
export async function recommendations(req: Request, res: Response, next: NextFunction) {
  const userId = (req as any).user?.id || (req.query.userId as string) || "u1";
  try {
    const result = await AiService.processRecommendations(userId);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

// Analytics
export async function analytics(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await AiService.getAiAnalytics();
    res.json(result);
  } catch (error) {
    next(error);
  }
}

// Demand Forecast
export async function demandForecast(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await AiService.getDemandForecast();
    res.json(result);
  } catch (error) {
    next(error);
  }
}

// Delivery Route AI
export async function deliveryRoute(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await AiService.getDeliveryRouteAi();
    res.json(result);
  } catch (error) {
    next(error);
  }
}

// History
export async function getHistory(req: Request, res: Response, next: NextFunction) {
  const userId = (req as any).user?.id || (req.query.userId as string) || "u1";
  try {
    const result = await AiService.getAiHistory(userId);
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function clearHistory(req: Request, res: Response, next: NextFunction) {
  const userId = (req as any).user?.id || req.body.userId || "u1";
  try {
    const result = await AiService.clearAiHistory(userId);
    res.json(result);
  } catch (error) {
    next(error);
  }
}
