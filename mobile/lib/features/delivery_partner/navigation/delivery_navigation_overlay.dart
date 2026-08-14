import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../models/delivery_partner_models.dart';
import '../widgets/delivery_partner_widgets.dart';
import '../providers/delivery_partner_providers.dart';

class DeliveryNavigationOverlay extends ConsumerWidget {
  final DeliveryOrder activeOrder;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onNext;

  const DeliveryNavigationOverlay({
    super.key,
    required this.activeOrder,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onNext,
  });

  void _callNumber(BuildContext context, String name, String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(LucideIcons.phoneCall, size: 36, color: Colors.blue),
        title: Text('Calling $name'),
        content: Text('Simulating telephone call via device dialer to phone number: $phone'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hang Up'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        leading: IconButton(
          icon: const Icon(LucideIcons.slash),
          onPressed: () {
            // Cancel active gig confirmation
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Forfeit Order?', style: TextStyle(fontWeight: FontWeight.bold)),
                content: const Text('Are you sure you want to cancel this accepted delivery gig? It might decrease your Rider Acceptance rating.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No, keep order'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(deliveryPartnerActiveOrderProvider.notifier).cancelActiveOrder();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text('Yes, forfeit'),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.alertTriangle, color: Colors.redAccent),
            onPressed: () {
              // Direct Emergency button
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (context) => const _EmergencySheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Dynamic Custom GPS Map
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MapPlaceholderWidget(
                currentLat: 28.4900,
                currentLng: 77.0800,
                targetLat: activeOrder.latitude,
                targetLng: activeOrder.longitude,
                label: activeOrder.customerName,
              ),
            ),
          ),

          // Navigation Instructions & Active Action Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161A22) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Direction indicator header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.cornerUpRight, size: 22, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'In 250 meters turn right',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'Onto Cyber City Avenue',
                              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.alertCircle, size: 10, color: Colors.redAccent),
                          SizedBox(width: 4),
                          Text(
                            'Heavy Traffic',
                            style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0x1F808080)),
                const SizedBox(height: 16),

                // Special instructions panel
                if (activeOrder.specialInstructions.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.info, size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Instructions: ${activeOrder.specialInstructions}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Customer / Store quick info & call bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          child: const Icon(LucideIcons.user, size: 16, color: Colors.indigoAccent),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeOrder.status == DeliveryStatus.accepted ? activeOrder.storeName : activeOrder.customerName,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeOrder.status == DeliveryStatus.accepted ? 'Pickup Point' : 'Delivery Destination',
                              style: const TextStyle(fontSize: 9, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.phone, size: 18, color: Colors.blueAccent),
                          onPressed: () {
                            if (activeOrder.status == DeliveryStatus.accepted) {
                              _callNumber(context, activeOrder.storeName, activeOrder.storePhone);
                            } else {
                              _callNumber(context, activeOrder.customerName, activeOrder.customerPhone);
                            }
                          },
                          style: IconButton.styleFrom(backgroundColor: Colors.blueAccent.withOpacity(0.1)),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(LucideIcons.messageCircle, size: 18, color: Colors.teal),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('💬 Simulated customer chat initiated. Secure connection opened.')),
                            );
                          },
                          style: IconButton.styleFrom(backgroundColor: Colors.teal.withOpacity(0.1)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Live Navigation numbers and CTA button
                NavigationCard(
                  title: subtitle,
                  subtitle: 'Arrive safely. Speed limit is 40 km/h.',
                  etaMinutes: activeOrder.etaMinutes,
                  distance: activeOrder.distance,
                  ctaLabel: ctaLabel,
                  onCtaPressed: onNext,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _EmergencySheet extends StatelessWidget {
  const _EmergencySheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(LucideIcons.lifeBuoy, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text(
            'Rider Emergency Center',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Experiencing issues on your journey? Select a quick emergency resolution service below:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Simulated accident reporting
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Report Incident'),
                  content: const Text('An incident report form has been drafted. Logistics helpdesk will phone you in 2 minutes.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                ),
              );
            },
            icon: const Icon(LucideIcons.fileText),
            label: const Text('Report Accident or Vehicle Breakdown'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Trigger instant high volume alarm sound mock
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📢 Police SOS triggered. Broadcaster streaming live GPS trace to Gurgaon Control.')),
              );
            },
            icon: const Icon(LucideIcons.shieldAlert),
            label: const Text('Trigger Siren / Alert Police'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel / Close Panel'),
          ),
        ],
      ),
    );
  }
}
