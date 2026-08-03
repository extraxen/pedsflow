import 'package:flutter_test/flutter_test.dart';

import 'package:pediatric_night_companion/features/dka/dka_engine.dart';

void main() {
  group('DkaEngine', () {
    test('calculates the reference 30 kg example', () {
      final result = DkaEngine.calculate(
        const DkaInputs(
          ageYears: 8,
          weightKg: 30,
          glucose: 17,
          previousGlucose: 23,
          ph: 7.18,
          bicarbonate: 8,
          sodium: 131,
          chloride: 98,
          potassium: 4.7,
          betaHydroxybutyrate: 4.2,
          bagBConcentration: 12.5,
          desiredDextrose: 5,
          insulinUnitsPerKgHour: 0.05,
        ),
      );

      expect(result.diagnosis, DkaDiagnosis.criteriaMet);
      expect(result.severity, DkaSeverity.moderate);
      expect(result.correctedSodium, closeTo(134.6, 0.001));
      expect(result.anionGap, closeTo(25, 0.001));
      expect(result.effectiveOsmolality, closeTo(279, 0.001));
      expect(result.glucoseFallPerHour, closeTo(6, 0.001));
      expect(result.initialBolusMl, closeTo(300, 0.001));
      expect(result.cpsFluid.rateMlHour, closeTo(150, 0.001));
      expect(result.selectedInsulinUnitsHour, closeTo(1.5, 0.001));
      expect(result.bagARateMlHour, closeTo(90, 0.001));
      expect(result.bagBRateMlHour, closeTo(60, 0.001));
    });

    test('uses all CPS weight bands and the 250 mL/h cap', () {
      expect(DkaEngine.cpsHourlyRate(5).rateMlHour, 32.5);
      expect(DkaEngine.cpsHourlyRate(10).rateMlHour, 60);
      expect(DkaEngine.cpsHourlyRate(20).rateMlHour, 100);
      expect(DkaEngine.cpsHourlyRate(40).rateMlHour, 160);
      expect(DkaEngine.cpsHourlyRate(100).rateMlHour, 250);
      expect(DkaEngine.cpsHourlyRate(4.9).rateMlHour, isNull);
    });

    test('requires the biochemical triad and anion gap', () {
      final incomplete = DkaEngine.calculate(
        const DkaInputs(weightKg: 25, glucose: 18, ph: 7.15),
      );
      expect(incomplete.diagnosis, DkaDiagnosis.incomplete);

      final triadWithoutGap = DkaEngine.calculate(
        const DkaInputs(
          weightKg: 25,
          glucose: 18,
          ph: 7.15,
          betaHydroxybutyrate: 4,
        ),
      );
      expect(triadWithoutGap.diagnosis, DkaDiagnosis.triadMetGapUnavailable);

      final notDka = DkaEngine.calculate(
        const DkaInputs(
          weightKg: 25,
          glucose: 18,
          ph: 7.35,
          bicarbonate: 22,
          betaHydroxybutyrate: 4,
          sodium: 135,
          chloride: 100,
        ),
      );
      expect(notDka.diagnosis, DkaDiagnosis.notFullyMet);
    });

    test('holds insulin at potassium 3.0 or lower', () {
      final atThree = DkaEngine.calculate(
        const DkaInputs(weightKg: 20, glucose: 18, potassium: 3),
      );
      final aboveThree = DkaEngine.calculate(
        const DkaInputs(weightKg: 20, glucose: 18, potassium: 3.1),
      );
      expect(atThree.holdInsulin, isTrue);
      expect(atThree.selectedInsulinUnitsHour, isNull);
      expect(aboveThree.holdInsulin, isFalse);
      expect(aboveThree.selectedInsulinUnitsHour, closeTo(1, 0.001));
    });

    test('grades severity using the worse pH or bicarbonate category', () {
      expect(DkaEngine.severity(7.25, 12), DkaSeverity.mild);
      expect(DkaEngine.severity(7.15, 8), DkaSeverity.moderate);
      expect(DkaEngine.severity(7.2, 4), DkaSeverity.severe);
      expect(DkaEngine.severity(null, null), DkaSeverity.notGradeable);
    });

    test('flags possible hyperosmolar physiology', () {
      final result = DkaEngine.calculate(
        const DkaInputs(weightKg: 60, glucose: 40, sodium: 141, potassium: 4),
      );
      expect(result.effectiveOsmolality, closeTo(322, 0.001));
      expect(result.possibleHhs, isTrue);
    });

    test('calculates cerebral injury doses with caps', () {
      final result = DkaEngine.calculate(
        const DkaInputs(weightKg: 60, glucose: 18, potassium: 4),
      );
      expect(result.hypertonicSaline3PercentMl, 250);
      expect(result.mannitolLowG, 30);
      expect(result.mannitolHighG, 60);
      expect(result.mannitol20PercentLowMl, 150);
      expect(result.mannitol20PercentHighMl, 300);
    });
  });
}
