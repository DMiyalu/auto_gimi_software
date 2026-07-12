/// Client d'un établissement (tenant SaaS).
class ClientEntity {
  const ClientEntity({
    required this.id,
    required this.name,
    required this.whatsappPhone,
    required this.loyaltyPoints,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String whatsappPhone;
  final int loyaltyPoints;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayPhone {
    if (whatsappPhone.startsWith('+')) return whatsappPhone;
    return '+$whatsappPhone';
  }
}
