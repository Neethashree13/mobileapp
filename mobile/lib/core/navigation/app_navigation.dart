import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import All Presentation Screens
import 'package:flashcart_ai/features/auth/presentation/screens/splash_screen.dart';
import 'package:flashcart_ai/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:flashcart_ai/features/auth/presentation/screens/login_options_screen.dart';
import 'package:flashcart_ai/features/auth/presentation/screens/phone_login_screen.dart';
import 'package:flashcart_ai/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:flashcart_ai/features/auth/presentation/screens/email_login_screen.dart';
import 'package:flashcart_ai/features/auth/presentation/screens/register_screen.dart';
import 'package:flashcart_ai/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:flashcart_ai/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flashcart_ai/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:flashcart_ai/features/auth/presentation/screens/location_permission_screen.dart';

// Import Home Experience Screens
import 'package:flashcart_ai/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:flashcart_ai/features/home/presentation/screens/categories_screen.dart';
import 'package:flashcart_ai/features/home/presentation/screens/product_listing_screen.dart';
import 'package:flashcart_ai/features/home/presentation/screens/product_details_screen.dart';
import 'package:flashcart_ai/features/home/presentation/screens/search_screen.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';

// Import Shopping Experience Screens
import '../../features/shopping/models/shopping_models.dart';
import '../../features/shopping/presentation/screens/wishlist_screen.dart';
import '../../features/shopping/presentation/screens/cart_screen.dart';
import '../../features/shopping/presentation/screens/address_screen.dart';
import '../../features/shopping/presentation/screens/checkout_screen.dart';
import '../../features/shopping/presentation/screens/payment_screen.dart';
import '../../features/shopping/presentation/screens/orders_screen.dart';
import '../../features/shopping/presentation/screens/order_details_screen.dart';
import '../../features/shopping/presentation/screens/live_tracking_screen.dart';
import '../../features/shopping/presentation/screens/coupons_screen.dart';
import '../../features/shopping/presentation/screens/wallet_screen.dart';
import '../../features/shopping/presentation/screens/notifications_screen.dart';
import '../../features/shopping/presentation/screens/profile_screen.dart';
import '../../features/shopping/presentation/screens/settings_screen.dart';
import '../../features/shopping/presentation/screens/help_center_screen.dart';
import 'package:flashcart_ai/features/profile/presentation/screens/activity_history_screen.dart';
import 'package:flashcart_ai/features/profile/presentation/screens/referral_screen.dart';

// Import All AI Experience Screens
import 'package:flashcart_ai/features/ai/presentation/screens/ai_hub_screen.dart';
import 'package:flashcart_ai/features/ai/assistant/ai_assistant_screen.dart';
import 'package:flashcart_ai/features/ai/budget/ai_grocery_planner_screen.dart';
import 'package:flashcart_ai/features/ai/recipes/ai_recipe_generator_screen.dart';
import 'package:flashcart_ai/features/ai/pantry/ai_pantry_scanner_screen.dart';
import 'package:flashcart_ai/features/ai/image_search/ai_image_search_screen.dart';
import 'package:flashcart_ai/features/ai/voice/ai_voice_shopping_screen.dart';
import 'package:flashcart_ai/features/ai/budget/ai_budget_planner_screen.dart';
import 'package:flashcart_ai/features/ai/nutrition/ai_nutrition_dashboard_screen.dart';
import 'package:flashcart_ai/features/ai/recommendations/ai_smart_recommendations_screen.dart';
import 'package:flashcart_ai/features/ai/insights/ai_shopping_insights_screen.dart';

// Import Store Manager Screens
import 'package:flashcart_ai/features/store_manager/auth/store_login_screen.dart';
import 'package:flashcart_ai/features/store_manager/store_manager_main_screen.dart';

// Import Delivery Partner Screens
import 'package:flashcart_ai/features/delivery_partner/auth/delivery_auth_screen.dart';
import 'package:flashcart_ai/features/delivery_partner/delivery_partner_main_screen.dart';

class AppNavigation {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      // 1. Splash Screen
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      // 2. 3-Page Onboarding Screen
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),
      // 3. Login Options
      GoRoute(
        path: '/login-options',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginOptionsScreen();
        },
      ),
      // 4. Phone Number Login
      GoRoute(
        path: '/phone-login',
        builder: (BuildContext context, GoRouterState state) {
          return const PhoneLoginScreen();
        },
      ),
      // 5. OTP Verification
      GoRoute(
        path: '/otp-verify',
        builder: (BuildContext context, GoRouterState state) {
          final phone = state.extra as String? ?? '+91 98765 43210';
          return OtpVerificationScreen(phoneNumber: phone);
        },
      ),
      // 6. Email Login
      GoRoute(
        path: '/email-login',
        builder: (BuildContext context, GoRouterState state) {
          return const EmailLoginScreen();
        },
      ),
      // 7. Email Registration / Sign Up
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),
      // 8. Forgot Password
      GoRoute(
        path: '/forgot-password',
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordScreen();
        },
      ),
      // 9. Reset Password
      GoRoute(
        path: '/reset-password',
        builder: (BuildContext context, GoRouterState state) {
          final email = state.extra as String? ?? 'user@example.com';
          return ResetPasswordScreen(email: email);
        },
      ),
      // 10. Create / Setup Profile
      GoRoute(
        path: '/profile-setup',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileSetupScreen();
        },
      ),
      // 11. Location Permission
      GoRoute(
        path: '/location-permission',
        builder: (BuildContext context, GoRouterState state) {
          return const LocationPermissionScreen();
        },
      ),
      // 12. App Dashboard Home (Full Zepto/Blinkit Premium Home)
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeDashboardScreen();
        },
      ),
      // 13. Browse Categories Grid
      GoRoute(
        path: '/categories',
        builder: (BuildContext context, GoRouterState state) {
          return const CategoriesScreen();
        },
      ),
      // 14. Product Listing Screen (Filterable by Category, Collection, or Brand)
      GoRoute(
        path: '/products',
        builder: (BuildContext context, GoRouterState state) {
          final categoryId = state.uri.queryParameters['categoryId'];
          final brandName = state.uri.queryParameters['brand'];
          final collectionId = state.uri.queryParameters['collectionId'];

          return ProductListingScreen(
            initialCategoryId: categoryId,
            initialBrand: brandName,
            initialCollectionId: collectionId,
          );
        },
      ),
      // 15. Product Details Screen
      GoRoute(
        path: '/product-details',
        builder: (BuildContext context, GoRouterState state) {
          final product = state.extra as Product;
          return ProductDetailsScreen(product: product);
        },
      ),
      // 16. Search Screen (Store + Conversational AI Shopper)
      GoRoute(
        path: '/search',
        builder: (BuildContext context, GoRouterState state) {
          final isAIFocus = state.extra as bool? ?? false;
          return SearchScreen(initialAIFocus: isAIFocus);
        },
      ),
      // 17. Wishlist Basket Screen
      GoRoute(
        path: '/wishlist',
        builder: (BuildContext context, GoRouterState state) {
          return const WishlistScreen();
        },
      ),
      // 18. Cart Screen
      GoRoute(
        path: '/cart-screen',
        builder: (BuildContext context, GoRouterState state) {
          return const ShoppingCartScreen();
        },
      ),
      // 19. Saved Addresses Screen
      GoRoute(
        path: '/address-management',
        builder: (BuildContext context, GoRouterState state) {
          return const AddressScreen();
        },
      ),
      // 20. Checkout Screen
      GoRoute(
        path: '/checkout',
        builder: (BuildContext context, GoRouterState state) {
          return const CheckoutScreen();
        },
      ),
      // 21. Payment Gateway Options Screen
      GoRoute(
        path: '/payment',
        builder: (BuildContext context, GoRouterState state) {
          return const PaymentScreen();
        },
      ),
      // 22. My Orders List Screen
      GoRoute(
        path: '/orders',
        builder: (BuildContext context, GoRouterState state) {
          return const OrdersScreen();
        },
      ),
      GoRoute(
        path: '/orders-screen',
        builder: (BuildContext context, GoRouterState state) {
          return const OrdersScreen();
        },
      ),
      // 23. Order Details Screen
      GoRoute(
        path: '/order-details',
        builder: (BuildContext context, GoRouterState state) {
          return OrderDetailsScreen(order: state.extra as dynamic);
        },
      ),
      GoRoute(
        path: '/order-details-screen',
        builder: (BuildContext context, GoRouterState state) {
          return OrderDetailsScreen(order: state.extra as dynamic);
        },
      ),
      // 24. Live Rider Tracking Screen
      GoRoute(
        path: '/live-tracking',
        builder: (BuildContext context, GoRouterState state) {
          return LiveTrackingScreen(order: state.extra as dynamic);
        },
      ),
      // 25. Coupons Voucher Screen
      GoRoute(
        path: '/coupons',
        builder: (BuildContext context, GoRouterState state) {
          return const CouponsScreen();
        },
      ),
      // 26. Wallet Balance Screen
      GoRoute(
        path: '/wallet',
        builder: (BuildContext context, GoRouterState state) {
          return const WalletScreen();
        },
      ),
      // 27. Notifications Center Screen
      GoRoute(
        path: '/notifications',
        builder: (BuildContext context, GoRouterState state) {
          return const NotificationsScreen();
        },
      ),
      // 28. User Profile Dashboard Screen
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) {
          return const UserProfileScreen();
        },
      ),
      // 29. Security Settings Screen
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
      // Activity History Screen
      GoRoute(
        path: '/activity-history',
        builder: (BuildContext context, GoRouterState state) {
          return const ActivityHistoryScreen();
        },
      ),
      // Referral Info Screen
      GoRoute(
        path: '/referral-info',
        builder: (BuildContext context, GoRouterState state) {
          return const ReferralScreen();
        },
      ),
      // 30. AI Help Center Helpdesk Screen
      GoRoute(
        path: '/help-center',
        builder: (BuildContext context, GoRouterState state) {
          return const HelpCenterScreen();
        },
      ),
      // ==========================================
      // MODULE 4 - AI EXPERIENCE ROUTES
      // ==========================================
      GoRoute(
        path: '/ai-hub',
        builder: (BuildContext context, GoRouterState state) {
          return const AIHubScreen();
        },
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (BuildContext context, GoRouterState state) {
          return const AIAssistantScreen();
        },
      ),
      GoRoute(
        path: '/ai-grocery-planner',
        builder: (BuildContext context, GoRouterState state) {
          return const AIGroceryPlannerScreen();
        },
      ),
      GoRoute(
        path: '/ai-recipe-generator',
        builder: (BuildContext context, GoRouterState state) {
          return const AIRecipeGeneratorScreen();
        },
      ),
      GoRoute(
        path: '/ai-pantry-scanner',
        builder: (BuildContext context, GoRouterState state) {
          return const AIPantryScannerScreen();
        },
      ),
      GoRoute(
        path: '/ai-image-search',
        builder: (BuildContext context, GoRouterState state) {
          return const AIImageSearchScreen();
        },
      ),
      GoRoute(
        path: '/ai-voice-shopping',
        builder: (BuildContext context, GoRouterState state) {
          return const AIVoiceShoppingScreen();
        },
      ),
      GoRoute(
        path: '/ai-budget-planner',
        builder: (BuildContext context, GoRouterState state) {
          return const AIBudgetPlannerScreen();
        },
      ),
      GoRoute(
        path: '/ai-nutrition-dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const AINutritionDashboardScreen();
        },
      ),
      GoRoute(
        path: '/ai-smart-recommendations',
        builder: (BuildContext context, GoRouterState state) {
          return const AISmartRecommendationsScreen();
        },
      ),
      GoRoute(
        path: '/ai-shopping-insights',
        builder: (BuildContext context, GoRouterState state) {
          return const AIShoppingInsightsScreen();
        },
      ),
      // ==========================================
      // MODULE 5 - STORE MANAGER SYSTEM ROUTES
      // ==========================================
      GoRoute(
        path: '/store-manager/login',
        builder: (BuildContext context, GoRouterState state) {
          return const StoreLoginScreen();
        },
      ),
      GoRoute(
        path: '/store-manager',
        builder: (BuildContext context, GoRouterState state) {
          return const StoreLoginScreen();
        },
      ),
      GoRoute(
        path: '/store-manager/dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const StoreManagerMainScreen();
        },
      ),
      // ==========================================
      // MODULE 6 - DELIVERY PARTNER SYSTEM ROUTES
      // ==========================================
      GoRoute(
        path: '/delivery-partner',
        builder: (BuildContext context, GoRouterState state) {
          return const DeliveryAuthScreen();
        },
      ),
      GoRoute(
        path: '/delivery-partner/login',
        builder: (BuildContext context, GoRouterState state) {
          return const DeliveryAuthScreen();
        },
      ),
      GoRoute(
        path: '/delivery-partner/dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const DeliveryPartnerMainScreen();
        },
      ),
    ],
  );
}
