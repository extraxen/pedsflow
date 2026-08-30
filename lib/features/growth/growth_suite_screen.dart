// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'growth_reference_engine.dart';

class GrowthSuiteScreen extends StatefulWidget {
  const GrowthSuiteScreen({super.key});

  @override
  State<GrowthSuiteScreen> createState() => _GrowthSuiteScreenState();
}

class _GrowthSuiteScreenState extends State<GrowthSuiteScreen> {
  DateTime _dob = DateTime.now().subtract(const Duration(days: 365));
  DateTime _measurementDate = DateTime.now();
  GrowthSex _sex = GrowthSex.male;
  int _gaWeeks = 40;
  int _gaDays = 0;
  bool _useCorrectedAge = true;
  GrowthMetric _metric = GrowthMetric.weight;

  final TextEditingController _weight = TextEditingController(text: '10.2');
  final TextEditingController _height = TextEditingController(text: '75.5');

  final List<_PatientGrowthPoint> _points = <_PatientGrowthPoint>[];

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  double? _number(TextEditingController controller) {
    final value = double.tryParse(controller.text.trim());
    return value != null && value.isFinite && value > 0 ? value : null;
  }

  int get _chronologicalDays =>
      math.max(0, _measurementDate.difference(_dob).inDays);

  int get _prematurityDays =>
      math.max(0, 280 - (_gaWeeks * 7 + _gaDays));

  int get _correctedDays =>
      math.max(0, _chronologicalDays - _prematurityDays);

  double get _chronologicalMonths => _chronologicalDays / 30.4375;
  double get _correctedMonths => _correctedDays / 30.4375;

  bool get _correctionApplicable =>
      _gaWeeks < 37 && _chronologicalDays < 730;

  double get _referenceAgeMonths =>
      _useCorrectedAge && _correctionApplicable
          ? _correctedMonths
          : _chronologicalMonths;

  double? get _currentValue =>
      _metric == GrowthMetric.weight ? _number(_weight) : _number(_height);

  GrowthReferenceResult? get _result {
    final value = _currentValue;
    if (value == null) return null;
    return GrowthReferenceEngine.assess(
      metric: _metric,
      sex: _sex,
      ageMonths: _referenceAgeMonths,
      value: value,
    );
  }

  String _dateText(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate({required bool dob}) async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: dob ? _dob : _measurementDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (chosen == null) return;
    setState(() {
      if (dob) {
        _dob = chosen;
        if (_measurementDate.isBefore(_dob)) {
          _measurementDate = _dob;
        }
      } else {
        _measurementDate = chosen.isBefore(_dob) ? _dob : chosen;
      }
    });
  }

  void _addPoint() {
    final value = _currentValue;
    if (value == null) return;

    setState(() {
      _points.removeWhere(
        (point) =>
            point.date.year == _measurementDate.year &&
            point.date.month == _measurementDate.month &&
            point.date.day == _measurementDate.day &&
            point.metric == _metric,
      );
      _points.add(
        _PatientGrowthPoint(
          date: _measurementDate,
          ageMonths: _referenceAgeMonths,
          metric: _metric,
          value: value,
        ),
      );
      _points.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final supported = GrowthReferenceEngine.supports(
      metric: _metric,
      ageMonths: _referenceAgeMonths,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Growth Suite',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            children: <Widget>[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Working offline growth chart. Validated reference coverage in this build: WHO birth to 24 months and CDC 2 to 5 years for weight-for-age and length/stature-for-age. Percentiles and z-scores use the published LMS equations. Older-child CDC and preterm Fenton/INTERGROWTH tables are not yet enabled.',
                    style: TextStyle(fontWeight: FontWeight.w700, height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _section(
                context,
                'Patient',
                <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<GrowthSex>(
                          initialValue: _sex,
                          decoration: const InputDecoration(
                            labelText: 'Sex for reference',
                            border: OutlineInputBorder(),
                          ),
                          items: const <DropdownMenuItem<GrowthSex>>[
                            DropdownMenuItem(
                              value: GrowthSex.male,
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: GrowthSex.female,
                              child: Text('Female'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _sex = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<GrowthMetric>(
                          initialValue: _metric,
                          decoration: const InputDecoration(
                            labelText: 'Chart',
                            border: OutlineInputBorder(),
                          ),
                          items: const <DropdownMenuItem<GrowthMetric>>[
                            DropdownMenuItem(
                              value: GrowthMetric.weight,
                              child: Text('Weight for age'),
                            ),
                            DropdownMenuItem(
                              value: GrowthMetric.lengthHeight,
                              child: Text('Length / height for age'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _metric = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(dob: true),
                          icon: const Icon(Icons.cake_outlined),
                          label: Text('DOB\n${_dateText(_dob)}'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(dob: false),
                          icon: const Icon(Icons.event_outlined),
                          label: Text(
                            'Measurement\n${_dateText(_measurementDate)}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _gaWeeks,
                          decoration: const InputDecoration(
                            labelText: 'GA at birth (weeks)',
                            border: OutlineInputBorder(),
                          ),
                          items: List<int>.generate(24, (i) => i + 20)
                              .map(
                                (week) => DropdownMenuItem<int>(
                                  value: week,
                                  child: Text('$week'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _gaWeeks = value ?? _gaWeeks),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _gaDays,
                          decoration: const InputDecoration(
                            labelText: '+ days',
                            border: OutlineInputBorder(),
                          ),
                          items: List<int>.generate(7, (i) => i)
                              .map(
                                (day) => DropdownMenuItem<int>(
                                  value: day,
                                  child: Text('$day'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _gaDays = value ?? _gaDays),
                        ),
                      ),
                    ],
                  ),
                  if (_correctionApplicable)
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Use corrected age for charting'),
                      subtitle: Text(
                        'Chronological ${_chronologicalMonths.toStringAsFixed(1)} mo • corrected ${_correctedMonths.toStringAsFixed(1)} mo',
                      ),
                      value: _useCorrectedAge,
                      onChanged: (value) =>
                          setState(() => _useCorrectedAge = value),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _section(
                context,
                'Measurement',
                <Widget>[
                  if (_metric == GrowthMetric.weight)
                    _field(_weight, 'Weight', 'kg')
                  else
                    _field(_height, 'Length / height', 'cm'),
                  const SizedBox(height: 12),
                  _resultRow(
                    'Reference age',
                    '${_referenceAgeMonths.toStringAsFixed(2)} months',
                  ),
                  _resultRow(
                    'Reference',
                    supported
                        ? GrowthReferenceEngine.referenceForAge(
                            _referenceAgeMonths,
                          )
                        : 'Not available in this build',
                  ),
                  if (result != null) ...<Widget>[
                    _resultRow(
                      'Percentile',
                      _formatPercentile(result.percentile),
                    ),
                    _resultRow(
                      'Z-score',
                      result.zScore.toStringAsFixed(2),
                    ),
                  ],
                  if (!supported)
                    _warning(
                      context,
                      'This build has validated LMS data through age 5 years only. PedsFlow will not estimate or extrapolate a percentile beyond the installed reference table.',
                    ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: supported && _currentValue != null
                        ? _addPoint
                        : null,
                    icon: const Icon(Icons.add_chart),
                    label: const Text('Add / update point'),
                  ),
                ],
              ),
              if (supported) ...<Widget>[
                const SizedBox(height: 12),
                _section(
                  context,
                  _metric == GrowthMetric.weight
                      ? 'Weight-for-age chart'
                      : 'Length / height-for-age chart',
                  <Widget>[
                    SizedBox(
                      height: 360,
                      child: _GrowthChart(
                        sex: _sex,
                        metric: _metric,
                        currentAgeMonths: _referenceAgeMonths,
                        currentValue: _currentValue,
                        patientPoints: _points
                            .where((point) => point.metric == _metric)
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: <Widget>[
                        Text('Curves: 3rd, 10th, 25th, 50th, 75th, 90th, 97th'),
                        Text('● Patient'),
                      ],
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Card(
                child: ExpansionTile(
                  title: const Text(
                    'Reference & limitations',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: const <Widget>[
                    Text(
                      'WHO: Child Growth Standards, weight-for-age and length-for-age. CDC: 2000 Growth Charts LMS data files. CDC publishes the LMS equations used here and notes that interpolation may be used between age rows. Growth charts support clinical assessment and are not diagnostic by themselves.',
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This first repaired release intentionally limits exact percentile output to the reference rows embedded and validated in the app. BMI-for-age, head circumference, CDC 5–20 years, and preterm Fenton/INTERGROWTH will be added only with validated source tables.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPercentile(double p) {
    if (p < 0.1) return '<0.1st';
    if (p > 99.9) return '>99.9th';
    if (p < 1 || p > 99) return '${p.toStringAsFixed(1)}th';
    return '${p.round()}th';
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String suffix,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _warning(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PatientGrowthPoint {
  final DateTime date;
  final double ageMonths;
  final GrowthMetric metric;
  final double value;

  const _PatientGrowthPoint({
    required this.date,
    required this.ageMonths,
    required this.metric,
    required this.value,
  });
}

class _GrowthChart extends StatelessWidget {
  final GrowthSex sex;
  final GrowthMetric metric;
  final double currentAgeMonths;
  final double? currentValue;
  final List<_PatientGrowthPoint> patientPoints;

  const _GrowthChart({
    required this.sex,
    required this.metric,
    required this.currentAgeMonths,
    required this.currentValue,
    required this.patientPoints,
  });

  @override
  Widget build(BuildContext context) {
    final maxAge = math.max(24.0, math.min(60.5, currentAgeMonths + 6));
    return CustomPaint(
      painter: _PercentileChartPainter(
        sex: sex,
        metric: metric,
        maxAgeMonths: maxAge,
        currentAgeMonths: currentAgeMonths,
        currentValue: currentValue,
        patientPoints: patientPoints,
        primary: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.onSurface,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _PercentileChartPainter extends CustomPainter {
  final GrowthSex sex;
  final GrowthMetric metric;
  final double maxAgeMonths;
  final double currentAgeMonths;
  final double? currentValue;
  final List<_PatientGrowthPoint> patientPoints;
  final Color primary;
  final Color textColor;

  const _PercentileChartPainter({
    required this.sex,
    required this.metric,
    required this.maxAgeMonths,
    required this.currentAgeMonths,
    required this.currentValue,
    required this.patientPoints,
    required this.primary,
    required this.textColor,
  });

  static const List<({double z, String label})> _curves = <
      ({double z, String label})>[
    (z: -1.88079, label: '3'),
    (z: -1.28155, label: '10'),
    (z: -0.67449, label: '25'),
    (z: 0, label: '50'),
    (z: 0.67449, label: '75'),
    (z: 1.28155, label: '90'),
    (z: 1.88079, label: '97'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const left = 46.0;
    const right = 28.0;
    const top = 18.0;
    const bottom = 34.0;
    final rect = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );

    final allCurves = _curves
        .map(
          (curve) => (
            curve: curve,
            points: GrowthReferenceEngine.curve(
              metric: metric,
              sex: sex,
              z: curve.z,
              maxAgeMonths: maxAgeMonths,
            ),
          ),
        )
        .toList();

    final values = <double>[
      for (final item in allCurves)
        for (final point in item.points) point.value,
      if (currentValue != null) currentValue!,
      ...patientPoints.map((point) => point.value),
    ];
    if (values.isEmpty) return;

    double minY = values.reduce(math.min);
    double maxY = values.reduce(math.max);
    final padding = math.max(1.0, (maxY - minY) * 0.08);
    minY -= padding;
    maxY += padding;

    final axisPaint = Paint()
      ..color = textColor.withValues(alpha: 0.24)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.bottom),
      axisPaint,
    );

    Offset mapPoint(double age, double value) {
      final x = rect.left + (age / maxAgeMonths) * rect.width;
      final y =
          rect.bottom - ((value - minY) / (maxY - minY)) * rect.height;
      return Offset(x, y);
    }

    for (final item in allCurves) {
      final isMedian = item.curve.z == 0;
      final paint = Paint()
        ..color = primary.withValues(alpha: isMedian ? 0.92 : 0.45)
        ..strokeWidth = isMedian ? 2.4 : 1.2
        ..style = PaintingStyle.stroke;
      final path = Path();
      for (int i = 0; i < item.points.length; i++) {
        final p = mapPoint(item.points[i].ageMonths, item.points[i].value);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, paint);

      if (item.points.isNotEmpty) {
        final end = mapPoint(
          item.points.last.ageMonths,
          item.points.last.value,
        );
        _text(
          canvas,
          '${item.curve.label}th',
          end.translate(4, -7),
          9,
          primary,
        );
      }
    }

    for (final point in patientPoints) {
      if (point.ageMonths < 0 || point.ageMonths > maxAgeMonths) continue;
      final offset = mapPoint(point.ageMonths, point.value);
      canvas.drawCircle(offset, 4.5, Paint()..color = textColor);
    }

    if (currentValue != null &&
        currentAgeMonths >= 0 &&
        currentAgeMonths <= maxAgeMonths) {
      final offset = mapPoint(currentAgeMonths, currentValue!);
      canvas.drawCircle(offset, 6, Paint()..color = primary);
      canvas.drawCircle(
        offset,
        8,
        Paint()
          ..color = primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    for (int month = 0; month <= maxAgeMonths.floor(); month += 12) {
      final x = mapPoint(month.toDouble(), minY).dx;
      canvas.drawLine(
        Offset(x, rect.bottom),
        Offset(x, rect.bottom + 4),
        axisPaint,
      );
      _text(
        canvas,
        month < 24 ? '${month}m' : '${(month / 12).round()}y',
        Offset(x - 8, rect.bottom + 8),
        10,
        textColor,
      );
    }

    for (int i = 0; i <= 4; i++) {
      final value = minY + (maxY - minY) * i / 4;
      final y = mapPoint(0, value).dy;
      _text(
        canvas,
        value.toStringAsFixed(metric == GrowthMetric.weight ? 1 : 0),
        Offset(4, y - 6),
        10,
        textColor,
      );
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset offset,
    double size,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: size, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _PercentileChartPainter oldDelegate) {
    return oldDelegate.sex != sex ||
        oldDelegate.metric != metric ||
        oldDelegate.maxAgeMonths != maxAgeMonths ||
        oldDelegate.currentAgeMonths != currentAgeMonths ||
        oldDelegate.currentValue != currentValue ||
        oldDelegate.patientPoints != patientPoints ||
        oldDelegate.primary != primary ||
        oldDelegate.textColor != textColor;
  }
}
