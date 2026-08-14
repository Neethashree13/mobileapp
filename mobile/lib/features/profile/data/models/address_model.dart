import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.title,
    required super.addressLine1,
    super.addressLine2,
    super.houseNo,
    super.apartment,
    super.street,
    super.landmark,
    required super.city,
    required super.state,
    super.country = 'India',
    required super.postalCode,
    required super.latitude,
    required super.longitude,
    super.isDefault = false,
    super.createdAt,
    super.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Home',
      addressLine1: json['addressLine1']?.toString() ?? json['address_line_1']?.toString() ?? '',
      addressLine2: json['addressLine2']?.toString() ?? json['address_line_2']?.toString(),
      houseNo: json['houseNo']?.toString(),
      apartment: json['apartment']?.toString(),
      street: json['street']?.toString(),
      landmark: json['landmark']?.toString(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? 'India',
      postalCode: json['postalCode']?.toString() ?? json['pincode']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 12.9279,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.6250,
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'houseNo': houseNo,
      'apartment': apartment,
      'street': street,
      'landmark': landmark,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      id: entity.id,
      title: entity.title,
      addressLine1: entity.addressLine1,
      addressLine2: entity.addressLine2,
      houseNo: entity.houseNo,
      apartment: entity.apartment,
      street: entity.street,
      landmark: entity.landmark,
      city: entity.city,
      state: entity.state,
      country: entity.country,
      postalCode: entity.postalCode,
      latitude: entity.latitude,
      longitude: entity.longitude,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
