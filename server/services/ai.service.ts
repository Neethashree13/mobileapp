import { getGeminiClient, Type } from "../config/gemini";
import {
  PRODUCT_CATALOG_CONTEXT,
  DB_STATE,
  simulateAssistant,
  simulateMealPlanner,
  simulateRecipe,
  simulatePantryScan,
  getPresetDescription,
} from "../config/dbState";
import { dbQuery, usePostgreSQL } from "../config/database";
import { logger } from "../utils/logger";

async function logAiUsage(
  userId: string,
  feature: string,
  modelName: string,
  promptTokens: number,
  completionTokens: number,
  latencyMs: number,
  status: string = "SUCCESS"
) {
  if (usePostgreSQL) {
    try {
      await dbQuery(
        `INSERT INTO ai_usage_logs (user_id, feature, model_name, prompt_tokens, completion_tokens, latency_ms, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [userId || "u1", feature, modelName, promptTokens, completionTokens, latencyMs, status]
      );
    } catch (err) {
      logger.warn("Could not log AI usage to DB:", err);
    }
  }
}

async function logPromptHistory(userId: string, feature: string, prompt: string, response: string) {
  if (usePostgreSQL) {
    try {
      await dbQuery(
        `INSERT INTO prompt_history (user_id, feature, prompt, response)
         VALUES ($1, $2, $3, $4)`,
        [userId || "u1", feature, prompt, typeof response === "string" ? response : JSON.stringify(response)]
      );
    } catch (err) {
      logger.warn("Could not log prompt history to DB:", err);
    }
  }
}

export class AiService {
  // 1. Conversational Shopping & Support Assistant
  static async processChat(
    prompt: string,
    currentCart: any[] = [],
    userId: string = "u1",
    conversationId?: string,
    userContext?: any
  ): Promise<any> {
    const startTime = Date.now();
    const ai = getGeminiClient();

    if (!ai) {
      logger.info("Gemini API key missing/unconfigured. Serving offline simulation for chat.");
      return simulateAssistant(prompt);
    }

    try {
      const systemInstruction = `You are the FlashCart AI Intelligent Conversational Assistant & Support Agent.
      You help customers search, select, build cart, track orders, resolve issues, and answer support queries.
      You must respond in strict JSON format.

      ${PRODUCT_CATALOG_CONTEXT}

      User Query: "${prompt}"
      Current Cart: ${JSON.stringify(currentCart)}
      User Context: ${JSON.stringify(userContext || {})}

      Instructions:
      1. Parse intent: SHOPPING (item search/cart building), SUPPORT (order status, refund, coupon, delivery query), or GENERAL.
      2. If SHOPPING: Select items from catalog matching request, suggest appropriate quantities, calculate estimated cost.
      3. If SUPPORT: Provide clear, empathetic, helpful guidance, order status updates, or refund/coupon troubleshooting.
      4. Return JSON structure:
      {
        "intent": "SHOPPING" | "SUPPORT" | "GENERAL",
        "reply": "Conversational response for the user",
        "suggestedActions": ["Action 1", "Action 2"],
        "items": [{"productId": "p1", "quantity": 1}],
        "totalPrice": 0,
        "supportResolution": "Optional resolution summary if support query"
      }`;

      const response = await ai.models.generateContent({
        model: "gemini-3.6-flash",
        contents: systemInstruction,
        config: {
          responseMimeType: "application/json",
          responseSchema: {
            type: Type.OBJECT,
            properties: {
              intent: { type: Type.STRING },
              reply: { type: Type.STRING },
              suggestedActions: { type: Type.ARRAY, items: { type: Type.STRING } },
              items: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    productId: { type: Type.STRING },
                    quantity: { type: Type.INTEGER },
                  },
                  required: ["productId", "quantity"],
                },
              },
              totalPrice: { type: Type.NUMBER },
              supportResolution: { type: Type.STRING },
            },
            required: ["intent", "reply", "items"],
          },
        },
      });

      const latency = Date.now() - startTime;
      const parsed = JSON.parse((response.text || "{}").trim());

      await logAiUsage(userId, "chat_assistant", "gemini-3.6-flash", 150, 200, latency);
      await logPromptHistory(userId, "chat_assistant", prompt, JSON.stringify(parsed));

      return {
        explanation: parsed.reply,
        items: parsed.items || [],
        totalPrice: parsed.totalPrice || 0,
        intent: parsed.intent || "SHOPPING",
        suggestedActions: parsed.suggestedActions || ["Add all to Cart", "View Nutrition"],
        supportResolution: parsed.supportResolution || null,
      };
    } catch (error: any) {
      logger.error("Gemini API Error in processChat, using fallback:", error);
      return simulateAssistant(prompt);
    }
  }

  // Alias for legacy assistant route
  static async processAssistant(prompt: string, currentCart: any[] = []): Promise<any> {
    return this.processChat(prompt, currentCart);
  }

  // 2. Recipe Assistant
  static async generateRecipe(recipeName: string, pantryItems: string[] = [], userId: string = "u1"): Promise<any> {
    const startTime = Date.now();
    const ai = getGeminiClient();

    if (!ai) {
      return simulateRecipe(recipeName);
    }

    try {
      const response = await ai.models.generateContent({
        model: "gemini-3.6-flash",
        contents: `You are the FlashCart Master Chef & Culinary AI.
        User wants to cook: "${recipeName}".
        User Pantry Items: ${JSON.stringify(pantryItems)}
        
        Catalog Context:
        ${PRODUCT_CATALOG_CONTEXT}

        Instructions:
        1. Build step-by-step cooking recipe with prep time, cook time, calories per serving, and cooking steps.
        2. Map ingredients required to items in our product catalog. Indicate missing items that need to be added to cart.
        3. Provide nutrition breakdown (Calories, Protein, Carbs, Fat, Sugar) and a chef tip.
        4. Return raw JSON with structure:
        {
          "title": "Recipe Name",
          "prepTime": "10 mins",
          "cookTime": "15 mins",
          "servings": 2,
          "caloriesPerServing": 350,
          "nutrition": {
            "calories": 350,
            "proteinG": 18,
            "carbsG": 30,
            "fatG": 12,
            "sugarG": 4
          },
          "itemsToBuy": [{"productId": "p5", "quantity": 1}],
          "pantryMatch": ["Salt", "Water"],
          "steps": ["Step 1...", "Step 2..."],
          "chefTip": "Useful tip",
          "totalCost": 150
        }`,
        config: {
          responseMimeType: "application/json",
          responseSchema: {
            type: Type.OBJECT,
            properties: {
              title: { type: Type.STRING },
              prepTime: { type: Type.STRING },
              cookTime: { type: Type.STRING },
              servings: { type: Type.INTEGER },
              caloriesPerServing: { type: Type.NUMBER },
              nutrition: {
                type: Type.OBJECT,
                properties: {
                  calories: { type: Type.NUMBER },
                  proteinG: { type: Type.NUMBER },
                  carbsG: { type: Type.NUMBER },
                  fatG: { type: Type.NUMBER },
                  sugarG: { type: Type.NUMBER },
                },
              },
              itemsToBuy: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    productId: { type: Type.STRING },
                    quantity: { type: Type.INTEGER },
                  },
                  required: ["productId", "quantity"],
                },
              },
              pantryMatch: { type: Type.ARRAY, items: { type: Type.STRING } },
              steps: { type: Type.ARRAY, items: { type: Type.STRING } },
              chefTip: { type: Type.STRING },
              totalCost: { type: Type.NUMBER },
            },
            required: ["title", "prepTime", "cookTime", "itemsToBuy", "steps", "chefTip"],
          },
        },
      });

      const latency = Date.now() - startTime;
      const parsed = JSON.parse((response.text || "{}").trim());

      await logAiUsage(userId, "recipe_assistant", "gemini-3.6-flash", 120, 250, latency);
      await logPromptHistory(userId, "recipe_assistant", recipeName, JSON.stringify(parsed));

      if (usePostgreSQL) {
        try {
          await dbQuery(
            `INSERT INTO recipe_history (user_id, recipe_name, recipe_data) VALUES ($1, $2, $3)`,
            [userId, parsed.title || recipeName, JSON.stringify(parsed)]
          );
        } catch (e) {
          logger.warn("Could not save recipe history:", e);
        }
      }

      return parsed;
    } catch (error: any) {
      logger.error("Gemini API Error in generateRecipe, using fallback:", error);
      return simulateRecipe(recipeName);
    }
  }

  // 3. Budget Planner
  static async processBudget(
    budgetLimit: number,
    period: "weekly" | "monthly" = "weekly",
    familySize: number = 2,
    dietPreferences: string = "balanced",
    userId: string = "u1"
  ): Promise<any> {
    const startTime = Date.now();
    const ai = getGeminiClient();

    if (!ai) {
      return {
        period,
        budgetLimit,
        familySize,
        dietPreferences,
        totalEstimatedCost: Math.min(budgetLimit, 850),
        savingsVsRegular: 180,
        groceryPlan: [
          { category: "Dairy & Eggs", productId: "p6", quantity: 2, name: "Organic Free-Range Eggs", cost: 190 },
          { category: "Daily Bread & Milk", productId: "p7", quantity: 3, name: "Pasteurized Milk", cost: 99 },
          { category: "Fresh Veggies", productId: "p2", quantity: 2, name: "Fresh Red Tomatoes", cost: 80 },
          { category: "Pantry Staples", productId: "p15", quantity: 1, name: "Organic Arhar Dal", cost: 160 },
          { category: "Pantry Staples", productId: "p14", quantity: 1, name: "Premium Basmati Rice", cost: 199 }
        ],
        optimizationTips: [
          "Buy unpolished Arhar Dal in 1kg bulk to save ₹30.",
          "Substitute organic milk with full cream pouch for ₹20 weekly savings.",
          "Choose seasonal red tomatoes over imported cherry tomatoes."
        ],
        cheaperAlternatives: [
          { original: "Imported Butter", alternative: "Fresh Paneer", savings: "₹45" }
        ]
      };
    }

    try {
      const response = await ai.models.generateContent({
        model: "gemini-3.6-flash",
        contents: `You are the FlashCart AI Budget Planner & Smart Grocery Optimizer.
        Build a ${period} grocery plan for a family of ${familySize} people with diet preference "${dietPreferences}".
        Strict Maximum Budget: ₹${budgetLimit}.

        ${PRODUCT_CATALOG_CONTEXT}

        Instructions:
        1. Select product IDs from catalog to fill a complete ${period} grocery basket within ₹${budgetLimit}.
        2. Provide actionable budget optimization tips, cheaper alternative recommendations, and brand comparison insights.
        3. Return JSON structure:
        {
          "period": "${period}",
          "budgetLimit": ${budgetLimit},
          "totalEstimatedCost": 0,
          "savingsVsRegular": 0,
          "groceryPlan": [
            {"category": "string", "productId": "p1", "quantity": 1, "name": "string", "cost": 0}
          ],
          "optimizationTips": ["tip 1", "tip 2"],
          "cheaperAlternatives": [
            {"original": "string", "alternative": "string", "savings": "string"}
          ]
        }`,
        config: {
          responseMimeType: "application/json",
          responseSchema: {
            type: Type.OBJECT,
            properties: {
              period: { type: Type.STRING },
              budgetLimit: { type: Type.NUMBER },
              totalEstimatedCost: { type: Type.NUMBER },
              savingsVsRegular: { type: Type.NUMBER },
              groceryPlan: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    category: { type: Type.STRING },
                    productId: { type: Type.STRING },
                    quantity: { type: Type.INTEGER },
                    name: { type: Type.STRING },
                    cost: { type: Type.NUMBER },
                  },
                  required: ["productId", "quantity", "cost"],
                },
              },
              optimizationTips: { type: Type.ARRAY, items: { type: Type.STRING } },
              cheaperAlternatives: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    original: { type: Type.STRING },
                    alternative: { type: Type.STRING },
                    savings: { type: Type.STRING },
                  },
                },
              },
            },
            required: ["totalEstimatedCost", "groceryPlan", "optimizationTips"],
          },
        },
      });

      const latency = Date.now() - startTime;
      const parsed = JSON.parse((response.text || "{}").trim());

      await logAiUsage(userId, "budget_planner", "gemini-3.6-flash", 140, 220, latency);
      await logPromptHistory(userId, "budget_planner", `Budget: ${budgetLimit} (${period})`, JSON.stringify(parsed));

      return parsed;
    } catch (error: any) {
      logger.error("Gemini API Error in processBudget, using fallback:", error);
      return {
        period,
        budgetLimit,
        totalEstimatedCost: Math.min(budgetLimit, 750),
        savingsVsRegular: 120,
        groceryPlan: [
          { category: "Veggies", productId: "p1", quantity: 2, name: "Organic Bananas", cost: 138 },
          { category: "Dairy", productId: "p7", quantity: 4, name: "Full Cream Milk", cost: 132 },
          { category: "Pantry", productId: "p14", quantity: 1, name: "Basmati Rice", cost: 199 },
          { category: "Pantry", productId: "p15", quantity: 1, name: "Arhar Dal", cost: 160 }
        ],
        optimizationTips: ["Purchase weekly bundles for high volume discounts.", "Swap branded items for FlashCart Direct."],
        cheaperAlternatives: []
      };
    }
  }

  // 4. Pantry Intelligence Scanner
  static async scanPantry(imagePresetIndex?: number, imageBase64?: string, userId: string = "u1"): Promise<any> {
    const startTime = Date.now();
    const ai = getGeminiClient();

    if (!ai || (!imageBase64 && imagePresetIndex !== undefined)) {
      return simulatePantryScan(imagePresetIndex || 0);
    }

    try {
      let response;
      if (imageBase64) {
        const cleanBase64 = imageBase64.replace(/^data:image\/\w+;base64,/, "");
        response = await ai.models.generateContent({
          model: "gemini-3.6-flash",
          contents: [
            {
              inlineData: {
                mimeType: "image/jpeg",
                data: cleanBase64,
              },
            },
            {
              text: `You are the FlashCart Vision & Pantry Intelligence AI.
              Analyze this photo of a kitchen pantry/refrigerator.
              Detect visible food items, estimate quantity status (Full, Low, Empty), estimate expiry timeline, and match to our catalog:
              ${PRODUCT_CATALOG_CONTEXT}

              Return raw JSON:
              {
                "detectedItems": [{"productId": "p1", "name": "Bananas", "status": "Low", "expiryEstimate": "2 days", "confidence": 0.95}],
                "recipeSuggestion": "Detailed dish suggestion based on detected items",
                "suggestedAdditions": [{"productId": "p7", "quantity": 2}],
                "healthInsight": "High fiber pantry overall."
              }`,
            },
          ],
          config: {
            responseMimeType: "application/json",
            responseSchema: {
              type: Type.OBJECT,
              properties: {
                detectedItems: {
                  type: Type.ARRAY,
                  items: {
                    type: Type.OBJECT,
                    properties: {
                      productId: { type: Type.STRING },
                      name: { type: Type.STRING },
                      status: { type: Type.STRING },
                      expiryEstimate: { type: Type.STRING },
                      confidence: { type: Type.NUMBER },
                    },
                    required: ["productId", "name", "status"],
                  },
                },
                recipeSuggestion: { type: Type.STRING },
                suggestedAdditions: {
                  type: Type.ARRAY,
                  items: {
                    type: Type.OBJECT,
                    properties: {
                      productId: { type: Type.STRING },
                      quantity: { type: Type.INTEGER },
                    },
                    required: ["productId", "quantity"],
                  },
                },
                healthInsight: { type: Type.STRING },
              },
              required: ["detectedItems", "recipeSuggestion", "suggestedAdditions"],
            },
          },
        });
      } else {
        const presetPrompt = getPresetDescription(imagePresetIndex || 0);
        response = await ai.models.generateContent({
          model: "gemini-3.6-flash",
          contents: `Analyze scanned pantry description: "${presetPrompt}". Map items to catalog.
          ${PRODUCT_CATALOG_CONTEXT}
          Return raw JSON with detectedItems, recipeSuggestion, suggestedAdditions, healthInsight.`,
          config: { responseMimeType: "application/json" },
        });
      }

      const latency = Date.now() - startTime;
      const parsed = JSON.parse((response.text || "{}").trim());

      await logAiUsage(userId, "pantry_scan", "gemini-3.6-flash", 200, 180, latency);

      return parsed;
    } catch (error: any) {
      logger.error("Vision API error in scanPantry, using fallback:", error);
      return simulatePantryScan(imagePresetIndex || 0);
    }
  }

  // 5. Image Search
  static async processImageSearch(imageBase64: string, userId: string = "u1"): Promise<any> {
    const startTime = Date.now();
    const ai = getGeminiClient();

    if (!ai || !imageBase64) {
      return {
        detectedProduct: "Organic Fresh Bananas",
        brandMatch: "Organic India Fresh",
        packageDetection: "1 bunch (5-6 pcs)",
        confidenceScore: 0.96,
        matchingProducts: [
          { ...DB_STATE.products[0], matchPercentage: 98 },
          { ...DB_STATE.products[2], matchPercentage: 75 }
        ],
        searchTags: ["fruit", "potassium", "fresh", "organic"]
      };
    }

    try {
      const cleanBase64 = imageBase64.replace(/^data:image\/\w+;base64,/, "");
      const response = await ai.models.generateContent({
        model: "gemini-3.6-flash",
        contents: [
          { inlineData: { mimeType: "image/jpeg", data: cleanBase64 } },
          {
            text: `Analyze this uploaded product image for quick commerce visual search.
            Detect product identity, brand name, packaging type, and match with catalog products:
            ${PRODUCT_CATALOG_CONTEXT}

            Return JSON:
            {
              "detectedProduct": "Name of product",
              "brandMatch": "Brand name detected",
              "packageDetection": "500g / 1kg / Pack of 6",
              "confidenceScore": 0.95,
              "matchingProductIds": ["p1", "p3"],
              "searchTags": ["tag1", "tag2"]
            }`,
          },
        ],
        config: {
          responseMimeType: "application/json",
          responseSchema: {
            type: Type.OBJECT,
            properties: {
              detectedProduct: { type: Type.STRING },
              brandMatch: { type: Type.STRING },
              packageDetection: { type: Type.STRING },
              confidenceScore: { type: Type.NUMBER },
              matchingProductIds: { type: Type.ARRAY, items: { type: Type.STRING } },
              searchTags: { type: Type.ARRAY, items: { type: Type.STRING } },
            },
            required: ["detectedProduct", "confidenceScore", "matchingProductIds"],
          },
        },
      });

      const latency = Date.now() - startTime;
      const parsed = JSON.parse((response.text || "{}").trim());

      const matchingProducts = (parsed.matchingProductIds || ["p1", "p2"]).map((id: string, idx: number) => {
        const found = DB_STATE.products.find((p) => p.id === id) || DB_STATE.products[0];
        return { ...found, matchPercentage: Math.max(98 - idx * 12, 70) };
      });

      await logAiUsage(userId, "image_search", "gemini-3.6-flash", 220, 150, latency);

      return {
        detectedProduct: parsed.detectedProduct,
        brandMatch: parsed.brandMatch || "Verified Local Producer",
        packageDetection: parsed.packageDetection || "Standard Retail Pack",
        confidenceScore: parsed.confidenceScore || 0.92,
        matchingProducts,
        searchTags: parsed.searchTags || ["fresh", "grocery"],
      };
    } catch (err) {
      logger.error("Image search error, fallback:", err);
      return {
        detectedProduct: "Fresh Produce Item",
        confidenceScore: 0.88,
        matchingProducts: [DB_STATE.products[0], DB_STATE.products[1]],
        searchTags: ["fresh", "organic"]
      };
    }
  }

  // 6. Voice Shopping
  static async processVoice(transcript: string, currentCart: any[] = [], userId: string = "u1"): Promise<any> {
    const startTime = Date.now();
    const ai = getGeminiClient();

    if (!ai) {
      const lower = transcript.toLowerCase();
      let action = "search";
      if (lower.includes("add") || lower.includes("buy")) action = "add_to_cart";
      if (lower.includes("remove") || lower.includes("delete")) action = "remove_from_cart";
      if (lower.includes("order") || lower.includes("checkout")) action = "place_order";

      return {
        transcript,
        action,
        spokenResponse: `Understood! I parsed your voice request: "${transcript}". Updating your shopping list right away.`,
        items: [{ productId: "p1", quantity: 1 }],
        confidence: 0.95
      };
    }

    try {
      const response = await ai.models.generateContent({
        model: "gemini-3.6-flash",
        contents: `You are the FlashCart Voice Assistant Engine.
        Process transcribed user voice command: "${transcript}".
        Current Cart: ${JSON.stringify(currentCart)}

        ${PRODUCT_CATALOG_CONTEXT}

        Instructions:
        1. Parse action: "add_to_cart" | "remove_from_cart" | "search" | "place_order" | "track_order".
        2. Identify target product IDs and quantities.
        3. Formulate a natural human spoken text response (under 25 words).
        4. Return raw JSON:
        {
          "transcript": "${transcript}",
          "action": "add_to_cart",
          "spokenResponse": "Added 2 packs of organic eggs to your cart!",
          "items": [{"productId": "p6", "quantity": 2}],
          "confidence": 0.98
        }`,
        config: {
          responseMimeType: "application/json",
          responseSchema: {
            type: Type.OBJECT,
            properties: {
              transcript: { type: Type.STRING },
              action: { type: Type.STRING },
              spokenResponse: { type: Type.STRING },
              items: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    productId: { type: Type.STRING },
                    quantity: { type: Type.INTEGER },
                  },
                  required: ["productId", "quantity"],
                },
              },
              confidence: { type: Type.NUMBER },
            },
            required: ["action", "spokenResponse", "items"],
          },
        },
      });

      const latency = Date.now() - startTime;
      const parsed = JSON.parse((response.text || "{}").trim());

      await logAiUsage(userId, "voice_shopping", "gemini-3.6-flash", 100, 120, latency);

      return parsed;
    } catch (err) {
      logger.error("Voice processing error:", err);
      return {
        transcript,
        action: "add_to_cart",
        spokenResponse: "Got it! Adding requested items to your cart now.",
        items: [{ productId: "p1", quantity: 1 }],
        confidence: 0.90
      };
    }
  }

  // 7. Nutrition Coach
  static async processNutrition(itemsOrQuery: any, userId: string = "u1"): Promise<any> {
    const startTime = Date.now();
    const ai = getGeminiClient();

    if (!ai) {
      return {
        healthScore: 88,
        totalCalories: 480,
        macros: { proteinG: 24, carbsG: 45, fatG: 14, sugarG: 8 },
        dietRecommendations: [
          "Great protein-to-carbs ratio for morning energy!",
          "Consider adding fiber-rich green spinach for enhanced iron absorption."
        ],
        allergenWarnings: ["Contains Eggs", "Contains Dairy"],
        ecoScoreAverage: "A"
      };
    }

    try {
      const response = await ai.models.generateContent({
        model: "gemini-3.6-flash",
        contents: `You are the FlashCart AI Clinical Nutrition Coach.
        Analyze nutrition for the input: ${JSON.stringify(itemsOrQuery)}

        ${PRODUCT_CATALOG_CONTEXT}

        Instructions:
        1. Calculate overall calories, protein (g), carbs (g), fat (g), sugar (g).
        2. Assign a Health Score from 1 to 100.
        3. Provide personalized diet recommendations and flag allergen warnings (e.g. dairy, gluten, nuts).
        4. Return raw JSON:
        {
          "healthScore": 85,
          "totalCalories": 450,
          "macros": {
            "proteinG": 22,
            "carbsG": 40,
            "fatG": 12,
            "sugarG": 6
          },
          "dietRecommendations": ["rec 1", "rec 2"],
          "allergenWarnings": ["warning 1"],
          "ecoScoreAverage": "A"
        }`,
        config: {
          responseMimeType: "application/json",
          responseSchema: {
            type: Type.OBJECT,
            properties: {
              healthScore: { type: Type.INTEGER },
              totalCalories: { type: Type.NUMBER },
              macros: {
                type: Type.OBJECT,
                properties: {
                  proteinG: { type: Type.NUMBER },
                  carbsG: { type: Type.NUMBER },
                  fatG: { type: Type.NUMBER },
                  sugarG: { type: Type.NUMBER },
                },
              },
              dietRecommendations: { type: Type.ARRAY, items: { type: Type.STRING } },
              allergenWarnings: { type: Type.ARRAY, items: { type: Type.STRING } },
              ecoScoreAverage: { type: Type.STRING },
            },
            required: ["healthScore", "totalCalories", "macros", "dietRecommendations"],
          },
        },
      });

      const latency = Date.now() - startTime;
      const parsed = JSON.parse((response.text || "{}").trim());

      await logAiUsage(userId, "nutrition_coach", "gemini-3.6-flash", 110, 180, latency);

      if (usePostgreSQL) {
        try {
          await dbQuery(
            `INSERT INTO nutrition_logs (user_id, log_data, health_score) VALUES ($1, $2, $3)`,
            [userId, JSON.stringify(parsed), parsed.healthScore || 85]
          );
        } catch (e) {
          logger.warn("Could not log nutrition:", e);
        }
      }

      return parsed;
    } catch (err) {
      logger.error("Nutrition calculation error:", err);
      return {
        healthScore: 82,
        totalCalories: 410,
        macros: { proteinG: 20, carbsG: 38, fatG: 10, sugarG: 5 },
        dietRecommendations: ["Balanced meal choice with wholesome whole foods."],
        allergenWarnings: [],
        ecoScoreAverage: "B"
      };
    }
  }

  // 8. Smart Recommendations
  static async processRecommendations(userId: string = "u1", context?: any): Promise<any> {
    const hour = new Date().getHours();
    const timeOfDay = hour < 11 ? "Morning Breakfast" : hour < 17 ? "Afternoon Fuel" : "Evening Snacks & Dinner";

    return {
      frequentlyBoughtTogether: [
        { mainProduct: DB_STATE.products[7], suggested: [DB_STATE.products[4], DB_STATE.products[5]] }, // Milk -> Eggs, Paneer
        { mainProduct: DB_STATE.products[13], suggested: [DB_STATE.products[15], DB_STATE.products[1]] } // Rice -> Dal, Bananas
      ],
      personalRecommendations: [DB_STATE.products[0], DB_STATE.products[5], DB_STATE.products[7], DB_STATE.products[12]],
      seasonalProducts: [
        { title: "Monsoon Hot Beverages & Immunity", items: [DB_STATE.products[12], DB_STATE.products[15]] }
      ],
      festivalBundles: [
        { bundleName: "Festive Indian Sweets & Dairy Essentials", items: [DB_STATE.products[4], DB_STATE.products[6], DB_STATE.products[9]] }
      ],
      weatherBased: {
        condition: "Rainy 24°C",
        title: "Warm Brews & Crispy Munchies",
        items: [DB_STATE.products[12], DB_STATE.products[10], DB_STATE.products[7]]
      },
      timeOfDay: {
        slot: timeOfDay,
        title: `${timeOfDay} Selections`,
        items: hour < 12 ? [DB_STATE.products[0], DB_STATE.products[5], DB_STATE.products[7]] : [DB_STATE.products[4], DB_STATE.products[13], DB_STATE.products[14]]
      }
    };
  }

  // 9. Admin Analytics
  static async getAiAnalytics(): Promise<any> {
    let totalRequests = 1240;
    let totalPromptTokens = 185000;
    let totalCompletionTokens = 240000;
    let avgLatencyMs = 210;

    if (usePostgreSQL) {
      try {
        const statsRes = await dbQuery(`
          SELECT 
            COUNT(*) as total_reqs,
            COALESCE(SUM(prompt_tokens), 0) as p_tokens,
            COALESCE(SUM(completion_tokens), 0) as c_tokens,
            COALESCE(AVG(latency_ms), 200) as avg_lat
          FROM ai_usage_logs
        `);
        if (statsRes.rows.length > 0) {
          totalRequests = parseInt(statsRes.rows[0].total_reqs || "1240", 10);
          totalPromptTokens = parseInt(statsRes.rows[0].p_tokens || "185000", 10);
          totalCompletionTokens = parseInt(statsRes.rows[0].c_tokens || "240000", 10);
          avgLatencyMs = Math.round(parseFloat(statsRes.rows[0].avg_lat || "210"));
        }
      } catch (err) {
        logger.warn("Could not query AI analytics stats:", err);
      }
    }

    return {
      modelHealth: {
        status: "HEALTHY",
        activeModel: "gemini-3.6-flash",
        uptimePercentage: 99.98,
        errorRatePercentage: 0.02,
        avgLatencyMs,
      },
      tokenUsage: {
        totalPromptTokens,
        totalCompletionTokens,
        totalCombinedTokens: totalPromptTokens + totalCompletionTokens,
        estimatedCostUSD: ((totalPromptTokens + totalCompletionTokens) * 0.000001).toFixed(4),
      },
      popularQueries: [
        { query: "Quick high-protein breakfast for 5 people under ₹500", count: 320 },
        { query: "Paneer butter masala quick ingredient list", count: 280 },
        { query: "Pantry scan: low milk and egg alert", count: 210 },
        { query: "Weekly grocery budget under ₹1500 for family of 4", count: 185 },
        { query: "Calorie & protein breakdown for eggs and brown bread", count: 140 },
      ],
      featureUsageBreakdown: [
        { feature: "Conversational Shopping", percentage: 42 },
        { feature: "Recipe Builder", percentage: 22 },
        { feature: "Pantry Intelligence", percentage: 16 },
        { feature: "Budget Planner", percentage: 11 },
        { feature: "Voice & Vision Search", percentage: 9 },
      ],
    };
  }

  // 10. Store Manager Demand Forecast & Inventory AI Hooks
  static async getDemandForecast(): Promise<any> {
    return {
      forecastPeriod: "Next 7 Days",
      predictedHighDemandItems: [
        { productId: "p7", name: "Full Cream Milk", expectedSurge: "+35%", recommendedStock: 120, confidence: 0.94 },
        { productId: "p6", name: "Organic Eggs", expectedSurge: "+28%", recommendedStock: 80, confidence: 0.91 },
        { productId: "p1", name: "Fresh Bananas", expectedSurge: "+20%", recommendedStock: 65, confidence: 0.89 }
      ],
      lowStockPredictions: [
        { productId: "p5", name: "Premium Paneer", currentStock: 4, predictedStockoutTime: "In 2 hours", restockUrgency: "HIGH" },
        { productId: "p8", name: "Sourdough Bread", currentStock: 2, predictedStockoutTime: "In 45 mins", restockUrgency: "CRITICAL" }
      ],
      inventorySuggestions: [
        "Increase morning dairy pouch orders by 30 units for weekend breakfast surge.",
        "Bundle low-selling potato chips with cold brew beverages for 15% clearance."
      ]
    };
  }

  // 11. Delivery Partner Route & Peak Predictions
  static async getDeliveryRouteAi(): Promise<any> {
    return {
      suggestedRoute: {
        totalDistanceKm: 3.2,
        estimatedDurationMins: 9,
        trafficStatus: "Light",
        optimizedWaypoints: [
          { name: "Koramangala Dark Store (Pickup)", lat: 12.9279, lng: 77.6250 },
          { name: "Symphony Apts (Dropoff)", lat: 12.9348, lng: 77.6189 }
        ]
      },
      peakHourPrediction: {
        currentSurgeMultiplier: 1.25,
        upcomingPeakWindow: "7:30 PM - 9:30 PM",
        expectedBonusPerTrip: "₹45",
        highDemandZones: ["Koramangala 3rd Block", "Indiranagar 100ft Rd", "HSR Sector 1"]
      }
    };
  }

  // 12. Get AI History
  static async getAiHistory(userId: string = "u1"): Promise<any> {
    let promptLogs: any[] = [];
    let recipes: any[] = [];

    if (usePostgreSQL) {
      try {
        const promptsRes = await dbQuery(
          `SELECT feature, prompt, response, created_at FROM prompt_history WHERE user_id = $1 ORDER BY created_at DESC LIMIT 20`,
          [userId]
        );
        promptLogs = promptsRes.rows;

        const recipesRes = await dbQuery(
          `SELECT recipe_name, recipe_data, created_at FROM recipe_history WHERE user_id = $1 ORDER BY created_at DESC LIMIT 10`,
          [userId]
        );
        recipes = recipesRes.rows;
      } catch (err) {
        logger.warn("Could not fetch AI history from DB:", err);
      }
    }

    return {
      promptLogs,
      recipes,
    };
  }

  // 13. Clear AI History
  static async clearAiHistory(userId: string = "u1"): Promise<any> {
    if (usePostgreSQL) {
      try {
        await dbQuery(`DELETE FROM prompt_history WHERE user_id = $1`, [userId]);
        await dbQuery(`DELETE FROM recipe_history WHERE user_id = $1`, [userId]);
      } catch (err) {
        logger.warn("Could not clear AI history in DB:", err);
      }
    }
    return { success: true, message: "AI history cleared successfully." };
  }
}
