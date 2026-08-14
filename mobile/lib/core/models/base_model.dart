/// Base Domain Model contract with UUID, Timestamps and Soft Delete support.
import 'package:meta/meta.dart';

@immutable
abstract class BaseDomainModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;

  const BaseDomainModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  Map<String, dynamic> toJson();

  List<String> validate();

  bool get isValid => validate().isEmpty;

  static DateTime parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  static String formatDateTime(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
