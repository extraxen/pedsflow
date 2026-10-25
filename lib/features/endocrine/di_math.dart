// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
class DiMath {
  const DiMath._();

  /// Observed urine volume over an actual recorded time interval.
  /// Returns mL/kg/h; deliberately no inference about diagnosis or fluids.
  static double? urineOutputMlKgHour({
    required double? urineMl,
    required double? weightKg,
    required double? hours,
  }) {
    if (urineMl == null || !urineMl.isFinite || urineMl < 0 ||
        urineMl > 100000 ||
        weightKg == null || !weightKg.isFinite ||
        weightKg <= 0 || weightKg > 300 ||
        hours == null || !hours.isFinite || hours <= 0 || hours > 168) {
      return null;
    }
    return urineMl / weightKg / hours;
  }

  /// Flags for review, not diagnostic criteria or treatment triggers.
  /// RCH CPG describes >4 mL/kg/h averaged across six hours in children;
  /// infant/neonatal cut-offs must be discussed with specialists.
  static bool polyuriaFlag(double? mlKgHour, double? observedHours) =>
      mlKgHour != null && mlKgHour.isFinite && mlKgHour > 4 &&
      observedHours != null && observedHours >= 6;

  static bool sodiumHigh(double? sodiumMmolL) =>
      sodiumMmolL != null && sodiumMmolL.isFinite &&
      sodiumMmolL > 145 && sodiumMmolL <= 220;

  static bool sodiumLow(double? sodiumMmolL) =>
      sodiumMmolL != null && sodiumMmolL.isFinite &&
      sodiumMmolL < 135 && sodiumMmolL >= 80;

  static bool severeHypernatremia(double? sodiumMmolL) =>
      sodiumMmolL != null && sodiumMmolL.isFinite &&
      sodiumMmolL >= 170 && sodiumMmolL <= 220;

  /// Observed lab pattern only; DI subtype cannot be determined from this.
  static bool hypotonicPolyuriaPattern({
    required double? serumOsm,
    required double? urineOsm,
    required double? urineMlKgHour,
    required double? observationHours,
  }) =>
      serumOsm != null && serumOsm.isFinite && serumOsm > 300 &&
      urineOsm != null && urineOsm.isFinite && urineOsm < 300 &&
      polyuriaFlag(urineMlKgHour, observationHours);
}
