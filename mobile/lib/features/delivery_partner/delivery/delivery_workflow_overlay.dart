import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../models/delivery_partner_models.dart';
import '../widgets/delivery_partner_widgets.dart';

class DeliveryWorkflowOverlay extends StatefulWidget {
  final DeliveryOrder activeOrder;
  final Function(double, double) onNext; // tip, bonus

  const DeliveryWorkflowOverlay({
    super.key,
    required this.activeOrder,
    required this.onNext,
  });

  @override
  State<DeliveryWorkflowOverlay> createState() => _DeliveryWorkflowOverlayState();
}

class _DeliveryWorkflowOverlayState extends State<DeliveryWorkflowOverlay> with SingleTickerProviderStateMixin {
  bool _otpVerified = false;
  bool _photoTaken = false;
  bool _signatureCaptured = false;
  bool _isTakingPhoto = false;

  // Custom signature paint offsets
  List<Offset?> _sigPoints = [];

  // Confetti celebration state
  bool _showCelebration = false;
  late AnimationController _celebrationController;
  late Animation<double> _earningCounterAnimation;
  double _mockTip = 40.0;
  double _mockBonus = 30.0;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _earningCounterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.fastOutSlowIn),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _triggerPhotoCapture() async {
    setState(() {
      _isTakingPhoto = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isTakingPhoto = false;
        _photoTaken = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📸 Proof of Delivery photo saved to logistics folder.'), backgroundColor: Colors.teal),
      );
    }
  }

  void _triggerCompletion() {
    setState(() {
      _showCelebration = true;
    });
    _celebrationController.forward();
  }

  bool get _canComplete {
    return _otpVerified && _photoTaken && _signatureCaptured;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isTakingPhoto) {
      return _buildCameraUI();
    }

    if (_showCelebration) {
      return _buildCelebrationOverlay(isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Customer Doorstep Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Customer coordinates card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.12), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.home, color: Colors.redAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer: ${widget.activeOrder.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(widget.activeOrder.customerAddress, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 1: Customer Security OTP
            _buildSectionHeader('1. Verify Customer Security OTP', 'Ask customer for delivery PIN code'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Security Delivery PIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          'MOCK PIN: ${widget.activeOrder.deliveryOtp}',
                          style: const TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!_otpVerified)
                    OTPWidget(
                      length: 4,
                      onCompleted: (otp) {
                        if (otp == widget.activeOrder.deliveryOtp) {
                          setState(() {
                            _otpVerified = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🎉 Customer validation successful!'), backgroundColor: Colors.teal),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('❌ Incorrect PIN. Use the mock pin supplied above.'), backgroundColor: Colors.redAccent),
                          );
                        }
                      },
                    )
                  else
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.checkCircle, color: Colors.teal, size: 20),
                        SizedBox(width: 8),
                        Text('Customer PIN Confirmed', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 2: Proof of Delivery photo
            _buildSectionHeader('2. Capture Proof of Delivery Photo', 'Take photo of parcel placed at door'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _photoTaken ? null : _triggerPhotoCapture,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _photoTaken 
                      ? Colors.green.withOpacity(0.08) 
                      : (isDark ? const Color(0xFF161A22) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _photoTaken 
                        ? Colors.green.withOpacity(0.5) 
                        : (isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _photoTaken ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_photoTaken ? LucideIcons.check : LucideIcons.camera, color: _photoTaken ? Colors.green : Colors.grey),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _photoTaken ? 'Delivery Proof Photo Uploaded' : 'Capture Doorstep Parcel Photo',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _photoTaken ? 'Photo reference: POD-904812.jpg' : 'Align parcels clearly to avoid customer claims',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (!_photoTaken)
                      const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Step 3: Signature pad
            _buildSectionHeader('3. Digital Signature Verification', 'Have customer trace their signature in the box below'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 160,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: GestureDetector(
                      onPanUpdate: (DragUpdateDetails details) {
                        setState(() {
                          RenderBox object = context.findRenderObject() as RenderBox;
                          Offset localPosition = object.globalToLocal(details.globalPosition);
                          // Clamp inside pad boundaries
                          _sigPoints.add(localPosition);
                          _signatureCaptured = true;
                        });
                      },
                      onPanEnd: (DragEndDetails details) {
                        _sigPoints.add(null);
                      },
                      child: CustomPaint(
                        painter: SignaturePainter(points: _sigPoints, isDark: isDark),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(LucideIcons.penTool, size: 12, color: Colors.grey),
                            SizedBox(width: 4),
                            Text('Trace finger above', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _sigPoints.clear();
                              _signatureCaptured = false;
                            });
                          },
                          icon: const Icon(LucideIcons.rotateCcw, size: 12, color: Colors.redAccent),
                          label: const Text('Reset Pad', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Confirm Completion Action Button
            ElevatedButton(
              onPressed: _canComplete ? _triggerCompletion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Complete Order & Credit Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(height: 12),
            if (!_canComplete)
              Center(
                child: Text(
                  'Finish customer PIN, photo and digital signature verification to complete.',
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCameraUI() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 220,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.tealAccent, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.camera, color: Colors.white24, size: 48),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Fit order parcel inside the green box outline', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white, size: 28),
                  onPressed: () => setState(() => _isTakingPhoto = false),
                ),
                GestureDetector(
                  onTap: _triggerPhotoCapture,
                  child: const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.tealAccent,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.zap, color: Colors.white, size: 24),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationOverlay(bool isDark) {
    final double totalPay = widget.activeOrder.expectedEarnings + _mockTip + _mockBonus;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : Colors.white,
      body: Stack(
        children: [
          // Dynamic Confetti painter
          Positioned.fill(
            child: CustomPaint(
              painter: ConfettiPainter(controller: _celebrationController),
            ),
          ),

          // Central Earning Card with dynamic values counter
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedBuilder(
                animation: _earningCounterAnimation,
                builder: (context, child) {
                  final animatedFraction = _earningCounterAnimation.value;
                  return Card(
                    color: isDark ? const Color(0xFF161A22) : const Color(0xFFEDF2F7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.green.withOpacity(0.4), width: 1.5)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                            child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'GIG COMPLETED! 🎉',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.green, letterSpacing: 1),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order ${widget.activeOrder.orderId} Delivered safely',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Individual items breakdown
                          _buildPriceLine('Order Base Pay', '₹${(widget.activeOrder.expectedEarnings * animatedFraction).toStringAsFixed(1)}'),
                          _buildPriceLine('Peak Hours Bonus', '₹${(_mockBonus * animatedFraction).toStringAsFixed(1)}', isAccent: true),
                          _buildPriceLine('Customer Appreciated Tip', '₹${(_mockTip * animatedFraction).toStringAsFixed(1)}', isAccent: true),
                          const Divider(height: 24, thickness: 1, color: Color(0x1F808080)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Credited Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(
                                '₹${(totalPay * animatedFraction).toStringAsFixed(1)}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.green),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Finish action
                          ElevatedButton(
                            onPressed: () {
                              widget.onNext(_mockTip, _mockBonus);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('Back to Rider Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPriceLine(String label, String price, {bool isAccent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            price,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isAccent ? Colors.indigoAccent : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter representing handwriting signature
class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final bool isDark;

  SignaturePainter({required this.points, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = isDark ? Colors.tealAccent : Colors.indigo
      ..strokeCap = StrokeCap.round;

    // Work around scale differences
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        // Adjust coordinate offset mapping inside canvas container
        final p1 = Offset(points[i]!.dx - 12, points[i]!.dy - 12);
        final p2 = Offset(points[i + 1]!.dx - 12, points[i + 1]!.dy - 12);
        paint.strokeWidth = 3.0;
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}

// Confetti celebration painter
class ConfettiPainter extends CustomPainter {
  final AnimationController controller;
  late List<_ConfettiParticle> _particles;
  final Random _random = Random();

  ConfettiPainter({required this.controller}) : super(repaint: controller) {
    _particles = List.generate(80, (index) {
      return _ConfettiParticle(
        color: _getRandomColor(),
        x: _random.nextDouble(),
        y: _random.nextDouble() * -0.5, // Start above screen
        size: _random.nextDouble() * 8 + 4,
        speedY: _random.nextDouble() * 3 + 2,
        speedX: _random.nextDouble() * 2 - 1,
        angle: _random.nextDouble() * pi * 2,
        spin: _random.nextDouble() * 0.1 - 0.05,
      );
    });
  }

  Color _getRandomColor() {
    final colors = [Colors.redAccent, Colors.tealAccent, Colors.yellow, Colors.blueAccent, Colors.pink, Colors.orange];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = controller.value;
    if (t == 0) return;

    for (var p in _particles) {
      double curY = (p.y + p.speedY * t * 0.5) * size.height;
      double curX = (p.x + p.speedX * t * 0.2) * size.width;
      double sizeFactor = p.size;

      if (curY > size.height) continue;

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(curX, curY);
      canvas.rotate(p.angle + p.spin * t * 50);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: sizeFactor, height: sizeFactor * 0.5), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ConfettiParticle {
  final Color color;
  final double x;
  final double y;
  final double size;
  final double speedY;
  final double speedX;
  final double angle;
  final double spin;

  const _ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.angle,
    required this.spin,
  });
}
