enum AddressType { home, work, other }

class AddressEntity {
  final String id;
  final String title;
  final String addressLine1;
  final String? addressLine2;
  final String? houseNo;
  final String? apartment;
  final String? street;
  final String? landmark;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String? createdAt;
  final String? updatedAt;

  const AddressEntity({
    required this.id,
    required this.title,
    required this.addressLine1,
    this.addressLine2,
    this.houseNo,
    this.apartment,
    this.street,
    this.landmark,
    required this.city,
    required this.state,
    this.country = 'India',
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  AddressType get type {
    final lower = title.toLowerCase();
    if (lower.contains('home')) return AddressType.home;
    if (lower.contains('work') || lower.contains('office')) return AddressType.work;
    return AddressType.other;
  }

  AddressEntity copyWith({
    String? id,
    String? title,
    String? addressLine1,
    String? addressLine2,
    String? houseNo,
    String? apartment,
    String? street,
    String? landmark,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
    String? createdAt,
    String? updatedAt,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      houseNo: houseNo ?? this.houseNo,
      apartment: apartment ?? this.apartment,
      street: street ?? this.street,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
