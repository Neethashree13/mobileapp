import { ProductRepository, Product, Category } from "../repositories/product.repository";
import { UserRepository } from "../repositories/user.repository";
import { ActivityRepository } from "../repositories/activity.repository";

export class ProductService {
  static async getDashboardData(): Promise<{ categories: Category[]; products: Product[] }> {
    const categories = await ProductRepository.getCategories();
    const { products } = await ProductRepository.getAll();
    return { categories, products };
  }

  static async searchProducts(query: string, mood?: string): Promise<Product[]> {
    if (query && query.trim()) {
      await UserRepository.addSearchHistory(query.trim(), mood);
      const user = await UserRepository.getProfile();
      await ActivityRepository.log(user.id, "search_product", `Searched for "${query}" with mood tag "${mood || 'None'}"`);
    }
    return ProductRepository.search(query);
  }

  static async adminUpdateProduct(id: string, price?: number, inventory?: number): Promise<Product | null> {
    const updated = await ProductRepository.update(id, price, inventory);
    if (updated) {
      await ActivityRepository.log(
        "admin",
        "admin_update_product",
        `Admin modified product ${id}: price=${price}, inventory=${inventory}`
      );
    }
    return updated;
  }
}
