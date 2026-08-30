// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
//
// Source basis: LHSC NICU Basic Nutrition Quick Guide / Neonatal TPN &
// Enteral quick-reference cards supplied by the user (updated 2024).
//
// IMPORTANT: This engine intentionally does NOT infer a universal enteral
// feed-advancement rate because that rule is not explicit on the supplied
// quick-reference cards.

enum NicuMilkType { ebm, donor, formula, mixed }

enum NicuIvStatus { tpnSmof, ivOnly, none }

class NicuStartingFeed {
  final double mlPerFeed;
  final int intervalHours;

  const NicuStartingFeed({
    required this.mlPerFeed,
    required this.intervalHours,
  });

  double get mlPerDay => mlPerFeed * (24 / intervalHours);
}

class NicuTpnPathway {
  final String title;
  final double? tfiMlKgDay;
  final List<String> lines;
  final bool boundaryNeedsVerification;

  const NicuTpnPathway({
    required this.title,
    required this.tfiMlKgDay,
    required this.lines,
    this.boundaryNeedsVerification = false,
  });
}

class NicuFeedingPlanEngine {
  const NicuFeedingPlanEngine._();

  static double gestationalAgeDays(int weeks, int days) =>
      (weeks * 7 + days).toDouble();

  static NicuStartingFeed startingFeedForWeightKg(double weightKg) {
    if (weightKg < 1.0) {
      return const NicuStartingFeed(mlPerFeed: 1, intervalHours: 4);
    }
    if (weightKg <= 1.5) {
      return const NicuStartingFeed(mlPerFeed: 1, intervalHours: 2);
    }
    if (weightKg <= 2.0) {
      return const NicuStartingFeed(mlPerFeed: 4, intervalHours: 3);
    }
    if (weightKg <= 2.5) {
      return const NicuStartingFeed(mlPerFeed: 5, intervalHours: 3);
    }
    return const NicuStartingFeed(mlPerFeed: 10, intervalHours: 3);
  }

  static double enteralMlPerDay({
    required double mlPerFeed,
    required int intervalHours,
  }) {
    if (mlPerFeed < 0 || intervalHours <= 0) return 0;
    return mlPerFeed * (24 / intervalHours);
  }

  static double enteralMlKgDay({
    required double weightKg,
    required double mlPerFeed,
    required int intervalHours,
  }) {
    if (weightKg <= 0) return 0;
    return enteralMlPerDay(
          mlPerFeed: mlPerFeed,
          intervalHours: intervalHours,
        ) /
        weightKg;
  }

  static List<String> donorMilkEligibilityReasons({
    required double birthWeightKg,
    required int gaWeeks,
    required int gaDays,
    bool perinatalAcidosisOrHie = false,
    bool giSurgeryOrNec = false,
    bool complexCardiacDisease = false,
    bool qualifyingTwin = false,
  }) {
    final List<String> reasons = <String>[];
    final double gaDaysTotal = gestationalAgeDays(gaWeeks, gaDays);

    if (birthWeightKg <= 2.0) {
      reasons.add('Birth weight ≤2 kg');
    }
    if (gaDaysTotal <= 34 * 7) {
      reasons.add('Gestational age ≤34+0 weeks');
    }
    if (perinatalAcidosisOrHie) {
      reasons.add('Perinatal acidosis / HIE');
    }
    if (giSurgeryOrNec) {
      reasons.add('GI surgery / NEC');
    }
    if (complexCardiacDisease) {
      reasons.add('Complex cardiac disease');
    }
    if (qualifyingTwin) {
      reasons.add('Twin qualifies because sibling qualifies');
    }
    return reasons;
  }

  static NicuTpnPathway tpnPathway({
    required int gaWeeks,
    required int gaDays,
    required double birthWeightKg,
  }) {
    final int totalDays = gaWeeks * 7 + gaDays;

    if (totalDays >= 22 * 7 && totalDays <= (23 * 7 + 6)) {
      return const NicuTpnPathway(
        title: '22+0 to 23+6 weeks',
        tfiMlKgDay: 120,
        lines: <String>[
          'TPN 5%',
          '3% amino acids',
          'Na⁺ / K⁺ / Cl⁻ / PO₄ free',
          'With calcium gluconate',
          'SMOF 1 g/kg/day',
          'ART line: heparin 1 unit/mL in 0.45% sodium acetate at 0.5 mL/hr',
        ],
      );
    }

    if (totalDays >= 24 * 7 && totalDays <= (25 * 7 + 6)) {
      return const NicuTpnPathway(
        title: '24+0 to 25+6 weeks',
        tfiMlKgDay: 100,
        lines: <String>[
          'TPN 7.5%',
          '4% amino acids',
          'Na⁺ / K⁺ / Cl⁻ / PO₄ free',
          'With calcium gluconate',
          'SMOF 1 g/kg/day',
          'ART line: heparin 1 unit/mL in 0.45% sodium acetate at 0.5 mL/hr',
        ],
      );
    }

    // The supplied card's next line is worded ">26+0 weeks AND <1.5 kg".
    // Exact 26+0 is therefore deliberately flagged rather than silently assigned.
    if (totalDays == 26 * 7 && birthWeightKg < 1.5) {
      return const NicuTpnPathway(
        title: '26+0 weeks — verify quick-guide boundary',
        tfiMlKgDay: null,
        lines: <String>[
          'The supplied quick card labels the next pathway as >26+0 weeks and <1.5 kg.',
          'Verify the exact 26+0 boundary against the full LHSC Neonatal TPN and Enteral Guideline before prescribing.',
        ],
        boundaryNeedsVerification: true,
      );
    }

    if (totalDays > 26 * 7 && birthWeightKg < 1.5) {
      return const NicuTpnPathway(
        title: '>26+0 weeks and <1.5 kg',
        tfiMlKgDay: 80,
        lines: <String>[
          'TPN 10%',
          '3.5% amino acids',
          'K⁺ free',
          'Sodium acetate',
          'SMOF 2 g/kg/day',
          'Initiate patient-specific TPN by 24 hours per quick guide',
          'For <1.5 kg: add vitamins and trace elements except manganese to patient-specific TPN',
        ],
      );
    }

    if (birthWeightKg >= 1.5) {
      return const NicuTpnPathway(
        title: '≥1.5 kg',
        tfiMlKgDay: null,
        lines: <String>[
          'D10W / 0.2 NaCl',
          'TFI 60–80 mL/kg/day',
          'If full feeds are not anticipated by 3–5 days: TPN 10%, 3.5% amino acids, SMOF 2 g/kg/day',
          'If >2.5 kg: quick card states start TPN/SMOF at 7 days',
        ],
      );
    }

    return const NicuTpnPathway(
      title: 'Pathway not resolved from quick card',
      tfiMlKgDay: null,
      lines: <String>[
        'Verify against the full LHSC Neonatal TPN and Enteral Guideline.',
      ],
      boundaryNeedsVerification: true,
    );
  }

  static bool fortificationMilestoneReached(double enteralMlKgDay) =>
      enteralMlKgDay >= 100;

  static double remainingToFortification(double enteralMlKgDay) =>
      enteralMlKgDay >= 100 ? 0 : 100 - enteralMlKgDay;

  static bool tpnDiscontinuationMilestone({
    required double enteralMlKgDay,
    double? enteralPercentOfTotalFluids,
  }) {
    return enteralMlKgDay >= 100 ||
        (enteralPercentOfTotalFluids != null &&
            enteralPercentOfTotalFluids >= 75);
  }

  static bool ivDiscontinuationMilestone({
    required double enteralMlKgDay,
    required bool fortifiedFeedsTolerated,
  }) {
    return enteralMlKgDay >= 130 && fortifiedFeedsTolerated;
  }
}
