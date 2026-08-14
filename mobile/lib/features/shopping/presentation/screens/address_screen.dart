import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/shopping_providers.dart';
import '../../../profile/presentation/providers/user_profile_providers.dart';
import '../../../profile/domain/entities/address_entity.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(userAddressesProvider);
    final isDark = ref.watch(settingsProvider).isDarkMode;
    final addresses = addressState.addresses;

    return Theme(
      data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          actions: [
            if (addressState.isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                ),
              )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.read(userAddressesProvider.notifier).loadAddresses(),
          color: const Color(0xFF10B981),
          child: Column(
            children: [
              // 1. Map Placeholder Card with Reverse Geocoding
              _buildInteractiveMapPlaceholder(isDark),

              // 2. Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SAVED LOCATIONS (${addresses.length})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 0.8,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add_location_alt_rounded, size: 16, color: Color(0xFF10B981)),
                      label: const Text('ADD NEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                      onPressed: () => _showAddEditAddressBottomSheet(context, null),
                    ),
                  ],
                ),
              ),

              // 3. Address list
              Expanded(
                child: addresses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off_rounded, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const Text('No Saved Addresses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Add delivery addresses for 10-minute instant checkout', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('ADD ADDRESS'),
                              onPressed: () => _showAddEditAddressBottomSheet(context, null),
                            )
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return _buildAddressCard(address, isDark);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveMapPlaceholder(bool isDark) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.my_location_rounded, size: 36, color: Color(0xFF10B981)),
                const SizedBox(height: 8),
                const Text('GPS Auto-Geocoding Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Detect current position & auto-fill address details', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.gps_fixed_rounded, size: 16),
                  label: const Text('DETECT CURRENT LOCATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Detecting location via GPS...'), duration: Duration(seconds: 1)),
                    );
                    final geocoded = await ref.read(userAddressesProvider.notifier).reverseGeocode(12.9279, 77.6250);
                    if (geocoded != null && mounted) {
                      _showAddEditAddressBottomSheet(context, geocoded);
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressEntity address, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: address.isDefault ? const Color(0xFF10B981) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                address.type == AddressType.home
                    ? Icons.home_rounded
                    : (address.type == AddressType.work ? Icons.business_rounded : Icons.location_on_rounded),
                color: const Color(0xFF10B981),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                address.title.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('DEFAULT', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                onPressed: () => _showAddEditAddressBottomSheet(context, address),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                onPressed: () async {
                  await ref.read(userAddressesProvider.notifier).deleteAddress(address.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address deleted'), backgroundColor: Colors.redAccent),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${address.addressLine1}${address.addressLine2 != null && address.addressLine2!.isNotEmpty ? ', ' + address.addressLine2! : ''}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            '${address.city}, ${address.state} - ${address.postalCode}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          if (!address.isDefault) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF10B981)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  ref.read(userAddressesProvider.notifier).setDefaultAddress(address.id);
                },
                child: const Text('SET AS DEFAULT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ),
            ),
          ]
        ],
      ),
    );
  }

  void _showAddEditAddressBottomSheet(BuildContext context, AddressEntity? address) {
    final isEdit = address != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleController = TextEditingController(text: address?.title ?? 'Home');
    final line1Controller = TextEditingController(text: address?.addressLine1 ?? '');
    final line2Controller = TextEditingController(text: address?.addressLine2 ?? '');
    final cityController = TextEditingController(text: address?.city ?? 'Bengaluru');
    final stateController = TextEditingController(text: address?.state ?? 'Karnataka');
    final postalController = TextEditingController(text: address?.postalCode ?? '560102');
    bool isDefault = address?.isDefault ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEdit ? 'Edit Address' : 'Add New Address',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: ['Home', 'Work', 'Other'].map((type) {
                        final selected = titleController.text.toLowerCase() == type.toLowerCase();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(type),
                            selected: selected,
                            selectedColor: const Color(0xFF10B981),
                            onSelected: (val) {
                              if (val) setModalState(() => titleController.text = type);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: line1Controller,
                      decoration: const InputDecoration(labelText: 'House / Flat / Street Name *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: line2Controller,
                      decoration: const InputDecoration(labelText: 'Apartment / Landmark / Area', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cityController,
                            decoration: const InputDecoration(labelText: 'City *', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: stateController,
                            decoration: const InputDecoration(labelText: 'State *', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: postalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Pincode / Postal Code *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),

                    SwitchListTile.adaptive(
                      title: const Text('Set as default delivery address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      value: isDefault,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (val) => setModalState(() => isDefault = val),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (line1Controller.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Address Line 1 is required')),
                          );
                          return;
                        }

                        final newAddr = AddressEntity(
                          id: address?.id ?? '',
                          title: titleController.text.trim(),
                          addressLine1: line1Controller.text.trim(),
                          addressLine2: line2Controller.text.trim(),
                          city: cityController.text.trim(),
                          state: stateController.text.trim(),
                          postalCode: postalController.text.trim(),
                          latitude: address?.latitude ?? 12.9279,
                          longitude: address?.longitude ?? 77.6250,
                          isDefault: isDefault,
                        );

                        Navigator.pop(ctx);

                        if (isEdit) {
                          await ref.read(userAddressesProvider.notifier).updateAddress(address.id, newAddr);
                        } else {
                          await ref.read(userAddressesProvider.notifier).addAddress(newAddr);
                        }

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEdit ? 'Address updated!' : 'Address added!'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                      child: Text(
                        isEdit ? 'SAVE CHANGES' : 'ADD ADDRESS',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
