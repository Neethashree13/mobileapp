import 'cart_summary_model.dart';

class CartResponseModel {
  final String status;
  final CartSummaryModel? summary;
  final String? message;

  const CartResponseModel({
    required this.status,
    this.summary,
    this.message,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    CartSummaryModel? summary;
    if (json['summary'] != null && json['summary'] is Map<String, dynamic>) {
      summary = CartSummaryModel.fromJson(json['summary'] as Map<String, dynamic>);
    } else if (json.containsKey('subtotal') || json.containsKey('items')) {
      summary = CartSummaryModel.fromJson(json);
    }

    return CartResponseModel(
      status: json['status'] as String? ?? 'success',
      summary: summary,
      message: json['message'] as String?,
    );
  }
}
