import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';
import 'package:flashcart_ai/features/ai/models/ai_models.dart';
import 'package:flashcart_ai/features/ai/providers/ai_providers.dart';
import 'package:flashcart_ai/features/ai/presentation/widgets/ai_reusable_widgets.dart';
import 'package:flashcart_ai/features/shopping/providers/shopping_providers.dart';

class AIBudgetPlannerScreen extends ConsumerStatefulWidget {
  const AIBudgetPlannerScreen({super.key});

  @override
  ConsumerState<AIBudgetPlannerScreen> createState() => _AIBudgetPlannerScreenState();
}

class _AIBudgetPlannerScreenState extends ConsumerState<AIBudgetPlannerScreen> {
  double _budgetLimit = 30.0;
  int _familySize = 2;
  String _selectedGoal = 'Health-focused';

  final List<String> _goals = ['Health-focused', 'Max Savings'];

  void _triggerOptimization() {
    ref.read(budgetPlannerProvider.notifier).optimizeBudget(
          _budgetLimit,
          _familySize,
          _selectedGoal,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetPlannerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Intelligent Budget Planner', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Budget Settings Panel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'AI PLANNER CONFIGURATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Slider 1: Budget Limit
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Weekly Spending Limit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          Text(
                            '\$${_budgetLimit.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF10B981)),
                          ),
                        ],
                      ),
                      Slider(
                        value: _budgetLimit,
                        min: 15.0,
                        max: 100.0,
                        divisions: 17,
                        activeColor: const Color(0xFF10B981),
                        onChanged: (val) {
                          setState(() {
                            _budgetLimit = val;
                          });
                          _triggerOptimization();
                        },
                      ),

                      // Slider 2: Family Size
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Family Size / Portion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          Text(
                            '$_familySize Person(s)',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                        ],
                      ),
                      Slider(
                        value: _familySize.toDouble(),
                        min: 1,
                        max: 6,
                        divisions: 5,
                        activeColor: const Color(0xFF10B981),
                        onChanged: (val) {
                          setState(() {
                            _familySize = val.toInt();
                          });
                          _triggerOptimization();
                        },
                      ),

                      // Goals Row
                      const Text('Optimization Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: _goals.map((goal) {
                          final isSel = _selectedGoal == goal;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedGoal = goal;
                                });
                                _triggerOptimization();
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFF10B981).withOpacity(0.12)
                                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                                  border: Border.all(
                                    color: isSel ? const Color(0xFF10B981) : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  goal,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: isSel ? const Color(0xFF10B981) : (isDark ? Colors.grey[300] : Colors.grey[700]),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Budget Result Card
                BudgetCard(
                  limit: state.limit,
                  spent: state.totalCost,
                  savings: state.savingsAmount,
                  goal: state.goal,
                ),
                const SizedBox(height: 24),

                // 3. Recommended Items list fitting budget
                const Text(
                  'Optimized High-Savings Basket',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),

                state.optimizedList.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No products fit this budget limit. Try increasing the weekly spend ceiling.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.optimizedList.length,
                        itemBuilder: (context, idx) {
                          final prod = state.optimizedList[idx];
                          final hasAlt = state.alternativeProducts.containsKey(prod.id);
                          final altProd = state.alternativeProducts[prod.id];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Text(prod.emoji, style: const TextStyle(fontSize: 24)),
                                  title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text(prod.weight, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '\$${prod.price.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF10B981)),
                                        onPressed: () {
                                          ref.read(cartProvider.notifier).addToCart(prod);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Added ${prod.name} to Cart!')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasAlt && altProd != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B).withOpacity(0.08),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.lightbulb_outline_rounded, color: Colors.orange, size: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Cheaper Alternative: Swap with ${altProd.emoji} ${altProd.name} (Saves \$${(prod.price - altProd.price).toStringAsFixed(2)})',
                                            style: const TextStyle(fontSize: 10.5, color: Colors.orange, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref.read(cartProvider.notifier).addToCart(altProd);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Swapped! Added ${altProd.name} to Cart.')),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: const Text('Swap & Add', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 16),

                // Bulk Add Button
                if (state.optimizedList.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      for (final prod in state.optimizedList) {
                        ref.read(cartProvider.notifier).addToCart(prod);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('All ${state.optimizedList.length} optimized items added to Cart! 🛒'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.shopping_bag_rounded, color: Colors.white),
                    label: const Text('Add Optimized List to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
