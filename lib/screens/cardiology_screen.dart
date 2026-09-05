// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.

import 'package:flutter/material.dart';

class CardiologyScreen extends StatelessWidget {
  const CardiologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cardiology',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.monitor_heart_outlined,
                        size: 34,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Pediatric Cardiology',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Age-aware ECG reference tools for bedside interpretation.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'ECG',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.stacked_line_chart),
                  ),
                  title: const Text(
                    'Pediatric ECG Normal Values',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Heart rate, QRS axis, PR interval, QRS duration and QTc by age and sex',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PediatricEcgNormalValuesScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.fact_check_outlined),
                  ),
                  title: Text(
                    'ECG Interpretation Guide',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    'Rate → rhythm → axis → intervals → chambers → ST-T changes',
                  ),
                  trailing: Chip(label: Text('Next')),
                ),
              ),
              const SizedBox(height: 10),
              const Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.explore_outlined),
                  ),
                  title: Text(
                    'Axis Helper',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    'Rapid pediatric frontal-plane QRS axis interpretation',
                  ),
                  trailing: Chip(label: Text('Next')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PediatricEcgNormalValuesScreen extends StatefulWidget {
  const PediatricEcgNormalValuesScreen({super.key});

  @override
  State<PediatricEcgNormalValuesScreen> createState() =>
      _PediatricEcgNormalValuesScreenState();
}

class _PediatricEcgNormalValuesScreenState
    extends State<PediatricEcgNormalValuesScreen> {
  int _ageIndex = 7;
  String _sex = 'M';

  final TextEditingController _hr = TextEditingController();
  final TextEditingController _axis = TextEditingController();
  final TextEditingController _pr = TextEditingController();
  final TextEditingController _qrs = TextEditingController();
  final TextEditingController _qtc = TextEditingController();

  static const List<_EcgAgeBand> _bands = <_EcgAgeBand>[
    _EcgAgeBand(
      '0–1 month',
      male: _EcgValues(
        hr: _EcgRange(160, 129, 192),
        axis: _EcgRange(97, 75, 140),
        pr: _EcgRange(99, 77, 120),
        qrs: _EcgRange(67, 50, 85),
        qtc: _EcgRange(413, 378, 448),
      ),
      female: _EcgValues(
        hr: _EcgRange(155, 136, 216),
        axis: _EcgRange(110, 63, 155),
        pr: _EcgRange(101, 91, 121),
        qrs: _EcgRange(67, 54, 79),
        qtc: _EcgRange(420, 379, 462),
      ),
    ),
    _EcgAgeBand(
      '1–3 months',
      male: _EcgValues(
        hr: _EcgRange(152, 126, 187),
        axis: _EcgRange(87, 37, 138),
        pr: _EcgRange(98, 85, 120),
        qrs: _EcgRange(64, 52, 77),
        qtc: _EcgRange(419, 396, 458),
      ),
      female: _EcgValues(
        hr: _EcgRange(154, 126, 200),
        axis: _EcgRange(80, 39, 121),
        pr: _EcgRange(99, 78, 133),
        qrs: _EcgRange(63, 48, 77),
        qtc: _EcgRange(424, 381, 454),
      ),
    ),
    _EcgAgeBand(
      '3–6 months',
      male: _EcgValues(
        hr: _EcgRange(134, 112, 165),
        axis: _EcgRange(66, -6, 107),
        pr: _EcgRange(106, 87, 134),
        qrs: _EcgRange(66, 54, 85),
        qtc: _EcgRange(422, 391, 453),
      ),
      female: _EcgValues(
        hr: _EcgRange(139, 122, 191),
        axis: _EcgRange(70, 17, 108),
        pr: _EcgRange(106, 84, 127),
        qrs: _EcgRange(64, 50, 78),
        qtc: _EcgRange(418, 386, 448),
      ),
    ),
    _EcgAgeBand(
      '6–12 months',
      male: _EcgValues(
        hr: _EcgRange(128, 106, 194),
        axis: _EcgRange(68, 14, 122),
        pr: _EcgRange(114, 82, 141),
        qrs: _EcgRange(69, 52, 86),
        qtc: _EcgRange(411, 379, 449),
      ),
      female: _EcgValues(
        hr: _EcgRange(134, 106, 187),
        axis: _EcgRange(67, 1, 102),
        pr: _EcgRange(109, 88, 133),
        qrs: _EcgRange(64, 52, 80),
        qtc: _EcgRange(414, 381, 446),
      ),
    ),
    _EcgAgeBand(
      '1–3 years',
      male: _EcgValues(
        hr: _EcgRange(119, 97, 155),
        axis: _EcgRange(64, -4, 118),
        pr: _EcgRange(118, 86, 151),
        qrs: _EcgRange(71, 54, 88),
        qtc: _EcgRange(412, 383, 455),
      ),
      female: _EcgValues(
        hr: _EcgRange(128, 95, 178),
        axis: _EcgRange(69, 2, 121),
        pr: _EcgRange(113, 78, 147),
        qrs: _EcgRange(68, 54, 85),
        qtc: _EcgRange(417, 381, 447),
      ),
    ),
    _EcgAgeBand(
      '3–5 years',
      male: _EcgValues(
        hr: _EcgRange(98, 73, 123),
        axis: _EcgRange(70, 7, 112),
        pr: _EcgRange(121, 98, 152),
        qrs: _EcgRange(75, 58, 92),
        qtc: _EcgRange(412, 377, 448),
      ),
      female: _EcgValues(
        hr: _EcgRange(101, 78, 124),
        axis: _EcgRange(69, 3, 106),
        pr: _EcgRange(123, 99, 153),
        qrs: _EcgRange(71, 58, 88),
        qtc: _EcgRange(415, 388, 442),
      ),
    ),
    _EcgAgeBand(
      '5–8 years',
      male: _EcgValues(
        hr: _EcgRange(88, 62, 113),
        axis: _EcgRange(70, -10, 112),
        pr: _EcgRange(129, 99, 160),
        qrs: _EcgRange(80, 63, 98),
        qtc: _EcgRange(411, 371, 443),
      ),
      female: _EcgValues(
        hr: _EcgRange(89, 68, 115),
        axis: _EcgRange(74, 27, 117),
        pr: _EcgRange(124, 92, 156),
        qrs: _EcgRange(77, 59, 95),
        qtc: _EcgRange(409, 375, 449),
      ),
    ),
    _EcgAgeBand(
      '8–12 years',
      male: _EcgValues(
        hr: _EcgRange(78, 55, 101),
        axis: _EcgRange(70, -21, 114),
        pr: _EcgRange(134, 105, 174),
        qrs: _EcgRange(85, 67, 103),
        qtc: _EcgRange(411, 373, 440),
      ),
      female: _EcgValues(
        hr: _EcgRange(80, 58, 110),
        axis: _EcgRange(66, 5, 117),
        pr: _EcgRange(129, 103, 163),
        qrs: _EcgRange(82, 66, 99),
        qtc: _EcgRange(410, 365, 447),
      ),
    ),
    _EcgAgeBand(
      '12–16 years',
      male: _EcgValues(
        hr: _EcgRange(73, 48, 99),
        axis: _EcgRange(65, -9, 112),
        pr: _EcgRange(139, 107, 178),
        qrs: _EcgRange(91, 78, 111),
        qtc: _EcgRange(407, 362, 449),
      ),
      female: _EcgValues(
        hr: _EcgRange(76, 54, 107),
        axis: _EcgRange(66, 5, 101),
        pr: _EcgRange(135, 106, 176),
        qrs: _EcgRange(87, 72, 106),
        qtc: _EcgRange(414, 370, 457),
      ),
    ),
    _EcgAgeBand(
      '16–19 years',
      male: _EcgValues(
        hr: _EcgRange(73, 49, 107),
        axis: _EcgRange(74, -15, 111),
        pr: _EcgRange(148, 118, 200),
        qrs: _EcgRange(100, 82, 126),
        qtc: _EcgRange(416, 379, 460),
      ),
      female: _EcgValues(
        hr: _EcgRange(72, 47, 105),
        axis: _EcgRange(65, -11, 103),
        pr: _EcgRange(144, 112, 190),
        qrs: _EcgRange(92, 74, 112),
        qtc: _EcgRange(429, 382, 473),
      ),
    ),
  ];

  @override
  void dispose() {
    _hr.dispose();
    _axis.dispose();
    _pr.dispose();
    _qrs.dispose();
    _qtc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _EcgAgeBand band = _bands[_ageIndex];
    final _EcgValues values = _sex == 'M' ? band.male : band.female;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pediatric ECG Normal Values'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: <Widget>[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Values are displayed as median (2nd–98th percentile). Pediatric ECG measurements vary substantially with age. Always interpret the tracing in clinical context and verify borderline or abnormal measurements manually.',
                    style: TextStyle(height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: _ageIndex,
                decoration: const InputDecoration(
                  labelText: 'Age group',
                  border: OutlineInputBorder(),
                ),
                items: List<DropdownMenuItem<int>>.generate(
                  _bands.length,
                  (int index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text(_bands[index].label),
                  ),
                ),
                onChanged: (int? value) {
                  if (value == null) return;
                  setState(() => _ageIndex = value);
                },
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'M',
                    label: Text('Male'),
                    icon: Icon(Icons.male),
                  ),
                  ButtonSegment<String>(
                    value: 'F',
                    label: Text('Female'),
                    icon: Icon(Icons.female),
                  ),
                ],
                selected: <String>{_sex},
                onSelectionChanged: (Set<String> selected) {
                  setState(() => _sex = selected.first);
                },
              ),
              const SizedBox(height: 18),
              Text(
                '${band.label} · ${_sex == 'M' ? 'Male' : 'Female'}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double width = constraints.maxWidth >= 680
                      ? (constraints.maxWidth - 20) / 3
                      : constraints.maxWidth >= 440
                          ? (constraints.maxWidth - 10) / 2
                          : constraints.maxWidth;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      _ValueCard(
                        width: width,
                        label: 'Heart rate',
                        range: values.hr,
                        unit: 'bpm',
                        icon: Icons.favorite_border,
                      ),
                      _ValueCard(
                        width: width,
                        label: 'QRS axis',
                        range: values.axis,
                        unit: '°',
                        icon: Icons.explore_outlined,
                      ),
                      _ValueCard(
                        width: width,
                        label: 'PR interval',
                        range: values.pr,
                        unit: 'ms',
                        icon: Icons.linear_scale,
                      ),
                      _ValueCard(
                        width: width,
                        label: 'QRS duration',
                        range: values.qrs,
                        unit: 'ms',
                        icon: Icons.monitor_heart_outlined,
                      ),
                      _ValueCard(
                        width: width,
                        label: 'QTc interval',
                        range: values.qtc,
                        unit: 'ms',
                        icon: Icons.timelapse_outlined,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.rule_outlined),
                  title: const Text(
                    'Compare measured ECG values',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Enter a value to compare with the selected age/sex reference interval',
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: <Widget>[
                    _MeasuredField(
                      controller: _hr,
                      label: 'Heart rate (bpm)',
                      range: values.hr,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _MeasuredField(
                      controller: _axis,
                      label: 'QRS axis (°)',
                      range: values.axis,
                      allowSigned: true,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _MeasuredField(
                      controller: _pr,
                      label: 'PR interval (ms)',
                      range: values.pr,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _MeasuredField(
                      controller: _qrs,
                      label: 'QRS duration (ms)',
                      range: values.qrs,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _MeasuredField(
                      controller: _qtc,
                      label: 'QTc interval (ms)',
                      range: values.qtc,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'A value outside a statistical reference interval is not, by itself, a diagnosis. Confirm measurement technique, rhythm, lead quality, symptoms, medications and the overall ECG pattern.',
                      style: TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'References',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Ages 0–16 y: Rijnbeek PR, Witsenburg M, Schrama E, Hess J, Kors JA. New normal limits for the paediatric electrocardiogram. Eur Heart J. 2001;22:702–711. DOI: 10.1053/euhj.2000.2399.',
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Ages 16–19 y: lead-independent reference values from population ECG normal-value data for ages 16–90 years. Values shown here match the supplied teaching table.',
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Educational reference only. Institutional and pediatric cardiology guidance supersede.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final double width;
  final String label;
  final _EcgRange range;
  final String unit;
  final IconData icon;

  const _ValueCard({
    required this.width,
    required this.label,
    required this.range,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${_format(range.median)} $unit',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                '2nd–98th: ${_format(range.low)} to ${_format(range.high)} $unit',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasuredField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final _EcgRange range;
  final bool allowSigned;
  final VoidCallback onChanged;

  const _MeasuredField({
    required this.controller,
    required this.label,
    required this.range,
    required this.onChanged,
    this.allowSigned = false,
  });

  @override
  Widget build(BuildContext context) {
    final double? value = double.tryParse(controller.text.trim());
    final String? interpretation = value == null
        ? null
        : value < range.low
            ? 'Below reference interval'
            : value > range.high
                ? 'Above reference interval'
                : 'Within reference interval';

    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: allowSigned,
      ),
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        helperText: interpretation,
        suffixIcon: value == null
            ? null
            : Icon(
                value >= range.low && value <= range.high
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
              ),
      ),
    );
  }
}

String _format(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}

class _EcgAgeBand {
  final String label;
  final _EcgValues male;
  final _EcgValues female;

  const _EcgAgeBand(
    this.label, {
    required this.male,
    required this.female,
  });
}

class _EcgValues {
  final _EcgRange hr;
  final _EcgRange axis;
  final _EcgRange pr;
  final _EcgRange qrs;
  final _EcgRange qtc;

  const _EcgValues({
    required this.hr,
    required this.axis,
    required this.pr,
    required this.qrs,
    required this.qtc,
  });
}

class _EcgRange {
  final double median;
  final double low;
  final double high;

  const _EcgRange(this.median, this.low, this.high);
}
