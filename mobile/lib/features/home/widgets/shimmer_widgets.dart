import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final String type; // 'product', 'category', 'banner'

  const ShimmerLoading({
    super.key,
    this.type = 'product',
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'category':
        return Column(
          children: [
            SkeletonLoader(width: 56, height: 56, borderRadius: 16),
            const SizedBox(height: 8),
            SkeletonLoader(width: 48, height: 10),
          ],
        );
      case 'banner':
        return SkeletonLoader(
          width: double.infinity,
          height: 150,
          borderRadius: 16,
        );
      case 'product':
      default:
        return Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF111317)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1F2937)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SkeletonLoader(width: 100, height: 100, borderRadius: 12),
              ),
              const SizedBox(height: 12),
              const SkeletonLoader(width: 120, height: 14),
              const SizedBox(height: 6),
              const SkeletonLoader(width: 80, height: 10),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLoader(width: 50, height: 14),
                      SizedBox(height: 4),
                      SkeletonLoader(width: 30, height: 10),
                    ],
                  ),
                  const SkeletonLoader(width: 60, height: 32, borderRadius: 8),
                ],
              ),
            ],
          ),
        );
    }
  }
}
