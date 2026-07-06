import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:auto_mobile_software/app.dart';
import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/providers/database_provider.dart';
import 'package:auto_mobile_software/features/settings/presentation/providers/locale_provider.dart';
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

  testWidgets('App démarre avec le titre localisé', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const GarageApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Garage Manager'), findsOneWidget);
  });
}
