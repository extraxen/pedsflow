import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/endocrine/di_math.dart';

void main() {
  test('urine output is urine mL divided by kg divided by hours', () {
    expect(DiMath.urineOutputMlKgHour(
      urineMl: 600, weightKg: 20, hours: 6,
    ), closeTo(5, 0.00001));
    expect(DiMath.polyuriaFlag(5, 6), isTrue);
    expect(DiMath.polyuriaFlag(5, 2), isFalse);
    expect(DiMath.polyuriaFlag(4, 6), isFalse);
  });
  test('rejects invalid or absent urine data', () {
    expect(DiMath.urineOutputMlKgHour(
      urineMl: 600, weightKg: 0, hours: 6,
    ), isNull);
    expect(DiMath.urineOutputMlKgHour(
      urineMl: 600, weightKg: 20, hours: 0,
    ), isNull);
    expect(DiMath.urineOutputMlKgHour(
      urineMl: -2, weightKg: 20, hours: 6,
    ), isNull);
    expect(DiMath.urineOutputMlKgHour(
      urineMl: null, weightKg: 20, hours: 6,
    ), isNull);
    expect(DiMath.urineOutputMlKgHour(
      urineMl: double.infinity, weightKg: 20, hours: 6,
    ), isNull);
  });
  test('sodium alerts include exact boundaries', () {
    expect(DiMath.sodiumHigh(146), isTrue);
    expect(DiMath.sodiumLow(134), isTrue);
    expect(DiMath.severeHypernatremia(170), isTrue);
    expect(DiMath.severeHypernatremia(169.9), isFalse);
    expect(DiMath.severeHypernatremia(double.nan), isFalse);
  });
  test('paired pattern flag is observation-only', () {
    expect(DiMath.hypotonicPolyuriaPattern(
      serumOsm: 321, urineOsm: 81, urineMlKgHour: 5,
      observationHours: 6,
    ), isTrue);
    expect(DiMath.hypotonicPolyuriaPattern(
      serumOsm: 321, urineOsm: 81, urineMlKgHour: null,
      observationHours: 6,
    ), isFalse);
  });
}
