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
}
