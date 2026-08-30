// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
//
// Offline LMS growth engine.
//
// Reference basis:
// - WHO Child Growth Standards: weight-for-age and length-for-age, birth to 24 months.
// - CDC 2000 Growth Charts: weight-for-age and stature-for-age, 2 to 5 years
//   in this validated first release.
//
// The LMS equations are those published by CDC:
//   z = (((X/M)^L) - 1) / (L*S), L != 0
//   z = ln(X/M) / S, L == 0
//
// Percentile curves are generated from the inverse LMS equation.
// Linear interpolation is used between adjacent published age rows.

import 'dart:math' as math;

enum GrowthSex { male, female }

enum GrowthMetric { weight, lengthHeight }

class LmsRow {
  final double ageMonths;
  final double maleL;
  final double maleM;
  final double maleS;
  final double femaleL;
  final double femaleM;
  final double femaleS;

  const LmsRow(
    this.ageMonths,
    this.maleL,
    this.maleM,
    this.maleS,
    this.femaleL,
    this.femaleM,
    this.femaleS,
  );

  ({double l, double m, double s}) forSex(GrowthSex sex) {
    if (sex == GrowthSex.male) {
      return (l: maleL, m: maleM, s: maleS);
    }
    return (l: femaleL, m: femaleM, s: femaleS);
  }
}

class GrowthReferenceResult {
  final String reference;
  final GrowthMetric metric;
  final double ageMonths;
  final double value;
  final double zScore;
  final double percentile;

  const GrowthReferenceResult({
    required this.reference,
    required this.metric,
    required this.ageMonths,
    required this.value,
    required this.zScore,
    required this.percentile,
  });
}

class GrowthCurvePoint {
  final double ageMonths;
  final double value;

  const GrowthCurvePoint(this.ageMonths, this.value);
}

class GrowthReferenceEngine {
  const GrowthReferenceEngine._();

  static const List<LmsRow> _whoWeight = <LmsRow>[
    LmsRow(0, 0.3487, 3.3464, 0.14602, 0.3809, 3.2322, 0.14171),
    LmsRow(1, 0.2297, 4.4709, 0.13395, 0.1714, 4.1873, 0.13724),
    LmsRow(2, 0.197, 5.5675, 0.12385, 0.0962, 5.1282, 0.13),
    LmsRow(3, 0.1738, 6.3762, 0.11727, 0.0402, 5.8458, 0.12619),
    LmsRow(4, 0.1553, 7.0023, 0.11316, -0.005, 6.4237, 0.12402),
    LmsRow(5, 0.1395, 7.5105, 0.1108, -0.043, 6.8985, 0.12274),
    LmsRow(6, 0.1257, 7.934, 0.10958, -0.0756, 7.297, 0.12204),
    LmsRow(7, 0.1134, 8.297, 0.10902, -0.1039, 7.6422, 0.12178),
    LmsRow(8, 0.1021, 8.6151, 0.10882, -0.1288, 7.9487, 0.12181),
    LmsRow(9, 0.0917, 8.9014, 0.10881, -0.1507, 8.2254, 0.12199),
    LmsRow(10, 0.082, 9.1649, 0.10891, -0.17, 8.48, 0.12223),
    LmsRow(11, 0.073, 9.4122, 0.10906, -0.1872, 8.7192, 0.12247),
    LmsRow(12, 0.0644, 9.6479, 0.10925, -0.2024, 8.9481, 0.12268),
    LmsRow(13, 0.0563, 9.8749, 0.10949, -0.2158, 9.1699, 0.12283),
    LmsRow(14, 0.0487, 10.0953, 0.10976, -0.2278, 9.387, 0.12294),
    LmsRow(15, 0.0413, 10.3108, 0.11007, -0.2384, 9.6008, 0.12299),
    LmsRow(16, 0.0343, 10.5228, 0.11041, -0.2478, 9.8124, 0.12303),
    LmsRow(17, 0.0275, 10.7319, 0.11079, -0.2562, 10.0226, 0.12306),
    LmsRow(18, 0.0211, 10.9385, 0.11119, -0.2637, 10.2315, 0.12309),
    LmsRow(19, 0.0148, 11.143, 0.11164, -0.2703, 10.4393, 0.12315),
    LmsRow(20, 0.0087, 11.3462, 0.11211, -0.2762, 10.6464, 0.12323),
    LmsRow(21, 0.0029, 11.5486, 0.11261, -0.2815, 10.8534, 0.12335),
    LmsRow(22, -0.0028, 11.7504, 0.11314, -0.2862, 11.0608, 0.1235),
    LmsRow(23, -0.0083, 11.9514, 0.11369, -0.2903, 11.2688, 0.12369),
    LmsRow(24, -0.0137, 12.1515, 0.11426, -0.2941, 11.4775, 0.1239),
  ];

  static const List<LmsRow> _whoLength = <LmsRow>[
    LmsRow(0, 1, 49.8842, 0.03795, 1, 49.1477, 0.0379),
    LmsRow(1, 1, 54.7244, 0.03557, 1, 53.6872, 0.0364),
    LmsRow(2, 1, 58.4249, 0.03424, 1, 57.0673, 0.03568),
    LmsRow(3, 1, 61.4292, 0.03328, 1, 59.8029, 0.0352),
    LmsRow(4, 1, 63.886, 0.03257, 1, 62.0899, 0.03486),
    LmsRow(5, 1, 65.9026, 0.03204, 1, 64.0301, 0.03463),
    LmsRow(6, 1, 67.6236, 0.03165, 1, 65.7311, 0.03448),
    LmsRow(7, 1, 69.1645, 0.03139, 1, 67.2873, 0.03441),
    LmsRow(8, 1, 70.5994, 0.03124, 1, 68.7498, 0.0344),
    LmsRow(9, 1, 71.9687, 0.03117, 1, 70.1435, 0.03444),
    LmsRow(10, 1, 73.2812, 0.03118, 1, 71.4818, 0.03452),
    LmsRow(11, 1, 74.5388, 0.03125, 1, 72.771, 0.03464),
    LmsRow(12, 1, 75.7488, 0.03137, 1, 74.015, 0.03479),
    LmsRow(13, 1, 76.9186, 0.03154, 1, 75.2176, 0.03496),
    LmsRow(14, 1, 78.0497, 0.03174, 1, 76.3817, 0.03514),
    LmsRow(15, 1, 79.1458, 0.03197, 1, 77.5099, 0.03534),
    LmsRow(16, 1, 80.2113, 0.03222, 1, 78.6055, 0.03555),
    LmsRow(17, 1, 81.2487, 0.0325, 1, 79.671, 0.03576),
    LmsRow(18, 1, 82.2587, 0.03279, 1, 80.7079, 0.03598),
    LmsRow(19, 1, 83.2418, 0.0331, 1, 81.7182, 0.0362),
    LmsRow(20, 1, 84.1996, 0.03342, 1, 82.7036, 0.03643),
    LmsRow(21, 1, 85.1348, 0.03376, 1, 83.6654, 0.03666),
    LmsRow(22, 1, 86.0477, 0.0341, 1, 84.604, 0.03688),
    LmsRow(23, 1, 86.941, 0.03445, 1, 85.5202, 0.03711),
    LmsRow(24, 1, 87.8161, 0.03479, 1, 86.4153, 0.03734),
  ];

  static const List<LmsRow> _cdcWeight2to5 = <LmsRow>[
    LmsRow(24, -0.20615, 12.67076, 0.108126, -0.73534, 12.05504, 0.107399),
    LmsRow(24.5, -0.2165, 12.74154, 0.108166, -0.75221, 12.13456, 0.10774),
    LmsRow(25.5, -0.23979, 12.88102, 0.108275, -0.78423, 12.29102, 0.108477),
    LmsRow(26.5, -0.26632, 13.01842, 0.108421, -0.8141, 12.44469, 0.109281),
    LmsRow(27.5, -0.29575, 13.1545, 0.108605, -0.84194, 12.59622, 0.110144),
    LmsRow(28.5, -0.32773, 13.2899, 0.108826, -0.86789, 12.74621, 0.111061),
    LmsRow(29.5, -0.36182, 13.42519, 0.109083, -0.8921, 12.89517, 0.112023),
    LmsRow(30.5, -0.39757, 13.56088, 0.109378, -0.91472, 13.04357, 0.113023),
    LmsRow(31.5, -0.43452, 13.69738, 0.109708, -0.93588, 13.19181, 0.114056),
    LmsRow(32.5, -0.47219, 13.83505, 0.110073, -0.95572, 13.34023, 0.115115),
    LmsRow(33.5, -0.51012, 13.97418, 0.110473, -0.97438, 13.48913, 0.116193),
    LmsRow(34.5, -0.54789, 14.11503, 0.110907, -0.99198, 13.63877, 0.117286),
    LmsRow(35.5, -0.58507, 14.2578, 0.111375, -1.00864, 13.78937, 0.118387),
    LmsRow(36.5, -0.62132, 14.40263, 0.111875, -1.02447, 13.94108, 0.119492),
    LmsRow(37.5, -0.6563, 14.54965, 0.112406, -1.03957, 14.09407, 0.120596),
    LmsRow(38.5, -0.68974, 14.69893, 0.112967, -1.05404, 14.24844, 0.121695),
    LmsRow(39.5, -0.72141, 14.85054, 0.113558, -1.06795, 14.40429, 0.122785),
    LmsRow(40.5, -0.75118, 15.00449, 0.114177, -1.08137, 14.56168, 0.123863),
    LmsRow(41.5, -0.7789, 15.16078, 0.114822, -1.09438, 14.72064, 0.124927),
    LmsRow(42.5, -0.80452, 15.3194, 0.115493, -1.10702, 14.88121, 0.125973),
    LmsRow(43.5, -0.828, 15.4803, 0.116188, -1.11934, 15.04341, 0.127),
    LmsRow(44.5, -0.84938, 15.64343, 0.116904, -1.13137, 15.20721, 0.128006),
    LmsRow(45.5, -0.8687, 15.80873, 0.117641, -1.14314, 15.37263, 0.12899),
    LmsRow(46.5, -0.88603, 15.9761, 0.118397, -1.15466, 15.53962, 0.129951),
    LmsRow(47.5, -0.90151, 16.14548, 0.119169, -1.16596, 15.70817, 0.130889),
    LmsRow(48.5, -0.91524, 16.31677, 0.119955, -1.17703, 15.87824, 0.131802),
    LmsRow(49.5, -0.92738, 16.48986, 0.120755, -1.18787, 16.04978, 0.132692),
    LmsRow(50.5, -0.93807, 16.66468, 0.121565, -1.19848, 16.22277, 0.133559),
    LmsRow(51.5, -0.94748, 16.8411, 0.122385, -1.20885, 16.39715, 0.134403),
    LmsRow(52.5, -0.95577, 17.01904, 0.123212, -1.21897, 16.57289, 0.135226),
    LmsRow(53.5, -0.9631, 17.19839, 0.124044, -1.2288, 16.74994, 0.136028),
    LmsRow(54.5, -0.96963, 17.37906, 0.124879, -1.23833, 16.92827, 0.136811),
    LmsRow(55.5, -0.97553, 17.56096, 0.125716, -1.24754, 17.10783, 0.137576),
    LmsRow(56.5, -0.98094, 17.744, 0.126554, -1.25639, 17.28859, 0.138324),
    LmsRow(57.5, -0.98601, 17.92809, 0.12739, -1.26486, 17.47052, 0.139058),
    LmsRow(58.5, -0.99087, 18.11316, 0.128224, -1.27293, 17.65361, 0.139779),
    LmsRow(59.5, -0.99564, 18.29912, 0.129054, -1.28055, 17.83782, 0.14049),
    LmsRow(60.5, -1.00045, 18.48592, 0.129879, -1.28769, 18.02314, 0.141191),
  ];

  static const List<LmsRow> _cdcStature2to5 = <LmsRow>[
    LmsRow(24, 0.94152, 86.4522, 0.040322, 1.07245, 84.97556, 0.040791),
    LmsRow(24.5, 1.00721, 86.86161, 0.040396, 1.05127, 85.39732, 0.04086),
    LmsRow(25.5, 0.83725, 87.65247, 0.040578, 1.04195, 86.29026, 0.041142),
    LmsRow(26.5, 0.68149, 88.42326, 0.040723, 1.01259, 87.15714, 0.041349),
    LmsRow(27.5, 0.53878, 89.17549, 0.040833, 0.97054, 87.99602, 0.0415),
    LmsRow(28.5, 0.4077, 89.91041, 0.040909, 0.92113, 88.80551, 0.041611),
    LmsRow(29.5, 0.28676, 90.62908, 0.040952, 0.86822, 89.58477, 0.041692),
    LmsRow(30.5, 0.17449, 91.33242, 0.040965, 0.81454, 90.33342, 0.041754),
    LmsRow(31.5, 0.06944, 92.02127, 0.04095, 0.76196, 91.05154, 0.041804),
    LmsRow(32.5, -0.02972, 92.69638, 0.040909, 0.71166, 91.73964, 0.041847),
    LmsRow(33.5, -0.12425, 93.35847, 0.040844, 0.66432, 92.39854, 0.041888),
    LmsRow(34.5, -0.21529, 94.00823, 0.040758, 0.62029, 93.02945, 0.041929),
    LmsRow(35.5, -0.30385, 94.64637, 0.040654, 0.57956, 93.63382, 0.041972),
    LmsRow(36.5, -0.39092, 95.27359, 0.040534, 0.54198, 94.21336, 0.042018),
    LmsRow(37.5, -0.2548, 95.91475, 0.040573, 0.51143, 94.79643, 0.042105),
    LmsRow(38.5, -0.12565, 96.54734, 0.040617, 0.4828, 95.37392, 0.0422),
    LmsRow(39.5, -0.00317, 97.17191, 0.040666, 0.45552, 95.94693, 0.0423),
    LmsRow(40.5, 0.11291, 97.78898, 0.040721, 0.42915, 96.51645, 0.042405),
    LmsRow(41.5, 0.22275, 98.39903, 0.040782, 0.40335, 97.08337, 0.042513),
    LmsRow(42.5, 0.32653, 99.00254, 0.040848, 0.37788, 97.64848, 0.042622),
    LmsRow(43.5, 0.42436, 99.59998, 0.040919, 0.35256, 98.21247, 0.042731),
    LmsRow(44.5, 0.51635, 100.19176, 0.040996, 0.32727, 98.77593, 0.04284),
    LmsRow(45.5, 0.6026, 100.77832, 0.041076, 0.30196, 99.3394, 0.042947),
    LmsRow(46.5, 0.68317, 101.36004, 0.041162, 0.27658, 99.90331, 0.043054),
    LmsRow(47.5, 0.75816, 101.93731, 0.041251, 0.25116, 100.46805, 0.043158),
    LmsRow(48.5, 0.82764, 102.51047, 0.041344, 0.22571, 101.03393, 0.04326),
    LmsRow(49.5, 0.89169, 103.07989, 0.041441, 0.20027, 101.60119, 0.043359),
    LmsRow(50.5, 0.95039, 103.64586, 0.04154, 0.17491, 102.17004, 0.043456),
    LmsRow(51.5, 1.00383, 104.20871, 0.041641, 0.1497, 102.74061, 0.043551),
    LmsRow(52.5, 1.05214, 104.76873, 0.041745, 0.12471, 103.31301, 0.043642),
    LmsRow(53.5, 1.09537, 105.32616, 0.04185, 0.10001, 103.88728, 0.043731),
    LmsRow(54.5, 1.13365, 105.88128, 0.041956, 0.0757, 104.46345, 0.043817),
    LmsRow(55.5, 1.1671, 106.43431, 0.042063, 0.05185, 105.04149, 0.0439),
    LmsRow(56.5, 1.19585, 106.98548, 0.04217, 0.02854, 105.62133, 0.04398),
    LmsRow(57.5, 1.22, 107.53497, 0.042277, 0.00585, 106.20289, 0.044058),
    LmsRow(58.5, 1.23972, 108.08297, 0.042383, -0.01613, 106.78606, 0.044133),
    LmsRow(59.5, 1.25512, 108.62965, 0.042489, -0.03735, 107.37068, 0.044206),
    LmsRow(60.5, 1.26637, 109.17514, 0.042593, -0.05773, 107.9566, 0.044277),
  ];

  static bool supports({
    required GrowthMetric metric,
    required double ageMonths,
  }) =>
      ageMonths >= 0 && ageMonths <= 60.5;

  static String referenceForAge(double ageMonths) =>
      ageMonths < 24 ? 'WHO Child Growth Standards' : 'CDC 2000 Growth Charts';

  static List<LmsRow> _table(GrowthMetric metric, double ageMonths) {
    if (ageMonths < 24) {
      return metric == GrowthMetric.weight ? _whoWeight : _whoLength;
    }
    return metric == GrowthMetric.weight ? _cdcWeight2to5 : _cdcStature2to5;
  }

  static ({double l, double m, double s})? lmsAt({
    required GrowthMetric metric,
    required GrowthSex sex,
    required double ageMonths,
  }) {
    if (!supports(metric: metric, ageMonths: ageMonths)) return null;
    final rows = _table(metric, ageMonths);

    if (ageMonths <= rows.first.ageMonths) return rows.first.forSex(sex);
    if (ageMonths >= rows.last.ageMonths) return rows.last.forSex(sex);

    for (int i = 0; i < rows.length - 1; i++) {
      final a = rows[i];
      final b = rows[i + 1];
      if (ageMonths >= a.ageMonths && ageMonths <= b.ageMonths) {
        final t = (ageMonths - a.ageMonths) / (b.ageMonths - a.ageMonths);
        final av = a.forSex(sex);
        final bv = b.forSex(sex);
        return (
          l: av.l + (bv.l - av.l) * t,
          m: av.m + (bv.m - av.m) * t,
          s: av.s + (bv.s - av.s) * t,
        );
      }
    }
    return null;
  }

  static double zScore({
    required double x,
    required double l,
    required double m,
    required double s,
  }) {
    if (l.abs() < 1e-12) return math.log(x / m) / s;
    return (math.pow(x / m, l) - 1) / (l * s);
  }

  static double valueAtZ({
    required double z,
    required double l,
    required double m,
    required double s,
  }) {
    if (l.abs() < 1e-12) return m * math.exp(s * z);
    final base = 1 + l * s * z;
    if (base <= 0) return double.nan;
    return m * math.pow(base, 1 / l);
  }

  static double normalCdf(double z) {
    // Abramowitz-Stegun approximation; accurate enough for display percentiles.
    final sign = z < 0 ? -1.0 : 1.0;
    final x = z.abs() / math.sqrt(2);
    final t = 1 / (1 + 0.3275911 * x);
    final erf = sign *
        (1 -
            (((((1.061405429 * t - 1.453152027) * t + 1.421413741) * t -
                            0.284496736) *
                        t +
                    0.254829592) *
                t) *
                math.exp(-x * x));
    return 0.5 * (1 + erf);
  }

  static GrowthReferenceResult? assess({
    required GrowthMetric metric,
    required GrowthSex sex,
    required double ageMonths,
    required double value,
  }) {
    final lms = lmsAt(metric: metric, sex: sex, ageMonths: ageMonths);
    if (lms == null || value <= 0) return null;
    final z = zScore(x: value, l: lms.l, m: lms.m, s: lms.s);
    return GrowthReferenceResult(
      reference: referenceForAge(ageMonths),
      metric: metric,
      ageMonths: ageMonths,
      value: value,
      zScore: z,
      percentile: normalCdf(z) * 100,
    );
  }

  static List<GrowthCurvePoint> curve({
    required GrowthMetric metric,
    required GrowthSex sex,
    required double z,
    required double maxAgeMonths,
  }) {
    final cappedMax = math.min(60.5, math.max(0, maxAgeMonths));
    final points = <GrowthCurvePoint>[];
    double age = 0;
    while (age <= cappedMax + 0.001) {
      final lms = lmsAt(metric: metric, sex: sex, ageMonths: age);
      if (lms != null) {
        final value = valueAtZ(z: z, l: lms.l, m: lms.m, s: lms.s);
        if (value.isFinite) points.add(GrowthCurvePoint(age, value));
      }
      age += age < 24 ? 1 : 0.5;
    }
    return points;
  }
}
