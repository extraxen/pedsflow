import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/endocrine/insulin_math.dart';

void main() {
  group('ISPAD estimation rules', () {
    test('500/330/250 ICR estimates for known TDD', () {
      expect(InsulinMath.estimatedIcr(20), 25);
      expect(InsulinMath.estimatedIcr(20, rule: 330), 16.5);
      expect(InsulinMath.estimatedIcr(20, rule: 250), 12.5);
      expect(InsulinMath.estimatedIcr(20, rule: 100), isNull);
    });
    test('100-rule mmol/L sensitivity and mg/dL equivalent', () {
      expect(InsulinMath.estimatedIsf(20), 5);
      expect(InsulinMath.glucoseMgDl(5), closeTo(90.091, 0.001));
      expect(InsulinMath.glucoseMmolL(180.182), closeTo(10, 0.0001));
    });
    test('rejects absent zero negative infinite and extreme TDD', () {
      for (final tdd in <double?>[null, 0, -1, double.infinity, 501]) {
        expect(InsulinMath.estimatedIcr(tdd), isNull);
        expect(InsulinMath.estimatedIsf(tdd), isNull);
      }
    });
  });
  group('patient-specific arithmetic', () {
    test('carbs divided by individually prescribed ICR', () {
      expect(InsulinMath.mealUnits(
        carbohydrateGrams: 63,
        prescribedIcrGramsPerUnit: 12,
      ), closeTo(5.25, 0.00001));
    });
    test('corrects above target, never creates negative correction', () {
      expect(InsulinMath.correctionUnits(
        currentMmolL: 12,
        targetMmolL: 6,
        prescribedIsfMmolLPerUnit: 3,
      ), 2);
      expect(InsulinMath.correctionUnits(
        currentMmolL: 4,
        targetMmolL: 6,
        prescribedIsfMmolLPerUnit: 3,
      ), 0);
      expect(InsulinMath.correctionUnits(
        currentMmolL: 6,
        targetMmolL: 6,
        prescribedIsfMmolLPerUnit: 3,
      ), 0);
    });
    test('fails closed for invalid settings or glucose', () {
      expect(InsulinMath.mealUnits(
        carbohydrateGrams: 50,
        prescribedIcrGramsPerUnit: 0,
      ), isNull);
      expect(InsulinMath.mealUnits(
        carbohydrateGrams: -2,
        prescribedIcrGramsPerUnit: 10,
      ), isNull);
      expect(InsulinMath.correctionUnits(
        currentMmolL: 12,
        targetMmolL: 6,
        prescribedIsfMmolLPerUnit: 0,
      ), isNull);
      expect(InsulinMath.correctionUnits(
        currentMmolL: double.nan,
        targetMmolL: 6,
        prescribedIsfMmolLPerUnit: 3,
      ), isNull);
      expect(InsulinMath.correctionUnits(
        currentMmolL: 70,
        targetMmolL: 6,
        prescribedIsfMmolLPerUnit: 3,
      ), isNull);
    });
    test('device step illustration requires chosen increment', () {
      expect(InsulinMath.nearestIncrement(2.26, 0.5), 2.5);
      expect(InsulinMath.nearestIncrement(2.24, 0.1),
          closeTo(2.2, 0.000001));
      expect(InsulinMath.nearestIncrement(2.25, null), isNull);
      expect(InsulinMath.nearestIncrement(-2, 0.5), isNull);
    });
    test('clinician entered TDD and basal percentage arithmetic', () {
      expect(InsulinMath.basalFromApprovedPercentage(40, 45), 18);
      expect(InsulinMath.basalFromApprovedPercentage(40, 110), isNull);
    });
  });
}
