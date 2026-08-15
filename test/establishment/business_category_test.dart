import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/domain/business_category.dart';

void main() {
  group('BusinessCategory', () {
    test('les nouvelles catégories se sérialisent pour Firestore', () {
      const expectedValues = {
        BusinessCategory.terraceBarLounge: 'terrace_bar_lounge',
        BusinessCategory.hairSalon: 'hair_salon',
        BusinessCategory.beautyInstitute: 'beauty_institute',
        BusinessCategory.clinicMedicalCenter: 'clinic_medical_center',
      };

      for (final entry in expectedValues.entries) {
        expect(entry.key.firestoreValue, entry.value);
        expect(BusinessCategory.fromFirestore(entry.value), entry.key);
      }
    });

    test('les nouvelles catégories utilisent le workflow commandes', () {
      expect(BusinessCategory.terraceBarLounge.usesRestaurantWorkflow, isTrue);
      expect(BusinessCategory.hairSalon.usesRestaurantWorkflow, isTrue);
      expect(BusinessCategory.beautyInstitute.usesRestaurantWorkflow, isTrue);
      expect(
        BusinessCategory.clinicMedicalCenter.usesRestaurantWorkflow,
        isTrue,
      );
    });
  });
}
