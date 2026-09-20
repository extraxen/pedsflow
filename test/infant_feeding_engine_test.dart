import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/neonatal/infant_feeding_engine.dart';

void main() {
  test('term DOL progression is correct', () {
    expect(InfantFeedingEngine.termTargetForDol(0).minMlKgDay, 60);
    expect(InfantFeedingEngine.termTargetForDol(1).midpoint, 90);
    expect(InfantFeedingEngine.termTargetForDol(2).midpoint, 110);
    expect(InfantFeedingEngine.termTargetForDol(3).midpoint, 130);
    expect(InfantFeedingEngine.termTargetForDol(4).midpoint, 145);
    expect(InfantFeedingEngine.termTargetForDol(5).midpoint, 150);
    expect(InfantFeedingEngine.termTargetForDol(17).midpoint, 150);
  });
  test('volume calculations', () {
    expect(InfantFeedingEngine.dailyVolume(weightKg: 3.2, mlKgDay: 130), closeTo(416, 0.001));
    expect(InfantFeedingEngine.volumePerFeed(weightKg: 3.2, mlKgDay: 130, feedsPerDay: 8), closeTo(52, 0.001));
  });
  test('150 mL/kg/day of 20 kcal/oz is about 101 kcal/kg/day', () {
    expect(InfantFeedingEngine.kcalKgDay(mlKgDay: 150, kcalPerOz: 20), closeTo(101.44, 0.1));
  });
  test('reverse calorie calculation', () {
    expect(InfantFeedingEngine.mlKgDayFromCalories(targetKcalKgDay: 100, kcalPerOz: 20), closeTo(147.87, 0.1));
  });
  test('weight change calculation', () {
    expect(InfantFeedingEngine.percentWeightChange(birthWeightKg: 3.3, currentWeightKg: 3.0), closeTo(-9.09, 0.1));
  });
  test('2023 DRI male infant EER equation', () {
    final eer = InfantFeedingEngine.eerKcalDay(
      ageDays: 30, heightCm: 56.5, weightKg: 5.0, sex: InfantSex.male);
    expect(eer, closeTo(565.6, 1.0));
    expect(InfantFeedingEngine.eerKcalKgDay(
      ageDays: 30, heightCm: 56.5, weightKg: 5.0, sex: InfantSex.male),
      closeTo(113.1, 0.5));
  });
  test('2023 DRI female infant EER equation', () {
    final eer = InfantFeedingEngine.eerKcalDay(
      ageDays: 30, heightCm: 55.9, weightKg: 4.9, sex: InfantSex.female);
    expect(eer, closeTo(530.7, 1.0));
  });
  test('age calorie reference bands and comparison', () {
    final oneMonth = InfantFeedingEngine.calorieReferenceForAgeDays(30)!;
    expect(oneMonth.minMlKgDay, 100);
    expect(oneMonth.maxMlKgDay, 110);
    expect(InfantFeedingEngine.calorieReferenceStatus(kcalKgDay: 105, reference: oneMonth), 'Within typical reference');
    expect(InfantFeedingEngine.calorieReferenceStatus(kcalKgDay: 90, reference: oneMonth), 'Below typical reference');
    expect(InfantFeedingEngine.calorieReferenceForAgeDays(365), isNull);
  });
}

