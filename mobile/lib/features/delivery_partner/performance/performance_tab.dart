import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/delivery_partner_providers.dart';
import '../widgets/delivery_partner_widgets.dart';

class PerformanceTab extends ConsumerWidget {
  const PerformanceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(deliveryPartnerPerformanceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Performance Scorecard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Prominent Ratings card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Text('CUSTOMER SATISFACTION INDEX', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${stats.customerRating}',
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingWidget(rating: stats.customerRating, size: 20),
                          const SizedBox(height: 4),
                          Text('Based on last ${stats.totalCompleted} reviews', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metrics grids
            Row(
              children: [
                Expanded(
                  child: PerformanceCard(
                    label: 'ACCEPTANCE RATE',
                    value: '${(stats.acceptanceRate * 100).toStringAsFixed(0)}%',
                    percentage: stats.acceptanceRate,
                    icon: LucideIcons.thumbsUp,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PerformanceCard(
                    label: 'COMPLETION RATE',
                    value: '${(stats.completionRate * 100).toStringAsFixed(0)}%',
                    percentage: stats.completionRate,
                    icon: LucideIcons.shieldCheck,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLogisticsStatCard(isDark, 'LATE GIGS', '${stats.lateDeliveries}', LucideIcons.clock, Colors.amber),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLogisticsStatCard(isDark, 'CANCELLED GIGS', '${stats.cancelledDeliveries}', LucideIcons.xOctagon, Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Achievements section
            const Text('Rider Badges & Achievements', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildBadgeCard(context, LucideIcons.zap, 'Monsoon Warrior', 'Completed 5 deliveries in rainfall', Colors.blue),
                  _buildBadgeCard(context, LucideIcons.moon, 'Night Owl', 'Delivered 10 times after 10 PM', Colors.purple),
                  _buildBadgeCard(context, LucideIcons.star, 'Perfect 5.0 Streak', 'Got five 5-star ratings consecutively', Colors.amber),
                  _buildBadgeCard(context, LucideIcons.shieldAlert, 'SOS Contributor', 'Supported safety reporting slots', Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Leaderboard simulator
            const Text('Sector Peer Leaderboard', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildLeaderboardRow('1', 'Sukhpreet Singh', '248 gigs • 4.98★', isSelf: false, isDark: isDark),
                  const Divider(height: 16, thickness: 1, color: Color(0x1F808080)),
                  _buildLeaderboardRow('2', 'Amit Yadav', '210 gigs • 4.95★', isSelf: false, isDark: isDark),
                  const Divider(height: 16, thickness: 1, color: Color(0x1F808080)),
                  _buildLeaderboardRow('3', 'Rider - You', '${stats.totalCompleted} gigs • ${stats.customerRating}★', isSelf: true, isDark: isDark),
                  const Divider(height: 16, thickness: 1, color: Color(0x1F808080)),
                  _buildLeaderboardRow('4', 'Kamlesh Mandal', '18 gigs • 4.80★', isSelf: false, isDark: isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLogisticsStatCard(bool isDark, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161A22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BuildContext context, IconData icon, String title, String desc, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161A22) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 9, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(String rank, String name, String subtitle, {required bool isSelf, required bool isDark}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelf ? Colors.green.withOpacity(0.15) : (rank == '1' ? Colors.amber.withOpacity(0.15) : Colors.grey.withOpacity(0.1)),
                shape: BoxShape.circle,
              ),
              child: Text(
                rank,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelf ? Colors.green : (rank == '1' ? Colors.amber : Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: isSelf ? FontWeight.bold : FontWeight.normal,
                    color: isSelf ? Colors.green : null,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            )
          ],
        ),
        if (isSelf)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: const Text('YOU', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
