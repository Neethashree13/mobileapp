import { Request, Response, NextFunction } from "express";
import { ProductRepository } from "../repositories/product.repository";
import { isProduction } from "../config/env";
import { usePostgreSQL } from "../config/database";

export async function getCategories(req: Request, res: Response, next: NextFunction) {
  try {
    const categories = await ProductRepository.getCategories();
    res.json(categories);
  } catch (error) {
    next(error);
  }
}

export async function getBrands(req: Request, res: Response, next: NextFunction) {
  try {
    const brands = await ProductRepository.getBrands();
    res.json(brands);
  } catch (error) {
    next(error);
  }
}

// export async function getProducts(req: Request, res: Response, next: NextFunction) {
//   try {
//     if (isProduction && !usePostgreSQL) {
//       res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
//       return;
//     }
//     const { category, brandId, q, minPrice, maxPrice, isOrganic, isHealthy, isFeatured, isTrending, isBestSeller, isFlashDeal, sortBy, page, limit } = req.query;

//     const filters = {
//       category: category ? String(category) : undefined,
//       brandId: brandId ? String(brandId) : undefined,
//       query: q ? String(q) : undefined,
//       minPrice: minPrice ? Number(minPrice) : undefined,
//       maxPrice: maxPrice ? Number(maxPrice) : undefined,
//       isOrganic: isOrganic === 'true',
//       isHealthy: isHealthy === 'true',
//       isFeatured: isFeatured === 'true',
//       isTrending: isTrending === 'true',
//       isBestSeller: isBestSeller === 'true',
//       isFlashDeal: isFlashDeal === 'true',
//       sortBy: sortBy ? String(sortBy) : undefined,
//       page: page ? Number(page) : 1,
//       limit: limit ? Number(limit) : 50,
//     };

//     const result = await ProductRepository.getAll(filters);
//     res.json(result.products);
//   } catch (error) {
//     next(error);
//   }
// }

export async function getProducts(req: Request, res: Response, next: NextFunction) {
  try {

    console.log("1. Product API started");

    const result = await ProductRepository.getAll({
      limit: 500
    });

    console.log("2. Repository finished");

    res.json(result.products);

  } catch (error) {
    console.log("PRODUCT ERROR:", error);
    next(error);
  }
}

export async function getProductById(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const product = await ProductRepository.findById(id);
    if (!product) {
      res.status(404).json({ error: "Product not found" });
      return;
    }
    res.json(product);
  } catch (error) {
    next(error);
  }
}

export async function getProductVariants(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const product = await ProductRepository.findById(id);
    if (!product) {
      res.status(404).json({ error: "Product not found" });
      return;
    }
    res.json(product.variants || []);
  } catch (error) {
    next(error);
  }
}

export async function searchProducts(req: Request, res: Response, next: NextFunction) {
  const { q } = req.query;
  try {
    const queryStr = q ? String(q) : "";
    const results = await ProductRepository.search(queryStr);
    res.json({ query: q, results });
  } catch (error) {
    next(error);
  }
}

export async function getTrendingProducts(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await ProductRepository.getAll({ isTrending: true, limit: 10 });
    res.json(result.products.length > 0 ? result.products : (await ProductRepository.getAll({ limit: 10 })).products);
  } catch (error) {
    next(error);
  }
}

export async function getBestSellers(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await ProductRepository.getAll({ isBestSeller: true, limit: 10 });
    res.json(result.products.length > 0 ? result.products : (await ProductRepository.getAll({ limit: 10 })).products);
  } catch (error) {
    next(error);
  }
}

export async function getFeaturedProducts(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await ProductRepository.getAll({ isFeatured: true, limit: 10 });
    res.json(result.products.length > 0 ? result.products : (await ProductRepository.getAll({ limit: 10 })).products);
  } catch (error) {
    next(error);
  }
}

export async function getRecommendedProducts(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await ProductRepository.getAll({ isHealthy: true, limit: 10 });
    res.json(result.products.length > 0 ? result.products : (await ProductRepository.getAll({ limit: 10 })).products);
  } catch (error) {
    next(error);
  }
}

export async function getOffers(req: Request, res: Response, next: NextFunction) {
  try {
    const all = await ProductRepository.getAll({ limit: 50 });
    const discounted = all.products.filter((p) => p.originalPrice && p.originalPrice > p.price);
    res.json(discounted.length > 0 ? discounted : all.products.slice(0, 10));
  } catch (error) {
    next(error);
  }
}

export async function getFlashDeals(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await ProductRepository.getAll({ isFlashDeal: true, limit: 10 });
    res.json(result.products.length > 0 ? result.products : (await ProductRepository.getAll({ limit: 8 })).products);
  } catch (error) {
    next(error);
  }
}

export async function getRecentlyViewed(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = (req.query.userId as string) || "6ba7b810-9dad-11d1-80b4-00c04fd430c8";
    const products = await ProductRepository.getRecentlyViewed(userId);
    res.json(products);
  } catch (error) {
    next(error);
  }
}

export async function addRecentlyViewed(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.body.userId || "6ba7b810-9dad-11d1-80b4-00c04fd430c8";
    const { productId } = req.body;
    if (productId) {
      await ProductRepository.addRecentlyViewed(userId, productId);
    }
    res.json({ status: "success" });
  } catch (error) {
    next(error);
  }
}

export async function getStoreInventory(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params; // store id e.g. s1
    const { products } = await ProductRepository.getAll({ limit: 100 });
    const inventoryList = products.map((p) => ({
      storeId: id,
      productId: p.id,
      productName: p.name,
      category: p.category,
      price: p.price,
      stockQuantity: p.inventory,
      lowStockThreshold: 10,
      isAvailable: p.inventory > 0,
    }));
    res.json({ storeId: id, inventory: inventoryList });
  } catch (error) {
    next(error);
  }
}

export async function recordStockMovement(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params; // store id
    const { productId, variantId, movementType, quantity, reason, notes, createdBy } = req.body;

    await ProductRepository.recordStockMovement({
      storeId: id || 's1',
      productId,
      variantId,
      movementType, // 'receive', 'move', 'damage', 'expired', 'adjustment', 'cycle_count'
      quantity: Number(quantity) || 0,
      reason,
      notes,
      createdBy,
    });

    res.json({ status: "success", message: `Stock movement '${movementType}' recorded successfully` });
  } catch (error) {
    next(error);
  }
}

export async function getStockMovements(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const movements = await ProductRepository.getStockMovements(id);
    res.json(movements);
  } catch (error) {
    next(error);
  }
}

export async function getStockAlerts(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const alerts = await ProductRepository.getLowStockAlerts(id);
    res.json(alerts);
  } catch (error) {
    next(error);
  }
}

