/// Rôle d'un utilisateur à l'intérieur d'un établissement.
enum EstablishmentRole {
  owner,
  manager,
  agent;

  String get firestoreValue => switch (this) {
    owner => 'owner',
    manager => 'manager',
    agent => 'agent',
  };

  String get label => switch (this) {
    owner => 'Propriétaire',
    manager => 'Gérant',
    agent => 'Agent',
  };

  bool get canInviteMembers => this == owner || this == manager;
  bool get canManageCatalog => this == owner || this == manager;
  bool get canConfigureEstablishment => this == owner || this == manager;
  bool get canCreateActivities => true;

  static EstablishmentRole fromFirestore(String? value) {
    return EstablishmentRole.values.firstWhere(
      (role) => role.firestoreValue == value,
      orElse: () => EstablishmentRole.agent,
    );
  }
}
