import 'package:flutter/material.dart';

class ProductBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const ProductBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bg = backgroundColor ?? (isDark ? const Color(0xFF047857) : const Color(0xFF10B981));
    final tc = textColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: tc),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: tc,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class RatingWidget extends StatelessWidget {
  final double rating;
  final int? reviewCount;

  const RatingWidget({
    super.key,
    required this.rating,
    this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFBBF24), // Gold
                size: 14,
              ),
              const SizedBox(width: 2),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }
}

class PriceWidget extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final double fontSize;
  final bool showSavings;

  const PriceWidget({
    super.key,
    required this.price,
    this.originalPrice,
    this.fontSize = 16.0,
    this.showSavings = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDiscounted = originalPrice != null && originalPrice! > price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
              ),
              if (isDiscounted) ...[
                const SizedBox(width: 4),
                Text(
                  '\$${originalPrice!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: fontSize * 0.8,
                    decoration: TextDecoration.lineThrough,
                    color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showSavings && isDiscounted) ...[
          const SizedBox(height: 2),
          Text(
            'Save \$${(originalPrice! - price).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981), // Emerald Green
            ),
          ),
        ],
      ],
    );
  }
}

class DeliveryETAWidget extends StatelessWidget {
  final int etaMins;
  final bool compact;

  const DeliveryETAWidget({
    super.key,
    required this.etaMins,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt_rounded,
            color: Color(0xFF10B981),
            size: 14,
          ),
          const SizedBox(width: 2),
          Text(
            '$etaMins MINS',
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF10B981),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
