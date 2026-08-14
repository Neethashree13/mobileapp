import 'package:flutter/material.dart';

class RiderDashboardScreen extends StatefulWidget {
  final VoidCallback onSwitchToCustomer;
  final VoidCallback onLogout;

  const RiderDashboardScreen({
    super.key,
    required this.onSwitchToCustomer,
    required this.onLogout,
  });

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  bool _isOnline = true;
  bool _hasActiveDelivery = false;
  int _completedDeliveriesCount = 3;
  double _todayEarnings = 42.50;
  
  // Active delivery details
  String _activeOrderId = '#F-84920';
  String _pickupLocation = 'FlashCart Hub (SOHO Lane 3)';
  String _dropLocation = 'Arav Sharma (Apt 4B, 82 Park Avenue)';
  String _activeTaskStatus = 'Arrived at Store';
  int _navigationStep = 0; // 0: Go to store, 1: Pickup items, 2: Deliver to client

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        title: Row(
          children: [
            const Icon(Icons.delivery_dining, color: Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rider Console',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  _isOnline ? '● Online & Accepting Jobs' : '○ Offline',
                  style: TextStyle(fontSize: 11, color: _isOnline ? Colors.green : Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Switch to Customer mode
          TextButton.icon(
            icon: const Icon(Icons.shopping_bag, color: Color(0xFF10B981), size: 18),
            label: const Text('Store', style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.bold)),
            onPressed: widget.onSwitchToCustomer,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey, size: 20),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Rider Status & Earnings summary cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatusCard(
                      title: "Today's Earnings",
                      value: '\$${_todayEarnings.toStringAsFixed(2)}',
                      icon: Icons.monetization_on,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusCard(
                      title: "Deliveries",
                      value: '$_completedDeliveriesCount Completed',
                      icon: Icons.task_alt,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ),

            // Online / Offline slide switch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: const Color(0xFF0F1115),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF1F2937)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Duty Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(height: 2),
                          Text('Set yourself offline to stop receiving orders', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      Switch(
                        value: _isOnline,
                        activeColor: const Color(0xFF3B82F6),
                        onChanged: (val) {
                          setState(() {
                            _isOnline = val;
                            if (!val) {
                              _hasActiveDelivery = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Job board / Active Task
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _isOnline
                  ? (_hasActiveDelivery ? _buildActiveDeliveryPanel() : _buildAvailableJobsList())
                  : _buildOfflinePlaceholder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflinePlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: const [
            Icon(Icons.portable_wifi_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('You are Offline', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              'Toggle your Duty Status online at the top to start accepting quick commerce delivery gigs!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableJobsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Deliveries Nearby',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '1 LIVE',
                style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Single Job Card
        Card(
          color: const Color(0xFF0F1115),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF1F2937)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order $_activeOrderId', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const Text('\$6.50 + Tips', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    const Icon(Icons.store, color: Colors.blueAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_pickupLocation, style: const TextStyle(color: Colors.white, fontSize: 13))),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 12,
                      width: 1,
                      child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_dropLocation, style: const TextStyle(color: Colors.white, fontSize: 13))),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF1F2937)),
                const SizedBox(height: 8),
                
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasActiveDelivery = true;
                      _navigationStep = 0;
                      _activeTaskStatus = 'Arrived at Store';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Accept Delivery Gig', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveDeliveryPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Delivery Navigation',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        
        Card(
          color: const Color(0xFF0F1115),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TASK ORDER $_activeOrderId', style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _activeTaskStatus.toUpperCase(),
                        style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Navigation progression checklist
                _buildProgressStep(
                  stepNum: 0,
                  title: 'Navigate to Store',
                  subtitle: _pickupLocation,
                  isActive: _navigationStep == 0,
                  isCompleted: _navigationStep > 0,
                ),
                _buildProgressStep(
                  stepNum: 1,
                  title: 'Pickup & Match Items',
                  subtitle: 'Items: Organic Whole Milk x1, Fresh Haas Avocado x2',
                  isActive: _navigationStep == 1,
                  isCompleted: _navigationStep > 1,
                ),
                _buildProgressStep(
                  stepNum: 2,
                  title: 'Deliver to Customer',
                  subtitle: _dropLocation,
                  isActive: _navigationStep == 2,
                  isCompleted: _navigationStep > 2,
                ),
                
                const SizedBox(height: 24),
                const Divider(color: Color(0xFF1F2937)),
                const SizedBox(height: 12),
                
                // Action Slider simulation
                ElevatedButton(
                  onPressed: _advanceTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    _navigationStep == 0
                        ? 'Confirm Arrival at Store'
                        : _navigationStep == 1
                            ? 'Confirm Items Picked Up'
                            : 'Complete Delivery Order',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _hasActiveDelivery = false;
                    });
                  },
                  child: const Text('Cancel / Decline Gig', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStep({
    required int stepNum,
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color circleColor = const Color(0xFF1F2937);
    IconData icon = Icons.circle_outlined;
    if (isActive) {
      circleColor = const Color(0xFF3B82F6);
      icon = Icons.directions_run;
    } else if (isCompleted) {
      circleColor = const Color(0xFF10B981);
      icon = Icons.check;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: circleColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: circleColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isActive ? Colors.white : (isCompleted ? Colors.grey : Colors.grey[600]),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: isActive ? Colors.grey[300] : Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _advanceTask() {
    setState(() {
      if (_navigationStep == 0) {
        _navigationStep = 1;
        _activeTaskStatus = 'Picking up Cargo';
      } else if (_navigationStep == 1) {
        _navigationStep = 2;
        _activeTaskStatus = 'En Route to Client';
      } else {
        // Complete order!
        _completedDeliveriesCount++;
        _todayEarnings += 6.50;
        _hasActiveDelivery = false;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Awesome job! Delivery complete. +\$6.50 credited!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    });
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
