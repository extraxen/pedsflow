import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'cdc_growth_repository.dart';
import 'growth_reference_engine.dart';

class GrowthSuiteScreen extends StatefulWidget {
  const GrowthSuiteScreen({super.key});

  @override
  State<GrowthSuiteScreen> createState() => _GrowthSuiteScreenState();
}

class _GrowthSuiteScreenState extends State<GrowthSuiteScreen> {
  DateTime _dob = DateTime.now().subtract(const Duration(days: 365 * 5));
  DateTime _measurementDate = DateTime.now();
  GrowthSex _sex = GrowthSex.male;
  int _gaWeeks = 40;
  int _gaDays = 0;
  bool _useCorrectedAge = true;

  final TextEditingController _weight = TextEditingController(text: '18');
  final TextEditingController _height = TextEditingController(text: '110');

  CdcGrowthRepository? _cdc;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCdc();
  }

  Future<void> _loadCdc() async {
    try {
      final repo = await CdcGrowthRepository.load();
      if (!mounted) return;
      setState(() => _cdc = repo);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error);
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  double? _num(TextEditingController controller) {
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
  double get _ageMonths => _useCorrectedAge && _correctionApplicable
      ? _correctedMonths
      : _chronologicalMonths;

  bool get _ageSupported => _ageMonths >= 0 && _ageMonths < 216.999;

  GrowthReferenceResult? _assess(GrowthMetric metric, double? value) {
    if (value == null || !_ageSupported) return null;

    if (_ageMonths < 24) {
      return GrowthReferenceEngine.assess(
        metric: metric,
        sex: _sex,
        ageMonths: _ageMonths,
        value: value,
      );
    }

    return _cdc?.assess(
      metric: metric,
      sex: _sex,
      ageMonths: _ageMonths,
      value: value,
    );
  }

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
        if (_measurementDate.isBefore(_dob)) _measurementDate = _dob;
      } else {
        _measurementDate = chosen.isBefore(_dob) ? _dob : chosen;
      }
    });
  }

  String _dateText(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _percentile(double p) {
    if (p < 0.1) return '<0.1st';
    if (p > 99.9) return '>99.9th';
    final rounded = p.round();
    final mod100 = rounded % 100;
    final mod10 = rounded % 10;
    if (mod100 >= 11 && mod100 <= 13) return '${rounded}th';
    if (mod10 == 1) return '${rounded}st';
    if (mod10 == 2) return '${rounded}nd';
    if (mod10 == 3) return '${rounded}rd';
    return '${rounded}th';
  }

  @override
  Widget build(BuildContext context) {
    final weight = _num(_weight);
    final height = _num(_height);
    final weightResult = _assess(GrowthMetric.weight, weight);
    final heightResult = _assess(GrowthMetric.lengthHeight, height);
    final bmi = weight != null && height != null
        ? weight / math.pow(height / 100, 2)
        : null;
    final isCdcAge = _ageMonths >= 24;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Growth Suite',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            children: <Widget>[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Enter weight and height once. PedsFlow gives separate weight-for-age and height-for-age centiles and z-scores and plots both growth charts. WHO is used under 2 years; CDC 2000 is used from 2 through 18 years.',
                    style: TextStyle(fontWeight: FontWeight.w700, height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _section(context, 'Patient & age', <Widget>[
                Row(children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<GrowthSex>(
                      initialValue: _sex,
                      decoration: const InputDecoration(
                        labelText: 'Sex for growth chart',
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
                        if (value != null) setState(() => _sex = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
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
                      label: Text('Measure\n${_dateText(_measurementDate)}'),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _gaWeeks,
                      decoration: const InputDecoration(
                        labelText: 'GA at birth',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(24, (i) => i + 20)
                          .map(
                            (week) => DropdownMenuItem(
                              value: week,
                              child: Text('$week weeks'),
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
                      items: List.generate(7, (i) => i)
                          .map(
                            (day) => DropdownMenuItem(
                              value: day,
                              child: Text('$day'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _gaDays = value ?? _gaDays),
                    ),
                  ),
                ]),
                if (_correctionApplicable)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Use corrected age'),
                    subtitle: Text(
                      'Chronological ${_chronologicalMonths.toStringAsFixed(1)} mo; corrected ${_correctedMonths.toStringAsFixed(1)} mo',
                    ),
                    value: _useCorrectedAge,
                    onChanged: (value) =>
                        setState(() => _useCorrectedAge = value),
                  ),
                _resultRow(
                  'Chart age',
                  '${(_ageMonths / 12).toStringAsFixed(2)} years',
                ),
                _resultRow(
                  'Reference',
                  _ageMonths < 24
                      ? 'WHO Child Growth Standards'
                      : 'CDC 2000 Growth Charts',
                ),
              ]),
              const SizedBox(height: 12),
              _section(context, 'Measurements', <Widget>[
                Row(children: <Widget>[
                  Expanded(child: _field(_weight, 'Weight', 'kg')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_height, 'Height / length', 'cm')),
                ]),
                if (bmi != null) ...<Widget>[
                  const SizedBox(height: 8),
                  _resultRow('BMI', bmi.toStringAsFixed(1)),
                ],
                if (!_ageSupported)
                  _warning(
                    context,
                    'This Growth Suite is intentionally capped at 18 years.',
                  ),
                if (_loadError != null && isCdcAge)
                  _warning(
                    context,
                    'CDC reference data could not be loaded. Reinstall this growth-data update.',
                  ),
              ]),
              const SizedBox(height: 12),
              _resultCard(
                context,
                title: 'Weight for age',
                icon: Icons.monitor_weight_outlined,
                value: weight == null
                    ? 'Enter weight'
                    : '${weight.toStringAsFixed(2)} kg',
                result: weightResult,
              ),
              const SizedBox(height: 10),
              _resultCard(
                context,
                title: 'Height for age',
                icon: Icons.height_outlined,
                value: height == null
                    ? 'Enter height'
                    : '${height.toStringAsFixed(1)} cm',
                result: heightResult,
              ),
              if (_ageSupported &&
                  (!isCdcAge || _cdc != null) &&
                  weight != null) ...<Widget>[
                const SizedBox(height: 12),
                _chartSection(
                  context,
                  title: 'Weight-for-age chart',
                  metric: GrowthMetric.weight,
                  value: weight,
                ),
              ],
              if (_ageSupported &&
                  (!isCdcAge || _cdc != null) &&
                  height != null) ...<Widget>[
                const SizedBox(height: 12),
                _chartSection(
                  context,
                  title: 'Height-for-age chart',
                  metric: GrowthMetric.lengthHeight,
                  value: height,
                ),
              ],
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'WHO Child Growth Standards are used below age 2. CDC 2000 Growth Chart LMS data are used from age 2 through 18. Growth charts support clinical assessment and should not be the sole basis for diagnosis.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartSection(
    BuildContext context, {
    required String title,
    required GrowthMetric metric,
    required double value,
  }) =>
      _section(context, title, <Widget>[
        SizedBox(
          height: 390,
          child: _GrowthChart(
            sex: _sex,
            metric: metric,
            ageMonths: _ageMonths,
            value: value,
            cdc: _cdc,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Curves: 3rd, 10th, 25th, 50th, 75th, 90th, 97th. Dot = patient.',
        ),
      ]);

  Widget _resultCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String value,
    required GrowthReferenceResult? result,
  }) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: <Widget>[
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(value),
                ],
              ),
            ),
            if (result != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _percentile(result.percentile),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  Text('z ${result.zScore.toStringAsFixed(2)}'),
                ],
              ),
          ]),
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label,
    String suffix,
  ) =>
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
        ),
      );

  Widget _section(
    BuildContext context,
    String title,
    List<Widget> children,
  ) =>
      Card(
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

  Widget _resultRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: <Widget>[
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
      );

  Widget _warning(BuildContext context, String text) => Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text),
      );
}

class _GrowthChart extends StatelessWidget {
  final GrowthSex sex;
  final GrowthMetric metric;
  final double ageMonths;
  final double value;
  final CdcGrowthRepository? cdc;

  const _GrowthChart({
    required this.sex,
    required this.metric,
    required this.ageMonths,
    required this.value,
    required this.cdc,
  });

  @override
  Widget build(BuildContext context) {
    const percentiles = <({double z, String label})>[
      (z: -1.88079, label: '3'),
      (z: -1.28155, label: '10'),
      (z: -0.67449, label: '25'),
      (z: 0.0, label: '50'),
      (z: 0.67449, label: '75'),
      (z: 1.28155, label: '90'),
      (z: 1.88079, label: '97'),
    ];

    final curves = <_Curve>[];
    if (ageMonths < 24) {
      for (final p in percentiles) {
        curves.add(
          _Curve(
            label: p.label,
            points: GrowthReferenceEngine.curve(
              metric: metric,
              sex: sex,
              z: p.z,
              maxAgeMonths: 24,
            ),
          ),
        );
      }
    } else if (cdc != null) {
      for (final p in percentiles) {
        curves.add(
          _Curve(
            label: p.label,
            points: cdc!.curve(
              metric: metric,
              sex: sex,
              z: p.z,
              startAgeMonths: 24,
              endAgeMonths: 216,
            ),
          ),
        );
      }
    }

    return CustomPaint(
      painter: _ChartPainter(
        curves: curves,
        ageMonths: ageMonths,
        value: value,
        color: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.onSurface,
        minAge: ageMonths < 24 ? 0 : 24,
        maxAge: ageMonths < 24 ? 24 : 216,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _Curve {
  final String label;
  final List<GrowthCurvePoint> points;
  const _Curve({required this.label, required this.points});
}

class _ChartPainter extends CustomPainter {
  final List<_Curve> curves;
  final double ageMonths;
  final double value;
  final Color color;
  final Color textColor;
  final double minAge;
  final double maxAge;

  const _ChartPainter({
    required this.curves,
    required this.ageMonths,
    required this.value,
    required this.color,
    required this.textColor,
    required this.minAge,
    required this.maxAge,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (curves.isEmpty) return;

    const left = 48.0;
    const right = 34.0;
    const top = 18.0;
    const bottom = 34.0;
    final rect =
        Rect.fromLTRB(left, top, size.width - right, size.height - bottom);

    final values = <double>[
      for (final curve in curves)
        for (final point in curve.points) point.value,
      value,
    ];
    double minY = values.reduce(math.min);
    double maxY = values.reduce(math.max);
    final pad = math.max(1.0, (maxY - minY) * 0.06);
    minY -= pad;
    maxY += pad;

    Offset map(double age, double yValue) => Offset(
          rect.left + ((age - minAge) / (maxAge - minAge)) * rect.width,
          rect.bottom - ((yValue - minY) / (maxY - minY)) * rect.height,
        );

    final axis = Paint()
      ..color = textColor.withValues(alpha: 0.25)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.bottom),
      axis,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.bottom),
      axis,
    );

    for (final curve in curves) {
      final median = curve.label == '50';
      final paint = Paint()
        ..color = color.withValues(alpha: median ? 0.95 : 0.42)
        ..strokeWidth = median ? 2.3 : 1.1
        ..style = PaintingStyle.stroke;

      final path = Path();
      bool started = false;
      for (final point in curve.points) {
        final p = map(point.ageMonths, point.value);
        if (!started) {
          path.moveTo(p.dx, p.dy);
          started = true;
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, paint);

      if (curve.points.isNotEmpty) {
        final end = curve.points.last;
        _text(
          canvas,
          '${curve.label}th',
          map(end.ageMonths, end.value).translate(3, -6),
          9,
          color,
        );
      }
    }

    final patient = map(ageMonths, value);
    canvas.drawCircle(patient, 6.5, Paint()..color = color);
    canvas.drawCircle(
      patient,
      9,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final yearsStart = (minAge / 12).ceil();
    final yearsEnd = (maxAge / 12).floor();
    final step = maxAge <= 24 ? 1 : 2;
    for (int year = yearsStart; year <= yearsEnd; year += step) {
      final x = map(year * 12.0, minY).dx;
      canvas.drawLine(
        Offset(x, rect.bottom),
        Offset(x, rect.bottom + 4),
        axis,
      );
      _text(
        canvas,
        '${year}y',
        Offset(x - 7, rect.bottom + 8),
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
      text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
