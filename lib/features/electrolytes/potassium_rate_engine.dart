// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.

import 'dart:math' as math;

enum PotassiumReplacementType { kcl, potassiumPhosphate }
enum PotassiumPhosphateOrderBasis { potassium, phosphate }
enum IvAccess { peripheral, central }

class PotassiumSourceResult {
  final double concentrationMmolPerL;
  final double mmolPerHour;
  final double mmolPerKgHour;

  const PotassiumSourceResult({
    required this.concentrationMmolPerL,
    required this.mmolPerHour,
    required this.mmolPerKgHour,
  });
}

class PotassiumRateLimits {
  final double ecgThresholdMmolPerHour;
  final double kclIntermittentMaxMmolPerHour;
  final double allIvMaxMmolPerHour;
  final double potassiumPhosphateMaxMmolPerHour;

  const PotassiumRateLimits({
    required this.ecgThresholdMmolPerHour,
    required this.kclIntermittentMaxMmolPerHour,
    required this.allIvMaxMmolPerHour,
    required this.potassiumPhosphateMaxMmolPerHour,
  });
}

class PotassiumRateEngine {
  const PotassiumRateEngine._();

  /// Exact potassium delivery from a bag:
  /// (mmol in bag / mL in bag) * mL/hr.
  static PotassiumSourceResult sourceFromBag({
    required double weightKg,
    required double potassiumMmolInBag,
    required double bagVolumeMl,
    required double rateMlPerHour,
  }) {
    if (weightKg <= 0 || bagVolumeMl <= 0) {
      return const PotassiumSourceResult(
        concentrationMmolPerL: 0,
        mmolPerHour: 0,
        mmolPerKgHour: 0,
      );
    }

    final double concentrationMmolPerL =
        _nonNegative(potassiumMmolInBag) * 1000 / bagVolumeMl;
    final double mmolPerHour =
        concentrationMmolPerL * _nonNegative(rateMlPerHour) / 1000;

    return PotassiumSourceResult(
      concentrationMmolPerL: concentrationMmolPerL,
      mmolPerHour: mmolPerHour,
      mmolPerKgHour: mmolPerHour / weightKg,
    );
  }

  static PotassiumRateLimits limits(double weightKg) {
    final double w = math.max(0, weightKg).toDouble();
    return PotassiumRateLimits(
      // LHSC KCl pediatric PDAM:
      // ECG required above 0.3 mmol/kg/hr OR 15 mmol/hr, whichever is less.
      ecgThresholdMmolPerHour: math.min(0.3 * w, 15).toDouble(),

      // LHSC KCl pediatric intermittent maximum:
      // 0.5 mmol/kg/hr OR 20 mmol/hr, whichever is less.
      kclIntermittentMaxMmolPerHour:
          math.min(0.5 * w, 20).toDouble(),

      // LHSC KCl pediatric maximum from ALL IV potassium sources:
      // 1 mmol/kg/hr OR 40 mmol/hr, whichever is less.
      allIvMaxMmolPerHour: math.min(1.0 * w, 40).toDouble(),

      // LHSC potassium-phosphate pediatric maximum, based on K content:
      // 0.19 mmol potassium/kg/hr.
      potassiumPhosphateMaxMmolPerHour: 0.19 * w,
    );
  }

  /// LHSC potassium phosphate examples use approximately:
  /// 30 mmol phosphate = 44 mmol potassium.
  static double potassiumFromPhosphate(double phosphateMmol) =>
      _nonNegative(phosphateMmol) * 44 / 30;

  static double phosphateFromPotassium(double potassiumMmol) =>
      _nonNegative(potassiumMmol) * 30 / 44;

  static double replacementPotassiumMmol({
    required PotassiumReplacementType type,
    required double orderedMmol,
    PotassiumPhosphateOrderBasis phosphateBasis =
        PotassiumPhosphateOrderBasis.potassium,
  }) {
    if (type == PotassiumReplacementType.kcl) {
      return _nonNegative(orderedMmol);
    }
    return phosphateBasis == PotassiumPhosphateOrderBasis.potassium
        ? _nonNegative(orderedMmol)
        : potassiumFromPhosphate(orderedMmol);
  }

  static double replacementPhosphateMmol({
    required PotassiumReplacementType type,
    required double orderedMmol,
    PotassiumPhosphateOrderBasis phosphateBasis =
        PotassiumPhosphateOrderBasis.potassium,
  }) {
    if (type == PotassiumReplacementType.kcl) return 0;
    return phosphateBasis == PotassiumPhosphateOrderBasis.phosphate
        ? _nonNegative(orderedMmol)
        : phosphateFromPotassium(orderedMmol);
  }

  static double intermittentConcentrationMmolPerMl({
    required double potassiumMmol,
    required double finalVolumeMl,
  }) {
    if (finalVolumeMl <= 0) return 0;
    return _nonNegative(potassiumMmol) / finalVolumeMl;
  }

  static double productMaxRateMmolPerHour({
    required PotassiumReplacementType type,
    required PotassiumRateLimits limits,
  }) =>
      type == PotassiumReplacementType.kcl
          ? limits.kclIntermittentMaxMmolPerHour
          : limits.potassiumPhosphateMaxMmolPerHour;

  static double maxReplacementRateWithBackground({
    required PotassiumReplacementType type,
    required PotassiumRateLimits limits,
    required double backgroundMmolPerHour,
  }) {
    final double allIvHeadroom =
        math.max(0, limits.allIvMaxMmolPerHour - backgroundMmolPerHour)
            .toDouble();
    return math.min(
      productMaxRateMmolPerHour(type: type, limits: limits),
      allIvHeadroom,
    ).toDouble();
  }

  static double _nonNegative(double value) => value < 0 ? 0 : value;
}
