import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final bool compact;

  const CategoryCard({
    super.key,
    required this.category,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        // Route to products listing page, passing the category id in query params
        context.push('/products?categoryId=${category.id}');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant circle background with shadow/border
          Container(
            width: compact ? 56 : 64,
            height: compact ? 56 : 64,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111317) : category.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark 
                    ? const Color(0xFF1F2937) 
                    : category.color.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                category.emoji,
                style: TextStyle(fontSize: compact ? 26 : 30),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Category Label
          SizedBox(
            width: compact ? 70 : 80,
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
