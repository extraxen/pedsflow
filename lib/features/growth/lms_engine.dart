// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'dart:math' as math;

class LmsPoint {
  final double l;
  final double m;
  final double s;
  const LmsPoint({required this.l, required this.m, required this.s});
}

class LmsEngine {
  static double zScore({required double measurement, required LmsPoint point}) {
    if (measurement <= 0 || point.m <= 0 || point.s <= 0) {
      throw ArgumentError('Measurement and LMS M/S values must be positive.');
    }
    if (point.l.abs() < 1e-12) {
      return math.log(measurement / point.m) / point.s;
    }
    return (math.pow(measurement / point.m, point.l) - 1) / (point.l * point.s);
  }

  static double percentileFromZ(double z) {
    // Abramowitz-Stegun approximation of the standard normal CDF.
    final double sign = z < 0 ? -1 : 1;
    final double x = z.abs() / math.sqrt(2.0);
    final double t = 1.0 / (1.0 + 0.3275911 * x);
    final double erf = sign * (1 - (((((1.061405429 * t - 1.453152027) * t + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t) * math.exp(-x * x));
    return 100 * 0.5 * (1 + erf);
  }
}

