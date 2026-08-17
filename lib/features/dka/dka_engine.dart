// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'dart:math' as math;

enum ClinicalCriterion { met, notMet, unknown }

enum DkaSeverity { notGradeable, noDkaRangeAcidosis, mild, moderate, severe }

enum DkaDiagnosis {
  incomplete,
  notFullyMet,
  triadMetGapUnavailable,
  criteriaMet,
}

enum UrineKetones { unknown, negativeTraceSmall, moderate, large }

enum UrineOutput { unknown, documented, absent }

class DkaInputs {
  const DkaInputs({
    this.ageYears,
    this.weightKg,
    this.glucose,
    this.previousGlucose,
    this.ph,
    this.bicarbonate,
    this.sodium,
    this.chloride,
    this.potassium,
    this.betaHydroxybutyrate,
    this.phosphate,
    this.urea,
    this.urineKetones = UrineKetones.unknown,
    this.urineOutput = UrineOutput.unknown,
    this.alteredMentalStatus = false,
    this.bolusMlPerKg = 10,
    this.insulinUnitsPerKgHour = 0.05,
    this.bagBConcentration = 12.5,
    this.desiredDextrose = 5,
  });

  final double? ageYears;
  final double? weightKg;
  final double? glucose;
  final double? previousGlucose;
  final double? ph;
  final double? bicarbonate;
  final double? sodium;
  final double? chloride;
  final double? potassium;
  final double? betaHydroxybutyrate;
  final double? phosphate;
  final double? urea;
  final UrineKetones urineKetones;
  final UrineOutput urineOutput;
  final bool alteredMentalStatus;
  final int bolusMlPerKg;
  final double insulinUnitsPerKgHour;
  final double bagBConcentration;
  final double desiredDextrose;
}

class CpsFluidRate {
  const CpsFluidRate({this.rateMlHour, this.factorMlKgHour, required this.band});

  final double? rateMlHour;
  final double? factorMlKgHour;
  final String band;
}

class DkaResults {
  const DkaResults({
    required this.hyperglycemia,
    required this.ketosis,
    required this.acidosis,
    required this.highAnionGap,
    required this.diagnosis,
    required this.severity,
    required this.correctedSodium,
    required this.anionGap,
    required this.effectiveOsmolality,
    required this.glucoseFallPerHour,
    required this.cpsFluid,
    required this.initialBolusMl,
    required this.insulinLowUnitsHour,
    required this.insulinHighUnitsHour,
    required this.selectedInsulinUnitsHour,
    required this.holdInsulin,
    required this.bagAPercent,
    required this.bagBPercent,
    required this.bagARateMlHour,
    required this.bagBRateMlHour,
    required this.possibleHhs,
    required this.hypertonicSaline3PercentMl,
    required this.mannitolLowG,
    required this.mannitolHighG,
    required this.mannitol20PercentLowMl,
    required this.mannitol20PercentHighMl,
    required this.validationMessages,
  });

  final ClinicalCriterion hyperglycemia;
  final ClinicalCriterion ketosis;
  final ClinicalCriterion acidosis;
  final ClinicalCriterion highAnionGap;
  final DkaDiagnosis diagnosis;
  final DkaSeverity severity;
  final double? correctedSodium;
  final double? anionGap;
  final double? effectiveOsmolality;
  final double? glucoseFallPerHour;
  final CpsFluidRate cpsFluid;
  final double? initialBolusMl;
  final double? insulinLowUnitsHour;
  final double? insulinHighUnitsHour;
  final double? selectedInsulinUnitsHour;
  final bool holdInsulin;
  final double bagAPercent;
  final double bagBPercent;
  final double? bagARateMlHour;
  final double? bagBRateMlHour;
  final bool possibleHhs;
  final double? hypertonicSaline3PercentMl;
  final double? mannitolLowG;
  final double? mannitolHighG;
  final double? mannitol20PercentLowMl;
  final double? mannitol20PercentHighMl;
  final List<String> validationMessages;

  String get diagnosisLabel {
    switch (diagnosis) {
      case DkaDiagnosis.incomplete:
        return 'Incomplete data';
      case DkaDiagnosis.notFullyMet:
        return 'DKA criteria not fully met';
      case DkaDiagnosis.triadMetGapUnavailable:
        return 'Triad met â€” verify anion gap';
      case DkaDiagnosis.criteriaMet:
        return 'DKA biochemical criteria met';
    }
  }

  String get severityLabel {
    switch (severity) {
      case DkaSeverity.notGradeable:
        return 'Not gradeable';
      case DkaSeverity.noDkaRangeAcidosis:
        return 'No DKA-range acidosis';
      case DkaSeverity.mild:
        return 'Mild DKA';
      case DkaSeverity.moderate:
        return 'Moderate DKA';
      case DkaSeverity.severe:
        return 'Severe DKA';
    }
  }
}

class DkaEngine {
  const DkaEngine._();

  static double? correctedSodium(double? sodium, double? glucose) {
    if (sodium == null || glucose == null) return null;
    return sodium + (glucose - 5) * 0.3;
  }

  static double? anionGap(double? sodium, double? chloride, double? bicarbonate) {
    if (sodium == null || chloride == null || bicarbonate == null) return null;
    return sodium - chloride - bicarbonate;
  }

  static double? effectiveOsmolality(double? sodium, double? glucose) {
    if (sodium == null || glucose == null) return null;
    return 2 * sodium + glucose;
  }

  static CpsFluidRate cpsHourlyRate(double? weightKg) {
    if (weightKg == null || weightKg < 5) {
      return const CpsFluidRate(band: 'Outside CPS table (<5 kg)');
    }
    if (weightKg < 10) {
      return CpsFluidRate(
        rateMlHour: weightKg * 6.5,
        factorMlKgHour: 6.5,
        band: '5 to <10 kg',
      );
    }
    if (weightKg < 20) {
      return CpsFluidRate(
        rateMlHour: weightKg * 6,
        factorMlKgHour: 6,
        band: '10 to <20 kg',
      );
    }
    if (weightKg < 40) {
      return CpsFluidRate(
        rateMlHour: weightKg * 5,
        factorMlKgHour: 5,
        band: '20 to <40 kg',
      );
    }
    return CpsFluidRate(
      rateMlHour: math.min(weightKg * 4, 250).toDouble(),
      factorMlKgHour: 4,
      band: 'â‰¥40 kg (maximum 250 mL/h)',
    );
  }

  static DkaSeverity severity(double? ph, double? bicarbonate) {
    final scores = <int>[];
    if (ph != null) {
      scores.add(ph < 7.1 ? 3 : ph < 7.2 ? 2 : ph < 7.3 ? 1 : 0);
    }
    if (bicarbonate != null) {
      scores.add(
        bicarbonate < 5 ? 3 : bicarbonate < 10 ? 2 : bicarbonate < 18 ? 1 : 0,
      );
    }
    if (scores.isEmpty) return DkaSeverity.notGradeable;
    switch (scores.reduce((a, b) => a > b ? a : b)) {
      case 3:
        return DkaSeverity.severe;
      case 2:
        return DkaSeverity.moderate;
      case 1:
        return DkaSeverity.mild;
      default:
        return DkaSeverity.noDkaRangeAcidosis;
    }
  }

  static DkaResults calculate(DkaInputs input) {
    final correctedNa = correctedSodium(input.sodium, input.glucose);
    final gap = anionGap(input.sodium, input.chloride, input.bicarbonate);
    final osmolality = effectiveOsmolality(input.sodium, input.glucose);
    final fluid = cpsHourlyRate(input.weightKg);

    final hyperglycemia = input.glucose == null
        ? ClinicalCriterion.unknown
        : input.glucose! > 11
            ? ClinicalCriterion.met
            : ClinicalCriterion.notMet;

    final ketosisKnown = input.betaHydroxybutyrate != null ||
        input.urineKetones != UrineKetones.unknown;
    final ketosisMet =
        (input.betaHydroxybutyrate != null && input.betaHydroxybutyrate! >= 3) ||
        input.urineKetones == UrineKetones.moderate ||
        input.urineKetones == UrineKetones.large;
    final ketosis = !ketosisKnown
        ? ClinicalCriterion.unknown
        : ketosisMet
            ? ClinicalCriterion.met
            : ClinicalCriterion.notMet;

    final acidosisKnown = input.ph != null || input.bicarbonate != null;
    final acidosisMet = (input.ph != null && input.ph! < 7.3) ||
        (input.bicarbonate != null && input.bicarbonate! < 18);
    final acidosis = !acidosisKnown
        ? ClinicalCriterion.unknown
        : acidosisMet
            ? ClinicalCriterion.met
            : ClinicalCriterion.notMet;

    final highAnionGap = gap == null
        ? ClinicalCriterion.unknown
        : gap > 12
            ? ClinicalCriterion.met
            : ClinicalCriterion.notMet;

    final coreKnown = input.glucose != null && ketosisKnown && acidosisKnown;
    final coreMet = hyperglycemia == ClinicalCriterion.met &&
        ketosis == ClinicalCriterion.met &&
        acidosis == ClinicalCriterion.met;

    final DkaDiagnosis diagnosis;
    if (!coreKnown) {
      diagnosis = DkaDiagnosis.incomplete;
    } else if (!coreMet || highAnionGap == ClinicalCriterion.notMet) {
      diagnosis = DkaDiagnosis.notFullyMet;
    } else if (highAnionGap == ClinicalCriterion.unknown) {
      diagnosis = DkaDiagnosis.triadMetGapUnavailable;
    } else {
      diagnosis = DkaDiagnosis.criteriaMet;
    }

    final weight = input.weightKg;
    final insulinHold = input.potassium == null || input.potassium! <= 3;
    final insulinLow = weight == null ? null : weight * 0.05;
    final insulinHigh = weight == null ? null : weight * 0.1;
    final selectedInsulin =
        weight == null || insulinHold ? null : weight * input.insulinUnitsPerKgHour;
    final bolus = weight == null
        ? null
        : math.min(weight * input.bolusMlPerKg, 1000).toDouble();

    final bagBFraction = input.bagBConcentration <= 0
        ? 0.0
        : (input.desiredDextrose / input.bagBConcentration)
            .clamp(0.0, 1.0)
            .toDouble();
    final bagAFraction = 1 - bagBFraction;
    final totalFluid = fluid.rateMlHour;

    final glucoseFall = input.previousGlucose == null || input.glucose == null
        ? null
        : input.previousGlucose! - input.glucose!;

    final possibleHhs = input.glucose != null &&
        input.glucose! > 33 &&
        osmolality != null &&
        osmolality > 320;

    final validation = <String>[];
    if (weight == null || weight <= 0) validation.add('Enter a valid weight.');
    if (weight != null && weight > 0 && weight < 5) {
      validation.add('The CPS weight-band table begins at 5 kg.');
    }
    if (input.glucose == null) validation.add('Current glucose is required.');
    if (input.ph != null && (input.ph! < 6.6 || input.ph! > 7.6)) {
      validation.add('Review the entered pH.');
    }
    if (input.potassium != null &&
        (input.potassium! < 1 || input.potassium! > 8)) {
      validation.add('Review the entered potassium.');
    }

    double? dose(double factor, double maxDose) =>
        weight == null ? null : math.min(weight * factor, maxDose).toDouble();

    return DkaResults(
      hyperglycemia: hyperglycemia,
      ketosis: ketosis,
      acidosis: acidosis,
      highAnionGap: highAnionGap,
      diagnosis: diagnosis,
      severity: severity(input.ph, input.bicarbonate),
      correctedSodium: correctedNa,
      anionGap: gap,
      effectiveOsmolality: osmolality,
      glucoseFallPerHour: glucoseFall,
      cpsFluid: fluid,
      initialBolusMl: bolus,
      insulinLowUnitsHour: insulinLow,
      insulinHighUnitsHour: insulinHigh,
      selectedInsulinUnitsHour: selectedInsulin,
      holdInsulin: insulinHold,
      bagAPercent: bagAFraction * 100,
      bagBPercent: bagBFraction * 100,
      bagARateMlHour: totalFluid == null ? null : totalFluid * bagAFraction,
      bagBRateMlHour: totalFluid == null ? null : totalFluid * bagBFraction,
      possibleHhs: possibleHhs,
      hypertonicSaline3PercentMl: dose(5, 250),
      mannitolLowG: dose(0.5, 100),
      mannitolHighG: dose(1, 100),
      mannitol20PercentLowMl: dose(2.5, 500),
      mannitol20PercentHighMl: dose(5, 500),
      validationMessages: List.unmodifiable(validation),
    );
  }
}

