// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.

class InfantFeedingTarget {
  final double minMlKgDay;
  final double maxMlKgDay;
  final String label;
  const InfantFeedingTarget(this.minMlKgDay, this.maxMlKgDay, this.label);
  double get midpoint => (minMlKgDay + maxMlKgDay) / 2;
}

class InfantFeedingEngine {
  static InfantFeedingTarget termTargetForDol(int dol) {
    if (dol <= 0) return const InfantFeedingTarget(60, 80, 'First 24 hours');
    if (dol == 1) return const InfantFeedingTarget(80, 100, 'Day of life 1');
    if (dol == 2) return const InfantFeedingTarget(100, 120, 'Day of life 2');
    if (dol == 3) return const InfantFeedingTarget(120, 140, 'Day of life 3');
    if (dol == 4) return const InfantFeedingTarget(140, 150, 'Day of life 4');
    return const InfantFeedingTarget(150, 150, 'Day of life 5+');
  }
  static double dailyVolume({required double weightKg, required double mlKgDay}) => weightKg * mlKgDay;
  static double volumePerFeed({required double weightKg, required double mlKgDay, required int feedsPerDay}) => dailyVolume(weightKg: weightKg, mlKgDay: mlKgDay) / feedsPerDay;
  static double kcalPerMl(double kcalPerOz) => kcalPerOz / 29.5735;
  static double kcalKgDay({required double mlKgDay, required double kcalPerOz}) => mlKgDay * kcalPerMl(kcalPerOz);
  static double mlKgDayFromCalories({required double targetKcalKgDay, required double kcalPerOz}) => targetKcalKgDay / kcalPerMl(kcalPerOz);
  static double percentWeightChange({required double birthWeightKg, required double currentWeightKg}) => (currentWeightKg - birthWeightKg) / birthWeightKg * 100;
}
