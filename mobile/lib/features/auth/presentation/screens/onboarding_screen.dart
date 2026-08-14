import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flashcart_ai/core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Lightning Fast Delivery',
      description: 'Get your groceries, fresh produce, and daily essentials delivered to your doorstep in less than 10 minutes.',
      icon: Icons.electric_bolt_rounded,
      color: const Color(0xFF10B981), // Emerald green
    ),
    OnboardingPageData(
      title: 'Eco-Friendly Logistics',
      description: '100% of our quick-commerce fleet consists of electric vehicles and eco-certified packaging partners.',
      icon: Icons.eco_rounded,
      color: const Color(0xFF059669), // Forest green
    ),
    OnboardingPageData(
      title: 'Premium Quality Goods',
      description: 'From organic farms directly to our localized dark stores. Handpicked and sanitarily packaged for you.',
      icon: Icons.verified_user_rounded,
      color: const Color(0xFF3B82F6), // Clean blue
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login-options');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: () => context.go('/login-options'),
              child: Text(
                'Skip',
                style: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Graphic Visual
                          Container(
                            width: isTablet ? 260 : 200,
                            height: isTablet ? 260 : 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: page.color.withOpacity(0.1),
                              border: Border.all(
                                color: page.color.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                page.icon,
                                size: isTablet ? 120 : 90,
                                color: page.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Title
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.w900,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Description
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    final isSelected = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: isSelected ? 24 : 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryColor
                            : (theme.brightness == Brightness.dark
                                ? const Color(0xFF374151)
                                : const Color(0xFFD1D5DB)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 36),
                // Custom CTA Button
                CustomButton(
                  text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                  onPressed: _onNext,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
