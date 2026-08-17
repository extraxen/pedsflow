// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'bilirubin_engine.dart';

class BilirubinScreen extends StatefulWidget {
  const BilirubinScreen({super.key});

  @override
  State<BilirubinScreen> createState() => _BilirubinScreenState();
}

class _BilirubinScreenState extends State<BilirubinScreen> {
  final TextEditingController _age = TextEditingController(text: '48');
  final TextEditingController _bilirubin = TextEditingController(text: '220');
  final TextEditingController _previousAge = TextEditingController();
  final TextEditingController _previousBilirubin = TextEditingController();
  final TextEditingController _direct = TextEditingController();

  int _gestation = 38;
  BilirubinUnit _unit = BilirubinUnit.micromolPerL;
  BilirubinMeasurementType _type = BilirubinMeasurementType.tsb;
  bool _hemolysis = false;
  bool _albumin = false;
  bool _sepsis = false;
  bool _instability = false;
  bool _previousPhototherapy = false;
  bool _abeSigns = false;
  BilirubinAssessment? _result;
  String? _error;

  bool get _additionalRisk => _hemolysis || _albumin || _sepsis || _instability;

  @override
  void dispose() {
    _age.dispose();
    _bilirubin.dispose();
    _previousAge.dispose();
    _previousBilirubin.dispose();
    _direct.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController controller) {
    final double? value = double.tryParse(controller.text.trim());
    return value != null && value.isFinite ? value : null;
  }

  void _calculate() {
    try {
      final double? age = _parse(_age);
      final double? bilirubin = _parse(_bilirubin);
      if (age == null || bilirubin == null) {
        throw ArgumentError('Enter a valid age and bilirubin value.');
      }
      final double? priorValue = _parse(_previousBilirubin);
      final double? priorAge = _parse(_previousAge);
      setState(() {
        _result = BilirubinEngine.assess(
          gestationalWeeks: _gestation,
          ageHours: age,
          bilirubin: bilirubin,
          unit: _unit,
          measurementType: _type,
          additionalNeurotoxicityRisk: _additionalRisk,
          acuteEncephalopathySigns: _abeSigns,
          previousPhototherapy: _previousPhototherapy,
          previousBilirubin: priorValue,
          previousUnit: _unit,
          previousAgeHours: priorAge,
        );
        _error = null;
      });
    } on ArgumentError catch (error) {
      setState(() {
        _result = null;
        _error = error.message.toString();
      });
    }
  }

  String _format(double micromol) {
    if (_unit == BilirubinUnit.micromolPerL) {
      return '${micromol.toStringAsFixed(0)} Âµmol/L';
    }
    return '${BilirubinEngine.toMgDl(micromol).toStringAsFixed(1)} mg/dL';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CPS Neonatal Bilirubin'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          _notice(context),
          const SizedBox(height: 12),
          _section(
            context,
            title: '1. Newborn and measurement',
            children: <Widget>[
              DropdownButtonFormField<int>(
                initialValue: _gestation,
                decoration: const InputDecoration(
                  labelText: 'Gestational age (completed weeks)',
                  border: OutlineInputBorder(),
                ),
                items: List<DropdownMenuItem<int>>.generate(
                  6,
                  (int index) => DropdownMenuItem<int>(
                    value: 35 + index,
                    child: Text('${35 + index} weeks'),
                  ),
                ),
                onChanged: (int? value) => setState(() => _gestation = value ?? 38),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _age,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Postnatal age at measurement (hours)',
                  helperText: 'Embedded threshold dataset: 12â€“336 hours',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<BilirubinMeasurementType>(
                segments: const <ButtonSegment<BilirubinMeasurementType>>[
                  ButtonSegment<BilirubinMeasurementType>(
                    value: BilirubinMeasurementType.tsb,
                    label: Text('Serum TSB'),
                  ),
                  ButtonSegment<BilirubinMeasurementType>(
                    value: BilirubinMeasurementType.tcb,
                    label: Text('TcB'),
                  ),
                ],
                selected: <BilirubinMeasurementType>{_type},
                onSelectionChanged: (Set<BilirubinMeasurementType> value) {
                  setState(() => _type = value.first);
                },
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _bilirubin,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Current bilirubin',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<BilirubinUnit>(
                      initialValue: _unit,
                      decoration: const InputDecoration(
                        labelText: 'Units',
                        border: OutlineInputBorder(),
                      ),
                      items: const <DropdownMenuItem<BilirubinUnit>>[
                        DropdownMenuItem<BilirubinUnit>(
                          value: BilirubinUnit.micromolPerL,
                          child: Text('Âµmol/L'),
                        ),
                        DropdownMenuItem<BilirubinUnit>(
                          value: BilirubinUnit.mgPerDl,
                          child: Text('mg/dL'),
                        ),
                      ],
                      onChanged: (BilirubinUnit? value) {
                        setState(() => _unit = value ?? BilirubinUnit.micromolPerL);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _direct,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Direct/conjugated bilirubin (${_unit == BilirubinUnit.micromolPerL ? 'Âµmol/L' : 'mg/dL'}) â€” optional',
                  helperText: 'Persistent jaundice or direct bilirubin >17 Âµmol/L requires cholestasis assessment.',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _section(
            context,
            title: '2. Additional neurotoxicity risk factors',
            subtitle: 'Gestational age is already built into the curve. Select only additional CPS factors.',
            children: <Widget>[
              _check('Suspected/confirmed hemolysis', _hemolysis, (bool value) => _hemolysis = value),
              _check('Albumin <30 g/L', _albumin, (bool value) => _albumin = value),
              _check('Suspected or confirmed sepsis', _sepsis, (bool value) => _sepsis = value),
              _check('Significant respiratory or hemodynamic instability in the preceding 24 h', _instability, (bool value) => _instability = value),
            ],
          ),
          const SizedBox(height: 12),
          _section(
            context,
            title: '3. Serial bilirubin and safety overrides',
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _previousAge,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Previous age (h)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _previousBilirubin,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Previous bilirubin (${_unit == BilirubinUnit.micromolPerL ? 'Âµmol/L' : 'mg/dL'})',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              _check('Infant previously received phototherapy', _previousPhototherapy, (bool value) => _previousPhototherapy = value),
              _check('Any sign of acute bilirubin encephalopathy', _abeSigns, (bool value) => _abeSigns = value),
              if (_abeSigns)
                const Padding(
                  padding: EdgeInsets.only(left: 12, right: 12, bottom: 8),
                  child: Text(
                    'Examples: hypertonia, retrocollis/opisthotonus, high-pitched cry, stupor, seizures, apnea or coma.',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Calculate CPS assessment'),
            ),
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!),
              ),
            ),
          ],
          if (_result != null) ...<Widget>[
            const SizedBox(height: 16),
            _resultCard(context, _result!),
            const SizedBox(height: 12),
            _chartCard(context, _result!),
            const SizedBox(height: 12),
            _recommendationCard(context, _result!),
          ],
          const SizedBox(height: 16),
          _clinicalReference(context),
        ],
      ),
    );
  }

  Widget _notice(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Text(
          'CPS-aligned decision support for newborns â‰¥35 weeks. Uses gestational-age-specific phototherapy and exchange thresholds, Î”TSB, TcB confirmation rules, rate of rise and pre-exchange escalation. Verify against the current CPS statement and local neonatal policy before clinical release.',
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 4),
              Text(subtitle),
            ],
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _check(String text, bool value, ValueChanged<bool> setter) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      title: Text(text),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (bool? next) => setState(() => setter(next ?? false)),
    );
  }

  Color _zoneColor(BuildContext context, BilirubinZone zone) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    switch (zone) {
      case BilirubinZone.belowThreshold:
        return colors.secondaryContainer;
      case BilirubinZone.nearPhototherapy:
        return colors.tertiaryContainer;
      case BilirubinZone.phototherapy:
        return Colors.orange.shade100;
      case BilirubinZone.preExchange:
      case BilirubinZone.exchange:
      case BilirubinZone.acuteEncephalopathy:
        return colors.errorContainer;
    }
  }

  String _zoneTitle(BilirubinZone zone) {
    switch (zone) {
      case BilirubinZone.belowThreshold:
        return 'Below phototherapy threshold';
      case BilirubinZone.nearPhototherapy:
        return 'Within 30 Âµmol/L of phototherapy threshold';
      case BilirubinZone.phototherapy:
        return 'Phototherapy indicated';
      case BilirubinZone.preExchange:
        return 'Pre-exchange escalation zone';
      case BilirubinZone.exchange:
        return 'At/above exchange threshold';
      case BilirubinZone.acuteEncephalopathy:
        return 'Possible acute bilirubin encephalopathy';
    }
  }

  Widget _resultCard(BuildContext context, BilirubinAssessment result) {
    return Card(
      color: _zoneColor(context, result.zone),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_zoneTitle(result.zone), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _metric('Age', '${result.ageHours.toStringAsFixed(1)} h'),
                _metric('TSB/TcB', _format(result.bilirubinMicromol)),
                _metric('Phototherapy', _format(result.phototherapyThreshold)),
                _metric('Î”TSB', '${result.deltaTsb >= 0 ? '+' : ''}${result.deltaTsb.toStringAsFixed(0)} Âµmol/L'),
                _metric('Pre-exchange', _format(result.preExchangeThreshold)),
                _metric('Exchange', _format(result.exchangeThreshold)),
                if (result.rateOfRise != null)
                  _metric('Rate of rise', '${result.rateOfRise!.toStringAsFixed(2)} Âµmol/L/h'),
              ],
            ),
            if (result.requiresSerumConfirmation) ...<Widget>[
              const SizedBox(height: 12),
              const Text('âš  TcB requires confirmatory serum TSB before disposition or treatment.', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 145),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _chartCard(BuildContext context, BilirubinAssessment result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Threshold chart', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Phototherapy, pre-exchange and exchange curves; current value is plotted as a point.'),
            const SizedBox(height: 12),
            SizedBox(
              height: 290,
              width: double.infinity,
              child: CustomPaint(
                painter: _BilirubinChartPainter(
                  gestation: _gestation,
                  risk: _additionalRisk,
                  ageHours: result.ageHours,
                  current: result.bilirubinMicromol,
                  priorAge: _parse(_previousAge),
                  priorValue: _parse(_previousBilirubin) == null
                      ? null
                      : BilirubinEngine.toMicromol(_parse(_previousBilirubin)!, _unit),
                ),
              ),
            ),
            const Wrap(
              spacing: 14,
              children: <Widget>[
                Text('â— Current'),
                Text('â€” Phototherapy'),
                Text('â‹¯ Pre-exchange'),
                Text('â€” Exchange'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _recommendationCard(BuildContext context, BilirubinAssessment result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Recommendations', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...result.recommendations.map((String item) => _bullet(item, Icons.arrow_right_alt)),
            const Divider(height: 24),
            Text('Cautions', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            ...result.cautions.map((String item) => _bullet(item, Icons.info_outline)),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 19),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _clinicalReference(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('CPS management reference', style: TextStyle(fontWeight: FontWeight.w800)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _referenceGroup('TcB confirmation', <String>[
            'Obtain TSB when TcB is within 50 Âµmol/L of the phototherapy threshold or TcB is >250 Âµmol/L.',
            'After phototherapy, TcB should only be used at least 18 hours after stopping treatment.',
          ]),
          _referenceGroup('Intensive phototherapy', <String>[
            'Narrow-spectrum blue light approximately 460â€“490 nm; irradiance â‰¥30 ÂµW/cmÂ²/nm.',
            'Maximize exposed skin and verify device positioning/irradiance.',
            'Check TSB within 12â€“24 h; if rising or nonresponsive, reassess at least every 4â€“6 h and evaluate hemolysis or another cause.',
          ]),
          _referenceGroup('Stopping and rebound', <String>[
            'â‰¥38 weeks: stop when TSB is >30 Âµmol/L below the current phototherapy threshold.',
            '35â€“37 weeks: stop when TSB is >60 Âµmol/L below the threshold.',
            'Routine rebound testing: 12â€“24 h. High-risk/hemolysis: 6â€“12 h, then every 24 h until reassuring.',
          ]),
          _referenceGroup('Pre-exchange', <String>[
            'Within 30 Âµmol/L below exchange threshold: intensive phototherapy, IV access/fluids as appropriate, neonatology, blood bank, transfer and TSB every 2â€“3 h.',
            'Signs of acute bilirubin encephalopathy require urgent exchange assessment regardless of the numeric threshold.',
          ]),
          _referenceGroup('Prolonged jaundice', <String>[
            'Jaundice persisting beyond 14 days warrants total/direct bilirubin and assessment for cholestasis, biliary atresia, infection, hypothyroidism and hemolysis.',
            'Direct bilirubin >17 Âµmol/L is abnormal and requires evaluation.',
          ]),
        ],
      ),
    );
  }

  Widget _referenceGroup(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          ...items.map((String item) => _bullet(item, Icons.circle_outlined)),
        ],
      ),
    );
  }
}

class _BilirubinChartPainter extends CustomPainter {
  final int gestation;
  final bool risk;
  final double ageHours;
  final double current;
  final double? priorAge;
  final double? priorValue;

  const _BilirubinChartPainter({
    required this.gestation,
    required this.risk,
    required this.ageHours,
    required this.current,
    this.priorAge,
    this.priorValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double left = 42;
    const double right = 10;
    const double top = 10;
    const double bottom = 30;
    final Rect plot = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final List<double> hours = BilirubinEngine.chartHours();
    final List<double> photo = BilirubinEngine.chartPhototherapy(gestationalWeeks: gestation, additionalNeurotoxicityRisk: risk);
    final List<double> exchange = BilirubinEngine.chartExchange(gestationalWeeks: gestation, additionalNeurotoxicityRisk: risk);
    final List<double> pre = exchange.map((double value) => math.max(0.0, value - 30.0).toDouble()).toList();
    final double maximum = math.max(550.0, <double>[...exchange, current, if (priorValue != null) priorValue!].reduce(math.max) + 30.0).toDouble();

    double x(double hour) => plot.left + (hour - 12) / (336 - 12) * plot.width;
    double y(double value) => plot.bottom - value / maximum * plot.height;

    final Paint grid = Paint()..color = Colors.grey.withValues(alpha: 0.25)..strokeWidth = 1;
    final TextPainter label = TextPainter(textDirection: TextDirection.ltr);
    for (int value = 0; value <= maximum; value += 100) {
      canvas.drawLine(Offset(plot.left, y(value.toDouble())), Offset(plot.right, y(value.toDouble())), grid);
      label.text = TextSpan(text: '$value', style: const TextStyle(fontSize: 10, color: Colors.grey));
      label.layout();
      label.paint(canvas, Offset(2, y(value.toDouble()) - 6));
    }
    for (final int hour in <int>[12, 48, 96, 168, 240, 336]) {
      canvas.drawLine(Offset(x(hour.toDouble()), plot.top), Offset(x(hour.toDouble()), plot.bottom), grid);
      label.text = TextSpan(text: '$hour', style: const TextStyle(fontSize: 10, color: Colors.grey));
      label.layout();
      label.paint(canvas, Offset(x(hour.toDouble()) - 8, plot.bottom + 6));
    }

    void curve(List<double> values, Color color, {bool dashed = false}) {
      final Paint paint = Paint()..color = color..strokeWidth = 2.4..style = PaintingStyle.stroke;
      final Path path = Path();
      for (int i = 0; i < hours.length; i++) {
        final Offset point = Offset(x(hours[i]), y(values[i]));
        if (i == 0) path.moveTo(point.dx, point.dy); else path.lineTo(point.dx, point.dy);
      }
      if (!dashed) {
        canvas.drawPath(path, paint);
      } else {
        for (int i = 0; i < hours.length - 1; i += 2) {
          canvas.drawLine(Offset(x(hours[i]), y(values[i])), Offset(x(hours[i + 1]), y(values[i + 1])), paint);
        }
      }
    }

    curve(photo, Colors.blue.shade700);
    curve(pre, Colors.orange.shade800, dashed: true);
    curve(exchange, Colors.red.shade700);

    if (priorAge != null && priorValue != null && priorAge! >= 12 && priorAge! <= 336) {
      final Paint trend = Paint()..color = Colors.black54..strokeWidth = 1.5;
      canvas.drawLine(Offset(x(priorAge!), y(priorValue!)), Offset(x(ageHours), y(current)), trend);
      canvas.drawCircle(Offset(x(priorAge!), y(priorValue!)), 4, Paint()..color = Colors.black54);
    }
    canvas.drawCircle(Offset(x(ageHours.clamp(12, 336)), y(current)), 6, Paint()..color = Colors.black);
    canvas.drawRect(plot, Paint()..color = Colors.grey.withValues(alpha: 0.5)..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant _BilirubinChartPainter oldDelegate) =>
      oldDelegate.gestation != gestation ||
      oldDelegate.risk != risk ||
      oldDelegate.ageHours != ageHours ||
      oldDelegate.current != current ||
      oldDelegate.priorAge != priorAge ||
      oldDelegate.priorValue != priorValue;
}

