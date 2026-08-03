import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:growth_standards/growth_standards.dart' as growth;

class PediatricReferenceScreen extends StatelessWidget {
  const PediatricReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pediatric Reference')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _ReferenceTile(
            icon: Icons.monitor_heart_outlined,
            title: 'Vital signs by age',
            subtitle: 'Resting HR, RR, BP, estimated MAP and PALS hypotension thresholds',
            screen: const VitalSignsReferenceScreen(),
          ),
          const SizedBox(height: 10),
          _ReferenceTile(
            icon: Icons.show_chart,
            title: 'WHO growth assessment',
            subtitle: 'Weight, length/height, BMI, head circumference, z-scores and percentiles',
            screen: const GrowthAssessmentScreen(),
          ),
        ],
      ),
    );
  }
}

class _ReferenceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;

  const _ReferenceTile({required this.icon, required this.title, required this.subtitle, required this.screen});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen)),
      ),
    );
  }
}

class VitalSignsReferenceScreen extends StatefulWidget {
  const VitalSignsReferenceScreen({super.key});

  @override
  State<VitalSignsReferenceScreen> createState() => _VitalSignsReferenceScreenState();
}

class _VitalSignsReferenceScreenState extends State<VitalSignsReferenceScreen> {
  int _selected = 0;
  final TextEditingController _ageYears = TextEditingController(text: '5');
  final TextEditingController _sbp = TextEditingController(text: '100');
  final TextEditingController _dbp = TextEditingController(text: '60');

  static const List<_VitalBand> _bands = <_VitalBand>[
    _VitalBand('Term newborn', '0–28 days', '100–180', '30–60', '60–80 / 30–45', '40–57', '<60 mmHg'),
    _VitalBand('Infant', '1–12 months', '100–160', '30–50', '70–100 / 50–65', '57–77', '<70 mmHg'),
    _VitalBand('Toddler', '1–2 years', '90–150', '24–40', '80–110 / 50–80', '60–90', '<70 + 2×age'),
    _VitalBand('Preschool', '3–5 years', '80–140', '22–34', '80–110 / 50–80', '60–90', '<70 + 2×age'),
    _VitalBand('School age', '6–11 years', '70–120', '18–30', '90–120 / 60–80', '70–93', '<70 + 2×age (to 10 y); <90 thereafter'),
    _VitalBand('Adolescent', '12–18 years', '60–100', '12–20', '100–130 / 65–85', '77–100', '<90 mmHg'),
  ];

  @override
  void dispose() {
    _ageYears.dispose();
    _sbp.dispose();
    _dbp.dispose();
    super.dispose();
  }

  double? _number(TextEditingController controller) => double.tryParse(controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final _VitalBand band = _bands[_selected];
    final double? age = _number(_ageYears);
    final double? sbp = _number(_sbp);
    final double? dbp = _number(_dbp);
    final double? map = sbp != null && dbp != null ? (sbp + 2 * dbp) / 3 : null;
    final double? hypotension = age == null
        ? null
        : age < 1
            ? 70
            : age <= 10
                ? 70 + 2 * age
                : 90;

    return Scaffold(
      appBar: AppBar(title: const Text('Vital Signs & Blood Pressure')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text('Quick bedside reference: these are approximate awake/resting ranges, not percentile-based diagnostic limits. Fever, pain, sleep, medications, athletic conditioning and illness alter vital signs. Trend and clinical context are essential.'),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _selected,
            decoration: const InputDecoration(labelText: 'Age group', border: OutlineInputBorder()),
            items: List<DropdownMenuItem<int>>.generate(
              _bands.length,
              (int index) => DropdownMenuItem<int>(value: index, child: Text('${_bands[index].label} (${_bands[index].age})')),
            ),
            onChanged: (int? value) => setState(() => _selected = value ?? 0),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(band.label, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  _rangeRow('Heart rate', '${band.hr} bpm'),
                  _rangeRow('Respiratory rate', '${band.rr} /min'),
                  _rangeRow('Typical BP', '${band.bp} mmHg'),
                  _rangeRow('Approximate MAP', '${band.map} mmHg'),
                  _rangeRow('PALS hypotension', band.hypotension),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('MAP and hypotension calculator', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  TextField(controller: _ageYears, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Age (years)', border: OutlineInputBorder()), onChanged: (_) => setState(() {})),
                  const SizedBox(height: 10),
                  Row(children: <Widget>[
                    Expanded(child: TextField(controller: _sbp, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'SBP', border: OutlineInputBorder()), onChanged: (_) => setState(() {}))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: _dbp, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'DBP', border: OutlineInputBorder()), onChanged: (_) => setState(() {}))),
                  ]),
                  const SizedBox(height: 12),
                  if (map != null) _rangeRow('Calculated MAP', '${map.toStringAsFixed(1)} mmHg'),
                  if (hypotension != null) _rangeRow('PALS SBP hypotension threshold', '<${hypotension.toStringAsFixed(0)} mmHg'),
                  const SizedBox(height: 8),
                  const Text('MAP = DBP + ⅓(SBP − DBP). A single universal “normal MAP” is not appropriate; targets vary with shock physiology, cardiac disease, renal disease, intracranial pressure and local PICU practice.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ExpansionTile(
              title: Text('Blood-pressure interpretation', style: TextStyle(fontWeight: FontWeight.w800)),
              childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: <Widget>[
                Text('For children 1–12 years, hypertension classification requires age-, sex- and height-specific percentiles. A quick typical range must not be used to diagnose hypertension.'),
                SizedBox(height: 8),
                Text('For adolescents ≥13 years, fixed categories are commonly used: normal <120/<80; elevated 120–129 and <80; stage 1 130–139 or 80–89; stage 2 ≥140 or ≥90 mmHg. Confirm technique, cuff size and repeated measurements.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rangeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: <Widget>[
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _VitalBand {
  final String label;
  final String age;
  final String hr;
  final String rr;
  final String bp;
  final String map;
  final String hypotension;
  const _VitalBand(this.label, this.age, this.hr, this.rr, this.bp, this.map, this.hypotension);
}

class GrowthAssessmentScreen extends StatefulWidget {
  const GrowthAssessmentScreen({super.key});

  @override
  State<GrowthAssessmentScreen> createState() => _GrowthAssessmentScreenState();
}

class _GrowthAssessmentScreenState extends State<GrowthAssessmentScreen> {
  DateTime _dob = DateTime.now().subtract(const Duration(days: 365));
  DateTime _measurementDate = DateTime.now();
  bool _male = true;
  bool _recumbent = true;
  final TextEditingController _weight = TextEditingController(text: '10.2');
  final TextEditingController _height = TextEditingController(text: '75.5');
  final TextEditingController _head = TextEditingController(text: '46.5');
  List<_GrowthResult> _results = <_GrowthResult>[];
  String? _error;

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _head.dispose();
    super.dispose();
  }

  double? _num(TextEditingController controller) => double.tryParse(controller.text.trim());

  growth.Months _month(int month) => growth.Months.values[month - 1];

  growth.Date _date(DateTime date) => growth.Date(year: date.year, month: _month(date.month), date: date.day);

  void _calculate() {
    final double? weight = _num(_weight);
    final double? height = _num(_height);
    final double? head = _num(_head);
    if (weight == null || weight <= 0 || height == null || height <= 0) {
      setState(() => _error = 'Enter valid weight and length/height.');
      return;
    }
    if (!_measurementDate.isAfter(_dob)) {
      setState(() => _error = 'Measurement date must be after date of birth.');
      return;
    }

    try {
      final growth.Age age = growth.Age(_date(_dob), observedDate: _date(_measurementDate));
      final growth.Sex sex = _male ? growth.Sex.male : growth.Sex.female;
      final growth.LengthHeightMeasurementPosition position = _recumbent
          ? growth.LengthHeightMeasurementPosition.recumbent
          : growth.LengthHeightMeasurementPosition.standing;
      final double years = _measurementDate.difference(_dob).inDays / 365.2425;
      final List<_GrowthResult> output = <_GrowthResult>[];

      void add(String name, dynamic result) {
        final double z = (result.zScore() as num).toDouble();
        final double percentile = (result.percentile() as num).toDouble();
        output.add(_GrowthResult(name, z, percentile));
      }

      if (years < 5) {
        final dynamic who = growth.GrowthStandard.who.fromBirthTo5Years;
        add('Weight-for-age', who.weightForAge(sex: sex, age: age, weight: growth.Mass$Kilogram(weight)));
        add('Length/height-for-age', who.lengthForAge(sex: sex, age: age, lengthHeight: growth.Length$Centimeter(height), measure: position));
        final dynamic bmiMeasurement = growth.WHOGrowthStandardsBodyMassIndexMeasurement.fromMeasurement(
          measure: position,
          lengthHeight: growth.Length$Centimeter(height),
          weight: growth.Mass$Kilogram(weight),
          age: age,
        );
        add('BMI-for-age', who.bodyMassIndexForAge(sex: sex, bodyMassIndexMeasurement: bmiMeasurement));
        if (_recumbent && height >= 45 && height <= 110) {
          add('Weight-for-length', who.weightForLength(sex: sex, age: age, lengthMeasurementResult: growth.Length$Centimeter(height), massMeasurementResult: growth.Mass$Kilogram(weight), measure: position));
        } else if (!_recumbent && height >= 65 && height <= 120) {
          add('Weight-for-height', who.weightForHeight(sex: sex, age: age, height: growth.Length$Centimeter(height), mass: growth.Mass$Kilogram(weight), measure: position));
        }
        if (head != null && head > 0) {
          add('Head circumference-for-age', who.headCircumferenceForAge(sex: sex, age: age, measurementResult: growth.Length$Centimeter(head)));
        }
      } else if (years <= 18) {
        final dynamic who = growth.GrowthStandard.who.from5YearsAndAbove;
        add('Height-for-age', who.heightForAge(sex: sex, age: age, lengthHeight: growth.Length$Centimeter(height), measure: growth.LengthHeightMeasurementPosition.standing));
        final double bmi = weight / math.pow(height / 100, 2);
        add('BMI-for-age', who.bodyMassIndexForAge(sex: sex, age: age, bodyMassIndexMeasurement: growth.WHOGrowthReferenceBodyMassIndexMeasurement(bmi)));
        if (years <= 10) {
          add('Weight-for-age', who.weightForAge(sex: sex, age: age, weight: growth.Mass$Kilogram(weight)));
        }
      } else {
        throw StateError('WHO growth reference in this module supports birth through 18 years.');
      }

      setState(() {
        _results = output;
        _error = null;
      });
    } catch (error) {
      setState(() {
        _results = <_GrowthResult>[];
        _error = 'Growth calculation could not be completed: $error';
      });
    }
  }

  Future<void> _pickDate(bool birth) async {
    final DateTime initial = birth ? _dob : _measurementDate;
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => birth ? _dob = date : _measurementDate = date);
  }

  String _dateText(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final double ageYears = _measurementDate.difference(_dob).inDays / 365.2425;
    return Scaffold(
      appBar: AppBar(title: const Text('WHO Growth Assessment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text('WHO Child Growth Standards (birth–5 years) and WHO Growth Reference (5–18 years). Calculates z-scores and exact percentiles. Serial trajectory tracking should be interpreted with measurement technique, growth velocity, parental height and clinical context.'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: <Widget>[
                  SegmentedButton<bool>(
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(value: true, label: Text('Male')),
                      ButtonSegment<bool>(value: false, label: Text('Female')),
                    ],
                    selected: <bool>{_male},
                    onSelectionChanged: (Set<bool> value) => setState(() => _male = value.first),
                  ),
                  const SizedBox(height: 12),
                  Row(children: <Widget>[
                    Expanded(child: OutlinedButton.icon(onPressed: () => _pickDate(true), icon: const Icon(Icons.cake_outlined), label: Text('DOB\n${_dateText(_dob)}'))),
                    const SizedBox(width: 10),
                    Expanded(child: OutlinedButton.icon(onPressed: () => _pickDate(false), icon: const Icon(Icons.event_outlined), label: Text('Measured\n${_dateText(_measurementDate)}'))),
                  ]),
                  const SizedBox(height: 8),
                  Text('Age: ${ageYears.toStringAsFixed(2)} years', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(controller: _weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _height, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Length/height (cm)', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _head, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Head circumference (cm) — optional', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  SegmentedButton<bool>(
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(value: true, label: Text('Recumbent length')),
                      ButtonSegment<bool>(value: false, label: Text('Standing height')),
                    ],
                    selected: <bool>{_recumbent},
                    onSelectionChanged: (Set<bool> value) => setState(() => _recumbent = value.first),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(onPressed: _calculate, icon: const Icon(Icons.show_chart), label: const Text('Calculate growth percentiles')),
                ],
              ),
            ),
          ),
          if (_error != null) Card(color: Theme.of(context).colorScheme.errorContainer, child: Padding(padding: const EdgeInsets.all(14), child: Text(_error!))),
          if (_results.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Growth results', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    ..._results.map((result) => _GrowthResultCard(result: result)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text('Interpretation reminders: values below −2 SD or above +2 SD merit clinical review; crossing major percentile channels, discordant weight/length patterns, poor growth velocity or concerning symptoms may be more important than a single percentile. For preterm infants, use corrected age and an appropriate preterm standard such as Fenton/INTERGROWTH before transitioning to WHO charts.'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GrowthResult {
  final String name;
  final double z;
  final double percentile;
  const _GrowthResult(this.name, this.z, this.percentile);
}

class _GrowthResultCard extends StatelessWidget {
  final _GrowthResult result;
  const _GrowthResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final double clamped = result.z.clamp(-3.0, 3.0);
    final String interpretation = result.z < -3
        ? 'Severely low'
        : result.z < -2
            ? 'Low'
            : result.z > 3
                ? 'Severely high'
                : result.z > 2
                    ? 'High'
                    : 'Within expected reference range';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(child: Text(result.name, style: const TextStyle(fontWeight: FontWeight.w800))),
            Text('${result.percentile.toStringAsFixed(1)}th percentile'),
          ]),
          const SizedBox(height: 5),
          Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Container(height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: const LinearGradient(colors: <Color>[Color(0xFFFFCDD2), Color(0xFFC8E6C9), Color(0xFFFFCDD2)]))),
              Align(alignment: Alignment((clamped / 3).clamp(-1.0, 1.0).toDouble(), 0), child: Container(width: 4, height: 22, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 5),
          Text('z-score ${result.z.toStringAsFixed(2)} SD • $interpretation', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
