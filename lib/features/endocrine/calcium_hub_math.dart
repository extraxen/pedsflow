// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
//
// Pure educational arithmetic and qualitative lab-pattern framing.
// These functions do not diagnose disease or prescribe calcium.
enum CalciumStatus { unknown, low, withinRange, high }
enum PthStatus { unknown, low, withinRange, high }

class CalciumPatternSummary {
  const CalciumPatternSummary(this.heading, this.interpretation,
      {required this.needsUrgentClinicalAssessment});
  final String heading;
  final String interpretation;
  final bool needsUrgentClinicalAssessment;
}

class CalciumHubMath {
  const CalciumHubMath._();

  static bool _valid(double? value, double min, double max) =>
      value != null && value.isFinite && value >= min && value <= max;

  /// Health Canada DRI table. Ages are completed months.
  /// Under 12 months: AI, not an RDA. RDA ages 12 months to <19 years.
  /// These are TOTAL dietary targets, NOT supplemental medication doses.
  static int? ageCalciumTargetMgPerDay(int? ageMonths) {
    if (ageMonths == null || ageMonths < 0 || ageMonths >= 228) {
      return null;
    }
    if (ageMonths <= 6) return 200;
    if (ageMonths < 12) return 260;
    if (ageMonths < 48) return 700;
    if (ageMonths < 108) return 1000;
    return 1300;
  }

  static bool infantAdequateIntake(int? ageMonths) =>
      ageMonths != null && ageMonths >= 0 && ageMonths < 12;

  /// Descriptive intake comparison; no automatic prescribing decision.
  static double? dailyCalciumDifferenceMg({
    required int? ageMonths,
    required double? reportedDailyIntakeMg,
  }) {
    final target = ageCalciumTargetMgPerDay(ageMonths);
    if (target == null || !_valid(reportedDailyIntakeMg, 0, 10000)) {
      return null;
    }
    return target - reportedDailyIntakeMg!;
  }

  static double? percentOfCalciumTarget({
    required int? ageMonths,
    required double? reportedDailyIntakeMg,
  }) {
    final target = ageCalciumTargetMgPerDay(ageMonths);
    if (target == null || !_valid(reportedDailyIntakeMg, 0, 10000)) {
      return null;
    }
    return reportedDailyIntakeMg! / target * 100;
  }

  /// Both spot urine concentrations MUST be in mmol/L (same units).
  /// Interpret against age-specific, laboratory-specific cut-offs;
  /// not the unitless adult spot mass ratio in mg/mg.
  static double? urineCalciumCreatinineRatioMmolPerMmol({
    required double? calciumMmolL,
    required double? creatinineMmolL,
  }) {
    if (!_valid(calciumMmolL, 0, 50) ||
        !_valid(creatinineMmolL, 0.01, 200)) return null;
    return calciumMmolL! / creatinineMmolL!;
  }

  /// Educational calculation when the actual package explicitly provides
  /// elemental fraction for its FORMULATION; do not assume a fixed product
  /// concentration or equate salt mass with elemental calcium.
  static double? elementalCalciumFromLabel({
    required double? saltMassMg,
    required double? labelledElementalPercent,
  }) {
    if (!_valid(saltMassMg, 0, 10000) ||
        !_valid(labelledElementalPercent, 0, 100)) return null;
    return saltMassMg! * labelledElementalPercent! / 100;
  }

  /// User must independently compare measured calcium and PTH with the
  /// performing lab's age-specific reference ranges. "Within range" PTH
  /// can be inappropriately non-suppressed in hypercalcemia or inappropriately
  /// low in hypocalcemia.
  static CalciumPatternSummary interpretation({
    required CalciumStatus calcium,
    required PthStatus pth,
    bool seriousSymptoms = false,
  }) {
    if (seriousSymptoms) {
      return const CalciumPatternSummary(
        'Symptomatic calcium disturbance — urgent assessment',
        'Seizure, tetany/stridor, arrhythmia, altered consciousness, '
            'marked dehydration or concerning ECG findings require '
            'immediate monitored pediatric assessment; send critical '
            'labs only if they do not delay treatment.',
        needsUrgentClinicalAssessment: true,
      );
    }
    switch (calcium) {
      case CalciumStatus.low:
        if (pth == PthStatus.low || pth == PthStatus.withinRange) {
          return const CalciumPatternSummary(
            'Low calcium with an inappropriately low PTH response',
            'Consider hypoparathyroidism (including 22q11/iatrogenic), '
                'magnesium depletion or CaSR-associated conditions. '
                'Check phosphate, Mg, creatinine, vitamin D and '
                'contemporaneous PTH; review the neonatal context.',
            needsUrgentClinicalAssessment: false,
          );
        }
        if (pth == PthStatus.high) {
          return const CalciumPatternSummary(
            'Low calcium with elevated PTH',
            'PTH is responding; consider vitamin D deficiency, '
                'malabsorption, renal dysfunction, phosphate problems '
                'or PTH resistance. Review phosphate, ALP, 25-OH D, '
                'Mg and renal function.',
            needsUrgentClinicalAssessment: false,
          );
        }
        return const CalciumPatternSummary(
          'Low calcium — determine the PTH response',
          'Confirm ionized/total calcium, albumin, pH and Mg. Obtain '
              'paired PTH, phosphate, ALP, 25-OH D and renal function.',
          needsUrgentClinicalAssessment: false,
        );
      case CalciumStatus.high:
        if (pth == PthStatus.low) {
          return const CalciumPatternSummary(
            'High calcium with suppressed PTH',
            'Consider non-PTH-mediated causes such as vitamin D or '
                'calcitriol excess, subcutaneous fat necrosis, '
                'granulomatous conditions and malignancy. '
                'Check phosphate, vitamin D metabolites when indicated, '
                'kidney function and urinary calcium.',
            needsUrgentClinicalAssessment: false,
          );
        }
        if (pth == PthStatus.withinRange || pth == PthStatus.high) {
          return const CalciumPatternSummary(
            'High calcium with non-suppressed PTH',
            'A laboratory-normal PTH can be inappropriate when calcium '
                'is elevated. Consider PTH-mediated disease and '
                'CaSR-related conditions. Review repeat calcium, '
                'age-specific urinary calcium excretion, renal studies '
                'and family history with endocrinology.',
            needsUrgentClinicalAssessment: false,
          );
        }
        return const CalciumPatternSummary(
          'High calcium — evaluate PTH-dependent versus independent',
          'Repeat appropriate calcium measurement and obtain paired '
              'PTH, phosphate, kidney function, vitamin D studies '
              'and urine calcium/creatinine as appropriate.',
          needsUrgentClinicalAssessment: false,
        );
      case CalciumStatus.withinRange:
        return const CalciumPatternSummary(
          'Reported calcium within local range',
          'Normal calcium today does not exclude later hypocalcemia '
              'in at-risk neonates or evolving hypercalcemia after '
              'subcutaneous fat necrosis. Follow clinical trends.',
          needsUrgentClinicalAssessment: false,
        );
      case CalciumStatus.unknown:
        return const CalciumPatternSummary(
          'Start with measured calcium and clinical status',
          'Review ionized calcium when available, total calcium, '
              'albumin and acid-base status. Interpret PTH only '
              'in relation to a contemporaneous calcium result.',
          needsUrgentClinicalAssessment: false,
        );
    }
  }
}
