import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/delivery_partner_models.dart';
import '../widgets/delivery_partner_widgets.dart';

class PickupWorkflowOverlay extends StatefulWidget {
  final DeliveryOrder activeOrder;
  final VoidCallback onNext;

  const PickupWorkflowOverlay({
    super.key,
    required this.activeOrder,
    required this.onNext,
  });

  @override
  State<PickupWorkflowOverlay> createState() => _PickupWorkflowOverlayState();
}

class _PickupWorkflowOverlayState extends State<PickupWorkflowOverlay> {
  late List<bool> _itemChecked;
  bool _thermalBagConfirmed = false;
  bool _bagCountConfirmed = false;
  bool _qrScanned = false;
  bool _otpVerified = false;
  bool _scanningActive = false;

  @override
  void initState() {
    super.initState();
    _itemChecked = List.generate(widget.activeOrder.items.length, (index) => false);
  }

  void _simulateQRScan() async {
    setState(() {
      _scanningActive = true;
    });
    // Simulate camera overlay scanning
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _scanningActive = false;
        _qrScanned = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ QR Code matched successfully! Cargo container unlocked.'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  bool get _canPickup {
    final allItemsChecked = _itemChecked.every((val) => val);
    return allItemsChecked && _thermalBagConfirmed && _bagCountConfirmed && _qrScanned && _otpVerified;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_scanningActive) {
      return _buildScanningUI(isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Verify Store Cargo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.helpCircle, color: Colors.grey),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Store Pickup Help'),
                  content: Text('Please match the physical box/bag number on the cargo bin with the order ID: ${widget.activeOrder.orderId}. Ensure all products list items below are loaded.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Store details card
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
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.12), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.store, color: Colors.blueAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.activeOrder.storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(widget.activeOrder.storeAddress, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 1: Item Checklist
            _buildSectionHeader('1. Verify Items List', 'Tap each to confirm presence'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.activeOrder.items.length,
                separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Color(0x1F808080)),
                itemBuilder: (context, index) {
                  final item = widget.activeOrder.items[index];
                  return CheckboxListTile(
                    value: _itemChecked[index],
                    onChanged: (val) {
                      setState(() {
                        _itemChecked[index] = val ?? false;
                      });
                    },
                    title: Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text('${item.spec} • Qty: ${item.quantity}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    activeColor: Theme.of(context).colorScheme.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Step 2: Safety & Bags checklists
            _buildSectionHeader('2. Hygiene & Thermal Bag Reminders', 'Required for quality assurance'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _thermalBagConfirmed,
                    onChanged: (val) => setState(() => _thermalBagConfirmed = val ?? false),
                    title: const Text('Thermal Insulation Bag Sanitized', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Cargo placed in clean insulated compartment to stay fresh.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    activeColor: Theme.of(context).colorScheme.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0x1F808080)),
                  CheckboxListTile(
                    value: _bagCountConfirmed,
                    onChanged: (val) => setState(() => _bagCountConfirmed = val ?? false),
                    title: const Text('Bag Count Validated', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Confirmed order size fits the required vehicle payload specs.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    activeColor: Theme.of(context).colorScheme.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 3: QR Cargo scan
            _buildSectionHeader('3. Store QR Validation', 'Scan bin barcode to unlock cargo'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _qrScanned ? null : _simulateQRScan,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _qrScanned 
                      ? Colors.green.withOpacity(0.08) 
                      : (isDark ? const Color(0xFF161A22) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _qrScanned 
                        ? Colors.green.withOpacity(0.5) 
                        : (isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
                    width: _qrScanned ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _qrScanned ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _qrScanned ? LucideIcons.check : LucideIcons.qrCode,
                        color: _qrScanned ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _qrScanned ? 'Barcode Scanned & Unlocked' : 'Scan Store Container Barcode',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _qrScanned ? 'Match confirmed with ${widget.activeOrder.orderId}' : 'Simulate phone camera lens barcode scanner',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (!_qrScanned)
                      const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Step 4: OTP verification
            _buildSectionHeader('4. Merchant Verification', 'Ask merchant for validation OTP code'),
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
                      const Text(
                        'Merchant OTP Pin Code',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          'MOCK OTP: ${widget.activeOrder.pickupOtp}',
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
                        if (otp == widget.activeOrder.pickupOtp) {
                          setState(() {
                            _otpVerified = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🎉 Store pickup verification successful!'), backgroundColor: Colors.teal),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('❌ Invalid PIN code. Please use the mock code provided.'), backgroundColor: Colors.redAccent),
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
                        Text('Verification Completed', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Pickup Confirmation Action Button
            ElevatedButton(
              onPressed: _canPickup ? widget.onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm Pickup & Go Online', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(height: 12),
            if (!_canPickup)
              Center(
                child: Text(
                  'Please finish steps 1, 2, 3 and 4 above to unlock',
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
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildScanningUI(bool isDark) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated camera view with radar scanner
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.scanLine, color: Colors.tealAccent, size: 96),
                const SizedBox(height: 24),
                const Text(
                  'Simulating Camera Scanner Lens',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Align order barcode on the container box... ID: ${widget.activeOrder.orderId}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SpinKitSquareCircle(color: Colors.tealAccent, size: 40),
              ],
            ),
          ),

          // Cancel Scan button
          Positioned(
            top: 48,
            left: 20,
            child: IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.white, size: 28),
              onPressed: () => setState(() => _scanningActive = false),
            ),
          ),
        ],
      ),
    );
  }
}
