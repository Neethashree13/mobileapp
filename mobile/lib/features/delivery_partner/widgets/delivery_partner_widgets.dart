import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../models/delivery_partner_models.dart';

// Status Badge
class StatusBadge extends StatelessWidget {
  final DeliveryStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String label = '';
    Color bgColor = Colors.grey;
    Color textColor = Colors.white;

    switch (status) {
      case DeliveryStatus.available:
        label = 'Nearby Gig';
        bgColor = Colors.blue.withOpacity(0.12);
        textColor = Colors.blue;
        break;
      case DeliveryStatus.accepted:
        label = 'Accepted';
        bgColor = Colors.orange.withOpacity(0.12);
        textColor = Colors.orange;
        break;
      case DeliveryStatus.reachedStore:
        label = 'Arrived at Store';
        bgColor = Colors.teal.withOpacity(0.12);
        textColor = Colors.teal;
        break;
      case DeliveryStatus.pickedUp:
        label = 'En Route';
        bgColor = Colors.purple.withOpacity(0.12);
        textColor = Colors.purple;
        break;
      case DeliveryStatus.reachedCustomer:
        label = 'Arrived at Customer';
        bgColor = Colors.pink.withOpacity(0.12);
        textColor = Colors.pink;
        break;
      case DeliveryStatus.completed:
        label = 'Completed';
        bgColor = Colors.green.withOpacity(0.12);
        textColor = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

// Order Card
class OrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onAccept,
    this.onReject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161A22) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
          border: Border.all(
            color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.package,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ID: ${order.orderId}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: order.status),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0x1F808080)),

            // Card Body (Addresses & Logistics Info)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Store Location Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.store, size: 18, color: Colors.blueAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.storeName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.storeAddress,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Connective dotted line
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(left: 0),
                        width: 2,
                        height: 16,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  ),

                  // Customer Location Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.mapPin, size: 18, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery: ${order.customerName}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.customerAddress,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0x1F808080)),

            // Card Footer (Logistics numbers & actions)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Distance & Time & Expected Earnings
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.navigation, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${order.distance} km',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(LucideIcons.clock, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${order.etaMinutes} mins',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'Pay: ',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '₹${order.expectedEarnings.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Actions
                  if (order.status == DeliveryStatus.available)
                    Row(
                      children: [
                        if (onReject != null)
                          IconButton(
                            onPressed: onReject,
                            icon: const Icon(LucideIcons.x, color: Colors.redAccent),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (onAccept != null)
                          ElevatedButton(
                            onPressed: onAccept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Accept',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                      ],
                    )
                  else
                    const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Earnings Card
class EarningsCard extends StatelessWidget {
  final double todayAmount;
  final int todayCount;
  final VoidCallback? onDetailsTap;

  const EarningsCard({
    super.key,
    required this.todayAmount,
    required this.todayCount,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF312E81) : const Color(0xFFC7D2FE),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigoAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.indianRupee, size: 18, color: Colors.indigoAccent),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Today's Income",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              if (onDetailsTap != null)
                TextButton(
                  onPressed: onDetailsTap,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(width: 2),
                      Icon(LucideIcons.chevronRight, size: 14),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${todayAmount.toStringAsFixed(1)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.checkCircle, size: 10, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '$todayCount orders completed',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Performance Card
class PerformanceCard extends StatelessWidget {
  final String label;
  final String value;
  final double percentage; // 0.0 to 1.0
  final IconData icon;
  final Color color;

  const PerformanceCard({
    super.key,
    required this.label,
    required this.value,
    required this.percentage,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161A22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          // Circular Progress indicator representation
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 46,
                height: 46,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 4.5,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Wallet Card
class WalletCard extends StatelessWidget {
  final double balance;
  final double pending;
  final double completed;
  final VoidCallback? onWithdraw;

  const WalletCard({
    super.key,
    required this.balance,
    required this.pending,
    required this.completed,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF134E5E), const Color(0xFF121620)]
              : [const Color(0xFFE0F2FE), const Color(0xFFF0F9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF0F766E).withOpacity(0.4) : const Color(0xFFBAE6FD),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Withdrawable Wallet Balance',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Instantly transfers to bank',
                    style: TextStyle(fontSize: 10, color: Colors.blueGrey),
                  ),
                ],
              ),
              Icon(LucideIcons.wallet, size: 24, color: isDark ? Colors.tealAccent : Colors.teal),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${balance.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (balance > 0 && onWithdraw != null)
                ElevatedButton(
                  onPressed: onWithdraw,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cashout Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0x22808080)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PENDING PAYOUTS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('₹${pending.toStringAsFixed(1)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.amber)),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.3)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('COMPLETED TRANSFERS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('₹${completed.toStringAsFixed(1)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.green)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// Navigation Card
class NavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int etaMinutes;
  final double distance;
  final String ctaLabel;
  final VoidCallback onCtaPressed;

  const NavigationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.etaMinutes,
    required this.distance,
    required this.ctaLabel,
    required this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161A22) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.navigation, size: 16, color: Colors.blue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ETA TO TARGET', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '$etaMinutes mins',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.teal),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($distance km)',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onCtaPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(ctaLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 6),
                    const Icon(LucideIcons.arrowRight, size: 14),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// OTP Widget
class OTPWidget extends StatefulWidget {
  final int length;
  final Function(String) onCompleted;

  const OTPWidget({
    super.key,
    this.length = 4,
    required this.onCompleted,
  });

  @override
  State<OTPWidget> createState() => _OTPWidgetState();
}

class _OTPWidgetState extends State<OTPWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (index) => TextEditingController());
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    // Check complete
    String currentOTP = _controllers.map((c) => c.text).join();
    if (currentOTP.length == widget.length) {
      widget.onCompleted(currentOTP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return Container(
          width: 50,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (val) => _onChanged(val, index),
          ),
        );
      }),
    );
  }
}

// Timeline Widget
class TimelineStep {
  final String title;
  final String description;
  final bool isCompleted;
  final bool isActive;

  const TimelineStep({
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isActive,
  });
}

class TimelineWidget extends StatelessWidget {
  final List<TimelineStep> steps;

  const TimelineWidget({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        Color dotColor = Colors.grey;
        if (step.isCompleted) {
          dotColor = Colors.green;
        } else if (step.isActive) {
          dotColor = Theme.of(context).colorScheme.primary;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: dotColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: 2),
                  ),
                  child: step.isCompleted
                      ? const Icon(LucideIcons.check, size: 12, color: Colors.green)
                      : Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                        ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 36,
                    color: step.isCompleted ? Colors.green : Colors.grey.withOpacity(0.3),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: step.isActive ? Theme.of(context).colorScheme.primary : (step.isCompleted ? Colors.green : Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.description,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// Map Placeholder Widget
class MapPlaceholderWidget extends StatelessWidget {
  final double currentLat;
  final double currentLng;
  final double targetLat;
  final double targetLng;
  final String label;

  const MapPlaceholderWidget({
    super.key,
    required this.currentLat,
    required this.currentLng,
    required this.targetLat,
    required this.targetLng,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Dynamic CustomPaint representation of a map
          Positioned.fill(
            child: CustomPaint(
              painter: MapRoadPainter(isDark: isDark),
            ),
          ),

          // Route indicator overlay
          const Positioned(
            top: 24,
            left: 24,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundColor: Colors.blueAccent,
                ),
                SizedBox(width: 6),
                Text(
                  'GPS Connected',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Map Marker: Store/Start
          const Positioned(
            top: 120,
            left: 100,
            child: Column(
              children: [
                Icon(LucideIcons.store, color: Colors.blueAccent, size: 28),
                Text('Hub Store', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, backgroundColor: Colors.black26, color: Colors.white)),
              ],
            ),
          ),

          // Animated Rider position
          const Positioned(
            top: 180,
            left: 170,
            child: Column(
              children: [
                Icon(LucideIcons.bike, color: Colors.tealAccent, size: 28),
                Text('You', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, backgroundColor: Colors.teal, color: Colors.white)),
              ],
            ),
          ),

          // Target Pin
          Positioned(
            bottom: 80,
            right: 80,
            child: Column(
              children: [
                const Icon(LucideIcons.mapPin, color: Colors.redAccent, size: 30),
                Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, backgroundColor: Colors.black38, color: Colors.white)),
              ],
            ),
          ),

          // Controls UI in bottom right corner
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                _MapButton(icon: LucideIcons.plus, onPressed: () {}),
                const SizedBox(height: 6),
                _MapButton(icon: LucideIcons.minus, onPressed: () {}),
                const SizedBox(height: 6),
                _MapButton(icon: LucideIcons.compass, onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        color: isDark ? Colors.white : Colors.black87,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// Painter representing simulated roads
class MapRoadPainter extends CustomPainter {
  final bool isDark;
  MapRoadPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.grey.shade800 : Colors.grey.shade300
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Road lines
    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.35);

    final path2 = Path()
      ..moveTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.3, size.height);

    final path3 = Path()
      ..moveTo(size.width * 0.7, 0)
      ..lineTo(size.width * 0.6, size.height);

    final path4 = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width, size.height * 0.65);

    // Active route route
    final routePath = Path()
      ..moveTo(100, 120) // Hub store
      ..lineTo(size.width * 0.3, size.height * 0.3)
      ..lineTo(170, 180) // Rider Position
      ..lineTo(size.width * 0.6, size.height * 0.65)
      ..lineTo(size.width - 80, size.height - 80); // Target Pin

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path4, paint);

    canvas.drawPath(routePath, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Rating Widget
class RatingWidget extends StatelessWidget {
  final double rating;
  final double size;

  const RatingWidget({
    super.key,
    required this.rating,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon = LucideIcons.star;
        Color color = Colors.amber;

        if (index >= rating.floor()) {
          icon = LucideIcons.star;
          color = Colors.grey.withOpacity(0.3);
        }

        return Icon(
          icon,
          size: size,
          color: color,
        );
      }),
    );
  }
}

// Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Loading State Widget (Shimmer)
class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.15),
        highlightColor: Colors.grey.withOpacity(0.05),
        child: Column(
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// Error State Widget
class ErrorStateWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.rotateCcw, size: 14),
              label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
