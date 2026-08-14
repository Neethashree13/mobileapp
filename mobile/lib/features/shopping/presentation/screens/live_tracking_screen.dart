import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/shopping_models.dart';
import '../../providers/shopping_providers.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  final OrderModel order;
  const LiveTrackingScreen({super.key, required this.order});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final List<Map<String, dynamic>> _mockChats = [
    {'sender': 'rider', 'text': 'I have picked up your fresh organic groceries.'},
    {'sender': 'rider', 'text': 'En-route. Navigating via ORR to avoid morning traffic.'},
    {'sender': 'user', 'text': 'Sure, please leave it near the gate.'},
  ];

  final TextEditingController _chatInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _chatInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(settingsProvider).isDarkMode;

    return Theme(
      data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Live Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Column(
          children: [
            // 1. Radar Map canvas
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    child: CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: RadarMapPainter(
                        isDark: isDark,
                        pulseValue: _pulseController,
                      ),
                    ),
                  ),
                  // ETA Overlay badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF10B981), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(backgroundColor: Color(0xFF10B981), radius: 6),
                          const SizedBox(width: 8),
                          Text(
                            'Arriving in ${widget.order.eta}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Handover OTP badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange, width: 1.2),
                      ),
                      child: Text(
                        'OTP: ${widget.order.otp}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black, fontFamily: 'JetBrains Mono'),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // 2. Rider Details card
            _buildRiderCard(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildRiderCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black12,
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Rider Profile avatar
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF10B981).withOpacity(0.12),
                  child: const Text('👨‍✈️', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 14),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.driverName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.order.vehicleNumber,
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text('4.9 Rating', style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
                // Action Buttons (Call, Chat)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981)),
                      onPressed: () => _simulateCallOverlay(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.blueAccent),
                      onPressed: () => _showChatOverlayBottomSheet(),
                    ),
                  ],
                )
              ],
            ),
            const Divider(height: 32, color: Color(0xFF334155)),
            Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rajesh is vaccinated & sanitizes before deliveries',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _simulateCallOverlay() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Text('📞', style: TextStyle(fontSize: 48)),
              SizedBox(height: 12),
              Text('Calling Rajesh Kumar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Text(
            'Simulating VoIP call connection to ${widget.order.driverPhone} under secure masked gateway.',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              child: const Text('End Simulation Call'),
            )
          ],
        );
      },
    );
  }

  void _showChatOverlayBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Chat with Rajesh Kumar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.center),
                  const Divider(height: 24, color: Color(0xFF334155)),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: _mockChats.length,
                      itemBuilder: (context, index) {
                        final chat = _mockChats[index];
                        final isMe = chat['sender'] == 'user';
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              chat['text']!,
                              style: TextStyle(color: isMe ? Colors.black : Colors.white, fontSize: 12.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatInputController,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Type message for rider...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: Color(0xFF10B981)),
                        onPressed: () {
                          if (_chatInputController.text.isNotEmpty) {
                            setModalState(() {
                              _mockChats.add({'sender': 'user', 'text': _chatInputController.text});
                              _chatInputController.clear();
                            });
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Map radar painter
class RadarMapPainter extends CustomPainter {
  final bool isDark;
  final Animation<double> pulseValue;

  RadarMapPainter({required this.isDark, required this.pulseValue}) : super(repaint: pulseValue);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isDark ? Colors.blueGrey.withOpacity(0.12) : Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1.0;

    final routePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final centerOffset = Offset(size.width * 0.5, size.height * 0.5);

    // Draw background grid grids
    for (double i = 0; i < size.height; i += 32) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
    for (double i = 0; i < size.width; i += 32) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }

    // Draw circular radar arcs
    final radarPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(1.0 - pulseValue.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(centerOffset, 48 * pulseValue.value, radarPaint);
    canvas.drawCircle(centerOffset, 96 * pulseValue.value, radarPaint);

    // Draw route path line
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.6, size.width * 0.45, size.height * 0.52)
      ..lineTo(centerOffset.dx, centerOffset.dy);

    canvas.drawPath(path, routePaint);

    // Draw Destination pin
    final destPaint = Paint()..color = Colors.redAccent;
    canvas.drawCircle(centerOffset, 8, destPaint);

    // Draw Rider bike symbol point moving
    final bikeOffset = Offset(
      size.width * 0.1 + (centerOffset.dx - size.width * 0.1) * 0.6,
      size.height * 0.8 + (centerOffset.dy - size.height * 0.8) * 0.6,
    );
    final bikePaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(bikeOffset, 10, bikePaint);

    // Draw a pulse shadow around the moving rider bike
    final riderPulse = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(bikeOffset, 16 + 8 * pulseValue.value, riderPulse);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
