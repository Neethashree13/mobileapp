import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcart_ai/features/ai/models/ai_models.dart';
import 'package:flashcart_ai/features/ai/providers/ai_providers.dart';
import 'package:flashcart_ai/features/home/providers/home_providers.dart';
import 'package:flashcart_ai/features/shopping/providers/shopping_providers.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';

class AIGroceryPlannerScreen extends ConsumerStatefulWidget {
  const AIGroceryPlannerScreen({super.key});

  @override
  ConsumerState<AIGroceryPlannerScreen> createState() => _AIGroceryPlannerScreenState();
}

class _AIGroceryPlannerScreenState extends ConsumerState<AIGroceryPlannerScreen> {
  final _nameController = TextEditingController();
  String _selectedType = 'Weekly Shopping';
  String _selectedEmoji = '🥬';

  final List<String> _planTypes = [
    'Weekly Shopping',
    'Monthly Shopping',
    'Festival Shopping',
    'Party Shopping',
    'Baby Essentials',
    'Pet Supplies',
    'Students',
    'Family'
  ];

  final Map<String, String> _typeEmojis = {
    'Weekly Shopping': '🥬',
    'Monthly Shopping': '📦',
    'Festival Shopping': '🪔',
    'Party Shopping': '🥳',
    'Baby Essentials': '🍼',
    'Pet Supplies': '🐶',
    'Students': '🎓',
    'Family': '👨‍👩‍👧‍👦',
  };

  void _showCreatePlanSheet() {
    _nameController.clear();
    _selectedType = 'Weekly Shopping';
    _selectedEmoji = '🥬';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create AI Grocery Plan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Plan Name',
                      hintText: 'e.g. Host Family Dinner',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Category / Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _planTypes.length,
                      itemBuilder: (context, idx) {
                        final type = _planTypes[idx];
                        final isSelected = _selectedType == type;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(type),
                            selected: isSelected,
                            selectedColor: const Color(0xFF10B981).withOpacity(0.25),
                            onSelected: (val) {
                              setSheetState(() {
                                _selectedType = type;
                                _selectedEmoji = _typeEmojis[type] ?? '🛒';
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.trim().isEmpty) return;
                      
                      // Select random items from catalogue to seed the list automatically
                      final allProducts = ref.read(productsProvider).value ?? [];
                      final seededItems = allProducts.take(3).toList();
                      ref.read(groceryPlannerProvider.notifier).createPlan(
                        _nameController.text.trim(),
                        _selectedType,
                        _selectedEmoji,
                        seededItems,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('AI Grocery Plan seeded with recommendations! ✨'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                    child: const Text('Generate with AI Recommendations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(groceryPlannerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Smart Grocery Planner', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePlanSheet,
        backgroundColor: const Color(0xFF10B981),
        label: const Row(
          children: [
            Icon(Icons.add_rounded, color: Colors.white),
            SizedBox(width: 4),
            Text('Create AI Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: plans.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('📦', style: TextStyle(fontSize: 60)),
                    SizedBox(height: 16),
                    Text('No Custom Plans Yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Tap "Create AI Plan" below to generate optimized shopping lists based on your goals.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, idx) {
                final plan = plans[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF10B981).withOpacity(0.12),
                      child: Text(plan.emoji, style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(
                      plan.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          plan.type,
                          style: TextStyle(color: theme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${plan.items.length} items',
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${plan.totalCost.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF10B981)),
                        ),
                        const Icon(Icons.expand_more_rounded, size: 18),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            ...plan.items.map((prod) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Text(prod.emoji, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      prod.name,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text(
                                    '\$${prod.price.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ref.read(groceryPlannerProvider.notifier).deletePlan(plan.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Plan deleted successfully.')),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(color: Colors.redAccent),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    minimumSize: Size.zero,
                                  ),
                                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                  label: const Text('Delete Plan', style: TextStyle(fontSize: 12)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    for (final item in plan.items) {
                                      ref.read(cartProvider.notifier).addToCart(item);
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('All ${plan.items.length} items added to Cart! 🛒'),
                                        backgroundColor: const Color(0xFF10B981),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    minimumSize: Size.zero,
                                  ),
                                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 16, color: Colors.white),
                                  label: const Text(
                                    'Add All to Cart',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
