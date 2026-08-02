/// Type de client — segmentation simple utilisée sur l'écran Clients.
enum ClientType {
  individual('particulier'),
  business('entreprise');

  const ClientType(this.code);

  final String code;

  String get label => switch (this) {
        ClientType.individual => 'Particulier',
        ClientType.business => 'Entreprise',
      };

  static ClientType fromCode(String? code) {
    return ClientType.values.firstWhere(
      (t) => t.code == code,
      orElse: () => ClientType.individual,
    );
  }
}
