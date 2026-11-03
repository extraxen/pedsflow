// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in repository root.
//
// Pure, independently testable EDUCATIONAL clinical calculations.
// Input bounds catch common entry errors; they are NOT patient exclusions.

enum SteroidAgent {
  hydrocortisone('Hydrocortisone', 20.0, 'PO / IV'),
  cortisone('Cortisone acetate', 25.0, 'PO'),
  prednisone('Prednisone', 5.0, 'PO'),
  prednisolone('Prednisolone', 5.0, 'PO'),
  methylprednisolone('Methylprednisolone', 4.0, 'PO / IV'),
  triamcinolone('Triamcinolone', 4.0, 'Systemic; verify formulation'),
  dexamethasone('Dexamethasone', 0.75, 'PO / IV'),
  betamethasone('Betamethasone', 0.6, 'Systemic; verify formulation');

  const SteroidAgent(this.label, this.equivalentMg, this.routeNote);
  final String label;
  final double equivalentMg;
  final String routeNote;
}

class EndocrineLabMath {
  const EndocrineLabMath._();

  static bool _ok(double? v, double low, double high) =>
      v != null && v.isFinite && v >= low && v <= high;

  /// Historical approximate anti-inflammatory glucocorticoid equivalents.
  /// Conversion does not account for route, bioavailability, duration,
  /// circadian timing, mineralocorticoid activity, HPA suppression or taper.
  /// Refer to Endocrine Reviews 2024 table 1 and Endotext table 1.
  static double? steroidEquivalent({
    required double? sourceDoseMg,
    required SteroidAgent from,
    required SteroidAgent to,
  }) {
    if (!_ok(sourceDoseMg, 0.001, 1000)) return null;
    final result = sourceDoseMg! / from.equivalentMg * to.equivalentMg;
    return result.isFinite && result <= 100000 ? result : null;
  }

  /// Only if an actual prescribed number of doses/day is supplied.
  static double? steroidDailyEquivalent({
    required double? sourceDoseMg,
    required int? administrationsPerDay,
    required SteroidAgent from,
    required SteroidAgent to,
  }) {
    if (administrationsPerDay == null ||
        administrationsPerDay < 1 || administrationsPerDay > 12) {
      return null;
    }
    final equivalent = steroidEquivalent(
      sourceDoseMg: sourceDoseMg, from: from, to: to,
    );
    if (equivalent == null) return null;
    return equivalent * administrationsPerDay;
  }

  /// glucose mmol/L to mg/dL; molar mass 180.182 g/mol.
  static double? glucoseMgDl(double? glucoseMmolL) =>
      _ok(glucoseMmolL, 0, 100) ? glucoseMmolL! * 18.0182 : null;

  /// Katz and Hillier use the 100 mg/dL glucose baseline.
  /// These are estimates, NOT a measured or "actual" sodium level.
  /// No extrapolation below 100 mg/dL.
  static double? correctedSodium({
    required double? measuredNaMmolL,
    required double? glucoseMgDl,
    required double correctionPer100MgDl,
  }) {
    if (!_ok(measuredNaMmolL, 80, 220) ||
        !_ok(glucoseMgDl, 100, 1801.82) ||
        !const [1.6, 2.4].contains(correctionPer100MgDl)) return null;
    return measuredNaMmolL! +
        correctionPer100MgDl * (glucoseMgDl! - 100) / 100;
  }

  /// CPS pediatric DKA pathway. Uses mmol/L glucose, factor 0.3 and
  /// baseline 5 mmol/L; intentionally distinct from Katz / Hillier.
  static double? cpsDkaCorrectedSodium({
    required double? measuredNaMmolL,
    required double? glucoseMmolL,
  }) {
    if (!_ok(measuredNaMmolL, 80, 220) ||
        !_ok(glucoseMmolL, 5, 100)) return null;
    return measuredNaMmolL! + (glucoseMmolL! - 5) * 0.3;
  }

  /// Standard three-electrolyte method, without potassium.
  /// Use measured Na (not glucose-corrected Na) and concurrent labs.
  static double? serumAnionGap({
    required double? sodiumMmolL,
    required double? chlorideMmolL,
    required double? bicarbonateMmolL,
  }) {
    if (!_ok(sodiumMmolL, 80, 220) ||
        !_ok(chlorideMmolL, 40, 180) ||
        !_ok(bicarbonateMmolL, 0, 60)) return null;
    return sodiumMmolL! - chlorideMmolL! - bicarbonateMmolL!;
  }

  /// Published approximation: +2.5 mmol/L per 10 g/L decrement in
  /// serum albumin below 40 g/L. Only compute for hypoalbuminemia,
  /// not above the reference concentration.
  static double? albuminAdjustedAnionGap({
    required double? anionGapMmolL,
    required double? albuminGL,
  }) {
    if (!_ok(anionGapMmolL, -100, 180) ||
        !_ok(albuminGL, 1, 40)) return null;
    return anionGapMmolL! + 0.25 * (40 - albuminGL!);
  }

  /// SI unit concentration-based estimate: mmol/L inputs.
  /// In common clinical usage the reported number is approximated as
  /// mOsm/kg, but this is a calculated osmolarity, NOT measured osmolality.
  static double? effectiveOsmolarity({
    required double? sodiumMmolL,
    required double? glucoseMmolL,
  }) {
    if (!_ok(sodiumMmolL, 80, 220) ||
        !_ok(glucoseMmolL, 0, 100)) return null;
    return 2 * sodiumMmolL! + glucoseMmolL!;
  }

  static double? calculatedTotalOsmolarity({
    required double? sodiumMmolL,
    required double? glucoseMmolL,
    required double? ureaMmolL,
  }) {
    final effective = effectiveOsmolarity(
      sodiumMmolL: sodiumMmolL, glucoseMmolL: glucoseMmolL);
    if (effective == null || !_ok(ureaMmolL, 0, 100)) return null;
    return effective + ureaMmolL!;
  }

  /// Screening gap; unexplained elevations require clinical review and
  /// method-specific consideration. No automated toxin interpretation.
  static double? osmolalGap({
    required double? measuredOsmolalityMOsmKg,
    required double? calculatedTotalOsmolarity,
  }) {
    if (!_ok(measuredOsmolalityMOsmKg, 150, 500) ||
        !_ok(calculatedTotalOsmolarity, 100, 600)) return null;
    return measuredOsmolalityMOsmKg! - calculatedTotalOsmolarity!;
  }
}
