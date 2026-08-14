/**
 * AI, Pantry, Meal Planning & Smart Shopping Models
 */

import { BaseDomainModel } from '../types';
import { AIRecommendationType, PantryStatus } from '../enums';
import { Product } from './catalog';

export interface AIRecommendation extends BaseDomainModel {
  userId: string;
  type: AIRecommendationType;
  title: string;
  reasoning: string;
  confidenceScore: number; // 0.0 - 1.0
  recommendedProducts: Product[];
  actionLabel?: string;
}

export interface RecipeIngredient {
  name: string;
  quantity: string;
  category: string;
  estimatedPrice: number;
  productId?: string;
  inStock?: boolean;
}

export interface Recipe extends BaseDomainModel {
  title: string;
  description: string;
  cuisine: string;
  prepTimeMinutes: number;
  cookTimeMinutes: number;
  servings: number;
  caloriesPerServing: number;
  difficulty: 'EASY' | 'MEDIUM' | 'ADVANCED';
  dietaryTags: string[];
  imageUrl: string;
  ingredients: RecipeIngredient[];
  instructions: string[];
}

export interface BudgetPlan extends BaseDomainModel {
  userId: string;
  monthlyLimit: number;
  spentAmount: number;
  predictedSpend: number;
  savingsGoal: number;
  currency: string;
  tips: string[];
  categoryBreakdown: Record<string, number>;
}

export interface NutritionInfo {
  calories: number;
  proteinGrams: number;
  fatGrams: number;
  carbohydrateGrams: number;
  fiberGrams: number;
  sugarGrams: number;
  sodiumMg: number;
  vitamins?: string[];
}

export interface SearchHistory extends BaseDomainModel {
  userId: string;
  queryText: string;
  searchType: 'TEXT' | 'VOICE' | 'IMAGE';
  resultCount: number;
  clickedProductId?: string;
}

export interface VoiceSearchQuery extends BaseDomainModel {
  userId: string;
  audioDurationSeconds: number;
  transcribedText: string;
  confidenceScore: number;
  matchedKeywords: string[];
}

export interface ImageSearchQuery extends BaseDomainModel {
  userId: string;
  inputImageUrl: string;
  detectedLabels: string[];
  matchedProductIds: string[];
}

export interface PantryItem extends BaseDomainModel {
  userId: string;
  productId?: string;
  name: string;
  category: string;
  quantity: string;
  status: PantryStatus;
  expiryDate?: string;
  autoReplenish: boolean;
  replenishThresholdDays?: number;
}
