import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:auto_mobile_software/app.dart';
import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/providers/database_provider.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:auto_mobile_software/features/auth/presentation/providers/phone_verification_repository_provider.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_repository_provider.dart';
import 'package:auto_mobile_software/features/settings/presentation/providers/locale_provider.dart';
import 'helpers/fake_phone_verification_repository.dart';
import 'helpers/fake_repositories.dart';
import 'package:drift/native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('App démarre avec le titre ZOLANA', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final authRepository = FakeAuthRepository();
    final establishmentRepository = FakeEstablishmentRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepository),
          establishmentRepositoryProvider.overrideWithValue(
            establishmentRepository,
          ),
          phoneVerificationRepositoryProvider.overrideWithValue(
            FakePhoneVerificationRepository(),
          ),
        ],
        child: const GarageApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ZOLANA'), findsOneWidget);
  });
}
