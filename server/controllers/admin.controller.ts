import { Request, Response, NextFunction } from "express";
import { ProductService } from "../services/product.service";
import { ProductRepository } from "../repositories/product.repository";
import { ActivityRepository } from "../repositories/activity.repository";
import { dbQuery, usePostgreSQL } from "../config/database";
import { DB_STATE } from "../config/dbState";
import { isProduction } from "../config/env";

export async function createProduct(req: Request, res: Response, next: NextFunction) {
  try {
    const product = await ProductRepository.createProduct(req.body);
    await ActivityRepository.log("admin", "create_product", `Admin created product: ${product.name} (${product.id})`);
    res.status(201).json({ status: "success", product });
  } catch (error) {
    next(error);
  }
}

export async function updateProduct(req: Request, res: Response, next: NextFunction) {
  const { id, price, inventory } = req.body;
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const updated = await ProductRepository.update(
      id || req.params.id,
      price !== undefined ? Number(price) : undefined,
      inventory !== undefined ? Number(inventory) : undefined,
      req.body
    );
    if (!updated) {
      res.status(404).json({ error: "Product not found" });
      return;
    }
    await ActivityRepository.log("admin", "update_product", `Admin updated product: ${id}`);
    res.json({ status: "success", product: updated });
  } catch (error) {
    next(error);
  }
}

export async function updateProductById(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const { price, inventory } = req.body;
    const updated = await ProductRepository.update(
      id,
      price !== undefined ? Number(price) : undefined,
      inventory !== undefined ? Number(inventory) : undefined,
      req.body
    );
    if (!updated) {
      res.status(404).json({ error: "Product not found" });
      return;
    }
    res.json({ status: "success", product: updated });
  } catch (error) {
    next(error);
  }
}

export async function deleteProductById(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const success = await ProductRepository.deleteProduct(id);
    if (!success) {
      res.status(404).json({ error: "Product not found" });
      return;
    }
    await ActivityRepository.log("admin", "delete_product", `Admin deleted product: ${id}`);
    res.json({ status: "success", message: "Product deleted" });
  } catch (error) {
    next(error);
  }
}

export async function importProductsCSV(req: Request, res: Response, next: NextFunction) {
  try {
    const { csvData, products } = req.body;
    const imported: any[] = [];
    
    let itemsToImport = products || [];
    if (csvData && typeof csvData === 'string') {
      const lines = csvData.trim().split("\n");
      const headers = lines[0].split(",").map(h => h.trim());
      for (let i = 1; i < lines.length; i++) {
        const row = lines[i].split(",").map(cell => cell.trim());
        if (row.length >= 3) {
          itemsToImport.push({
            id: row[0] || `p_csv_${Date.now()}_${i}`,
            name: row[1] || `CSV Item ${i}`,
            category: row[2] || "veggies",
            price: Number(row[3]) || 50,
            unit: row[4] || "1 pc",
            inventory: Number(row[5]) || 100,
          });
        }
      }
    }

    for (const item of itemsToImport) {
      const created = await ProductRepository.createProduct(item);
      imported.push(created);
    }

    await ActivityRepository.log("admin", "csv_import", `Bulk imported ${imported.length} products`);
    res.json({ status: "success", importedCount: imported.length, products: imported });
  } catch (error) {
    next(error);
  }
}

export async function exportProductsCSV(req: Request, res: Response, next: NextFunction) {
  try {
    const { products } = await ProductRepository.getAll({ limit: 1000 });
    const headers = "id,name,category,price,unit,inventory,rating\n";
    const rows = products.map(p => `${p.id},"${p.name.replace(/"/g, '""')}",${p.category},${p.price},"${p.unit}",${p.inventory},${p.rating}`).join("\n");
    
    res.setHeader("Content-Type", "text/csv");
    res.setHeader("Content-Disposition", "attachment; filename=products_export.csv");
    res.send(headers + rows);
  } catch (error) {
    next(error);
  }
}

export async function createCategory(req: Request, res: Response, next: NextFunction) {
  try {
    const cat = await ProductRepository.createCategory(req.body);
    res.status(201).json({ status: "success", category: cat });
  } catch (error) {
    next(error);
  }
}

export async function createBrand(req: Request, res: Response, next: NextFunction) {
  try {
    const brand = await ProductRepository.createBrand(req.body);
    res.status(201).json({ status: "success", brand });
  } catch (error) {
    next(error);
  }
}

export async function getActivityLogs(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }
    const logs = await ActivityRepository.getAll();
    res.json(logs);
  } catch (error) {
    next(error);
  }
}

export async function resetSandbox(req: Request, res: Response, next: NextFunction) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({ error: "PostgreSQL is not active or connected in production" });
      return;
    }

    await ActivityRepository.log("admin", "sandbox_reset", "Reset all simulator states and transactions");

    if (usePostgreSQL) {
      await dbQuery("DELETE FROM cart_items WHERE user_id = '6ba7b810-9dad-11d1-80b4-00c04fd430c8'");
      await dbQuery("DELETE FROM wishlists WHERE user_id = '6ba7b810-9dad-11d1-80b4-00c04fd430c8'");
      await dbQuery(
        "DELETE FROM deliveries WHERE order_id IN (SELECT id FROM orders WHERE user_id = '6ba7b810-9dad-11d1-80b4-00c04fd430c8')"
      );
      await dbQuery("DELETE FROM payments WHERE user_id = '6ba7b810-9dad-11d1-80b4-00c04fd430c8'");
      await dbQuery(
        "DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE user_id = '6ba7b810-9dad-11d1-80b4-00c04fd430c8')"
      );
      await dbQuery("DELETE FROM orders WHERE user_id = '6ba7b810-9dad-11d1-80b4-00c04fd430c8'");
      await dbQuery(
        "UPDATE users SET wallet_balance = 1200.00, streak_count = 5 WHERE id = '6ba7b810-9dad-11d1-80b4-00c04fd430c8'"
      );
    }

    DB_STATE.cart = [];
    DB_STATE.wishlist = [];
    DB_STATE.activeOrder = null;
    DB_STATE.walletBalance = 1200;
    DB_STATE.riderState = {
      id: "r1",
      name: "Suresh Kumar",
      phone: "+91 98765 43210",
      avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120",
      lat: 12.9279,
      lng: 77.6250,
      bearing: 0,
      status: "assigned",
      rating: 4.95,
    };
    DB_STATE.addresses = [
      {
        id: "ad1",
        title: "Home",
        addressLine1: "Symphony Premium Apts, Koramangala 3rd Block",
        addressLine2: "Apartment 4B, Tower A",
        landmark: "Near Sony Signal",
        city: "Bangalore",
        state: "Karnataka",
        postalCode: "560034",
        latitude: 12.9348,
        longitude: 77.6189,
        isDefault: true,
      },
    ];

    res.json({ status: "success", balance: 1200, cart: [] });
  } catch (error) {
    next(error);
  }
}

