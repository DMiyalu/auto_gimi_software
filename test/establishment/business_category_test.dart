import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/theme/app_colors.dart';
import 'package:auto_mobile_software/features/primary_module/config/business_module_configs.dart';

void main() {
  group('BusinessCategory', () {
    test('les nouvelles catégories se sérialisent pour Firestore', () {
      const expectedValues = {
        BusinessCategory.terraceBarLounge: 'terrace_bar_lounge',
        BusinessCategory.hairSalon: 'hair_salon',
        BusinessCategory.beautyInstitute: 'beauty_institute',
        BusinessCategory.clinicMedicalCenter: 'clinic_medical_center',
        BusinessCategory.hotelGuestHouse: 'hotel_guest_house',
      };

      for (final entry in expectedValues.entries) {
        expect(entry.key.firestoreValue, entry.value);
        expect(BusinessCategory.fromFirestore(entry.value), entry.key);
      }
    });

    test('toutes les catégories utilisent le même workflow UI Zuri', () {
      for (final category in BusinessCategory.values) {
        expect(category.usesRestaurantWorkflow, isTrue);
        expect(
          BusinessModuleConfigs.forCategory(category).primaryColor,
          AppColors.zuriRed,
        );
      }
    });

    test('mainActivity par défaut reflète la nature métier attendue', () {
      expect(BusinessCategory.restaurant.defaultMainActivity, 'Commandes');
      expect(
        BusinessCategory.terraceBarLounge.defaultMainActivity,
        'Commandes',
      );
      expect(BusinessCategory.garageAuto.defaultMainActivity, 'Prestations');
      expect(BusinessCategory.hotelGuestHouse.defaultMainActivity, 'Séjours');
      expect(BusinessCategory.pharmacy.defaultMainActivity, 'Activités');
    });
  });
}
