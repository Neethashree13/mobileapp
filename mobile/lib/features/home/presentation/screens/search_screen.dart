import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';
import 'package:flashcart_ai/features/home/providers/home_providers.dart';
import 'package:flashcart_ai/features/home/widgets/search_widgets.dart';
import 'package:flashcart_ai/features/home/widgets/product_card.dart';
import 'package:flashcart_ai/features/home/widgets/empty_state_and_error_widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final bool initialAIFocus;

  const SearchScreen({
    super.key,
    this.initialAIFocus = false,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isAIFocused = false;
  String _query = '';

  // AI Conversational state
  bool _isAILoading = false;
  String? _aiResponseText;
  List<Product> _aiParsedProducts = [];

  // Popular queries
  final List<String> _popularQueries = [
    'avocados',
    'feta cheese',
    'sourdough bread',
    'fresh strawberries',
    'diet cola',
    'combo packs',
  ];

  @override
  void initState() {
    super.initState();
    _isAIFocused = widget.initialAIFocus;
    if (_isAIFocused) {
      _aiResponseText = '✨ Ask me to find ingredients for a recipe, plan a diet, or suggest tonight\'s dinner combo!';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Execute standard text search
  void _executeSearch(String val) {
    if (val.trim().isEmpty) return;
    ref.read(searchHistoryProvider.notifier).addSearch(val);
    setState(() {
      _query = val;
      _isAIFocused = false;
    });
  }

  // Execute simulated AI Shopper parsing
  void _executeAISearch(String rawInput) async {
    if (rawInput.trim().isEmpty) return;
    
    setState(() {
      _isAILoading = true;
      _aiResponseText = null;
      _aiParsedProducts = [];
    });

    ref.read(searchHistoryProvider.notifier).addSearch(rawInput);

    // Simulate natural intelligence delay
    await Future.delayed(const Duration(seconds: 1500 ~/ 1000));

    final input = rawInput.toLowerCase();
    String aiResponse = '';
    final allProducts = ref.read(productsProvider).value ?? [];
    List<Product> matched = [];

    if (input.contains('salad') || input.contains('greek') || input.contains('healthy')) {
      aiResponse = '🥗 I\'ve compiled everything you need for a premium Greek Salad! Selected farm-fresh ingredients. Delivery in 9 minutes!';
      matched = allProducts.take(3).toList();
    } else if (input.contains('pizza') || input.contains('italian') || input.contains('dinner')) {
      aiResponse = '🍕 Perfetto! For an immersive Italian pizza night, I recommend sourdough flatbread pizza bases, gourmet whole milk mozzarella, and pepperoni. Let\'s bake!';
      matched = allProducts.skip(1).take(3).toList();
    } else if (input.contains('snack') || input.contains('keto') || input.contains('chips')) {
      aiResponse = '🥑 Here are some delicious low-carb and premium snack alternatives for your grazing needs!';
      matched = allProducts.skip(2).take(3).toList();
    } else {
      aiResponse = '✨ I analyzed your request for "$rawInput". Based on stock availability, here are the absolute freshest items matched for you:';
      matched = allProducts.where((p) {
        return p.name.toLowerCase().contains(input) || 
               p.brand.toLowerCase().contains(input) || 
               p.description.toLowerCase().contains(input);
      }).toList().take(3).toList();

      if (matched.isEmpty) {
        aiResponse = '✨ I couldn\'t find direct ingredients for "$rawInput" in stock, but I highly recommend these trending local favorites:';
        matched = allProducts.where((p) => p.isTrending).take(3).toList();
        if (matched.isEmpty) matched = allProducts.take(3).toList();
      }
    }

    if (mounted) {
      setState(() {
        _isAILoading = false;
        _aiResponseText = aiResponse;
        _aiParsedProducts = matched;
      });
    }
  }

  // Live matching list for search suggestions
  List<Product> _getLiveSearchResults() {
    if (_query.trim().isEmpty) return [];
    final allProducts = ref.read(productsProvider).value ?? [];
    return allProducts.where((p) {
      final nameMatch = p.name.toLowerCase().contains(_query.toLowerCase());
      final brandMatch = p.brand.toLowerCase().contains(_query.toLowerCase());
      final descMatch = p.description.toLowerCase().contains(_query.toLowerCase());
      return nameMatch || brandMatch || descMatch;
    }).toList();
  }

  // Trigger Voice search modal overlay
  void _showVoiceSearchModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const VoiceSearchModal();
      },
    ).then((spokenText) {
      if (spokenText != null && spokenText is String && spokenText.isNotEmpty) {
        _searchController.text = spokenText;
        if (_isAIFocused) {
          _executeAISearch(spokenText);
        } else {
          _executeSearch(spokenText);
        }
      }
    });
  }

  // Trigger Scanner camera view finder dialog
  void _showBarcodeScannerModal() {
    showDialog(
      context: context,
      builder: (context) => const BarcodeScannerDialog(),
    ).then((scannedText) {
      if (scannedText != null && scannedText is String && scannedText.isNotEmpty) {
        _searchController.text = scannedText;
        _executeSearch(scannedText);
      }
    });
  }

  // Trigger camera attachment simulation
  void _showPhotoSearchModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.camera_alt_rounded, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text('Visual AI Search', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Upload a photo of your fridge, a recipe book, or an empty carton. FlashCart AI will analyze the image and populate your cart!',
            style: TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Simulate analysis
                _searchController.text = 'fresh strawberries';
                _executeSearch('fresh strawberries');
              },
              child: const Text('Mock Fridge Photo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final history = ref.watch(searchHistoryProvider);
    final searchResults = _getLiveSearchResults();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isAIFocused ? 'Ask AI Shopper' : 'Search Store',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        actions: [
          // Mode Toggle
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isAIFocused = !_isAIFocused;
                _aiResponseText = _isAIFocused 
                    ? '✨ Ask me to find ingredients for a recipe, plan a diet, or suggest tonight\'s dinner combo!' 
                    : null;
                _aiParsedProducts = [];
                _query = '';
                _searchController.clear();
              });
            },
            icon: Icon(
              _isAIFocused ? Icons.store_rounded : Icons.auto_awesome_rounded,
              size: 16,
              color: _isAIFocused ? Colors.amber : const Color(0xFF7C3AED),
            ),
            label: Text(
              _isAIFocused ? 'Store' : 'Ask AI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: _isAIFocused ? Colors.amber : const Color(0xFF7C3AED),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar Header row with dynamic AI visual triggers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: _isAIFocused ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
                decoration: BoxDecoration(
                  gradient: _isAIFocused 
                      ? const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: HomeSearchBar(
                  controller: _searchController,
                  hintText: _isAIFocused 
                      ? 'Ask AI: "Plan a romantic Italian dinner"' 
                      : 'Search "milk", "organic apples" or "bread"',
                  autofocus: true,
                  onChanged: (val) {
                    if (!_isAIFocused) {
                      setState(() {
                        _query = val;
                      });
                    }
                  },
                  onSubmitted: (val) {
                    if (_isAIFocused) {
                      _executeAISearch(val);
                    } else {
                      _executeSearch(val);
                    }
                  },
                  onVoiceTap: _showVoiceSearchModal,
                  onScanTap: _showBarcodeScannerModal,
                ),
              ),
            ),

            // 2. Main Search Body Viewport
            Expanded(
              child: _isAIFocused
                  ? _buildAISearchBody(isDark, theme)
                  : (_query.isNotEmpty 
                      ? _buildLiveResultsGrid(searchResults)
                      : _buildDefaultSearchScreenBody(isDark, history)),
            ),
          ],
        ),
      ),
    );
  }

  // AI chat response layout
  Widget _buildAISearchBody(bool isDark, ThemeData theme) {
    return Column(
      children: [
        // AI chat output window
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Response block
                if (_aiResponseText != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF312E81) : const Color(0xFFC7D2FE),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: Color(0xFF7C3AED), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'AI Shopper Suggestion',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF312E81),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _aiResponseText!,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: isDark ? const Color(0xFFE0E7FF) : const Color(0xFF1E1B4B),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_isAILoading)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        const CircularProgressIndicator(color: Color(0xFF7C3AED)),
                        const SizedBox(height: 16),
                        Text(
                          'AI Shopper is formulating recipes...',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),

                // AI Matched products listing
                if (_aiParsedProducts.isNotEmpty) ...[
                  const Text(
                    '🛒 MATCHED RECIPE INGREDIENTS IN STOCK',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.63,
                    ),
                    itemCount: _aiParsedProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: _aiParsedProducts[index]);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),

        // Quick prompt suggestions
        if (!_isAILoading)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: isDark ? const Color(0xFF111317) : Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 RECIPES TO TRY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _promptChip('Greek Salad Ingredients 🥗', 'greek salad'),
                    const SizedBox(width: 8),
                    _promptChip('Pizza Dough & Toppings 🍕', 'italian pizza'),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _promptChip(String text, String actionQuery) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _searchController.text = actionQuery;
          _executeAISearch(actionQuery);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveResultsGrid(List<Product> results) {
    if (results.isEmpty) {
      return EmptyStateWidget(
        title: 'No Matching Groceries',
        message: 'Try looking for "Milk", "Avocados", "Bread" or "Chips".',
        emoji: '🥥',
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.63,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ProductCard(product: results[index]);
      },
    );
  }

  Widget _buildDefaultSearchScreenBody(bool isDark, List<String> history) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Interactive attachments placeholders
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan Barcode',
                  color: const Color(0xFF10B981),
                  onTap: _showBarcodeScannerModal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.image_search_rounded,
                  label: 'Photo Grocery',
                  color: const Color(0xFF7C3AED),
                  onTap: _showPhotoSearchModal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search History Section
          if (history.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(searchHistoryProvider.notifier).clearHistory();
                  },
                  child: const Text('Clear All', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...history.map((term) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history_rounded, size: 18, color: Colors.grey),
                title: Text(term, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                  onPressed: () {
                    ref.read(searchHistoryProvider.notifier).removeSearch(term);
                  },
                ),
                onTap: () {
                  _searchController.text = term;
                  _executeSearch(term);
                },
              );
            }).toList(),
            const SizedBox(height: 24),
          ],

          // Popular terms section
          const Text(
            '🔥 Popular Searches',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularQueries.map((term) {
              return ActionChip(
                label: Text(
                  term,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () {
                  _searchController.text = term;
                  _executeSearch(term);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------
// VOICE SEARCH SIMULATION SHEET
// ----------------------------------------
class VoiceSearchModal extends StatefulWidget {
  const VoiceSearchModal({super.key});

  @override
  State<VoiceSearchModal> createState() => _VoiceSearchModalState();
}

class _VoiceSearchModalState extends State<VoiceSearchModal> with SingleTickerProviderStateMixin {
  late AnimationController _soundwaveController;
  bool _finishedListening = false;

  @override
  void initState() {
    super.initState();
    _soundwaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _simulateSpeechParsing();
  }

  void _simulateSpeechParsing() async {
    await Future.delayed(const Duration(seconds: 2200 ~/ 1000));
    if (mounted) {
      setState(() {
        _finishedListening = true;
      });
      _soundwaveController.stop();
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.pop(context, 'organic milk'); // mock returns organic milk spoken text!
      }
    }
  }

  @override
  void dispose() {
    _soundwaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1115) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text(
            _finishedListening ? 'Recognizing...' : 'Listening...',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            _finishedListening ? '"organic milk"' : 'Try saying "fresh avocados" or "pepperoni pizza"',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 48),

          // Soundwave scale bars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _soundwaveController,
                builder: (context, child) {
                  // offset curves for different bars
                  final animVal = (index % 2 == 0) 
                      ? _soundwaveController.value 
                      : 1.0 - _soundwaveController.value;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 6,
                    height: 20 + (animVal * 40),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// ----------------------------------------
// BARCODE CAMERA VIEWFINDER DIALOG
// ----------------------------------------
class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({super.key});

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> with SingleTickerProviderStateMixin {
  late AnimationController _scannerLaserController;

  @override
  void initState() {
    super.initState();
    _scannerLaserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _simulateScannerDetection();
  }

  void _simulateScannerDetection() async {
    await Future.delayed(const Duration(seconds: 2000 ~/ 1000));
    if (mounted) {
      Navigator.pop(context, 'kettle chips'); // scanned code yields Kettle Chips!
    }
  }

  @override
  void dispose() {
    _scannerLaserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.black,
      child: Container(
        height: 340,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Scan Product Barcode', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Viewfinder box
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  // Mock camera background pattern
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Center(
                      child: Icon(Icons.camera_alt_rounded, color: Colors.white24, size: 48),
                    ),
                  ),

                  // Red Laser Line
                  AnimatedBuilder(
                    animation: _scannerLaserController,
                    builder: (context, child) {
                      return Positioned(
                        top: 20 + (_scannerLaserController.value * 160),
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 2,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            boxShadow: [
                              BoxShadow(color: Colors.redAccent, blurRadius: 4, spreadRadius: 1),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Align barcode of any packet inside the laser line',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
