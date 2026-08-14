import { dbQuery, usePostgreSQL } from "../config/database";
import { DB_STATE } from "../config/dbState";

export interface Review {
  id: string;
  productId: string;
  userName: string;
  rating: number;
  comment: string;
  createdAt: string;
}

export class ReviewRepository {
  private static mockReviews: Review[] = [
    { id: "rev1", productId: "p1", rating: 5, comment: "Fresh and great quality!", createdAt: new Date().toISOString(), userName: "Arav" },
    { id: "rev2", productId: "p5", rating: 4, comment: "Super soft paneer.", createdAt: new Date().toISOString(), userName: "Nisha" }
  ];

  static async getByProduct(productId: string): Promise<Review[]> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(
        `
        SELECT r.id, r.product_id as "productId", r.rating, r.comment_text as comment, r.created_at as "createdAt", u.first_name as "userName"
        FROM reviews r JOIN users u ON r.user_id = u.id WHERE r.product_id = $1 ORDER BY r.created_at DESC
      `,
        [productId]
      );
      return rows.map((r) => ({
        ...r,
        rating: Number(r.rating),
      }));
    }
    return this.mockReviews.filter((r) => r.productId === productId);
  }

  static async add(productId: string, userName: string, rating: number, comment: string): Promise<Review> {
    const newId = "rev_" + Math.random().toString(36).substring(2, 9);
    const createdAt = new Date().toISOString();

    if (usePostgreSQL) {
      const userRes = await dbQuery("SELECT id FROM users ORDER BY created_at ASC LIMIT 1");
      const userId = userRes.rows[0]?.id;
      await dbQuery(
        `
        INSERT INTO reviews (product_id, user_id, reviewer_name, rating, comment_text)
        VALUES ($1, $2, $3, $4, $5)
      `,
        [productId, userId, userName, rating, comment]
      );
      // Update average rating & reviews count in products
      await dbQuery(
        `
        UPDATE products
        SET rating = (SELECT AVG(rating) FROM reviews WHERE product_id = $1),
            reviews_count = (SELECT COUNT(*) FROM reviews WHERE product_id = $1)
        WHERE id = $1
      `,
        [productId]
      );
    }

    const reviewObj: Review = {
      id: newId,
      productId,
      userName,
      rating,
      comment,
      createdAt,
    };

    this.mockReviews.unshift(reviewObj);
    const prod = DB_STATE.products.find((p) => p.id === productId);
    if (prod) {
      prod.reviewsCount += 1;
      prod.rating = parseFloat(((prod.rating * (prod.reviewsCount - 1) + rating) / prod.reviewsCount).toFixed(2));
    }

    return reviewObj;
  }
}
