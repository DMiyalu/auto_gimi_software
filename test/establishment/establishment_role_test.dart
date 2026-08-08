import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/features/establishment/domain/models/establishment_role.dart';

void main() {
  test('un proprietaire peut inviter agent, gerant et proprietaire', () {
    expect(
      EstablishmentRole.owner.invitableRoles,
      [
        EstablishmentRole.agent,
        EstablishmentRole.manager,
        EstablishmentRole.owner,
      ],
    );
    expect(EstablishmentRole.owner.canInviteAs(EstablishmentRole.owner), isTrue);
  });

  test('un gerant peut inviter agent et gerant seulement', () {
    expect(
      EstablishmentRole.manager.invitableRoles,
      [EstablishmentRole.agent, EstablishmentRole.manager],
    );
    expect(
      EstablishmentRole.manager.canInviteAs(EstablishmentRole.owner),
      isFalse,
    );
  });

  test('un agent ne peut inviter personne', () {
    expect(EstablishmentRole.agent.invitableRoles, isEmpty);
  });
}
