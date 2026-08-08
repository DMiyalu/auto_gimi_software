import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_role.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/user_profile.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/reporting/domain/repositories/restaurant_report_mail_repository.dart';
import 'package:auto_mobile_software/features/reporting/presentation/providers/restaurant_report_providers.dart';

class MockFirebaseUser extends Mock implements User {}

class _FakeMailRepo implements RestaurantReportMailRepository {
  String? lastKind;
  String? lastEstablishmentId;
  int calls = 0;

  @override
  Future<void> sendReport({
    required String establishmentId,
    required String kind,
  }) async {
    calls++;
    lastEstablishmentId = establishmentId;
    lastKind = kind;
  }
}

void main() {
  test('refuse l’envoi sans e-mail propriétaire', () async {
    final user = MockFirebaseUser();
    when(() => user.uid).thenReturn('uid-1');
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(user)),
        currentEstablishmentProvider.overrideWith(
          (ref) => Stream.value(
            Establishment(
              id: 'est-1',
              name: 'Resto',
              category: BusinessCategory.restaurant,
              ownerId: 'uid-1',
              managerName: 'Owner',
              phone: '2439',
              phoneVerified: true,
              createdAt: DateTime(2026, 1, 1),
            ),
          ),
        ),
        userProfileProvider.overrideWith(
          (ref) => Stream.value(
            UserProfile(
              uid: 'uid-1',
              phone: '2439',
              fullName: 'Owner',
              establishmentId: 'est-1',
              role: 'owner',
              phoneVerified: true,
              createdAt: DateTime(2026, 1, 1),
              establishmentIds: const ['est-1'],
              activeEstablishmentId: 'est-1',
              rolesByEstablishment: const {'est-1': 'owner'},
            ),
          ),
        ),
        activeEstablishmentRoleProvider.overrideWithValue(
          EstablishmentRole.owner,
        ),
        restaurantReportMailRepositoryProvider.overrideWithValue(
          _FakeMailRepo(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(currentEstablishmentProvider.future);
    await container.read(userProfileProvider.future);

    await container.read(sendRestaurantReportProvider.notifier).send(
      kind: 'weekly',
    );
    final state = container.read(sendRestaurantReportProvider);
    expect(state.hasError, isTrue);
    expect(
      state.error.toString(),
      contains('Ajoutez votre e-mail'),
    );
  });

  test('envoie le rapport hebdo quand l’e-mail est présent', () async {
    final user = MockFirebaseUser();
    when(() => user.uid).thenReturn('uid-1');
    final mail = _FakeMailRepo();
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(user)),
        currentEstablishmentProvider.overrideWith(
          (ref) => Stream.value(
            Establishment(
              id: 'est-1',
              name: 'Resto',
              category: BusinessCategory.restaurant,
              ownerId: 'uid-1',
              managerName: 'Owner',
              phone: '2439',
              phoneVerified: true,
              createdAt: DateTime(2026, 1, 1),
            ),
          ),
        ),
        userProfileProvider.overrideWith(
          (ref) => Stream.value(
            UserProfile(
              uid: 'uid-1',
              phone: '2439',
              fullName: 'Owner',
              email: 'owner@example.com',
              establishmentId: 'est-1',
              role: 'owner',
              phoneVerified: true,
              createdAt: DateTime(2026, 1, 1),
              establishmentIds: const ['est-1'],
              activeEstablishmentId: 'est-1',
              rolesByEstablishment: const {'est-1': 'owner'},
            ),
          ),
        ),
        activeEstablishmentRoleProvider.overrideWithValue(
          EstablishmentRole.owner,
        ),
        restaurantReportMailRepositoryProvider.overrideWithValue(mail),
      ],
    );
    addTearDown(container.dispose);

    await container.read(currentEstablishmentProvider.future);
    await container.read(userProfileProvider.future);

    await container.read(sendRestaurantReportProvider.notifier).send(
      kind: 'weekly',
    );
    final state = container.read(sendRestaurantReportProvider);
    expect(state.hasError, isFalse);
    expect(mail.calls, 1);
    expect(mail.lastKind, 'weekly');
    expect(mail.lastEstablishmentId, 'est-1');
  });
}
