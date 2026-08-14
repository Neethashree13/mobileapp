import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers/product_provider.dart';
import '../data/providers/cart_provider.dart';
import '../data/models/product_model.dart';
import 'cart_screen.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToRider;
  final VoidCallback onLogout;

  const CustomerHomeScreen({
    super.key,
    required this.onSwitchToRider,
    required this.onLogout,
  });

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentTabIndex = 0; // 0: Shop, 1: Profile

  // --- Profile Fields ---
  String _profileName = "Arav Sharma";
  String _profileEmail = "arav@example.com";
  String _profilePhone = "+91 98765 43210";
  String _profileDob = "Oct 12, 1995";
  String _profileGender = "Male";
  String _profilePic = "assets/images/user_avatar.jpg";
  double _walletBalance = 45.00;

  // --- Addresses ---
  final List<Map<String, dynamic>> _addresses = [
    {
      "id": 1,
      "title": "Home",
      "addressLine1": "Flat 402, Green Meadows",
      "addressLine2": "Outer Ring Road",
      "landmark": "Near Central Mall",
      "city": "Bengaluru",
      "state": "Karnataka",
      "postalCode": "560103",
      "isDefault": true
    },
    {
      "id": 2,
      "title": "Work",
      "addressLine1": "Tower B, Tech Park",
      "addressLine2": "Whitefield",
      "landmark": "Behind Fire Station",
      "city": "Bengaluru",
      "state": "Karnataka",
      "postalCode": "560066",
      "isDefault": false
    },
  ];

  // --- Past Orders ---
  final List<Map<String, dynamic>> _orders = [
    {"id": "FC-98421", "date": "15 Jul 2026", "items": "Organic Bananas x1, Whole Milk 1L x2", "total": "\$12.50", "status": "Delivered in 7 Mins"},
    {"id": "FC-98110", "date": "12 Jul 2026", "items": "Sourdough Bread x1, Salted Butter x1", "total": "\$8.90", "status": "Delivered in 9 Mins"},
  ];

  // --- Active Sessions ---
  final List<Map<String, String>> _sessions = [
    {"device": "Google Pixel 8 Pro", "location": "Bengaluru, India (Current)", "icon": "phone_android"},
    {"device": "MacBook Pro 16\"", "location": "Whitefield, India", "icon": "laptop"},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final products = ref.watch(filteredProductsProvider);
    final cart = ref.watch(cartProvider);

    // Apply client-side search query filtering
    final displayedProducts = products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF07080A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        title: Row(
          children: [
            const Icon(Icons.bolt, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FlashCart AI',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Deliver to: $_profileName • 8 Mins',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Swap Mode Button
          TextButton.icon(
            icon: const Icon(Icons.delivery_dining, color: Color(0xFF3B82F6), size: 18),
            label: const Text('Rider', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 13, fontWeight: FontWeight.bold)),
            onPressed: widget.onSwitchToRider,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey, size: 20),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: _currentTabIndex == 0 
          ? _buildShopView(categories, selectedCategory, displayedProducts)
          : _buildProfileView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        backgroundColor: const Color(0xFF0F1115),
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
      // Cart Floating Button (only on Shop tab)
      floatingActionButton: _currentTabIndex == 0 && cart.items.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.shopping_bag, size: 18),
              label: Text(
                'Basket (${cart.items.values.fold(0, (sum, i) => sum + i.quantity)}) • \$${cart.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildShopView(dynamic categories, dynamic selectedCategory, List<ProductModel> displayedProducts) {
    return Column(
      children: [
        // Banner for AI Green Logistics
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/eco_banner.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'AI CO2-Neutral Match Active',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Your cart currently prevents 0.8kg CO2 compared to local driving.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Search Field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search organic bananas, dairy, fresh bread...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF0F1115),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1F2937)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal Categories Scroller
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selectedCategory == cat['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    cat['name']!,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFF0F1115),
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(selectedCategoryProvider.notifier).state = cat['id']!;
                    }
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Main Products Grid
        Expanded(
          child: displayedProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, color: Colors.grey, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'No products found matching "$_searchQuery"',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: displayedProducts.length,
                  itemBuilder: (context, index) {
                    final product = displayedProducts[index];
                    return _ProductCard(
                      product: product,
                      onTap: () => _showProductDetails(context, product),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card with Profile Picture & Info
          Card(
            color: const Color(0xFF0F1115),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF1F2937)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showEditProfilePhotoSheet,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF1F2937),
                          backgroundImage: _profilePic.startsWith('assets/') 
                              ? AssetImage(_profilePic) as ImageProvider
                              : NetworkImage(_profilePic),
                          child: _profilePic.isEmpty 
                              ? const Icon(Icons.person, size: 40, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 12, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profileName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profileEmail,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _profilePhone,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _showEditProfileDetailsSheet,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F2937),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Edit Profile', style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            _buildVerificationBadge(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Wallet & Balance Tracker Card
          Card(
            color: const Color(0xFF0F1115),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF1F2937)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FlashCart Wallet Balance',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_walletBalance.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddMoneySheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Money', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Address Management Section
          _buildAddressesSection(),
          
          const SizedBox(height: 16),
          
          // Security Settings Section
          _buildSecuritySection(),
          
          const SizedBox(height: 16),

          // Utility Sections: Saved Places, Coupons, Orders, Wishlist, Favorites, Language, Notifications
          _buildUtilityAccordion(),

          const SizedBox(height: 24),
          
          // Footer with Version & App Build info
          const Text(
            'FlashCart AI v2.4.0 (Build 9021)\nSub-10 Min Green Deliveries',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.5),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF047857).withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF047857)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified, color: Color(0xFF10B981), size: 12),
          SizedBox(width: 4),
          Text('Verified', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAddressesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Delivery Addresses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            TextButton.icon(
              onPressed: _showAddAddressSheet,
              icon: const Icon(Icons.add, size: 16, color: Color(0xFF10B981)),
              label: const Text('Add New', style: TextStyle(color: Color(0xFF10B981), fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._addresses.map((addr) {
          final isDefault = addr["isDefault"] ?? false;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1115),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDefault ? const Color(0xFF10B981) : const Color(0xFF1F2937)),
            ),
            child: Row(
              children: [
                Icon(
                  addr["title"] == "Home" ? Icons.home : (addr["title"] == "Work" ? Icons.work : Icons.location_on),
                  color: isDefault ? const Color(0xFF10B981) : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            addr["title"],
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Default', style: TextStyle(color: Color(0xFF10B981), fontSize: 9)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${addr['addressLine1']}, ${addr['addressLine2'] ?? ''}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        "${addr['city']}, ${addr['state']} - ${addr['postalCode']}",
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  onPressed: () {
                    setState(() {
                      _addresses.removeWhere((element) => element["id"] == addr["id"]);
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      color: const Color(0xFF0F1115),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1F2937)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security & Device Management',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline, color: Colors.grey),
              title: const Text('Change Password', style: TextStyle(color: Colors.white, fontSize: 13)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              onTap: _showChangePasswordDialog,
            ),
            const Divider(color: Color(0xFF1F2937), height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.devices, color: Colors.grey),
              title: const Text('Device Sessions', style: TextStyle(color: Colors.white, fontSize: 13)),
              subtitle: Text('${_sessions.length} active login sessions', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              onTap: _showDeviceSessionsDialog,
            ),
            const Divider(color: Color(0xFF1F2937), height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.redAccent),
              onTap: _showDeleteAccountDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilityAccordion() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        children: [
          ExpansionTile(
            collapsedIconColor: Colors.grey,
            iconColor: const Color(0xFF10B981),
            title: const Text('Past Orders', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            leading: const Icon(Icons.receipt_long, color: Color(0xFF10B981)),
            children: _orders.map((ord) {
              return ListTile(
                title: Text(ord["id"], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text("${ord['date']} • ${ord['items']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: Text(ord["total"], style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
          const Divider(color: Color(0xFF1F2937), height: 1),
          ExpansionTile(
            collapsedIconColor: Colors.grey,
            iconColor: const Color(0xFF10B981),
            title: const Text('Active Promo Coupons', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            leading: const Icon(Icons.local_offer, color: Color(0xFF10B981)),
            children: [
              _buildCouponTile("FLASH50", "Get 50% Off up to \$10 on your first order", "Active"),
              _buildCouponTile("GREENSAVER", "Free neutral emissions delivery code", "Active"),
            ],
          ),
          const Divider(color: Color(0xFF1F2937), height: 1),
          ExpansionTile(
            collapsedIconColor: Colors.grey,
            iconColor: const Color(0xFF10B981),
            title: const Text('Saved & Favorite Places', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            leading: const Icon(Icons.bookmark_border, color: Color(0xFF10B981)),
            children: const [
              ListTile(
                title: Text("Vance's Bistro", style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: Text("Sector 5, Outer Ring Road", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              ListTile(
                title: Text("Organic Orchards Outlet", style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: Text("Indiranagar, Bengaluru", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ],
          ),
          const Divider(color: Color(0xFF1F2937), height: 1),
          ExpansionTile(
            collapsedIconColor: Colors.grey,
            iconColor: const Color(0xFF10B981),
            title: const Text('App Preferences', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            leading: const Icon(Icons.settings, color: Color(0xFF10B981)),
            children: [
              ListTile(
                title: const Text('Language', style: TextStyle(color: Colors.white, fontSize: 13)),
                trailing: const Text('English (US)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language preference saved.')));
                },
              ),
              ListTile(
                title: const Text('Push Notifications', style: TextStyle(color: Colors.white, fontSize: 13)),
                trailing: Switch(
                  value: true,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (v) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponTile(String code, String desc, String status) {
    return ListTile(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: Text(code, style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      subtitle: Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Promo coupon $code applied successfully!')));
        },
        child: const Text('APPLY', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- Modal Sheets & Interactive Dialogs ---

  void _showEditProfilePhotoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1115),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text('Update Profile Picture', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.grey),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    _profilePic = "assets/images/user_avatar.jpg";
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulated image gallery selection.')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.grey),
                title: const Text('Take a Photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    _profilePic = "assets/images/user_avatar.jpg";
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulated camera capture.')));
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDetailsSheet() {
    final nameCont = TextEditingController(text: _profileName);
    final emailCont = TextEditingController(text: _profileEmail);
    final phoneCont = TextEditingController(text: _profilePhone);
    final dobCont = TextEditingController(text: _profileDob);
    final genderCont = TextEditingController(text: _profileGender);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1115),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Edit Personal Information', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                _buildSheetTextField(nameCont, 'Full Name', Icons.person),
                const SizedBox(height: 12),
                _buildSheetTextField(emailCont, 'Email Address', Icons.email),
                const SizedBox(height: 12),
                _buildSheetTextField(phoneCont, 'Phone Number', Icons.phone),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSheetTextField(dobCont, 'Date of Birth', Icons.calendar_today)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSheetTextField(genderCont, 'Gender', Icons.wc)),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _profileName = nameCont.text;
                      _profileEmail = emailCont.text;
                      _profilePhone = phoneCont.text;
                      _profileDob = dobCont.text;
                      _profileGender = genderCont.text;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey, size: 18),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1F2937))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF10B981))),
      ),
    );
  }

  void _showAddMoneySheet() {
    final moneyCont = TextEditingController(text: "15");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1115),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Money to Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: moneyCont,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(color: Color(0xFF10B981), fontSize: 24, fontWeight: FontWeight.bold),
                  labelText: 'Enter Deposit Amount',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1F2937))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF10B981))),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["\$10", "\$20", "\$50", "\$100"].map((preset) {
                  return InkWell(
                    onTap: () {
                      moneyCont.text = preset.substring(1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(preset, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final parsedVal = double.tryParse(moneyCont.text) ?? 0.0;
                  setState(() {
                    _walletBalance += parsedVal;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('\$${parsedVal.toStringAsFixed(2)} successfully credited.')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Proceed to Pay (Simulated Gateway)', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showAddAddressSheet() {
    final titleCont = TextEditingController(text: "Home");
    final line1Cont = TextEditingController();
    final line2Cont = TextEditingController();
    final cityCont = TextEditingController(text: "Bengaluru");
    final stateCont = TextEditingController(text: "Karnataka");
    final zipCont = TextEditingController(text: "560103");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1115),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add Delivery Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    TextButton.icon(
                      icon: const Icon(Icons.my_location, size: 16, color: Color(0xFF10B981)),
                      label: const Text('Use GPS', style: TextStyle(color: Color(0xFF10B981))),
                      onPressed: () {
                        line1Cont.text = "GPS Coordinates: 12.9279, 77.6250";
                        line2Cont.text = "Near HSR Layout Sector 4";
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulated dynamic GPS location coordinates injected.')));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSheetTextField(titleCont, 'Address Label (e.g. Home, Work, Other)', Icons.bookmark),
                const SizedBox(height: 12),
                _buildSheetTextField(line1Cont, 'Address Line 1', Icons.location_on),
                const SizedBox(height: 12),
                _buildSheetTextField(line2Cont, 'Address Line 2 (Optional)', Icons.location_on),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSheetTextField(cityCont, 'City', Icons.map)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSheetTextField(zipCont, 'Postal Code', Icons.pin_drop)),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (line1Cont.text.isEmpty) return;
                    setState(() {
                      _addresses.add({
                        "id": DateTime.now().millisecondsSinceEpoch,
                        "title": titleCont.text,
                        "addressLine1": line1Cont.text,
                        "addressLine2": line2Cont.text,
                        "landmark": "Near injected landmark",
                        "city": cityCont.text,
                        "state": stateCont.text,
                        "postalCode": zipCont.text,
                        "isDefault": _addresses.isEmpty,
                      });
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Add Delivery Address', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final oldCont = TextEditingController();
    final newCont = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1115),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Change Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldCont,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Old Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1F2937))),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCont,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1F2937))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeviceSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F1115),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Active Device Sessions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final sess = _sessions[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(sess["icon"] == "laptop" ? Icons.laptop : Icons.phone_android, color: const Color(0xFF10B981)),
                      title: Text(sess["device"]!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(sess["location"]!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      trailing: index == 0 
                          ? const Text('Current', style: TextStyle(color: Color(0xFF10B981), fontSize: 11))
                          : IconButton(
                              icon: const Icon(Icons.exit_to_app, color: Colors.redAccent, size: 18),
                              onPressed: () {
                                setDialogState(() {
                                  _sessions.removeAt(index);
                                });
                                setState(() {});
                              },
                            ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      _sessions.removeWhere((element) => element["device"] != "Google Pixel 8 Pro");
                    });
                    setState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out of all other devices successfully.')));
                  },
                  child: const Text('Logout All Devices', style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1115),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('⚠️ Delete Account', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          content: const Text(
            'Are you absolutely sure you want to delete your FlashCart AI account? This action is permanent and cannot be undone. All wallet credits, coupons, and addresses will be wiped.',
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onLogout();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account successfully deleted.'), backgroundColor: Colors.redAccent));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              child: const Text('Confirm Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showProductDetails(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1115),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return _ProductDetailsSheet(product: product, scrollController: scrollController);
          },
        );
      },
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final countInCart = cart.items[product.id]?.quantity ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1115),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1F2937), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image with fallback & badge
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF1F2937),
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  
                  // Organic Label
                  if (product.isOrganic)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF047857),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ORGANIC',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                  // Fast Delivery indicator
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Color(0xFF10B981), size: 11),
                          const SizedBox(width: 2),
                          Text(
                            '${product.deliveryTimeMins}m',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Text info
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.unit,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  
                  // Price and Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                          ),
                          if (product.originalPrice != null)
                            Text(
                              '\$${product.originalPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                      
                      // Add Button
                      countInCart > 0
                          ? Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 14, color: Colors.black),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                    onPressed: () {
                                      ref.read(cartProvider.notifier).removeProduct(product.id);
                                    },
                                  ),
                                  Text(
                                    '$countInCart',
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 14, color: Colors.black),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                    onPressed: () {
                                      ref.read(cartProvider.notifier).addProduct(product);
                                    },
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                ref.read(cartProvider.notifier).addProduct(product);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF10B981)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'ADD',
                                  style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailsSheet extends ConsumerWidget {
  final ProductModel product;
  final ScrollController scrollController;

  const _ProductDetailsSheet({required this.product, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final countInCart = cart.items[product.id]?.quantity ?? 0;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Top Notch line
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Large Product Image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            product.imageUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 220,
              color: const Color(0xFF1F2937),
              child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Product Title, Badge, and Price
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (product.isOrganic) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF047857),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Organic',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.unit,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                ),
                if (product.originalPrice != null)
                  Text(
                    '\$${product.originalPrice!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),
        const Divider(color: Color(0xFF1F2937)),
        const SizedBox(height: 8),

        // Description
        const Text(
          'Product Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          product.description ?? 'A high-quality fresh product curated specifically for FlashCart AI rapid 10-minute logistics.',
          style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
        ),

        const SizedBox(height: 16),
        const Divider(color: Color(0xFF1F2937)),
        const SizedBox(height: 8),

        // Intelligent AI Metrics (Carbon, Nutrition, Delivery Speed)
        const Text(
          'Intelligent AI Diagnostics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF10B981)),
        ),
        const SizedBox(height: 12),

        // Grid of Metrics
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _MetricTile(
              icon: Icons.energy_savings_leaf,
              title: 'Eco-Score: ${product.ecoScore}',
              subtitle: '${product.carbonEmissionKg}kg CO2 Emission',
              color: const Color(0xFF10B981),
            ),
            _MetricTile(
              icon: Icons.bolt,
              title: 'Logistics Range',
              subtitle: '${product.deliveryTimeMins} Mins Delivery',
              color: const Color(0xFF3B82F6),
            ),
            _MetricTile(
              icon: Icons.local_fire_department,
              title: 'Nutrition Index',
              subtitle: '${product.calories} Kcal',
              color: Colors.orange,
            ),
            _MetricTile(
              icon: Icons.fitness_center,
              title: 'Protein Density',
              subtitle: '${product.proteinG}g Protein',
              color: Colors.purple,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Action Adding Bar
        Row(
          children: [
            Expanded(
              child: countInCart > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              ref.read(cartProvider.notifier).removeProduct(product.id);
                            },
                          ),
                          Text(
                            '$countInCart items added',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              ref.read(cartProvider.notifier).addProduct(product);
                            },
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        ref.read(cartProvider.notifier).addProduct(product);
                      },
                      icon: const Icon(Icons.add_shopping_cart, color: Colors.black),
                      label: const Text('Add to Basket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
