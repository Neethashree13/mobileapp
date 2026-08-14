import 'dart:async';
import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatefulWidget {
  final double orderTotal;

  const OrderTrackingScreen({super.key, required this.orderTotal});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _riderController;
  late final Timer _countdownTimer;
  int _secondsLeft = 600; // 10 minutes
  String _currentStatus = 'Matching eco-friendly rider...';
  int _currentStep = 0;

  final List<String> _steps = [
    'Matching eco-friendly rider...',
    'Rider assigned (Karan Dev)! Heading to store...',
    'Rider picking up your fresh organic basket...',
    'Karan Dev is en route (Electric Scooter)...',
    'Rider is nearby! Prepare to receive order...',
    'Delivered! Tap to continue.',
  ];

  @override
  void initState() {
    super.initState();
    
    // Smooth transition from shop to customer
    _riderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25), // Simulation cycle
    )..forward();

    _riderController.addListener(() {
      // Step update based on movement percentage
      final val = _riderController.value;
      int step = 0;
      if (val > 0.15) step = 1;
      if (val > 0.40) step = 2;
      if (val > 0.65) step = 3;
      if (val > 0.85) step = 4;
      if (val >= 1.00) step = 5;
      
      if (step != _currentStep) {
        setState(() {
          _currentStep = step;
          _currentStatus = _steps[step];
        });
      }
    });

    // 10-minute timer countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        _countdownTimer.cancel();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    _riderController.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080A),
      appBar: AppBar(
        title: const Text('Rapid Delivery Tracking', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0F1115),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tracking Canvas
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1115),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Stack(
                children: [
                  // Vector map drawing
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _riderController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: MapPainter(progress: _riderController.value),
                        );
                      },
                    ),
                  ),
                  
                  // ETA Overlay
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ESTIMATED ARRIVAL', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(
                            _formatTime(_secondsLeft),
                            style: const TextStyle(color: Color(0xFF10B981), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Info Sheets
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF0F1115),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: Color(0xFF1F2937))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active Step
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delivery_dining, color: Color(0xFF10B981), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delivery Progress',
                              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentStatus,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Progress Indicator Dots
                  Row(
                    children: List.generate(5, (index) {
                      final isActive = index <= _currentStep;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: index == 4 ? 0 : 8),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFF10B981) : const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  const Spacer(),
                  
                  // Summary Detail Lines
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('RIDER ASSIGNED', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          SizedBox(height: 2),
                          Text('Karan Dev', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('ORDER TOTAL', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('\$${widget.orderTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep >= 5 ? const Color(0xFF10B981) : const Color(0xFF1F2937),
                      foregroundColor: _currentStep >= 5 ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(_currentStep >= 5 ? 'Done, Back to Store' : 'Minimize Tracker'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final double progress;

  MapPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Paints setup
    final bgPaint = Paint()..color = const Color(0xFF0F1115);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final dashRoadPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Define points for Shop (Start) to Home (End) with some realistic grid turns
    final start = Offset(size.width * 0.15, size.height * 0.75);
    final turn1 = Offset(size.width * 0.45, size.height * 0.75);
    final turn2 = Offset(size.width * 0.45, size.height * 0.25);
    final end = Offset(size.width * 0.85, size.height * 0.25);

    // Draw the roads/paths
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(turn1.dx, turn1.dy)
      ..lineTo(turn2.dx, turn2.dy)
      ..lineTo(end.dx, end.dy);

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, dashRoadPaint);

    // Helper: Calculate Rider coordinate based on 0.0 - 1.0 progress
    Offset riderPos;
    if (progress < 0.4) {
      // Segment 1: start to turn1
      final p = progress / 0.4;
      riderPos = Offset(start.dx + (turn1.dx - start.dx) * p, start.dy);
    } else if (progress < 0.8) {
      // Segment 2: turn1 to turn2
      final p = (progress - 0.4) / 0.4;
      riderPos = Offset(turn1.dx, turn1.dy + (turn2.dy - turn1.dy) * p);
    } else {
      // Segment 3: turn2 to end
      final p = (progress - 0.8) / 0.2;
      riderPos = Offset(turn2.dx + (end.dx - turn2.dx) * p, turn2.dy);
    }

    // Draw Shop pin
    final pinPaint = Paint()..style = PaintingStyle.fill;
    
    pinPaint.color = Colors.blueAccent;
    canvas.drawCircle(start, 12, pinPaint);
    _drawMarkerLabel(canvas, "FlashCart Hub", start, Colors.blueAccent);

    // Draw Destination Pin
    pinPaint.color = const Color(0xFF10B981);
    canvas.drawCircle(end, 12, pinPaint);
    _drawMarkerLabel(canvas, "My Home", end, const Color(0xFF10B981));

    // Draw Rider Circle (Smooth Electric Scooter indicator)
    pinPaint.color = Colors.amber;
    canvas.drawCircle(riderPos, 14, pinPaint);
    
    // Draw smaller black center to represent a wheel/indicator
    pinPaint.color = Colors.black;
    canvas.drawCircle(riderPos, 6, pinPaint);
  }

  void _drawMarkerLabel(Canvas canvas, String label, Offset position, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, backgroundColor: Colors.black.withOpacity(0.6)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(position.dx - textPainter.width / 2, position.dy - 24));
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
