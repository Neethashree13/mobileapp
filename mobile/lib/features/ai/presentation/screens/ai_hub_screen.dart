import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AIHubScreen extends StatelessWidget {
  const AIHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> aiFeatures = [
      {
        'title': 'AI Conversational Assistant',
        'desc': 'Smart, chat-based food and essentials shopping with contextual answers.',
        'route': '/ai-assistant',
        'icon': Icons.forum_rounded,
        'color': const Color(0xFF10B981),
        'badge': 'PREMIUM',
      },
      {
        'title': 'AI Recipe Generator',
        'desc': 'Convert any dish request into ingredients & add them instantly to cart.',
        'route': '/ai-recipe-generator',
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFFFBBF24),
        'badge': 'SMART',
      },
      {
        'title': 'Pantry Scanner',
        'desc': 'Scan your shelves using the camera, track food expiry, and autofill missing items.',
        'route': '/ai-pantry-scanner',
        'icon': Icons.qr_code_scanner_rounded,
        'color': const Color(0xFF3B82F6),
        'badge': 'VISION',
      },
      {
        'title': 'Smart Grocery Planner',
        'desc': 'Create fully custom recurring grocery lists for student life, big family meals, or parties.',
        'route': '/ai-grocery-planner',
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFF8B5CF6),
        'badge': 'NEW',
      },
      {
        'title': 'AI Voice Shopping',
        'desc': 'Speak your shopping list and add match-recognized products in real-time.',
        'route': '/ai-voice-shopping',
        'icon': Icons.mic_rounded,
        'color': const Color(0xFFEC4899),
        'badge': 'REALTIME',
      },
      {
        'title': 'AI Image Product Search',
        'desc': 'Upload snaps of labels, veggies, or treats to find exact store listing match.',
        'route': '/ai-image-search',
        'icon': Icons.image_search_rounded,
        'color': const Color(0xFF06B6D4),
        'badge': 'ACCURATE',
      },
      {
        'title': 'Intelligent Budget Planner',
        'desc': 'Lock in family size and budget limits to get an optimized high-savings list.',
        'route': '/ai-budget-planner',
        'icon': Icons.savings_rounded,
        'color': const Color(0xFF10B981),
        'badge': 'HOT',
      },
      {
        'title': 'Nutrition Dashboard',
        'desc': 'View total macro count, diet breakdowns, and healthy score of your food basket.',
        'route': '/ai-nutrition-dashboard',
        'icon': Icons.donut_large_rounded,
        'color': const Color(0xFFFBBF24),
        'badge': 'FITNESS',
      },
      {
        'title': 'Season & Weather Suggestions',
        'desc': 'Personalized catalog recommendations mapped to current weather and trending recipes.',
        'route': '/ai-smart-recommendations',
        'icon': Icons.wb_sunny_rounded,
        'color': const Color(0xFF3B82F6),
        'badge': 'DYNAMIC',
      },
      {
        'title': 'AI Spending Insights',
        'desc': 'Visual graphs showing monthly spending categories, coupon cashbacks, and coupons saved.',
        'route': '/ai-shopping-insights',
        'icon': Icons.analytics_rounded,
        'color': const Color(0xFF8B5CF6),
        'badge': 'ANALYTICS',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('FlashCart AI Experience', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Premium AI Header Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E1B4B), const Color(0xFF064E3B)]
                          : [const Color(0xFFE0F2FE), const Color(0xFFD1FAE5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? const Color(0xFF312E81) : const Color(0xFFBAE6FD),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CO-PILOT MODE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Transforming your grocery routine with intelligence.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Speak, snap, or let the AI optimize your budget, health score, and meals instantly.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[300] : const Color(0xFF334155),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.10)),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('✨', style: TextStyle(fontSize: 32)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Bento Card Grid Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Intelligent Suites',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt, color: Color(0xFF10B981), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Active 10/10',
                            style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3. Bento Layout List of Features
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: aiFeatures.length,
                  itemBuilder: (context, index) {
                    final f = aiFeatures[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          context.push(f['route']);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: f['color'].withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(f['icon'], color: f['color'], size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          f['title'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: f['color'].withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            f['badge'],
                                            style: TextStyle(
                                              color: f['color'],
                                              fontSize: 8,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      f['desc'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
