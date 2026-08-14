import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/shopping_models.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/shopping_widgets.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flashcart_ai/core/network/api_client.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedSlot = 'Instant (10 Mins)';
  String _selectedPayment = 'UPI (Paytm)';
  bool _isGiftOption = false;
  late Razorpay _razorpay;

  String? _backendPaymentId;
  String? _razorpayOrderId;
  final TextEditingController _giftMessageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final Set<String> _selectedInstructionChips = {};
  bool _isPlacingOrder = false;

   @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handleRazorpaySuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handleRazorpayError,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );
  }

   @override
  void dispose() {
    _razorpay.clear();
    _giftMessageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  // ============================================================
  // RAZORPAY PAYMENT HANDLERS
  // ============================================================

Future<void> _handleRazorpaySuccess(
  PaymentSuccessResponse response,
) async {
  debugPrint('========================================');
  debugPrint('RAZORPAY PAYMENT SUCCESS');
  debugPrint('Payment ID: ${response.paymentId}');
  debugPrint('Order ID: ${response.orderId}');
  debugPrint('Signature: ${response.signature}');
  debugPrint('Backend Payment ID: $_backendPaymentId');
  debugPrint('========================================');

  if (!mounted) return;

  setState(() {
    _isPlacingOrder = true;
  });

  try {
    final api = ApiClient();

    final verifyResponse = await api.http.post(
      '/payment/verify',
      data: {
        'paymentId': _backendPaymentId,
        'transactionId': response.paymentId,
        'gatewaySignature': response.signature,
      },
    );

    debugPrint(
      'Payment verification response: ${verifyResponse.data}',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment verified successfully!'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _isPlacingOrder = false;
    });

    // We will connect order finalization here in the next step.
  } on DioException catch (e) {
    debugPrint(
      'Payment verification failed: ${e.response?.data}',
    );

    if (!mounted) return;

    setState(() {
      _isPlacingOrder = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.response?.data?['error'] ??
              'Payment verification failed',
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e) {
    debugPrint('Payment verification error: $e');

    if (!mounted) return;

    setState(() {
      _isPlacingOrder = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment verification failed: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
  void _handleRazorpayError(PaymentFailureResponse response) {
    debugPrint('========================================');
    debugPrint('RAZORPAY PAYMENT FAILED');
    debugPrint('Code: ${response.code}');
    debugPrint('Message: ${response.message}');
    debugPrint('========================================');

    if (!mounted) return;

    setState(() {
      _isPlacingOrder = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment failed: ${response.message ?? "Please try again"}',
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('========================================');
    debugPrint('EXTERNAL WALLET');
    debugPrint('Wallet: ${response.walletName}');
    debugPrint('========================================');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'External wallet selected: ${response.walletName ?? "Wallet"}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  final List<String> _deliverySlots = [
    'Instant (10 Mins)',
    'Morning (7:00 AM - 9:00 AM)',
    'Afternoon (1:00 PM - 3:00 PM)',
    'Evening (6:00 PM - 8:00 PM)',
  ];

  final List<Map<String, dynamic>> _instructionChips = [
    {'label': 'Leave at Gate', 'icon': Icons.door_front_door_rounded},
    {'label': 'Avoid Calling', 'icon': Icons.phone_disabled_rounded},
    {'label': 'Don\'t Ring Bell', 'icon': Icons.notifications_off_rounded},
    {'label': 'Leave with Guard', 'icon': Icons.security_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final addresses = ref.watch(addressProvider);
    final isDark = ref.watch(settingsProvider).isDarkMode;

    final defaultAddress = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);

    return Theme(
      data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Delivery Address Card
              _buildSectionTitle('DELIVERY ADDRESS', isDark),
              _buildAddressSummaryCard(context, defaultAddress, isDark),
              const SizedBox(height: 16),

              // 2. Delivery Slot Picker
              _buildSectionTitle('SELECT DELIVERY TIMING SLOT', isDark),
              _buildSlotPicker(isDark),
              const SizedBox(height: 16),

              // 3. Payment Method
              _buildSectionTitle('PAYMENT METHOD', isDark),
              _buildPaymentSummaryCard(context, isDark),
              const SizedBox(height: 16),

              // 4. Delivery Instructions
              _buildSectionTitle('DELIVERY INSTRUCTIONS', isDark),
              _buildInstructionsSection(isDark),
              const SizedBox(height: 16),

              // 5. Premium Gift Wrap Toggle
              _buildSectionTitle('GIFT WRAP OPTION', isDark),
              _buildGiftWrapCard(isDark),
              const SizedBox(height: 16),

              // 6. Checkout Receipt Summary
              _buildSectionTitle('ORDER RECEIPT SUMMARY', isDark),
              _buildCheckoutSummaryCard(cartState, isDark),
              const SizedBox(height: 24),

              // 7. Place Order Slider Button
              ElevatedButton(
                onPressed: (cartState.isLoading || _isPlacingOrder || !cartState.isCartValid || cartState.items.isEmpty)
                    ? null
                    : () => _handlePlaceOrder(cartState, defaultAddress),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey[700],
                  disabledForegroundColor: Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: (cartState.isLoading || _isPlacingOrder)
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PLACE ORDER & PAY',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.payment_rounded, size: 20),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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

  Widget _buildAddressSummaryCard(BuildContext context, Address address, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(address.icon, color: const Color(0xFF10B981), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivering to: ${address.label}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${address.addressLine1}, ${address.addressLine2}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              context.push('/address-management');
            },
            child: const Text(
              'CHANGE',
              style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSlotPicker(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: _deliverySlots.map((slot) {
          final isSelected = _selectedSlot == slot;
          return RadioListTile<String>(
            title: Text(
              slot,
              style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
            value: slot,
            groupValue: _selectedSlot,
            activeColor: const Color(0xFF10B981),
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              setState(() {
                _selectedSlot = val ?? _selectedSlot;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentSummaryCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF1E293B),
            child: Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedPayment,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Instantly verified checkout',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showPaymentMethodSelector(context),
            child: const Text(
              'CHANGE',
              style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  void _showPaymentMethodSelector(BuildContext context) {
    final methods = ['UPI (Paytm)', 'UPI (Google Pay)', 'Saved Credit Card', 'Cash on Delivery (COD)'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ...methods.map((method) => ListTile(
                    title: Text(method, style: const TextStyle(fontSize: 13)),
                    onTap: () {
                      setState(() {
                        _selectedPayment = method;
                      });
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructionsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _instructionChips.map((chip) {
              final label = chip['label'] as String;
              final icon = chip['icon'] as IconData;
              final isSelected = _selectedInstructionChips.contains(label);

              return ChoiceChip(
                avatar: Icon(icon, size: 14, color: isSelected ? Colors.black : Colors.grey),
                label: Text(label, style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                selectedColor: const Color(0xFF10B981),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black),
                ),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedInstructionChips.add(label);
                    } else {
                      _selectedInstructionChips.remove(label);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _instructionsController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Enter any additional instructions (e.g. Leave with guard)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGiftWrapCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.pinkAccent,
                radius: 18,
                child: Text('🎁', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wrap as a Gourmet Gift (+ \$1.49)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Eco-friendly gift boxes with personalized card notes', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _isGiftOption,
                activeColor: const Color(0xFF10B981),
                onChanged: (val) {
                  setState(() {
                    _isGiftOption = val;
                  });
                },
              )
            ],
          ),
          if (_isGiftOption) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _giftMessageController,
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Enter gift note message (e.g. Happy Birthday!)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildCheckoutSummaryCard(CartState state, bool isDark) {
    final double finalPrice = state.total + (_isGiftOption ? 1.49 : 0.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildRow('Basket Subtotal', '\$${state.subtotal.toStringAsFixed(2)}', isDark),
          _buildRow('Delivery Charges', state.deliveryFee == 0.0 ? 'FREE' : '\$${state.deliveryFee.toStringAsFixed(2)}', isDark, valueColor: state.deliveryFee == 0.0 ? const Color(0xFF10B981) : null),
          _buildRow('Platform Surcharge', '\$${state.platformFee.toStringAsFixed(2)}', isDark),
          _buildRow('Taxes', '\$${state.taxes.toStringAsFixed(2)}', isDark),
          if (state.deliveryTip > 0)
            _buildRow('Tipping Rajesh', '\$${state.deliveryTip.toStringAsFixed(2)}', isDark),
          if (state.appliedCoupon != null)
            _buildRow('Applied Coupon (${state.appliedCoupon!.code})', '-\$${state.discount.toStringAsFixed(2)}', isDark, valueColor: const Color(0xFF10B981)),
          if (state.useWallet)
            _buildRow('Wallet Deduction', '-\$${state.walletDeduction.toStringAsFixed(2)}', isDark, valueColor: Colors.blueAccent),
          if (_isGiftOption)
            _buildRow('Premium Gift Wrapping', '\$1.49', isDark),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFF334155))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Net Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('\$${finalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF10B981))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRow(String label, String val, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
          Text(
            val,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor ?? (isDark ? Colors.white : Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _openRazorpay({
  required double amount,
  required String razorpayOrderId,
  required String razorpayKeyId,
  required String paymentId,
}) async {
  _backendPaymentId = paymentId;
  _razorpayOrderId = razorpayOrderId;

  final options = {
    'key': razorpayKeyId,
    'amount': (amount * 100).round(), // Razorpay uses paise
    'name': 'FlashCart AI',
    'description': 'Order Payment',
    'order_id': razorpayOrderId,

    // Optional customer information
    'prefill': {
      'contact': '',
      'email': '',
    },

    'theme': {
      'color': '#10B981',
    },

    'external': {
      'wallets': ['paytm'],
    },
  };

  try {
    debugPrint('Opening Razorpay...');
    debugPrint('Razorpay Order ID: $razorpayOrderId');
    debugPrint('Backend Payment ID: $paymentId');
    debugPrint('Amount: ₹$amount');

    _razorpay.open(options);
  } catch (e) {
    debugPrint('Razorpay open error: $e');

    if (!mounted) return;

    setState(() {
      _isPlacingOrder = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to open payment: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> _createRazorpayPayment({
  required String orderId,
  required double amount,
}) async {
  try {
    final api = ApiClient();

    final response = await api.http.post(
      '/payment/create',
      data: {
        'orderId': orderId,
        'amount': amount,
        'paymentMethod': _selectedPayment,
        'provider': 'Razorpay',
        'idempotencyKey':
            'PAY-${orderId}-${DateTime.now().millisecondsSinceEpoch}',
      },
    );

    debugPrint('Payment create response: ${response.data}');

    final data = response.data;

    final payment = data['payment'] ?? data;

    final paymentId = payment['id'];
    final razorpayOrderId = payment['razorpayOrderId'];
    final razorpayKeyId = payment['razorpayKeyId'];

    if (paymentId == null ||
        razorpayOrderId == null ||
        razorpayKeyId == null) {
      throw Exception(
        'Invalid payment response from backend: $data',
      );
    }

    await _openRazorpay(
      amount: amount,
      razorpayOrderId: razorpayOrderId,
      razorpayKeyId: razorpayKeyId,
      paymentId: paymentId,
    );
  } on DioException catch (e) {
    debugPrint('Payment API error: ${e.response?.data}');
    debugPrint('Payment API status: ${e.response?.statusCode}');

    if (!mounted) return;

    setState(() {
      _isPlacingOrder = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.response?.data?['message'] ??
              'Unable to create payment',
        ),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    debugPrint('Payment creation error: $e');

    if (!mounted) return;

    setState(() {
      _isPlacingOrder = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  Future<void> _handlePlaceOrder(CartState cartState, Address defaultAddress) async {
    if (_isPlacingOrder) return;
    setState(() => _isPlacingOrder = true);

    final double finalPrice = cartState.total + (_isGiftOption ? 1.49 : 0.0);
    final activeItems = cartState.items.where((i) => !i.isSavedForLater).toList();

    if (activeItems.isEmpty) {
      setState(() => _isPlacingOrder = false);
      return;
    }

    // Create the actual order
    final newOrder = OrderModel(
      id: '',
      items: activeItems,
      orderDate: DateTime.now(),
      status: OrderStatus.active,
      paymentMethod: _selectedPayment,
      deliveryAddress: defaultAddress,
      subTotal: cartState.subtotal,
      deliveryCharges: cartState.deliveryFee,
      platformFee: cartState.platformFee,
      taxes: cartState.taxes,
      discount: cartState.discount,
      finalAmount: finalPrice,
      deliverySlot: _selectedSlot,
      deliveryInstructions: _instructionsController.text.isNotEmpty ? _instructionsController.text : _selectedInstructionChips.join(', '),
    );

    // Write to orders provider
    final placedOrder = await ref.read(ordersProvider.notifier).placeOrder(newOrder);

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    final err = ref.read(ordersProvider).errorMessage;
    if (placedOrder == null || err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Failed to place order'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    // If wallet is used, deduct the wallet amount
    if (cartState.useWallet) {
      ref.read(walletProvider.notifier).deductWallet(cartState.walletDeduction);
    }

    // Add Cashback to wallet as promo reward
    final cashbackReward = finalPrice * 0.10; // 10% cashback
    ref.read(walletProvider.notifier).addCashback(cashbackReward);

    // Empty the cart
    await ref.read(cartProvider.notifier).clearCart();

    if (!mounted) return;

    // Trigger Success Overlay with custom vector confetti Dialog
    _showSuccessConfettiDialog(placedOrder);
  }

  void _showSuccessConfettiDialog(OrderModel order) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Confetti Particle Simulation Icon
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🎉', style: TextStyle(fontSize: 48)),
                            SizedBox(width: 12),
                            Text('🥦', style: TextStyle(fontSize: 48)),
                            SizedBox(width: 12),
                            Text('✨', style: TextStyle(fontSize: 48)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 72),
                        const SizedBox(height: 16),
                        const Text(
                          'Order Placed Successfully!',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your order ID is #${order.id}. Delivery hero Rajesh Kumar has accepted and is wrapping your farm products!',
                          style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '10% CASHBACK \$1.50 CREDITED!',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // close dialog
                            context.pushReplacement('/live-tracking', extra: order);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('TRACK LIVE ORDER 🛵', style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
