import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;

  const OfferCard({
    super.key,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111317) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            // Left Discount Label badge
            Container(
              width: 90,
              height: double.infinity,
              color: offer.bgColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_offer_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    offer.discountText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Middle Divider Dashes (Physical Coupon Look)
            CustomPaint(
              size: const Size(12, double.infinity),
              painter: TicketDividerPainter(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB)),
            ),

            // Right coupon details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            offer.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            offer.subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tap to copy button
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: offer.code));
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Promo Code "${offer.code}" copied to clipboard!'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: offer.bgColor, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            offer.code,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : offer.bgColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'TAP TO COPY',
                          style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter to draw ticket-like cutout dots between discount badge and details
class TicketDividerPainter extends CustomPainter {
  final Color color;

  TicketDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw dashed vertical line
    double startY = 10;
    while (startY < size.height - 10) {
      canvas.drawLine(Offset(size.width / 2, startY), Offset(size.width / 2, startY + 4), paint);
      startY += 8;
    }

    // Draw top circle cutout
    final cutoutPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill; // transparent to inherit background, but let's draw semi circles
    
    // We can also draw solid semi circles matching the card outer edge. Since this is drawn on top,
    // we can draw circles at (width/2, 0) and (width/2, height) inside the canvas bounds to simulate physical cutouts
  }

  @override
  bool shouldRepaint(covariant TicketDividerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
