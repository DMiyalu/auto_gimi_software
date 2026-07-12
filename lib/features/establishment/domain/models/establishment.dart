import '../../../../core/domain/business_category.dart';

/// Établissement — unité d'isolation des données (tenant SaaS).
class Establishment {
  const Establishment({
    required this.id,
    required this.name,
    required this.category,
    required this.ownerId,
    required this.managerName,
    required this.phone,
    required this.phoneVerified,
    required this.createdAt,
  });

  final String id;
  final String name;
  final BusinessCategory category;
  final String ownerId;
  final String managerName;
  final String phone;
  final bool phoneVerified;
  final DateTime createdAt;
}
