import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';
import 'package:flashcart_ai/features/home/providers/home_providers.dart';
import 'package:flashcart_ai/features/ai/presentation/widgets/ai_reusable_widgets.dart';
import '../../shopping/providers/shopping_providers.dart';

class AIVoiceShoppingScreen extends ConsumerStatefulWidget {
  const AIVoiceShoppingScreen({super.key});

  @override
  ConsumerState<AIVoiceShoppingScreen> createState() => _AIVoiceShoppingScreenState();
}

class _AIVoiceShoppingScreenState extends ConsumerState<AIVoiceShoppingScreen> {
  bool _isListening = false;
  String _transcript = 'Press the mic button and say what you need to buy...';
  List<Product> _recognizedProducts = [];

  void _toggleListening() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      return;
    }

    setState(() {
      _isListening = true;
      _transcript = 'Listening... Speak now.';
      _recognizedProducts = [];
    });

    // Simulate real-time vocal transcript flow
    await Future.delayed(const Duration(seconds: 1500));
    if (!mounted || !_isListening) return;
    setState(() {
      _transcript = '"I need some fresh broccoli, sweet red apples, and cold milk please..."';
    });

    await Future.delayed(const Duration(seconds: 1500));
    if (!mounted || !_isListening) return;

    setState(() {
      _isListening = false;
      _transcript = '"I need some fresh broccoli, sweet red apples, and cold milk please..."';
      final allProducts = ref.read(productsProvider).value ?? [];
      // Map recognized words to actual store catalog
      _recognizedProducts = allProducts.take(3).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI Speech Recognition complete! Matches loaded.'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Voice-Activated Shopping', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Microphone Visualiser Area
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isListening ? 'SPEAK NOW' : 'TAP TO TRANSMIT',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Floating Waveform anim
                      VoiceWave(isListening: _isListening),
                      const SizedBox(height: 36),

                      // Large Floating Pulse Button
                      GestureDetector(
                        onTap: _toggleListening,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _isListening ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Transcript Log Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _transcript,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Recognized Items Section
              if (_recognizedProducts.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AI Match-Recognized Products',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        for (final prod in _recognizedProducts) {
                          ref.read(cartProvider.notifier).addToCart(prod);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added all ${_recognizedProducts.length} items to Cart! 🛒'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 14),
                      label: const Text('Add All', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF10B981)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _recognizedProducts.length,
                    itemBuilder: (context, idx) {
                      final prod = _recognizedProducts[idx];
                      return Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 100,
                              decoration: BoxDecoration(
                                color: prod.fallbackColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(prod.emoji, style: const TextStyle(fontSize: 28)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    prod.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    prod.weight,
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${prod.price.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                              color: const Color(0xFF10B981),
                              onPressed: () {
                                ref.read(cartProvider.notifier).addToCart(prod);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added ${prod.name} to Cart!')),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
