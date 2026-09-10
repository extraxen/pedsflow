// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.

import 'dart:math' as math;

enum EcgPolarity { positive, negative, equiphasic }

enum EcgAxisQuadrant {
  normalOrRightward,
  leftward,
  rightward,
  extreme,
  indeterminate,
}

class EcgAxisResult {
  final EcgAxisQuadrant quadrant;
  final String label;
  final String range;
  final String guidance;

  const EcgAxisResult({
    required this.quadrant,
    required this.label,
    required this.range,
    required this.guidance,
  });
}

EcgAxisResult classifyAxis(EcgPolarity leadI, EcgPolarity leadAvf) {
  if (leadI == EcgPolarity.equiphasic ||
      leadAvf == EcgPolarity.equiphasic) {
    return const EcgAxisResult(
      quadrant: EcgAxisQuadrant.indeterminate,
      label: 'Refine with the most equiphasic limb lead',
      range: 'Axis is approximately perpendicular to that lead',
      guidance:
          'Choose the perpendicular direction that points toward the predominantly positive limb leads. Compare the final degree with the child’s age-specific range.',
    );
  }

  if (leadI == EcgPolarity.positive && leadAvf == EcgPolarity.positive) {
    return const EcgAxisResult(
      quadrant: EcgAxisQuadrant.normalOrRightward,
      label: 'Positive quadrant',
      range: 'Approximately 0° to +90°',
      guidance:
          'Usually normal after infancy. A rightward axis may still be physiological in neonates and young infants; use the age-specific reference.',
    );
  }
  if (leadI == EcgPolarity.positive && leadAvf == EcgPolarity.negative) {
    return const EcgAxisResult(
      quadrant: EcgAxisQuadrant.leftward,
      label: 'Leftward quadrant',
      range: 'Approximately 0° to −90°',
      guidance:
          'Check lead II: positive suggests 0° to −30°; negative suggests left-axis deviation (−30° to −90°). Marked left axis can occur with AV septal defect or conduction disease.',
    );
  }
  if (leadI == EcgPolarity.negative && leadAvf == EcgPolarity.positive) {
    return const EcgAxisResult(
      quadrant: EcgAxisQuadrant.rightward,
      label: 'Rightward quadrant',
      range: 'Approximately +90° to +180°',
      guidance:
          'This may be physiological in early infancy. In an older child, compare with age norms and assess for right ventricular hypertrophy or congenital heart disease.',
    );
  }
  return const EcgAxisResult(
    quadrant: EcgAxisQuadrant.extreme,
    label: 'Extreme / superior axis',
    range: 'Approximately −90° to ±180°',
    guidance:
        'Recheck limb-lead placement and obtain senior/cardiology review. Consider congenital heart disease, ventricular rhythm, pre-excitation or dextrocardia in context.',
  );
}

double heartRateFromRrSeconds(double rrSeconds) {
  if (!rrSeconds.isFinite || rrSeconds <= 0) {
    throw ArgumentError.value(rrSeconds, 'rrSeconds', 'Must be positive');
  }
  return 60 / rrSeconds;
}

double heartRateFromLargeSquares(double largeSquares, {double speed = 25}) {
  if (!largeSquares.isFinite || largeSquares <= 0 || speed <= 0) {
    throw ArgumentError('Large squares and paper speed must be positive');
  }
  return (300 * (speed / 25)) / largeSquares;
}

double heartRateFromComplexes(double complexes, double stripSeconds) {
  if (!complexes.isFinite ||
      !stripSeconds.isFinite ||
      complexes < 0 ||
      stripSeconds <= 0) {
    throw ArgumentError('Complex count must be non-negative and time positive');
  }
  return complexes * 60 / stripSeconds;
}

class QtcResult {
  final double bazettMs;
  final double fridericiaMs;

  const QtcResult({required this.bazettMs, required this.fridericiaMs});
}

QtcResult calculateQtc({required double qtMs, required double rrSeconds}) {
  if (!qtMs.isFinite || !rrSeconds.isFinite || qtMs <= 0 || rrSeconds <= 0) {
    throw ArgumentError('QT and RR must be positive');
  }
  final double qtSeconds = qtMs / 1000;
  return QtcResult(
    bazettMs: qtSeconds / math.sqrt(rrSeconds) * 1000,
    fridericiaMs: qtSeconds / math.pow(rrSeconds, 1 / 3) * 1000,
  );
}
