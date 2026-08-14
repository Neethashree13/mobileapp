import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/store_manager_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(storeManagerActiveStaffProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Workspace Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Avatar and Name Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isDark ? Colors.white.withOpacity(0.10) : Colors.black12.withOpacity(0.05)),
              ),
              color: isDark ? const Color(0xFF161A22) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(staff.avatarUrl),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      staff.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      staff.role,
                      style: TextStyle(fontSize: 13, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Chip(
                      label: Text("Employee ID: ${staff.employeeId}"),
                      avatar: const Icon(LucideIcons.userCheck, size: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Store & Shift Details Section
            _buildSectionHeader("Official Store Information"),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? Colors.white.withOpacity(0.10) : Colors.grey.withOpacity(0.15)),
              ),
              color: isDark ? const Color(0xFF161A22) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(LucideIcons.store, "Assigned Terminal", "Dark Store #14 - Bengaluru"),
                    const Divider(height: 24),
                    _buildDetailRow(LucideIcons.clock, "Current Assigned Shift", staff.shift),
                    const Divider(height: 24),
                    _buildDetailRow(LucideIcons.shieldAlert, "Access clearance", "Level 2 Fulfillment Executive"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Workspace Helplines
            _buildSectionHeader("Dark Store Manager Helpdesk"),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.15)),
              ),
              color: isDark ? const Color(0xFF161A22) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHelplineRow("Supervisor Terminal Call", "Line 04 (Aisle Intercom)", LucideIcons.phoneCall),
                    const Divider(height: 24),
                    _buildHelplineRow("Inventory Discrepancy Escalation", "System Ticket desk", LucideIcons.ticket),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Logout Action Button
            ElevatedButton.icon(
              onPressed: () {
                _showLogoutConfirmDialog(context, ref);
              },
              icon: const Icon(LucideIcons.logOut, size: 18),
              label: const Text("Lock Terminal & Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "FlashCart Terminal v2.4.1 (Stable Build)\nLogged under strict workspace monitoring rules.",
              style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.3),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String val) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHelplineRow(String title, String val, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.green),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(val, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
        const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
      ],
    );
  }

  void _showLogoutConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to lock this terminal? Any active Picking or Packing sessions will remain paused."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(storeManagerLoginProvider.notifier).logout();
                Navigator.pop(context); // close dialog
                context.go('/store-manager/login'); // Route back to login
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}
