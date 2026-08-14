import { GoogleGenAI, Type } from '@google/genai';
import dotenv from 'dotenv';

dotenv.config();

// Available product catalog context for Gemini
const PRODUCT_CATALOG_CONTEXT = `
Available products in FlashCart AI store:
- p1: Organic Fresh Bananas (Category: veggies, Price: ₹69, Unit: 1 bunch of 5-6 pcs, Calories: 105, Protein: 1.3g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.15kg)
- p2: Fresh Red Tomatoes (Category: veggies, Price: ₹40, Unit: 500 g, Calories: 18, Protein: 0.9g, ecoScore: B, carbon: 0.28kg)
- p3: Hydroponic English Cucumber (Category: veggies, Price: ₹75, Unit: 1 pc, Calories: 15, Protein: 0.7g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.08kg)
- p4: Fresh Spinach Palak (Category: veggies, Price: ₹25, Unit: 1 bunch (250g), Calories: 23, Protein: 2.9g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.12kg)
- p5: Premium Fresh Paneer (Category: dairy, Price: ₹110, Unit: 200 g, Calories: 265, Protein: 18.3g, isHealthy: true, ecoScore: C, carbon: 1.20kg)
- p6: Organic Free-Range Eggs (Category: dairy, Price: ₹95, Unit: 6 pcs pack, Calories: 78, Protein: 6.3g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.45kg)
- p7: Pasteurized Full Cream Milk (Category: dairy, Price: ₹33, Unit: 500 ml pouch, Calories: 150, Protein: 8.0g, isHealthy: true, ecoScore: B, carbon: 0.85kg)
- p8: Artisanal Sourdough Bread (Category: bakery, Price: ₹120, Unit: 400 g, Calories: 220, Protein: 8.0g, isOrganic: true, isHealthy: true, ecoScore: B, carbon: 0.35kg)
- p9: Whole Wheat Brown Bread (Category: bakery, Price: ₹45, Unit: 400 g pack, Calories: 190, Protein: 6.5g, isHealthy: true, ecoScore: B, carbon: 0.42kg)
- p10: Gourmet Salted Roasted Cashews (Category: snacks, Price: ₹180, Unit: 100 g, Calories: 553, Protein: 18.2g, isOrganic: true, isHealthy: true, ecoScore: B, carbon: 0.52kg)
- p11: Spicy Potato Chips Classic (Category: snacks, Price: ₹30, Unit: 80 g bag, Calories: 450, Protein: 5.0g, ecoScore: D, carbon: 0.98kg)
- p12: Sparkling Natural Spring Water (Category: beverages, Price: ₹80, Unit: 750 ml Glass Bottle, Calories: 0, Protein: 0.0g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.10kg)
- p13: Premium Cold Brew Black Coffee (Category: beverages, Price: ₹150, Unit: 250 ml can, Calories: 5, Protein: 0.2g, isOrganic: true, isHealthy: true, ecoScore: B, carbon: 0.40kg)
- p14: Premium Basmati Rice Rozana (Category: pantry, Price: ₹199, Unit: 1 kg pack, Calories: 365, Protein: 7.1g, isHealthy: true, ecoScore: B, carbon: 0.65kg)
- p15: Organic Unpolished Arhar Dal (Category: pantry, Price: ₹160, Unit: 1 kg pack, Calories: 343, Protein: 22.0g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.30kg)
- p16: Premium Daily Multivitamin (Category: medicine, Price: ₹350, Unit: 30 tablets, Calories: 0, Protein: 0.0g, isHealthy: true, ecoScore: B, carbon: 0.18kg)
- p17: Biodegradable Bamboo Baby Wipes (Category: baby, Price: ₹220, Unit: 80 wipes, Calories: 0, Protein: 0.0g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.05kg)
`;

let aiInstance: GoogleGenAI | null = null;

function getAI(): GoogleGenAI {
  if (!aiInstance) {
    const key = process.env.GEMINI_API_KEY;
    if (!key) {
      throw new Error('GEMINI_API_KEY environment variable is required');
    }
    aiInstance = new GoogleGenAI({
      apiKey: key,
      httpOptions: {
        headers: {
          'User-Agent': 'aistudio-build',
        },
      },
    });
  }
  return aiInstance;
}

/**
 * AI Shopping Assistant - Selects products from catalog based on natural language queries
 */
export async function runShoppingAssistant(prompt: string, currentCart: any[] = []) {
  const ai = getAI();
  const response = await ai.models.generateContent({
    model: 'gemini-3.5-flash',
    contents: `You are the FlashCart AI Shopping Assistant. Your task is to process the user's quick-commerce prompt and select actual items from our catalog.
    
    ${PRODUCT_CATALOG_CONTEXT}
    
    User Prompt: "${prompt}"
    Current Cart Items: ${JSON.stringify(currentCart)}
    
    Instructions:
    1. Select the product IDs that match the user request.
    2. Set a realistic quantity.
    3. Return a JSON with: explanation, items list, and totalPrice.`,
    config: {
      responseMimeType: 'application/json',
      responseSchema: {
        type: Type.OBJECT,
        properties: {
          explanation: { type: Type.STRING },
          items: {
            type: Type.ARRAY,
            items: {
              type: Type.OBJECT,
              properties: {
                productId: { type: Type.STRING },
                quantity: { type: Type.INTEGER },
              },
              required: ['productId', 'quantity'],
            },
          },
          totalPrice: { type: Type.NUMBER },
        },
        required: ['explanation', 'items', 'totalPrice'],
      },
    },
  });

  return JSON.parse(response.text || '{}');
}

/**
 * Smart Meal Planner - Creates a custom meal plan mapping to local catalog products
 */
export async function runMealPlanner(diet: string, cuisine: string, calories: number, budget: number) {
  const ai = getAI();
  const response = await ai.models.generateContent({
    model: 'gemini-3.5-flash',
    contents: `You are the FlashCart AI Nutritionist. Build a 1-day meal plan (Breakfast, Lunch, Dinner) matching these parameters:
    Diet: ${diet}
    Cuisine: ${cuisine}
    Calories Target: ${calories} kcal
    Max Budget: ₹${budget}
    
    ${PRODUCT_CATALOG_CONTEXT}
    
    Map ingredients to product IDs. Keep total price below budget.`,
    config: {
      responseMimeType: 'application/json',
      responseSchema: {
        type: Type.OBJECT,
        properties: {
          breakfast: {
            type: Type.OBJECT,
            properties: {
              name: { type: Type.STRING },
              items: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    productId: { type: Type.STRING },
                    quantity: { type: Type.INTEGER },
                  },
                  required: ['productId', 'quantity'],
                },
              },
              explanation: { type: Type.STRING },
            },
            required: ['name', 'items', 'explanation'],
          },
          lunch: {
            type: Type.OBJECT,
            properties: {
              name: { type: Type.STRING },
              items: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    productId: { type: Type.STRING },
                    quantity: { type: Type.INTEGER },
                  },
                  required: ['productId', 'quantity'],
                },
              },
              explanation: { type: Type.STRING },
            },
            required: ['name', 'items', 'explanation'],
          },
          dinner: {
            type: Type.OBJECT,
            properties: {
              name: { type: Type.STRING },
              items: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    productId: { type: Type.STRING },
                    quantity: { type: Type.INTEGER },
                  },
                  required: ['productId', 'quantity'],
                },
              },
              explanation: { type: Type.STRING },
            },
            required: ['name', 'items', 'explanation'],
          },
        },
        required: ['breakfast', 'lunch', 'dinner'],
      },
    },
  });

  return JSON.parse(response.text || '{}');
}

/**
 * AI Recipe Builder - Builds cooking guide and mapping list
 */
export async function runRecipeBuilder(recipeName: string) {
  const ai = getAI();
  const response = await ai.models.generateContent({
    model: 'gemini-3.5-flash',
    contents: `Build a cooking recipe for "${recipeName}" using available ingredients:
    ${PRODUCT_CATALOG_CONTEXT}`,
    config: {
      responseMimeType: 'application/json',
      responseSchema: {
        type: Type.OBJECT,
        properties: {
          title: { type: Type.STRING },
          prepTime: { type: Type.STRING },
          cookTime: { type: Type.STRING },
          itemsToBuy: {
            type: Type.ARRAY,
            items: {
              type: Type.OBJECT,
              properties: {
                productId: { type: Type.STRING },
                quantity: { type: Type.INTEGER },
              },
              required: ['productId', 'quantity'],
            },
          },
          steps: { type: Type.ARRAY, items: { type: Type.STRING } },
          chefTip: { type: Type.STRING },
        },
        required: ['title', 'prepTime', 'cookTime', 'itemsToBuy', 'steps', 'chefTip'],
      },
    },
  });

  return JSON.parse(response.text || '{}');
}

/**
 * Computer Vision Pantry Scanner - Evaluates food visual layouts to detect depleted stock
 */
export async function runPantryScanner(imageBase64: string) {
  const ai = getAI();
  const cleanBase64 = imageBase64.replace(/^data:image\/\w+;base64,/, '');

  const response = await ai.models.generateContent({
    model: 'gemini-3.5-flash',
    contents: [
      {
        inlineData: {
          mimeType: 'image/jpeg',
          data: cleanBase64,
        },
      },
      {
        text: `Analyze this image of a fridge or pantry. Detect visible items and cross-reference with our store products:
        ${PRODUCT_CATALOG_CONTEXT}
        Return JSON mapping found products, status (Full/Low/Empty), and auto additions.`,
      },
    ],
    config: {
      responseMimeType: 'application/json',
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
                confidence: { type: Type.NUMBER },
              },
              required: ['productId', 'name', 'status'],
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
              required: ['productId', 'quantity'],
            },
          },
        },
        required: ['detectedItems', 'recipeSuggestion', 'suggestedAdditions'],
      },
    },
  });

  return JSON.parse(response.text || '{}');
}
