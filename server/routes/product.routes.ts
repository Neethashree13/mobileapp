import { Router } from "express";
import * as productController from "../controllers/product.controller";
import { checkDbConnection } from "../middleware/dbCheck";

const router = Router();

// Catalog Categories & Brands
router.get("/categories", productController.getCategories);
router.get("/brands", productController.getBrands);

// Product Special Collections
router.get("/products/trending", productController.getTrendingProducts);
router.get("/products/best-sellers", productController.getBestSellers);
router.get("/products/featured", productController.getFeaturedProducts);
router.get("/products/recommended", productController.getRecommendedProducts);
router.get("/products/offers", productController.getOffers);
router.get("/products/flash-deals", productController.getFlashDeals);

// Recently Viewed
router.get("/products/recently-viewed", productController.getRecentlyViewed);
router.post("/products/recently-viewed", productController.addRecentlyViewed);

// Product Search & Detail
router.get("/search", checkDbConnection, productController.searchProducts);
router.get("/products", checkDbConnection, productController.getProducts);
router.get("/products/:id", checkDbConnection, productController.getProductById);
router.get("/products/:id/variants", checkDbConnection, productController.getProductVariants);

// Store Inventory & Stock Movements
router.get("/stores/:id/inventory", checkDbConnection, productController.getStoreInventory);
router.post("/stores/:id/stock-movement", checkDbConnection, productController.recordStockMovement);
router.get("/stores/:id/stock-movements", checkDbConnection, productController.getStockMovements);
router.get("/stores/:id/stock-alerts", checkDbConnection, productController.getStockAlerts);

export default router;

