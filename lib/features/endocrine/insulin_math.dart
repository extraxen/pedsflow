// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
//
// Pure educational calculation helpers. Not an insulin prescribing engine.
class InsulinMath {
  const InsulinMath._();

  static bool _valid(double? n, double min, double max) =>
      n != null && n.isFinite && n >= min && n <= max;

  /// ISPAD 2024 Chapter 9, pp. 596-597: 500/TDD; alternative 330 or
  /// 250/TDD may be considered in preschool children. All are estimates.
  static double? estimatedIcr(double? totalDailyUnits, {int rule = 500}) {
    if (!_valid(totalDailyUnits, 0.01, 500) ||
        !const [500, 330, 250].contains(rule)) {
      return null;
    }
    return rule / totalDailyUnits!;
  }

  /// ISPAD 2024 Chapter 9 p. 597: 100/TDD, mmol/L fall per unit of
  /// rapid-acting insulin. It is only a starting estimate.
  static double? estimatedIsf(double? totalDailyUnits) {
    if (!_valid(totalDailyUnits, 0.01, 500)) return null;
    return 100 / totalDailyUnits!;
  }

  static double? glucoseMgDl(double? glucoseMmolL) {
    if (!_valid(glucoseMmolL, 0, 100)) return null;
    return glucoseMmolL! * 18.0182;
  }

  static double? glucoseMmolL(double? glucoseMgDl) {
    if (!_valid(glucoseMgDl, 0, 1801.82)) return null;
    return glucoseMgDl! / 18.0182;
  }

  /// Uses a patient-specific established ICR, not an estimated ICR.
  /// Result is unrounded units, NOT an instruction to administer.
  static double? mealUnits({
    required double? carbohydrateGrams,
    required double? prescribedIcrGramsPerUnit,
  }) {
    if (!_valid(carbohydrateGrams, 0, 500) ||
        !_valid(prescribedIcrGramsPerUnit, 0.1, 500)) {
      return null;
    }
    return carbohydrateGrams! / prescribedIcrGramsPerUnit!;
  }

  /// Uses a patient-specific established ISF. Never returns a negative
  /// insulin correction; BG below target requires a separate clinical plan.
  /// Does NOT account for active insulin/IOB or pump algorithm behavior.
  static double? correctionUnits({
    required double? currentMmolL,
    required double? targetMmolL,
    required double? prescribedIsfMmolLPerUnit,
  }) {
    if (!_valid(currentMmolL, 0, 60) ||
        !_valid(targetMmolL, 2, 20) ||
        !_valid(prescribedIsfMmolLPerUnit, 0.1, 40)) {
      return null;
    }
    if (currentMmolL! <= targetMmolL!) return 0;
    return (currentMmolL - targetMmolL) / prescribedIsfMmolLPerUnit!;
  }

  /// A mathematical device-resolution illustration, not a dosing rule.
  /// Requires the clinician to select the actual supported increment.
  static double? nearestIncrement(double? units, double? increment) {
    if (!_valid(units, 0, 100) ||
        increment == null ||
        !const [1.0, 0.5, 0.1, 0.05].contains(increment)) {
      return null;
    }
    return (units! / increment).round() * increment;
  }

  /// Arithmetic only; no recommended basal percentage is implied.
  static double? basalFromApprovedPercentage(
    double? prescribedTotalDailyUnits,
    double? clinicianSelectedPercent,
  ) {
    if (!_valid(prescribedTotalDailyUnits, 0.01, 500) ||
        !_valid(clinicianSelectedPercent, 0, 100)) return null;
    return prescribedTotalDailyUnits! * clinicianSelectedPercent! / 100;
  }
}
