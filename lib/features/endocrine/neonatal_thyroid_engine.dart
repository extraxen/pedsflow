// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
//
// Educational, source-labelled neonatal thyroid triage.
// Reference intervals are transcribed from a user-supplied slide.
// They have NOT been verified for any specific analyzer/laboratory.
// This does not diagnose congenital hypothyroidism or prescribe LT4.

enum ThyroidValueFlag { below, within, above, unavailable }
enum ThyroidPriority { incomplete, chartOnly, followUp, urgent }
enum ThyroidScreenStatus { unknown, reportedNormal, reportedAbnormal }

class ThyroidReference {
  const ThyroidReference(this.ageLabel, this.low, this.high);
  final String ageLabel;
  final double low, high;
  String get formatted => '$low–$high';
}

class ThyroidTriageInput {
  const ThyroidTriageInput({
    required this.ageDays,
    this.serumConfirmed = false,
    this.tshMiuL,
    this.freeT4PmolL,
    this.newbornScreen = ThyroidScreenStatus.unknown,
    this.pretermOrNicu = false,
    this.pituitaryConcern = false,
    this.onLevothyroxine = false,
  });

  final int? ageDays;
  final bool serumConfirmed;
  final double? tshMiuL;
  final double? freeT4PmolL;
  final ThyroidScreenStatus newbornScreen;
  final bool pretermOrNicu;
  final bool pituitaryConcern;
  final bool onLevothyroxine;
}

class ThyroidTriageResult {
  const ThyroidTriageResult({
    required this.tshReference,
    required this.freeT4Reference,
    required this.tshFlag,
    required this.freeT4Flag,
    required this.priority,
    required this.heading,
    required this.steps,
    required this.notes,
  });

  final ThyroidReference? tshReference, freeT4Reference;
  final ThyroidValueFlag tshFlag, freeT4Flag;
  final ThyroidPriority priority;
  final String heading;
  final List<String> steps;
  final List<String> notes;
}

class NeonatalThyroidEngine {
  const NeonatalThyroidEngine._();

  /// First-month day bands are exact reproductions of the slide.
  /// The slide does not provide a TSH band at precisely day 5.
  /// Beyond 31 d, month/year intervals are approximate translations
  /// (30 d/month, 365 d/year), not a replacement for DOB-based lab ranges.
  static ThyroidReference? tshReference(int? ageDays) {
    if (ageDays == null || ageDays < 0) return null;
    if (ageDays < 5) return const ThyroidReference('<5 days', 3.2, 19);
    if (ageDays == 5) return null;
    if (ageDays <= 31) {
      return const ThyroidReference('6–31 days', 1.7, 9.1);
    }
    if (ageDays < 90) {
      return const ThyroidReference('1–2 months (approximate)', 0.5, 6.3);
    }
    if (ageDays < 180) {
      return const ThyroidReference('3–<6 months (approximate)', 0.5, 4.77);
    }
    if (ageDays < 365) {
      return const ThyroidReference('6 months–<1 year (approximate)', 0.61, 4.58);
    }
    if (ageDays < 5110) {
      return const ThyroidReference('1–<14 years (approximate)', 0.73, 4.09);
    }
    if (ageDays < 6935) {
      return const ThyroidReference('14–<19 years (approximate)', 0.47, 4.00);
    }
    return null;
  }

  static ThyroidReference? freeT4Reference(int? ageDays) {
    if (ageDays == null || ageDays < 3) return null;
    if (ageDays < 15) {
      return const ThyroidReference('3–<15 days', 13.0, 52.2);
    }
    if (ageDays < 30) {
      return const ThyroidReference('15–<30 days', 10.5, 30.0);
    }
    if (ageDays < 120) {
      return const ThyroidReference('30 days–<4 months (approximate)', 10.5, 22.7);
    }
    if (ageDays < 365) {
      return const ThyroidReference('4 months–<1 year (approximate)', 10.0, 22.0);
    }
    if (ageDays < 6935) {
      return const ThyroidReference('1–<19 years (approximate)', 10.0, 17.6);
    }
    return null;
  }

  static ThyroidValueFlag flag(double? value, ThyroidReference? range) {
    if (value == null || !value.isFinite || range == null) {
      return ThyroidValueFlag.unavailable;
    }
    if (value < range.low) return ThyroidValueFlag.below;
    if (value > range.high) return ThyroidValueFlag.above;
    return ThyroidValueFlag.within;
  }

  static bool _valid(double? value, double max) =>
      value == null || (value.isFinite && value >= 0 && value <= max);

  static ThyroidTriageResult assess(ThyroidTriageInput input) {
    final age = input.ageDays;
    final tshRef = tshReference(age);
    final ft4Ref = freeT4Reference(age);
    final tshFlag = flag(input.tshMiuL, tshRef);
    final ft4Flag = flag(input.freeT4PmolL, ft4Ref);
    final notes = <String>[
      'Reference intervals were transcribed from the supplied image, '
          'NOT authenticated for the patient laboratory or assay.',
      'The source has no FT4 reference at ages 0–2 days and no TSH '
          'reference for day 5. Do not infer a normal interval.',
    ];
    if (age != null && age >= 30) {
      notes.add('Source month/year age cutoffs are mapped approximately '
          'from days; verify actual calendar age and local assay ranges.');
    }
    if (age != null && age <= 2) {
      notes.add('Physiologic postnatal TSH surge complicates immediate '
          'post-delivery interpretation.');
    }
    if (input.pretermOrNicu) {
      notes.add('Preterm/NICU infants may have delayed TSH elevation, '
          'non-thyroidal illness effects and different reference values. '
          'AAP suggests repeat newborn screening at 2–4 weeks for '
          'selected at-risk infants under the local screening program.');
    }
    if (input.pituitaryConcern) {
      notes.add('Pituitary/midline abnormalities or recurrent hypoglycemia '
          'warrant assessment for central hypothyroidism and adrenal '
          'insufficiency even when TSH is not elevated.');
    }
    if (input.onLevothyroxine) {
      notes.add('Already receiving levothyroxine: use the treating '
          'endocrinology monitoring plan rather than new-diagnosis rules.');
    }

    ThyroidTriageResult result(
      ThyroidPriority priority, String title, List<String> steps,
    ) => ThyroidTriageResult(
      tshReference: tshRef, freeT4Reference: ft4Ref,
      tshFlag: tshFlag, freeT4Flag: ft4Flag,
      priority: priority, heading: title,
      steps: List.unmodifiable(steps), notes: List.unmodifiable(notes),
    );

    if (age == null || age < 0 || age >= 6935 ||
        !_valid(input.tshMiuL, 1000) ||
        !_valid(input.freeT4PmolL, 250)) {
      return result(ThyroidPriority.incomplete, 'Verify inputs and age', [
        'Enter a valid postnatal age in completed days and serum TSH/FT4 '
            'in mIU/L and pmol/L. Values outside the supported range '
            'require direct laboratory and specialist review.',
      ]);
    }

    if (!input.serumConfirmed) {
      return result(
        input.newbornScreen == ThyroidScreenStatus.reportedAbnormal
            ? ThyroidPriority.urgent : ThyroidPriority.incomplete,
        'Confirm serum specimen before interpretation',
        [
          if (input.newbornScreen == ThyroidScreenStatus.reportedAbnormal)
            'Abnormal newborn screening requires prompt pediatric '
                'endocrinology/newborn-screen program contact.',
          'Obtain paired confirmatory SERUM TSH and free T4. Dried-blood-spot '
              'screening values must not be compared with serum ranges '
              'or used as serum treatment thresholds.',
        ],
      );
    }

    if (input.newbornScreen == ThyroidScreenStatus.reportedAbnormal) {
      return result(ThyroidPriority.urgent,
        'Abnormal newborn screen — prompt specialist assessment', [
          'Contact pediatric endocrinology/newborn-screen program promptly '
              'and verify whether the serum sample is confirmatory.',
          'Review paired serum TSH and FT4, collection age and screening '
              'details. A result appearing within a slide interval does '
              'not cancel an abnormal screen.',
          if (ft4Flag == ThyroidValueFlag.below ||
              (input.tshMiuL != null && input.tshMiuL! > 20))
            'The serum results also raise concern for congenital '
                'hypothyroidism. Discuss prompt levothyroxine initiation '
                'with pediatric endocrinology using age-specific lab ranges.',
        ]);
    }

    if (input.tshMiuL == null || input.freeT4PmolL == null) {
      return result(ThyroidPriority.incomplete,
        'Both serum TSH and free T4 are needed', [
          'Obtain paired serum TSH and free T4 to assess possible '
              'primary or central congenital hypothyroidism.',
          if (input.pretermOrNicu || input.pituitaryConcern)
            'Arrange specialist review and the local repeat-screen '
                'plan rather than relying on a single incomplete sample.',
        ]);
    }

    final tsh = input.tshMiuL!;
    if (input.onLevothyroxine) {
      final concerning = tsh > 20 ||
          ft4Flag == ThyroidValueFlag.below ||
          (ft4Flag == ThyroidValueFlag.above &&
              tshFlag == ThyroidValueFlag.below);
      return result(
        concerning ? ThyroidPriority.urgent : ThyroidPriority.followUp,
        concerning
            ? 'On levothyroxine — concerning results need prompt review'
            : 'On levothyroxine — use treated-patient monitoring', [
          'Review the current endocrine plan, recent dose and timing of '
              'blood collection, trajectory, adherence and symptoms.',
          if (concerning)
            'Contact the treating pediatric endocrine team promptly '
                'for assessment of markedly abnormal values.',
          'Do not start, stop or change LT4 solely from this initial '
              'diagnosis pathway; contact the treating endocrine team.',
        ]);
    }

    if (ft4Flag == ThyroidValueFlag.below) {
      if (tshFlag == ThyroidValueFlag.above) {
        return result(ThyroidPriority.urgent,
          'Low FT4 with elevated TSH — primary CH concern', [
            'Urgently contact pediatric endocrinology. Guidelines '
                'recommend prompt levothyroxine when serum FT4 is '
                'below the age-specific limit and TSH is clearly raised.',
            'Confirm assay, newborn-screen result, gestational age and '
                'specimen timing without delaying specialist decisions.',
          ]);
      }
      return result(ThyroidPriority.urgent,
        'Low FT4 — urgent primary or central CH assessment', [
          'Urgently discuss with pediatric endocrinology. Low FT4 '
              'requires assessment even if TSH is normal, low or '
              'only slightly raised; central CH may be missed by TSH.',
          'If central CH/pituitary disease is possible, evaluate adrenal '
              'function BEFORE initiating levothyroxine under specialist '
              'guidance to avoid precipitating adrenal crisis.',
        ]);
    }

    if (tsh > 20 && age >= 7 && age < 365) {
      return result(ThyroidPriority.urgent,
        'Serum TSH >20 mIU/L — urgent endocrine review', [
          'Contact pediatric endocrinology the same day. ENDO-ERN '
              'and AAP advise levothyroxine treatment for confirmatory '
              'serum TSH >20 mIU/L even when free T4 is normal '
              'in the newborn period. Beyond the newborn period, '
              'specialist interpretation remains necessary.'
          'Confirm that the value is serum (not dried-blood-spot), '
              'review sample age and repeat sampling as directed. '
              'Treatment timing must not wait for unnecessary imaging.',
        ]);
    }
    if (tsh > 20 && age < 7) {
      return result(ThyroidPriority.urgent,
        'Marked neonatal TSH elevation — urgent assessment', [
          'Contact the pediatric endocrinology/newborn-screen program '
              'promptly; early physiologic TSH changes require '
              'age-of-sample interpretation.',
          'Confirm timing and repeat paired serum studies urgently '
              'as advised, rather than applying second-week thresholds '
              'to the immediate postnatal period.',
        ]);
    }

    if (ft4Flag == ThyroidValueFlag.above &&
        tshFlag == ThyroidValueFlag.below) {
      return result(ThyroidPriority.urgent,
        'High FT4 with suppressed TSH — evaluate thyrotoxicosis', [
          'Promptly review maternal Graves disease/thyroid antibodies, '
              'infant heart rate, feeding, weight and symptoms with '
              'pediatric endocrinology.',
          'Repeat and confirm paired laboratory tests and consider '
              'assay interference/medications as directed.',
        ]);
    }

    if (age >= 22 && age <= 90 &&
        tsh >= 6 && tsh <= 20 &&
        ft4Flag == ThyroidValueFlag.within) {
      return result(ThyroidPriority.followUp,
        'TSH 6–20 after day 21 with normal FT4 — review', [
          'Discuss with pediatric endocrinology: ENDO-ERN offers '
              'either levothyroxine with later reassessment OR '
              'observation with repeat serum TSH and FT4 in 1–2 weeks '
              'for an otherwise healthy infant.',
          'Use age-specific laboratory reference values and previous '
              'trend; this is not an automatic treatment decision.',
        ]);
    }

    if (tshFlag == ThyroidValueFlag.above ||
        tshFlag == ThyroidValueFlag.below ||
        ft4Flag == ThyroidValueFlag.above) {
      return result(ThyroidPriority.followUp,
        'Outside supplied reference interval — clinical review', [
          'Review paired serum TSH/FT4, newborn screening, age and '
              'local lab-specific reference intervals with the '
              'pediatric endocrine team.',
          'For elevated TSH with normal FT4, assess degree and '
              'persistence and agree on an individualized repeat-test '
              'interval. Avoid delaying review when CH is suspected.',
        ]);
    }

    if (tshRef == null || ft4Ref == null) {
      return result(ThyroidPriority.followUp,
        'One or both age-specific ranges are unavailable', [
          'The supplied slide is incomplete for this exact age. '
              'Use the performing laboratory neonatal reference '
              'interval and clinical context before interpretation.',
          'If the newborn screen is abnormal, symptoms are present '
              'or pituitary disease is possible, contact endocrinology.',
        ]);
    }

    if (input.pretermOrNicu || input.pituitaryConcern) {
      return result(ThyroidPriority.followUp,
        'Within slide ranges, but higher-risk clinical context', [
          'Do not treat one apparently normal pair as excluding '
              'thyroid disease in preterm, NICU or pituitary-risk infants.',
          'Confirm the screening program plan, consider repeat NBS '
              'at 2–4 weeks for eligible at-risk infants, and arrange '
              'endocrinology review when indicated.',
        ]);
    }

    return result(ThyroidPriority.chartOnly,
      'Within supplied age-specific serum intervals', [
        'Verify the local performing-laboratory ranges, a documented '
            'normal newborn screen and clinical course.',
        'If symptoms, risk factors or a positive screening result arise, '
            'repeat paired serum testing and seek specialist advice.',
      ]);
  }
}
