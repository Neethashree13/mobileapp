import { ReviewRepository, Review } from "../repositories/review.repository";
import { UserRepository } from "../repositories/user.repository";
import { ActivityRepository } from "../repositories/activity.repository";

export class ReviewService {
  static async getProductReviews(productId: string): Promise<Review[]> {
    return ReviewRepository.getByProduct(productId);
  }

  static async addProductReview(productId: string, userName: string, rating: number, comment: string): Promise<Review> {
    const review = await ReviewRepository.add(productId, userName, rating, comment);
    const user = await UserRepository.getProfile();
    await ActivityRepository.log(
      user.id,
      "add_review",
      `Added ${rating}-star review for product ${productId} by ${userName}`
    );
    return review;
  }
}
