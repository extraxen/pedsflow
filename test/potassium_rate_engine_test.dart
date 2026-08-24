import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/electrolytes/potassium_rate_engine.dart';

void main() {
  group('PotassiumRateEngine', () {
    test('calculates potassium delivery from a running IV bag', () {
      final PotassiumSourceResult result =
          PotassiumRateEngine.sourceFromBag(
        weightKg: 20,
        potassiumMmolInBag: 40,
        bagVolumeMl: 1000,
        rateMlPerHour: 50,
      );

      expect(result.concentrationMmolPerL, closeTo(40, 0.0001));
      expect(result.mmolPerHour, closeTo(2, 0.0001));
      expect(result.mmolPerKgHour, closeTo(0.1, 0.0001));
    });

    test('calculates patient-specific LHSC KCl limits', () {
      final PotassiumRateLimits limits =
          PotassiumRateEngine.limits(20);

      expect(limits.ecgThresholdMmolPerHour, closeTo(6, 0.0001));
      expect(limits.kclIntermittentMaxMmolPerHour, closeTo(10, 0.0001));
      expect(limits.allIvMaxMmolPerHour, closeTo(20, 0.0001));
      expect(
        limits.potassiumPhosphateMaxMmolPerHour,
        closeTo(3.8, 0.0001),
      );
    });

    test('applies absolute caps for a larger child', () {
      final PotassiumRateLimits limits =
          PotassiumRateEngine.limits(60);

      expect(limits.ecgThresholdMmolPerHour, closeTo(15, 0.0001));
      expect(limits.kclIntermittentMaxMmolPerHour, closeTo(20, 0.0001));
      expect(limits.allIvMaxMmolPerHour, closeTo(40, 0.0001));
    });

    test('converts potassium phosphate salt content', () {
      expect(
        PotassiumRateEngine.potassiumFromPhosphate(30),
        closeTo(44, 0.0001),
      );
      expect(
        PotassiumRateEngine.phosphateFromPotassium(44),
        closeTo(30, 0.0001),
      );
    });

    test('calculates replacement headroom with background potassium', () {
      final PotassiumRateLimits limits =
          PotassiumRateEngine.limits(20);

      final double maxKcl =
          PotassiumRateEngine.maxReplacementRateWithBackground(
        type: PotassiumReplacementType.kcl,
        limits: limits,
        backgroundMmolPerHour: 2,
      );

      expect(maxKcl, closeTo(10, 0.0001));
    });

    test('potassium phosphate product maximum can be limiting', () {
      final PotassiumRateLimits limits =
          PotassiumRateEngine.limits(10);

      final double maxKPhos =
          PotassiumRateEngine.maxReplacementRateWithBackground(
        type: PotassiumReplacementType.potassiumPhosphate,
        limits: limits,
        backgroundMmolPerHour: 0,
      );

      expect(maxKPhos, closeTo(1.9, 0.0001));
    });
  });
}
