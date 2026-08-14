import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class EmergencySupportScreen extends StatefulWidget {
  const EmergencySupportScreen({super.key});

  @override
  State<EmergencySupportScreen> createState() => _EmergencySupportScreenState();
}

class _EmergencySupportScreenState extends State<EmergencySupportScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'When is my earnings payout processed?',
      'answer': 'Your cash out balance is withdrawable instantly. Weekly automatic transfers process every Monday morning at 6:00 AM.'
    },
    {
      'question': 'What if the customer is not answering the door?',
      'answer': 'Wait at the customer coordinate point for 5 minutes. Try calling them 3 times. If they do not respond, trigger the "Customer Missing" flag in the active navigation panel to connect with store managers.'
    },
    {
      'question': 'How do I change my registered vehicle details?',
      'answer': 'Submit a request ticket under your Rider Profile Documents tab. Attach the new Vehicle Registration (RC) book and updated insurance.'
    },
    {
      'question': 'Am I covered by accidental rider insurance?',
      'answer': 'Yes, all online shifts include a ₹5,00,000 accidental cover policy. Ensure your duty status switch is kept online during transit.'
    },
  ];

  String _searchQuery = '';

  void _triggerAccidentReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Vehicle Incident', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A support desk specialist will call your registered phone immediately to assist with breakdown coordination and insurance filings.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Briefly describe your situation (e.g., flat tire, collision)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⚡ Incident recorded. Support dispatcher dial-out initiated.'), backgroundColor: Colors.teal),
              );
            },
            child: const Text('Report Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredFaqs = _faqs.where((faq) {
      return faq['question']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq['answer']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Safety & Support Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Urgent SOS Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(LucideIcons.shieldAlert, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'URGENT MEDICAL OR ROAD SOS',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Press to broadcast coordinates to police, medical dispatch, and Gurgaon safety supervisors.',
                    style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🚨 Emergency broadcast active! Dispatched safety team.'), backgroundColor: Colors.red),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('ACTIVATE SOS NOW', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Help lines Grid
            const Text('Instant Contact Helpdesk', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    context,
                    LucideIcons.phoneCall,
                    'Toll-Free Support',
                    'Call 1800-419-209',
                    Colors.blue,
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Dial Support Desk'),
                          content: const Text('Dialing FlashCart Rider Support Helpline: 1800-419-209...'),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hang Up'))],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactCard(
                    context,
                    LucideIcons.messageSquare,
                    'Chat Helpdesk',
                    'A.I. Support Chatbot',
                    Colors.teal,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('💬 Live chat support opened. AI assistant is compiling route details...')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _triggerAccidentReport,
              icon: const Icon(LucideIcons.fileWarning, size: 16),
              label: const Text('File Accident or breakdown report', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 28),

            // FAQs Search bar & collapse lists
            const Text('Rider Frequently Answered Questions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 10),
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search FAQ issues (e.g., payments, lost packets)',
                prefixIcon: Icon(LucideIcons.search, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredFaqs.length,
                separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Color(0x1F808080)),
                itemBuilder: (context, index) {
                  final faq = filteredFaqs[index];
                  return ExpansionTile(
                    title: Text(faq['question']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: Text(faq['answer']!, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
                      )
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161A22) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
