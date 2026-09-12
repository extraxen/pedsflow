// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.

import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/services/medication_dose_calculator.dart';

void main() {
  group('calculateMedicationDose', () {
    test('calculates a single mg/kg/dose rule', () {
      final MedicationDoseCalculation? result = calculateMedicationDose(
        text: 'Give 10 mg/kg/dose IV every 6 hours.',
        weightKg: 18,
      );
      expect(result, isNotNull);
      expect(result!.formattedDose, '180 mg/dose');
      expect(result.sourceRule, '10 mg/kg/dose');
    });

    test('calculates a dose range', () {
      final MedicationDoseCalculation? result = calculateMedicationDose(
        text: 'Use 10–15 mg/kg/dose PO.',
        weightKg: 20,
      );
      expect(result, isNotNull);
      expect(result!.formattedDose, '200–300 mg/dose');
    });

    test('normalizes microgram units', () {
      final MedicationDoseCalculation? result = calculateMedicationDose(
        text: '5 mcg/kg/dose IV.',
        weightKg: 12,
      );
      expect(result, isNotNull);
      expect(result!.formattedDose, '60 mcg/dose');
    });

    test('calculates a daily rule without presenting it as a dose', () {
      final MedicationDoseCalculation? result = calculateMedicationDose(
        text: '30 mg/kg/day divided every 8 hours.',
        weightKg: 10,
      );
      expect(result, isNotNull);
      expect(result!.formattedDose, '300 mg/day');
    });

    test('does not choose between competing regimens', () {
      final MedicationDoseCalculation? result = calculateMedicationDose(
        text: 'Mild: 10 mg/kg/dose. Severe: 20 mg/kg/dose.',
        weightKg: 20,
      );
      expect(result, isNull);
    });

    test('ignores non-weight-based text', () {
      expect(
        calculateMedicationDose(
          text: 'Give 250 mg PO every 8 hours.',
          weightKg: 20,
        ),
        isNull,
      );
    });
  });
}
