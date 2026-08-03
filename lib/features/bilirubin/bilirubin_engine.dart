import 'dart:math' as math;

enum BilirubinUnit { micromolPerL, mgPerDl }
enum BilirubinMeasurementType { tsb, tcb }

enum BilirubinZone {
  belowThreshold,
  nearPhototherapy,
  phototherapy,
  preExchange,
  exchange,
  acuteEncephalopathy,
}

class BilirubinAssessment {
  final int gestationalWeeks;
  final double ageHours;
  final double bilirubinMicromol;
  final double phototherapyThreshold;
  final double exchangeThreshold;
  final double preExchangeThreshold;
  final double deltaTsb;
  final double distanceFromExchange;
  final double? rateOfRise;
  final bool rapidRise;
  final bool requiresSerumConfirmation;
  final BilirubinZone zone;
  final List<String> recommendations;
  final List<String> cautions;

  const BilirubinAssessment({
    required this.gestationalWeeks,
    required this.ageHours,
    required this.bilirubinMicromol,
    required this.phototherapyThreshold,
    required this.exchangeThreshold,
    required this.preExchangeThreshold,
    required this.deltaTsb,
    required this.distanceFromExchange,
    required this.rateOfRise,
    required this.rapidRise,
    required this.requiresSerumConfirmation,
    required this.zone,
    required this.recommendations,
    required this.cautions,
  });
}

class BilirubinEngine {
  static const double micromolPerMgDl = 17.1;
  static const List<double> _hours = <double>[
    12, 24, 36, 48, 60, 72, 84, 96, 108, 120, 132, 144, 156, 168,
    180, 192, 204, 216, 228, 240, 252, 264, 276, 288, 300, 312, 324, 336,
  ];

  // Embedded AAP 2022 threshold table used by the CPS ≥35-week framework.
  // Values are mg/dL and are converted internally to µmol/L.
  static const Map<String, List<double>> _phototherapy = <String, List<double>>{
    '35_0': <double>[8.5,10.61,12.49,14.16,15.6,16.83,17.85,18.61,18.66,18.71,18.77,18.82,18.87,18.92,18.97,19.02,19.07,19.13,19.18,19.23,19.28,19.33,19.38,19.43,19.49,19.54,19.59,19.64],
    '36_0': <double>[9.03,11.16,13.07,14.76,16.23,17.49,18.53,19.32,19.38,19.43,19.49,19.54,19.59,19.64,19.69,19.74,19.79,19.85,19.9,19.95,20.0,20.05,20.1,20.15,20.21,20.26,20.31,20.36],
    '37_0': <double>[9.57,11.72,13.65,15.36,16.86,18.14,19.21,20.04,20.1,20.15,20.21,20.26,20.31,20.36,20.41,20.46,20.51,20.57,20.62,20.67,20.72,20.77,20.82,20.87,20.93,20.98,21.03,21.08],
    '38_0': <double>[10.1,12.27,14.23,15.97,17.49,18.8,19.89,20.75,20.82,20.87,20.93,20.98,21.03,21.08,21.13,21.18,21.23,21.29,21.34,21.39,21.44,21.49,21.54,21.59,21.65,21.7,21.75,21.8],
    '39_0': <double>[10.63,12.83,14.81,16.57,18.12,19.45,20.57,21.46,21.54,21.59,21.65,21.7,21.75,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8],
    '40_0': <double>[11.13,13.3,15.26,17.0,18.52,19.82,20.91,21.77,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8,21.8],
    '35_1': <double>[6.89,8.87,10.62,12.16,13.48,14.59,15.48,16.15,16.21,16.27,16.34,16.4,16.46,16.52,16.58,16.64,16.7,16.77,16.83,16.89,16.95,17.01,17.07,17.13,17.2,17.26,17.32,17.38],
    '36_1': <double>[7.43,9.45,11.25,12.83,14.2,15.35,16.29,17.01,17.07,17.13,17.2,17.26,17.32,17.38,17.44,17.5,17.56,17.63,17.69,17.75,17.81,17.87,17.93,17.99,18.06,18.12,18.18,18.24],
    '37_1': <double>[7.97,10.03,11.87,13.5,14.92,16.12,17.1,17.87,17.93,17.99,18.06,18.12,18.18,18.24,18.24,18.24,18.24,18.24,18.24,18.24,18.24,18.24,18.24,18.24,18.24,18.24,18.24,18.24],
    '38_1': <double>[8.5,10.5,12.4,14.0,15.4,16.6,17.5,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2],
    '39_1': <double>[8.5,10.5,12.4,14.0,15.4,16.6,17.5,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2],
    '40_1': <double>[8.5,10.5,12.4,14.0,15.4,16.6,17.5,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2,18.2],
  };

  static const Map<String, List<double>> _exchange = <String, List<double>>{
    '35_0': <double>[16.37,17.92,19.35,20.66,21.84,22.89,23.8,24.47,24.59,24.71,24.82,24.92,25.02,25.13,25.23,25.33,25.43,25.52,25.61,25.7,25.79,25.87,25.95,26.03,26.11,26.18,26.25,26.32],
    '36_0': <double>[17.51,19.12,20.59,21.9,23.06,24.07,24.91,25.51,25.63,25.72,25.82,25.91,26.0,26.08,26.17,26.25,26.33,26.4,26.48,26.55,26.62,26.68,26.75,26.81,26.87,26.93,26.98,27.03],
    '37_0': <double>[18.66,20.32,21.82,23.14,24.29,25.25,26.02,26.55,26.66,26.74,26.82,26.89,26.96,27.03,27.03,27.03,27.03,27.03,27.03,27.03,27.03,27.03,27.03,27.03,27.03,27.03,27.03,27.03],
    '38_0': <double>[19.8,21.4,22.8,24.0,25.0,25.9,26.6,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0],
    '39_0': <double>[19.8,21.4,22.8,24.0,25.0,25.9,26.6,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0],
    '40_0': <double>[19.8,21.4,22.8,24.0,25.0,25.9,26.6,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0,27.0],
    '35_1': <double>[14.64,16.1,17.37,18.45,19.37,20.11,20.68,21.05,21.19,21.3,21.42,21.53,21.64,21.74,21.85,21.94,22.04,22.13,22.23,22.31,22.4,22.48,22.56,22.63,22.71,22.78,22.85,22.91],
    '36_1': <double>[15.19,16.65,17.94,19.07,20.05,20.88,21.57,22.07,22.17,22.27,22.36,22.45,22.54,22.62,22.71,22.78,22.86,22.93,23.0,23.07,23.14,23.2,23.26,23.31,23.36,23.41,23.46,23.5],
    '37_1': <double>[15.74,17.2,18.51,19.69,20.74,21.66,22.46,23.07,23.15,23.23,23.3,23.37,23.44,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5],
    '38_1': <double>[16.2,17.6,19.0,20.1,21.2,22.1,23.0,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5],
    '39_1': <double>[16.2,17.6,19.0,20.1,21.2,22.1,23.0,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5],
    '40_1': <double>[16.2,17.6,19.0,20.1,21.2,22.1,23.0,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5,23.5],
  };

  static double toMicromol(double value, BilirubinUnit unit) =>
      unit == BilirubinUnit.micromolPerL ? value : value * micromolPerMgDl;

  static double toMgDl(double micromol) => micromol / micromolPerMgDl;

  static String _key(int gestationalWeeks, bool additionalRisk) =>
      '${gestationalWeeks.clamp(35, 40)}_${additionalRisk ? 1 : 0}';

  static double _interpolate(List<double> values, double ageHours) {
    final double age = ageHours.clamp(_hours.first, _hours.last);
    if (age <= _hours.first) return values.first * micromolPerMgDl;
    for (int i = 1; i < _hours.length; i++) {
      if (age <= _hours[i]) {
        final double fraction =
            (age - _hours[i - 1]) / (_hours[i] - _hours[i - 1]);
        final double mgDl = values[i - 1] +
            (values[i] - values[i - 1]) * fraction;
        return mgDl * micromolPerMgDl;
      }
    }
    return values.last * micromolPerMgDl;
  }

  static double phototherapyThreshold({
    required int gestationalWeeks,
    required double ageHours,
    required bool additionalNeurotoxicityRisk,
  }) =>
      _interpolate(
        _phototherapy[_key(gestationalWeeks, additionalNeurotoxicityRisk)]!,
        ageHours,
      );

  static double exchangeThreshold({
    required int gestationalWeeks,
    required double ageHours,
    required bool additionalNeurotoxicityRisk,
  }) =>
      _interpolate(
        _exchange[_key(gestationalWeeks, additionalNeurotoxicityRisk)]!,
        ageHours,
      );

  static List<double> chartHours() => List<double>.unmodifiable(_hours);

  static List<double> chartPhototherapy({
    required int gestationalWeeks,
    required bool additionalNeurotoxicityRisk,
  }) => _phototherapy[_key(gestationalWeeks, additionalNeurotoxicityRisk)]!
      .map((double value) => value * micromolPerMgDl)
      .toList(growable: false);

  static List<double> chartExchange({
    required int gestationalWeeks,
    required bool additionalNeurotoxicityRisk,
  }) => _exchange[_key(gestationalWeeks, additionalNeurotoxicityRisk)]!
      .map((double value) => value * micromolPerMgDl)
      .toList(growable: false);

  static BilirubinAssessment assess({
    required int gestationalWeeks,
    required double ageHours,
    required double bilirubin,
    required BilirubinUnit unit,
    required BilirubinMeasurementType measurementType,
    required bool additionalNeurotoxicityRisk,
    required bool acuteEncephalopathySigns,
    bool previousPhototherapy = false,
    double? previousBilirubin,
    BilirubinUnit previousUnit = BilirubinUnit.micromolPerL,
    double? previousAgeHours,
  }) {
    if (gestationalWeeks < 35 || gestationalWeeks > 40) {
      throw ArgumentError('Gestational age must be 35–40 completed weeks.');
    }
    if (!ageHours.isFinite || ageHours < 12 || ageHours > 336) {
      throw ArgumentError('Supported postnatal age is 12–336 hours.');
    }
    if (!bilirubin.isFinite || bilirubin < 0) {
      throw ArgumentError('Enter a valid bilirubin value.');
    }

    final double current = toMicromol(bilirubin, unit);
    final double photo = phototherapyThreshold(
      gestationalWeeks: gestationalWeeks,
      ageHours: ageHours,
      additionalNeurotoxicityRisk: additionalNeurotoxicityRisk,
    );
    final double exchange = exchangeThreshold(
      gestationalWeeks: gestationalWeeks,
      ageHours: ageHours,
      additionalNeurotoxicityRisk: additionalNeurotoxicityRisk,
    );
    final double preExchange = math.max(0.0, exchange - 30.0).toDouble();
    final double delta = photo - current;
    final double exchangeDistance = exchange - current;

    double? rate;
    if (previousBilirubin != null && previousAgeHours != null) {
      final double elapsed = ageHours - previousAgeHours;
      if (elapsed > 0) {
        rate = (current - toMicromol(previousBilirubin, previousUnit)) / elapsed;
      }
    }
    final bool rapidRise = rate != null &&
        rate >= (ageHours <= 24 ? 5.0 : 3.5);
    final bool serumConfirmation = measurementType == BilirubinMeasurementType.tcb &&
        (current > 250 || photo - current <= 50);

    final BilirubinZone zone;
    if (acuteEncephalopathySigns) {
      zone = BilirubinZone.acuteEncephalopathy;
    } else if (current >= exchange) {
      zone = BilirubinZone.exchange;
    } else if (current >= preExchange) {
      zone = BilirubinZone.preExchange;
    } else if (current >= photo) {
      zone = BilirubinZone.phototherapy;
    } else if (delta <= 30) {
      zone = BilirubinZone.nearPhototherapy;
    } else {
      zone = BilirubinZone.belowThreshold;
    }

    final List<String> actions = <String>[];
    final List<String> cautions = <String>[];
    if (acuteEncephalopathySigns) {
      actions.addAll(<String>[
        'Treat as possible acute bilirubin encephalopathy: obtain urgent neonatology/NICU support now.',
        'Start intensive phototherapy and prepare for urgent exchange-transfusion assessment regardless of the plotted threshold.',
      ]);
    } else if (zone == BilirubinZone.exchange) {
      actions.addAll(<String>[
        'TSB is at or above the exchange-transfusion threshold. Activate the exchange pathway immediately.',
        'Start/continue intensive phototherapy, establish IV access, notify neonatology and the blood bank, and arrange NICU transfer.',
        'Repeat serum bilirubin every 2–3 hours during escalation.',
      ]);
    } else if (zone == BilirubinZone.preExchange) {
      actions.addAll(<String>[
        'TSB is within 30 µmol/L of the exchange threshold: this is the CPS pre-exchange zone.',
        'Start/continue intensive phototherapy, consult neonatology immediately, establish IV access, notify blood bank and arrange transfer.',
        'Repeat serum bilirubin every 2–3 hours and investigate hemolysis/sepsis as clinically indicated.',
      ]);
    } else if (zone == BilirubinZone.phototherapy) {
      actions.addAll(<String>[
        'Start intensive phototherapy and assess feeding, hydration, weight change and the cause of hyperbilirubinemia.',
        'Measure serum bilirubin within 12–24 hours; use a shorter interval when close to exchange, rapidly rising or clinically unstable.',
      ]);
    } else if (zone == BilirubinZone.nearPhototherapy) {
      actions.addAll(<String>[
        'Bilirubin is within 30 µmol/L below the phototherapy threshold.',
        'Delay discharge or ensure close, reliable reassessment; repeat bilirubin based on trajectory and clinical risk, and consider phototherapy.',
      ]);
    } else {
      actions.add('Below the phototherapy threshold. Use ΔTSB, age, feeding, weight loss, trajectory and follow-up reliability to plan reassessment.');
    }

    if (serumConfirmation) {
      actions.insert(0, 'Obtain a serum TSB before making a treatment or discharge decision.');
    }
    if (rapidRise) {
      actions.add('Rate of rise suggests possible hemolysis; investigate urgently and use the lower-risk threshold pathway as appropriate.');
    }
    if (previousPhototherapy) {
      cautions.add('ΔTSB discharge prediction is not validated after previous phototherapy; use the rebound pathway instead.');
    } else if (ageHours < 12 || ageHours > 120) {
      cautions.add('The CPS ΔTSB discharge-follow-up framework is intended for 12–120 hours.');
    }
    if (measurementType == BilirubinMeasurementType.tcb) {
      cautions.add('TcB is a screening measurement and should not replace TSB when treatment is being considered or soon after phototherapy.');
    }
    cautions.add('Thresholds support—but do not replace—clinical assessment, local policy and neonatal consultation.');

    return BilirubinAssessment(
      gestationalWeeks: gestationalWeeks,
      ageHours: ageHours,
      bilirubinMicromol: current,
      phototherapyThreshold: photo,
      exchangeThreshold: exchange,
      preExchangeThreshold: preExchange,
      deltaTsb: delta,
      distanceFromExchange: exchangeDistance,
      rateOfRise: rate,
      rapidRise: rapidRise,
      requiresSerumConfirmation: serumConfirmation,
      zone: zone,
      recommendations: actions,
      cautions: cautions,
    );
  }
}
