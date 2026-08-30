import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;

import 'growth_reference_engine.dart';

class CdcLmsRow {
  final GrowthSex sex;
  final double ageMonths;
  final double l;
  final double m;
  final double s;

  const CdcLmsRow({
    required this.sex,
    required this.ageMonths,
    required this.l,
    required this.m,
    required this.s,
  });
}

class CdcGrowthRepository {
  final List<CdcLmsRow> weightRows;
  final List<CdcLmsRow> statureRows;

  const CdcGrowthRepository._({
    required this.weightRows,
    required this.statureRows,
  });

  static Future<CdcGrowthRepository> load() async {
    final weightCsv =
        await rootBundle.loadString('assets/growth/cdc_wtage_2_20.csv');
    final statureCsv =
        await rootBundle.loadString('assets/growth/cdc_statage_2_20.csv');

    return CdcGrowthRepository._(
      weightRows: parseCsv(weightCsv),
      statureRows: parseCsv(statureCsv),
    );
  }

  static List<CdcLmsRow> parseCsv(String csv) {
    final lines = csv
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (lines.length < 2) return const <CdcLmsRow>[];

    final header =
        lines.first.split(',').map((e) => e.trim().toLowerCase()).toList();

    int col(String name) => header.indexOf(name.toLowerCase());

    final sexCol = col('sex');
    final ageCol = col('agemos');
    final lCol = col('l');
    final mCol = col('m');
    final sCol = col('s');

    if (<int>[sexCol, ageCol, lCol, mCol, sCol].any((i) => i < 0)) {
      throw const FormatException(
        'CDC growth CSV is missing Sex, Agemos, L, M, or S.',
      );
    }

    final rows = <CdcLmsRow>[];
    for (final line in lines.skip(1)) {
      final cells = line.split(',').map((e) => e.trim()).toList();
      if (cells.length <= math.max(sCol, math.max(mCol, lCol))) continue;

      final sexRaw = int.tryParse(cells[sexCol]);
      final age = double.tryParse(cells[ageCol]);
      final l = double.tryParse(cells[lCol]);
      final m = double.tryParse(cells[mCol]);
      final s = double.tryParse(cells[sCol]);
      if (sexRaw == null || age == null || l == null || m == null || s == null) {
        continue;
      }

      rows.add(
        CdcLmsRow(
          sex: sexRaw == 1 ? GrowthSex.male : GrowthSex.female,
          ageMonths: age,
          l: l,
          m: m,
          s: s,
        ),
      );
    }
    rows.sort((a, b) {
      final sexCompare = a.sex.index.compareTo(b.sex.index);
      return sexCompare != 0
          ? sexCompare
          : a.ageMonths.compareTo(b.ageMonths);
    });
    return rows;
  }

  List<CdcLmsRow> _rowsFor(GrowthMetric metric, GrowthSex sex) {
    final source =
        metric == GrowthMetric.weight ? weightRows : statureRows;
    return source.where((row) => row.sex == sex).toList();
  }

  ({double l, double m, double s})? lmsAt({
    required GrowthMetric metric,
    required GrowthSex sex,
    required double ageMonths,
  }) {
    final rows = _rowsFor(metric, sex);
    if (rows.isEmpty ||
        ageMonths < rows.first.ageMonths ||
        ageMonths > rows.last.ageMonths) {
      return null;
    }

    for (int i = 0; i < rows.length - 1; i++) {
      final a = rows[i];
      final b = rows[i + 1];
      if (ageMonths >= a.ageMonths && ageMonths <= b.ageMonths) {
        final t = (ageMonths - a.ageMonths) / (b.ageMonths - a.ageMonths);
        return (
          l: a.l + (b.l - a.l) * t,
          m: a.m + (b.m - a.m) * t,
          s: a.s + (b.s - a.s) * t,
        );
      }
    }

    final row = rows.last;
    return (l: row.l, m: row.m, s: row.s);
  }

  GrowthReferenceResult? assess({
    required GrowthMetric metric,
    required GrowthSex sex,
    required double ageMonths,
    required double value,
  }) {
    final lms = lmsAt(metric: metric, sex: sex, ageMonths: ageMonths);
    if (lms == null || value <= 0) return null;
    final z = GrowthReferenceEngine.zScore(
      x: value,
      l: lms.l,
      m: lms.m,
      s: lms.s,
    );
    return GrowthReferenceResult(
      reference: 'CDC 2000 Growth Charts',
      metric: metric,
      ageMonths: ageMonths,
      value: value,
      zScore: z,
      percentile: GrowthReferenceEngine.normalCdf(z) * 100,
    );
  }

  List<GrowthCurvePoint> curve({
    required GrowthMetric metric,
    required GrowthSex sex,
    required double z,
    required double startAgeMonths,
    required double endAgeMonths,
  }) {
    final rows = _rowsFor(metric, sex);
    if (rows.isEmpty) return const <GrowthCurvePoint>[];

    final start = math.max(startAgeMonths, rows.first.ageMonths);
    final end = math.min(endAgeMonths, rows.last.ageMonths);
    final points = <GrowthCurvePoint>[];

    for (double age = start; age <= end + 0.001; age += 1) {
      final lms = lmsAt(metric: metric, sex: sex, ageMonths: age);
      if (lms == null) continue;
      final value = GrowthReferenceEngine.valueAtZ(
        z: z,
        l: lms.l,
        m: lms.m,
        s: lms.s,
      );
      if (value.isFinite) points.add(GrowthCurvePoint(age, value));
    }
    return points;
  }
}
