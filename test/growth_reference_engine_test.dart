import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/growth/growth_reference_engine.dart';

void main() {
  test('WHO boys 12 month median weight is z 0 and 50th percentile', () {
    final result = GrowthReferenceEngine.assess(
      metric: GrowthMetric.weight,
      sex: GrowthSex.male,
      ageMonths: 12,
      value: 9.6479,
    );
    expect(result, isNotNull);
    expect(result!.zScore, closeTo(0, 1e-9));
    expect(result.percentile, closeTo(50, 0.01));
  });

  test('WHO girls 12 month median length is z 0', () {
    final result = GrowthReferenceEngine.assess(
      metric: GrowthMetric.lengthHeight,
      sex: GrowthSex.female,
      ageMonths: 12,
      value: 74.015,
    );
    expect(result, isNotNull);
    expect(result!.zScore, closeTo(0, 1e-9));
  });

  test('CDC boys 24 month median weight is z 0', () {
    final result = GrowthReferenceEngine.assess(
      metric: GrowthMetric.weight,
      sex: GrowthSex.male,
      ageMonths: 24,
      value: 12.67076,
    );
    expect(result, isNotNull);
    expect(result!.zScore, closeTo(0, 1e-9));
  });

  test('CDC boys 24 month 5th percentile is about 10.64 kg', () {
    final lms = GrowthReferenceEngine.lmsAt(
      metric: GrowthMetric.weight,
      sex: GrowthSex.male,
      ageMonths: 24,
    );
    expect(lms, isNotNull);

    final value = GrowthReferenceEngine.valueAtZ(
      z: -1.6448536269514729,
      l: lms!.l,
      m: lms.m,
      s: lms.s,
    );

    expect(value, closeTo(10.64, 0.01));

    final roundTripZ = GrowthReferenceEngine.zScore(
      x: value,
      l: lms.l,
      m: lms.m,
      s: lms.s,
    );
    expect(roundTripZ, closeTo(-1.6448536269514729, 1e-9));
  });

  test('unsupported age over 5 years returns null', () {
    final result = GrowthReferenceEngine.assess(
      metric: GrowthMetric.weight,
      sex: GrowthSex.male,
      ageMonths: 72,
      value: 22,
    );
    expect(result, isNull);
  });

  test('curve contains published median point', () {
    final curve = GrowthReferenceEngine.curve(
      metric: GrowthMetric.weight,
      sex: GrowthSex.male,
      z: 0,
      maxAgeMonths: 12,
    );
    final twelve = curve.firstWhere((point) => point.ageMonths == 12);
    expect(twelve.value, closeTo(9.6479, 1e-6));
  });
}
