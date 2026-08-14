import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shopping_models.dart';
import '../../providers/shopping_providers.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'q': 'How fast is FlashCart AI delivery?',
      'a': 'We source products directly from our hyper-local Dark Stores. Delivery takes between 8 to 15 minutes, depending on your distance and weather factors.'
    },
    {
      'q': 'What happens if products are damaged?',
      'a': 'Simply go to your Order History details page, tap "Return / Support", choose "Damaged green vegetables", and submit. Approved refunds are credited to your FlashCart wallet instantly.'
    },
    {
      'q': 'How do I load funds into Flash Wallet?',
      'a': 'Navigate to the Wallet dashboard, tap the "+ ADD CASH" button, input any positive amount, and pay using credit cards, UPI, or Net Banking.'
    },
    {
      'q': 'Can I schedule orders for later?',
      'a': 'Yes. During checkout, you can choose from various timing slots, including Morning (7 AM - 9 AM) or Evening slots (6 PM - 8 PM).'
    },
  ];

  final List<Map<String, dynamic>> _chatHistory = [
    {
      'sender': 'bot',
      'text': 'Hello! I am FlashBot, your AI grocery support assistant. Ask me anything about order delivery speeds, active refunds, or promotional codes!'
    }
  ];

  final TextEditingController _chatController = TextEditingController();
  bool _isBotTyping = false;

  @override
  void dispose() {
    _chatController.dispose();
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
          title: const Text('Help Center & Support', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
        ),
        body: Column(
          children: [
            // 1. FAQs expandable list
            Expanded(
              flex: 4,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionTitle('FREQUENTLY ASKED QUESTIONS', isDark),
                  ..._faqs.map((faq) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ExpansionTile(
                          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                          shape: const RoundedRectangleBorder(side: BorderSide.none),
                          title: Text(faq['q']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                              child: Text(faq['a']!, style: TextStyle(fontSize: 12, color: Colors.grey[400], height: 1.5)),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 12),

                  _buildSectionTitle('OTHER CHANNELS', isDark),
                  _buildContactsGrid(isDark),
                ],
              ),
            ),

            // 2. Chat with FlashBot Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.grey[200],
              child: const Row(
                children: [
                  CircleAvatar(backgroundColor: Color(0xFF10B981), radius: 6),
                  SizedBox(width: 8),
                  Text(
                    'LIVE CONVERSATIONAL AI HELPDESK',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981), letterSpacing: 0.8),
                  ),
                ],
              ),
            ),

            // 3. Conversational Live Chat section
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                ),
                child: Column(
                  children: [
                    // Scrolling messages
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _chatHistory.length + (_isBotTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _chatHistory.length) {
                            return _buildBotTypingBubble();
                          }

                          final message = _chatHistory[index];
                          final isMe = message['sender'] == 'user';

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFF10B981) : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(16).copyWith(
                                  bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                                  topLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                                ),
                              ),
                              child: Text(
                                message['text']!,
                                style: TextStyle(color: isMe ? Colors.black : (isDark ? Colors.white : Colors.black), fontSize: 12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Inputs bar
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              style: const TextStyle(fontSize: 12.5),
                              onSubmitted: (val) => _handleUserMessage(),
                              decoration: const InputDecoration(
                                hintText: 'Ask FlashBot about refunds, ETA...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send_rounded, color: Color(0xFF10B981)),
                            onPressed: _handleUserMessage,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildContactsGrid(bool isDark) {
    final channels = [
      {'title': 'Call Support', 'sub': '+1-800-FLASH-BOT', 'emoji': '📞', 'color': const Color(0xFF10B981)},
      {'title': 'Email Tickets', 'sub': 'support@flashcart.ai', 'emoji': '✉️', 'color': Colors.blueAccent},
    ];

    return Row(
      children: channels.map((channel) {
        final color = channel['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(channel['emoji'] as String, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 8),
                Text(channel['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(channel['sub'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 10.5)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBotTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF10B981)),
            ),
            SizedBox(width: 8),
            Text('FlashBot is typing...', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _handleUserMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    _chatController.clear();
    setState(() {
      _chatHistory.add({'sender': 'user', 'text': text});
      _isBotTyping = true;
    });

    // Simple auto-reply map
    String botReply = 'I apologize, I didn\'t quite catch that. Try asking about "refunds", "speed", or "wallet".';
    final query = text.toLowerCase();

    if (query.contains('refund') || query.contains('return')) {
      botReply = 'All refunds are instant! Go to your Order Details, choose the damaged item, click "Refund", and your credits are instantly ready in your Flash Wallet!';
    } else if (query.contains('speed') || query.contains('delivery') || query.contains('time')) {
      botReply = 'FlashCart AI operates a fleet of high-speed EV vehicles connected to dark stores. Most orders arrive within 10 minutes flat!';
    } else if (query.contains('coupon') || query.contains('discount') || query.contains('promo')) {
      botReply = 'Use code "FLASHFAST50" on your cart for 50% off, or look in your available tickets sheet for Free Delivery options!';
    } else if (query.contains('wallet') || query.contains('balance')) {
      botReply = 'Your Flash Wallet holds refund balances, promotional cashback, and referral gifts. Click "+ ADD CASH" on the wallet tab to top up.';
    }

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isBotTyping = false;
        _chatHistory.add({'sender': 'bot', 'text': botReply});
      });
    });
  }
}
