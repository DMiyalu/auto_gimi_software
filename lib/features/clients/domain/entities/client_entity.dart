import '../../../../core/domain/client_type.dart';

/// Client d'un établissement (tenant SaaS).
class ClientEntity {
  const ClientEntity({
    required this.id,
    required this.name,
    required this.whatsappPhone,
    required this.loyaltyPoints,
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.address,
    this.clientType = ClientType.individual,
    this.notes,
  });

  final String id;
  final String name;
  final String whatsappPhone;
  final int loyaltyPoints;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? email;
  final String? address;
  final ClientType clientType;
  final String? notes;

  String get displayPhone {
    if (whatsappPhone.startsWith('+')) return whatsappPhone;
    return '+$whatsappPhone';
  }
}
