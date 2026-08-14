import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';
import '../support/emergency_support_screen.dart';

class DeliveryProfileTab extends StatefulWidget {
  final VoidCallback onLogout;
  const DeliveryProfileTab({super.key, required this.onLogout});

  @override
  State<DeliveryProfileTab> createState() => _DeliveryProfileTabState();
}

class _DeliveryProfileTabState extends State<DeliveryProfileTab> {
  String _shiftStatus = 'Morning Slot (6 AM - 2 PM)';
  bool _licenseUploaded = true;
  bool _insuranceUploaded = true;
  final _vehicleModel = 'Hero Splendor Plus (BS6)';
  final _plateNumber = 'DL 3S CQ 8492';

  void _triggerDocumentUpload(String docName, bool currentState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(LucideIcons.fileText, size: 40, color: Colors.blueAccent),
        title: Text('Upload $docName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select a secure PDF or image attachment of your document to upload for verification matching.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  if (docName == 'Driving License') {
                    _licenseUploaded = true;
                  } else {
                    _insuranceUploaded = true;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ $docName uploaded successfully. Verified matching!')),
                );
              },
              icon: const Icon(LucideIcons.uploadCloud, size: 14),
              label: const Text('Simulate File Picker'),
            )
          ],
        ),
      ),
    );
  }

  void _changeShift() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Working Shift Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        children: [
          _buildShiftOption('Morning Slot (6 AM - 2 PM)'),
          _buildShiftOption('Afternoon Slot (2 PM - 10 PM)'),
          _buildShiftOption('Night Owl Slot (10 PM - 6 AM)'),
          _buildShiftOption('Part-time Weekend Slot'),
        ],
      ),
    );
  }

  Widget _buildShiftOption(String shiftName) {
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          _shiftStatus = shiftName;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚡ Shift swapped to: $shiftName')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(shiftName, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Rider Profile Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile photo & ID Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 46,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.check, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Rider: Simran Jeet Singh', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 2),
                  const Text('Gurgaon Main Logistics Sector (Zone 5)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Text('RIDER ID: #FC-R-9042', style: TextStyle(fontSize: 9, color: Colors.teal, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Vehicle info Card
            const Text('Registered Vehicle details', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.indigoAccent.withOpacity(0.12), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.bike, color: Colors.indigoAccent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_vehicleModel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('Plate: $_plateNumber • Fuel: Petrol', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Document uploads
            const Text('Compliance Documents', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildDocRow('Driving License (DL)', _licenseUploaded, () => _triggerDocumentUpload('Driving License', _licenseUploaded)),
                  const Divider(height: 1, thickness: 1, color: Color(0x1F808080)),
                  _buildDocRow('Vehicle Insurance Policy', _insuranceUploaded, () => _triggerDocumentUpload('Vehicle Insurance', _insuranceUploaded)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Shift Status controls
            const Text('Shift Schedule', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Shift Status', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_shiftStatus, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: _changeShift,
                    icon: const Icon(LucideIcons.calendarRange, size: 12),
                    label: const Text('Swap shift', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Help & support link, SOS logs, logout
            const Text('Rider Services', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.lifeBuoy, color: Colors.redAccent, size: 20),
                    title: const Text('Emergency & Safety Center', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text('SOS beacons, incident reporting', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    trailing: const Icon(LucideIcons.chevronRight, size: 16),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencySupportScreen()));
                    },
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0x1F808080)),
                  ListTile(
                    leading: const Icon(LucideIcons.shieldCheck, color: Colors.teal, size: 20),
                    title: const Text('Secure Settings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Biometrics verification setup', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    trailing: const Icon(LucideIcons.chevronRight, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🔒 Settings secured. Biometrics are synchronised.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Log out Button
            ElevatedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(LucideIcons.logOut, size: 16),
              label: const Text('Sign Out of Rider Console', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.12),
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildDocRow(String title, bool isUploaded, VoidCallback onUpload) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: isUploaded ? Colors.green : Colors.amber, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(isUploaded ? 'Uploaded & Active' : 'Pending Upload', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
      trailing: OutlinedButton.icon(
        onPressed: onUpload,
        icon: Icon(isUploaded ? LucideIcons.check : LucideIcons.upload, size: 12),
        label: Text(isUploaded ? 'Uploaded' : 'Upload', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: isUploaded ? Colors.green : Colors.blueAccent,
          side: BorderSide(color: isUploaded ? Colors.green.withOpacity(0.4) : Colors.blueAccent.withOpacity(0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
