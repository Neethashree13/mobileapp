// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flashcart_ai/features/shopping/models/shopping_models.dart';
// import 'package:flashcart_ai/features/shopping/providers/shopping_providers.dart';
// import 'package:flashcart_ai/features/shopping/presentation/widgets/shopping_widgets.dart';

// class OrdersScreen extends ConsumerStatefulWidget {
//   const OrdersScreen({super.key});

//   @override
//   ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends ConsumerState<OrdersScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orders = ref.watch(ordersProvider);
//     final isDark = ref.watch(settingsProvider).isDarkMode;

//     // Filter by query
//     final filteredOrders = orders.where((order) {
//       if (_searchQuery.isEmpty) return true;
//       final matchId = order.id.toLowerCase().contains(_searchQuery.toLowerCase());
//       final matchProduct = order.items.any((item) => item.product.name.toLowerCase().contains(_searchQuery.toLowerCase()));
//       return matchId || matchProduct;
//     }).toList();

//     final activeOrders = filteredOrders.where((o) => o.status == OrderStatus.active).toList();
//     final completedOrders = filteredOrders.where((o) => o.status == OrderStatus.delivered).toList();
//     final cancelledOrReturned = filteredOrders.where((o) => o.status == OrderStatus.cancelled || o.status == OrderStatus.returned).toList();

//     return Theme(
//       data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
//       child: Scaffold(
//         backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
//         appBar: AppBar(
//           title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
//           elevation: 0,
//           bottom: TabBar(
//             controller: _tabController,
//             indicatorColor: const Color(0xFF10B981),
//             labelColor: const Color(0xFF10B981),
//             unselectedLabelColor: Colors.grey,
//             tabs: [
//               Tab(text: 'Active (${activeOrders.length})'),
//               Tab(text: 'Completed (${completedOrders.length})'),
//               Tab(text: 'History (${cancelledOrReturned.length})'),
//             ],
//           ),
//         ),
//         body: Column(
//           children: [
//             // Search Bar Header
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: (val) {
//                   setState(() {
//                     _searchQuery = val;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Search by Order ID or item name...',
//                   prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF10B981)),
//                   suffixIcon: _searchQuery.isNotEmpty
//                       ? IconButton(
//                           icon: const Icon(Icons.clear_rounded),
//                           onPressed: () {
//                             _searchController.clear();
//                             setState(() => _searchQuery = '');
//                           },
//                         )
//                       : null,
//                   filled: true,
//                   fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),

//             // Tab contents
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildOrderList(activeOrders, isDark),
//                   _buildOrderList(completedOrders, isDark),
//                   _buildOrderList(cancelledOrReturned, isDark),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderList(List<OrderModel> ordersList, bool isDark) {
//     if (ordersList.isEmpty) {
//       return const EmptyState(
//         icon: Icons.assignment_rounded,
//         title: 'No Orders Found',
//         description: 'You do not have any orders matching this category.',
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       itemCount: ordersList.length,
//       itemBuilder: (context, index) {
//         final order = ordersList[index];
//         return _buildOrderCard(context, order, isDark);
//       },
//     );
//   }

//   Widget _buildOrderCard(BuildContext context, OrderModel order, bool isDark) {
//     final Color statusColor;
//     final String statusLabel;

//     switch (order.status) {
//       case OrderStatus.active:
//         statusColor = const Color(0xFF10B981);
//         statusLabel = 'DELIVERING NOW';
//         break;
//       case OrderStatus.delivered:
//         statusColor = Colors.blueAccent;
//         statusLabel = 'DELIVERED';
//         break;
//       case OrderStatus.cancelled:
//         statusColor = Colors.redAccent;
//         statusLabel = 'CANCELLED';
//         break;
//       case OrderStatus.returned:
//         statusColor = Colors.orangeAccent;
//         statusLabel = 'RETURNED';
//         break;
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
//       ),
//       child: InkWell(
//         onTap: () {
//           context.push('/order-details', extra: order);
//         },
//         borderRadius: BorderRadius.circular(20),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Header line (ID, Status)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'ORDER #${order.id}',
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'JetBrains Mono'),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         _formatDate(order.orderDate),
//                         style: TextStyle(fontSize: 11, color: Colors.grey[500]),
//                       ),
//                     ],
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       statusLabel,
//                       style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//               const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF334155))),

//               // Product Thumbnails list preview
//               Row(
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: order.items.take(3).map((item) {
//                         return Container(
//                           margin: const EdgeInsets.only(right: 8),
//                           width: 48,
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: item.product.fallbackColor.withOpacity(0.12),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Image.network(
//                               item.product.imageUrl,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         '\$${order.finalAmount.toStringAsFixed(2)}',
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF10B981)),
//                       ),
//                       Text(
//                         '${order.items.fold(0, (sum, i) => sum + i.quantity)} Items',
//                         style: TextStyle(fontSize: 11, color: Colors.grey[400]),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//               const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF334155))),

//               // Action buttons (Invoice, Repeat, Track)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TextButton.icon(
//                     icon: const Icon(Icons.download_rounded, size: 16),
//                     label: const Text('Invoice', style: TextStyle(fontSize: 12)),
//                     style: TextButton.styleFrom(foregroundColor: Colors.grey),
//                     onPressed: () => _simulateInvoiceDownload(context, order.id),
//                   ),
//                   Row(
//                     children: [
//                       if (order.status == OrderStatus.active)
//                         ElevatedButton(
//                           onPressed: () {
//                             context.push('/live-tracking', extra: order);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF10B981),
//                             foregroundColor: Colors.black,
//                             elevation: 0,
//                             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                           ),
//                           child: const Text('Track Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
//                         )
//                       else
//                         ElevatedButton(
//                           onPressed: () {
//                             // Add items to cart
//                             final cart = ref.read(cartProvider.notifier);
//                             for (final item in order.items) {
//                               cart.addToCart(item.product, quantity: item.quantity);
//                             }
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('All items added back to basket!'),
//                                 backgroundColor: Color(0xFF10B981),
//                               ),
//                             );
//                             context.push('/cart-screen');
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: isDark ? Colors.white.withOpacity(0.10) : Colors.grey[200],
//                             foregroundColor: isDark ? Colors.white : Colors.black,
//                             elevation: 0,
//                             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                           ),
//                           child: const Text('Reorder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
//                         )
//                     ],
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day} ${_getMonth(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//   }

//   String _getMonth(int month) {
//     const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     return m[month - 1];
//   }

//   void _simulateInvoiceDownload(BuildContext context, String orderId) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             double progress = 0.0;
//             // Simulates download ticking
//             Future.doWhile(() async {
//               await Future.delayed(const Duration(milliseconds: 200));
//               setModalState(() {
//                 progress += 0.2;
//               });
//               return progress < 1.0;
//             }).then((_) {
//               Navigator.pop(context); // close progress dialog
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Invoice PDF for #$orderId saved in Downloads!'),
//                   backgroundColor: const Color(0xFF10B981),
//                 ),
//               );
//             });

//             return AlertDialog(
//               backgroundColor: const Color(0xFF1E293B),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//               title: const Row(
//                 children: [
//                   Icon(Icons.downloading_rounded, color: Color(0xFF10B981)),
//                   SizedBox(width: 12),
//                   Text('Downloading Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
//                 ],
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const Text('Generating tax invoice PDF file for local storage...', style: TextStyle(color: Colors.grey, fontSize: 12)),
//                   const SizedBox(height: 16),
//                   LinearProgressIndicator(value: progress, color: const Color(0xFF10B981), backgroundColor: Colors.black26),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/shopping_models.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/shopping_widgets.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleReorder(OrderModel order) async {
    if (_isReordering) return;
    setState(() {
      _isReordering = true;
    });

    final success = await ref.read(ordersProvider.notifier).reorder(order.id);

    if (mounted) {
      setState(() {
        _isReordering = false;
      });
      final err = ref.read(ordersProvider).errorMessage;
      if (!success || err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Failed to reorder'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reorder created successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        context.push('/cart-screen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);
    final orders = ordersState.orders;
    final isDark = ref.watch(settingsProvider).isDarkMode;

    // Filter by query
    final filteredOrders = orders.where((order) {
      if (_searchQuery.isEmpty) return true;
      final matchId = order.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchProduct = order.items.any((item) => item.product.name.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchId || matchProduct;
    }).toList();

    final activeOrders = filteredOrders.where((o) => o.status == OrderStatus.active).toList();
    final completedOrders = filteredOrders.where((o) => o.status == OrderStatus.delivered).toList();
    final cancelledOrReturned = filteredOrders.where((o) => o.status == OrderStatus.cancelled || o.status == OrderStatus.returned).toList();

    return Theme(
      data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.read(ordersProvider.notifier).refresh(),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF10B981),
            labelColor: const Color(0xFF10B981),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Active (${activeOrders.length})'),
              Tab(text: 'Completed (${completedOrders.length})'),
              Tab(text: 'History (${cancelledOrReturned.length})'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Search Bar Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by Order ID or item name...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF10B981)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Tab contents
            Expanded(
              child: ordersState.isLoading && orders.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF10B981)),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
                      color: const Color(0xFF10B981),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrderList(activeOrders, isDark),
                          _buildOrderList(completedOrders, isDark),
                          _buildOrderList(cancelledOrReturned, isDark),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> ordersList, bool isDark) {
    if (ordersList.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: '📦 No Orders Yet',
        description: "Looks like you haven't placed any orders.",
        buttonText: 'Shop Now',
        onAction: () => context.go('/home'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: ordersList.length,
      itemBuilder: (context, index) {
        final order = ordersList[index];
        return _buildOrderCard(context, order, isDark);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, bool isDark) {
    final Color statusColor;
    final String statusLabel;

    switch (order.status) {
      case OrderStatus.active:
        statusColor = const Color(0xFF10B981);
        statusLabel = 'DELIVERING NOW';
        break;
      case OrderStatus.delivered:
        statusColor = Colors.blueAccent;
        statusLabel = 'DELIVERED';
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.redAccent;
        statusLabel = 'CANCELLED';
        break;
      case OrderStatus.returned:
        statusColor = Colors.orangeAccent;
        statusLabel = 'RETURNED';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () {
          context.push('/order-details', extra: order);
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header line (ID, Status)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER #${order.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'JetBrains Mono'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(order.orderDate),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF334155))),

              // Product Thumbnails list preview
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: order.items.take(3).map((item) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: item.product.fallbackColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.product.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${order.finalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF10B981)),
                      ),
                      Text(
                        '${order.items.fold(0, (sum, i) => sum + i.quantity)} Items',
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  )
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF334155))),

              // Action buttons (Invoice, Repeat, Track)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Invoice', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    onPressed: () => _simulateInvoiceDownload(context, order.id),
                  ),
                  Row(
                    children: [
                      if (order.status == OrderStatus.active)
                        ElevatedButton(
                          onPressed: () {
                            context.push('/live-tracking', extra: order);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Track Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        )
                      else
                        ElevatedButton(
                          onPressed: _isReordering ? null : () => _handleReorder(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                            foregroundColor: isDark ? Colors.white : Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isReordering
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                                )
                              : const Text('Reorder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonth(int month) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return m[month - 1];
  }

  void _simulateInvoiceDownload(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double progress = 0.0;
            // Simulates download ticking
            Future.doWhile(() async {
              await Future.delayed(const Duration(milliseconds: 200));
              setModalState(() {
                progress += 0.2;
              });
              return progress < 1.0;
            }).then((_) {
              Navigator.pop(context); // close progress dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invoice PDF for #$orderId saved in Downloads!'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            });

            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.downloading_rounded, color: Color(0xFF10B981)),
                  SizedBox(width: 12),
                  Text('Downloading Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Generating tax invoice PDF file for local storage...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: progress, color: const Color(0xFF10B981), backgroundColor: Colors.black26),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
