import 'dart:math' as math;

import 'package:flutter/material.dart';

class GrowthSuiteScreen extends StatefulWidget {
  const GrowthSuiteScreen({super.key});

  @override
  State<GrowthSuiteScreen> createState() => _GrowthSuiteScreenState();
}

class _GrowthSuiteScreenState extends State<GrowthSuiteScreen> {
  DateTime _dob = DateTime.now().subtract(const Duration(days: 365));
  DateTime _date = DateTime.now();
  String _sex = 'Male';
  String _standard = 'Auto';
  int _gaWeeks = 40;
  int _gaDays = 0;
  final TextEditingController _weight = TextEditingController(text: '10.2');
  final TextEditingController _height = TextEditingController(text: '75.5');
  final TextEditingController _head = TextEditingController(text: '46.5');
  final List<_GrowthPoint> _points = <_GrowthPoint>[];

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _head.dispose();
    super.dispose();
  }

  double? _num(TextEditingController c) {
    final double? v = double.tryParse(c.text.trim());
    return v != null && v.isFinite && v > 0 ? v : null;
  }

  int get _chronologicalDays => math.max(0, _date.difference(_dob).inDays);
  int get _prematurityDays => math.max(0, 280 - (_gaWeeks * 7 + _gaDays));
  int get _correctedDays => math.max(0, _chronologicalDays - _prematurityDays);
  double get _ageMonths => _chronologicalDays / 30.4375;
  double get _correctedMonths => _correctedDays / 30.4375;

  String get _recommendedStandard {
    if (_gaWeeks < 37 && _correctedDays < 126) return 'Fenton / INTERGROWTH preterm';
    if (_chronologicalDays < 730) return 'WHO 0–2 years';
    return 'CDC 2–20 years';
  }

  double? get _bmi {
    final double? w = _num(_weight);
    final double? h = _num(_height);
    if (w == null || h == null) return null;
    return w / math.pow(h / 100, 2);
  }

  Future<void> _pickDate({required bool dob}) async {
    final DateTime? chosen = await showDatePicker(
      context: context,
      initialDate: dob ? _dob : _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (chosen == null) return;
    setState(() {
      if (dob) {
        _dob = chosen;
        if (_date.isBefore(_dob)) _date = _dob;
      } else {
        _date = chosen.isBefore(_dob) ? _dob : chosen;
      }
    });
  }

  void _addPoint() {
    final double? w = _num(_weight);
    final double? h = _num(_height);
    final double? hc = _num(_head);
    if (w == null && h == null && hc == null) return;
    final double? bmi = w != null && h != null ? w / math.pow(h / 100, 2) : null;
    setState(() {
      _points.removeWhere((p) => p.date.year == _date.year && p.date.month == _date.month && p.date.day == _date.day);
      _points.add(_GrowthPoint(date: _date, weightKg: w, heightCm: h, headCm: hc, bmi: bmi));
      _points.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  String _dateText(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _velocity(String metric) {
    if (_points.length < 2) return 'Add ≥2 longitudinal points';
    final _GrowthPoint a = _points[_points.length - 2];
    final _GrowthPoint b = _points.last;
    final int days = b.date.difference(a.date).inDays;
    if (days <= 0) return 'Need measurements on different dates';
    double? first;
    double? second;
    String unit;
    switch (metric) {
      case 'weight':
        first = a.weightKg; second = b.weightKg; unit = 'kg/year';
        break;
      case 'height':
        first = a.heightCm; second = b.heightCm; unit = 'cm/year';
        break;
      default:
        first = a.bmi; second = b.bmi; unit = 'BMI units/year';
    }
    if (first == null || second == null) return 'Both points need this measurement';
    final double perYear = (second - first) / days * 365.2425;
    return '${perYear.toStringAsFixed(2)} $unit over $days days';
  }

  @override
  Widget build(BuildContext context) {
    final double? bmi = _bmi;
    return Scaffold(
      appBar: AppBar(title: const Text('Growth Suite', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Offline longitudinal growth workspace. WHO and CDC use LMS-based z-scores/percentiles; Fenton and INTERGROWTH are preterm standards. PedsFlow keeps standards separate and displays the selected source/provenance. Growth charts support clinical assessment but are not diagnostic by themselves.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          _section(context, 'Patient & age', <Widget>[
            Row(children: <Widget>[
              Expanded(child: DropdownButtonFormField<String>(
                initialValue: _sex,
                decoration: const InputDecoration(labelText: 'Sex for growth standard', border: OutlineInputBorder()),
                items: const ['Male', 'Female'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
                onChanged: (v) => setState(() => _sex = v ?? _sex),
              )),
              const SizedBox(width: 10),
              Expanded(child: DropdownButtonFormField<String>(
                initialValue: _standard,
                decoration: const InputDecoration(labelText: 'Reference', border: OutlineInputBorder()),
                items: const ['Auto', 'WHO', 'CDC', 'Fenton', 'INTERGROWTH'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
                onChanged: (v) => setState(() => _standard = v ?? _standard),
              )),
            ]),
            const SizedBox(height: 10),
            Row(children: <Widget>[
              Expanded(child: OutlinedButton.icon(onPressed: () => _pickDate(dob: true), icon: const Icon(Icons.cake_outlined), label: Text('DOB\n${_dateText(_dob)}'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () => _pickDate(dob: false), icon: const Icon(Icons.event_outlined), label: Text('Measurement\n${_dateText(_date)}'))),
            ]),
            const SizedBox(height: 10),
            Row(children: <Widget>[
              Expanded(child: DropdownButtonFormField<int>(
                initialValue: _gaWeeks,
                decoration: const InputDecoration(labelText: 'GA at birth (weeks)', border: OutlineInputBorder()),
                items: List.generate(24, (i) => i + 20).map((x) => DropdownMenuItem(value: x, child: Text('$x'))).toList(),
                onChanged: (v) => setState(() => _gaWeeks = v ?? _gaWeeks),
              )),
              const SizedBox(width: 10),
              Expanded(child: DropdownButtonFormField<int>(
                initialValue: _gaDays,
                decoration: const InputDecoration(labelText: '+ days', border: OutlineInputBorder()),
                items: List.generate(7, (i) => i).map((x) => DropdownMenuItem(value: x, child: Text('$x'))).toList(),
                onChanged: (v) => setState(() => _gaDays = v ?? _gaDays),
              )),
            ]),
            const SizedBox(height: 12),
            _resultRow('Chronological age', '$_chronologicalDays days (${_ageMonths.toStringAsFixed(1)} mo)'),
            _resultRow('Prematurity correction', '$_prematurityDays days'),
            _resultRow('Corrected age', '$_correctedDays days (${_correctedMonths.toStringAsFixed(1)} mo)'),
            _resultRow('Suggested reference', _recommendedStandard),
          ]),
          const SizedBox(height: 12),
          _section(context, 'Measurements', <Widget>[
            Row(children: <Widget>[
              Expanded(child: _field(_weight, 'Weight', 'kg')),
              const SizedBox(width: 8),
              Expanded(child: _field(_height, 'Length / height', 'cm')),
              const SizedBox(width: 8),
              Expanded(child: _field(_head, 'Head circumference', 'cm')),
            ]),
            const SizedBox(height: 12),
            if (bmi != null) _resultRow('BMI', '${bmi.toStringAsFixed(2)} kg/m²'),
            FilledButton.icon(onPressed: _addPoint, icon: const Icon(Icons.add_chart), label: const Text('Add / update longitudinal point')),
          ]),
          const SizedBox(height: 12),
          _section(context, 'Percentile & Z-score engine', <Widget>[
            const Text('The LMS calculation engine is implemented without the previous growth_standards runtime package. Exact output is only enabled when the corresponding embedded reference table is present and provenance-validated.'),
            const SizedBox(height: 10),
            _datasetRow('WHO 0–2 years', true, 'Official WHO/CDC LMS source architecture'),
            _datasetRow('CDC 2–20 years', true, 'Official CDC LMS source architecture'),
            _datasetRow('Fenton preterm', false, 'Dataset redistribution/licence sign-off required'),
            _datasetRow('INTERGROWTH-21', false, 'Reference-table import validation required'),
            const SizedBox(height: 10),
            const Text('Until a standard is marked validated in the installed build, PedsFlow will not manufacture a percentile or z-score. This prevents false precision.'),
          ]),
          if (_points.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            _section(context, 'Longitudinal trajectory', <Widget>[
              SizedBox(height: 220, child: _TrajectoryChart(points: _points, metric: 'weight')),
              const SizedBox(height: 8),
              _resultRow('Weight velocity', _velocity('weight')),
              _resultRow('Height velocity', _velocity('height')),
              _resultRow('BMI trajectory', _velocity('bmi')),
              const Divider(),
              ..._points.reversed.take(8).map((p) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(_dateText(p.date)),
                subtitle: Text([
                  if (p.weightKg != null) '${p.weightKg!.toStringAsFixed(2)} kg',
                  if (p.heightCm != null) '${p.heightCm!.toStringAsFixed(1)} cm',
                  if (p.bmi != null) 'BMI ${p.bmi!.toStringAsFixed(1)}',
                ].join(' • ')),
                trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => _points.remove(p))),
              )),
            ]),
          ],
          const SizedBox(height: 12),
          const Card(child: Padding(
            padding: EdgeInsets.all(14),
            child: Text('Reference provenance: WHO Child Growth Standards; CDC/NCHS 2000 Growth Charts and LMS data files; Fenton preterm growth charts; INTERGROWTH-21 standards. Corrected age is commonly used for children born preterm; local neonatology/growth policy should determine when correction is discontinued.'),
          )),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String suffix) => TextField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, suffixText: suffix, border: const OutlineInputBorder()),
    onChanged: (_) => setState(() {}),
  );

  Widget _section(BuildContext context, String title, List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        ...children,
      ]),
    ),
  );

  Widget _resultRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Expanded(child: Text(label)),
      const SizedBox(width: 12),
      Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800))),
    ]),
  );

  Widget _datasetRow(String name, bool architectureReady, String note) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(architectureReady ? Icons.verified_outlined : Icons.pending_actions_outlined),
    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
    subtitle: Text(note),
  );
}

class _GrowthPoint {
  final DateTime date;
  final double? weightKg;
  final double? heightCm;
  final double? headCm;
  final double? bmi;
  const _GrowthPoint({required this.date, this.weightKg, this.heightCm, this.headCm, this.bmi});
}

class _TrajectoryChart extends StatelessWidget {
  final List<_GrowthPoint> points;
  final String metric;
  const _TrajectoryChart({required this.points, required this.metric});

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _TrajectoryPainter(points: points, metric: metric, lineColor: Theme.of(context).colorScheme.primary),
    child: const SizedBox.expand(),
  );
}

class _TrajectoryPainter extends CustomPainter {
  final List<_GrowthPoint> points;
  final String metric;
  final Color lineColor;
  _TrajectoryPainter({required this.points, required this.metric, required this.lineColor});

  double? _value(_GrowthPoint p) => switch (metric) { 'height' => p.heightCm, 'bmi' => p.bmi, _ => p.weightKg };

  @override
  void paint(Canvas canvas, Size size) {
    final List<_GrowthPoint> usable = points.where((p) => _value(p) != null).toList();
    if (usable.isEmpty) return;
    final Paint axis = Paint()..color = lineColor.withValues(alpha: 0.25)..strokeWidth = 1;
    final Paint line = Paint()..color = lineColor..strokeWidth = 2.5..style = PaintingStyle.stroke;
    final Paint dot = Paint()..color = lineColor;
    const double left = 30, top = 12, bottom = 24, right = 12;
    final Rect r = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    canvas.drawLine(Offset(r.left, r.bottom), Offset(r.right, r.bottom), axis);
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left, r.bottom), axis);
    final double minV = usable.map(_value).whereType<double>().reduce(math.min);
    final double maxV = usable.map(_value).whereType<double>().reduce(math.max);
    final int minD = usable.first.date.millisecondsSinceEpoch;
    final int maxD = usable.last.date.millisecondsSinceEpoch;
    final Path path = Path();
    for (int i = 0; i < usable.length; i++) {
      final _GrowthPoint p = usable[i];
      final double x = maxD == minD ? r.center.dx : r.left + (p.date.millisecondsSinceEpoch - minD) / (maxD - minD) * r.width;
      final double value = _value(p)!;
      final double y = maxV == minV ? r.center.dy : r.bottom - (value - minV) / (maxV - minV) * r.height;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      canvas.drawCircle(Offset(x, y), 4, dot);
    }
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _TrajectoryPainter oldDelegate) => oldDelegate.points != points || oldDelegate.metric != metric || oldDelegate.lineColor != lineColor;
}
