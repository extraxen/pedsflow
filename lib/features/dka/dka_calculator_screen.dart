// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dka_engine.dart';

class DkaCalculatorScreen extends StatefulWidget {
  const DkaCalculatorScreen({super.key});

  static const routeName = '/calculators/pediatric-dka';

  @override
  State<DkaCalculatorScreen> createState() => _DkaCalculatorScreenState();
}

class _DkaCalculatorScreenState extends State<DkaCalculatorScreen> {
  static const _navy = Color(0xFF0B2737);
  static const _teal = Color(0xFF1A7180);
  static const _paper = Color(0xFFFFFEFB);
  static const _background = Color(0xFFF6F4EE);
  static const _red = Color(0xFFB73A37);
  static const _orange = Color(0xFFD8793C);
  static const _green = Color(0xFF247155);

  final _controllers = <String, TextEditingController>{
    'age': TextEditingController(),
    'weight': TextEditingController(),
    'glucose': TextEditingController(),
    'previousGlucose': TextEditingController(),
    'ph': TextEditingController(),
    'bicarbonate': TextEditingController(),
    'sodium': TextEditingController(),
    'chloride': TextEditingController(),
    'potassium': TextEditingController(),
    'bohb': TextEditingController(),
    'phosphate': TextEditingController(),
    'urea': TextEditingController(),
  };

  int _selectedTab = 0;
  UrineKetones _urineKetones = UrineKetones.unknown;
  UrineOutput _urineOutput = UrineOutput.unknown;
  bool _alteredMentalStatus = false;
  int _bolusMlPerKg = 10;
  double _insulinFactor = 0.05;
  double _bagBConcentration = 12.5;
  double _desiredDextrose = 5;
  int _nextTrendId = 1;
  final List<_TrendReading> _trendReadings = [];

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers.values) {
      controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.removeListener(_refresh);
      controller.dispose();
    }
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  double? _number(String key) {
    final value = _controllers[key]!.text.trim();
    return value.isEmpty ? null : double.tryParse(value);
  }

  DkaInputs get _inputs => DkaInputs(
        ageYears: _number('age'),
        weightKg: _number('weight'),
        glucose: _number('glucose'),
        previousGlucose: _number('previousGlucose'),
        ph: _number('ph'),
        bicarbonate: _number('bicarbonate'),
        sodium: _number('sodium'),
        chloride: _number('chloride'),
        potassium: _number('potassium'),
        betaHydroxybutyrate: _number('bohb'),
        phosphate: _number('phosphate'),
        urea: _number('urea'),
        urineKetones: _urineKetones,
        urineOutput: _urineOutput,
        alteredMentalStatus: _alteredMentalStatus,
        bolusMlPerKg: _bolusMlPerKg,
        insulinUnitsPerKgHour: _insulinFactor,
        bagBConcentration: _bagBConcentration,
        desiredDextrose: _desiredDextrose,
      );

  DkaResults get _results => DkaEngine.calculate(_inputs);

  String _one(double? value) => value == null ? 'â€”' : value.toStringAsFixed(1);
  String _zero(double? value) => value == null ? 'â€”' : value.round().toString();

  void _loadExample() {
    const values = <String, String>{
      'age': '8',
      'weight': '30',
      'glucose': '17',
      'previousGlucose': '23',
      'ph': '7.18',
      'bicarbonate': '8',
      'sodium': '131',
      'chloride': '98',
      'potassium': '4.7',
      'bohb': '4.2',
      'phosphate': '',
      'urea': '',
    };
    for (final entry in values.entries) {
      _controllers[entry.key]!.text = entry.value;
    }
    setState(() {
      _urineKetones = UrineKetones.unknown;
      _urineOutput = UrineOutput.unknown;
      _alteredMentalStatus = false;
      _bolusMlPerKg = 10;
      _insulinFactor = 0.05;
      _bagBConcentration = 12.5;
      _desiredDextrose = 5;
      _trendReadings.clear();
    });
  }

  void _clear() {
    for (final controller in _controllers.values) {
      controller.clear();
    }
    setState(() {
      _urineKetones = UrineKetones.unknown;
      _urineOutput = UrineOutput.unknown;
      _alteredMentalStatus = false;
      _bolusMlPerKg = 10;
      _insulinFactor = 0.05;
      _bagBConcentration = 12.5;
      _desiredDextrose = 5;
      _trendReadings.clear();
    });
  }

  Future<void> _copySummary() async {
    final result = _results;
    final summary = '''
PEDIATRIC DKA CLINICAL SUPPORT â€” VERIFY INDEPENDENTLY
Weight: ${_one(_inputs.weightKg)} kg
Assessment: ${result.diagnosisLabel}; ${result.severityLabel}
Corrected Na: ${_one(result.correctedSodium)} mmol/L
Anion gap: ${_one(result.anionGap)} mmol/L
Effective osmolality: ${_one(result.effectiveOsmolality)} mOsm/kg
Initial isotonic bolus: ${_zero(result.initialBolusMl)} mL ($_bolusMlPerKg mL/kg)
Ongoing CPS fluid: ${_one(result.cpsFluid.rateMlHour)} mL/h
Insulin: ${result.holdInsulin ? 'HOLD â€” requires K >3.0' : '${_one(result.selectedInsulinUnitsHour)} units/h'}
Two-bag: A ${_one(result.bagARateMlHour)} mL/h + D$_bagBConcentration B ${_one(result.bagBRateMlHour)} mL/h â†’ D$_desiredDextrose
Educational prototype; confirm with local order set, endocrinology, pharmacy, and critical care.
''';
    await Clipboard.setData(ClipboardData(text: summary));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('DKA summary copied. Verify before use.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _results;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pediatric DKA', style: TextStyle(fontWeight: FontWeight.w800)),
            Text(
              'PedsFlow Â· CPS/TREKK clinical support',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _loadExample,
            child: const Text('Example', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: _clear,
            child: const Text('Clear', style: TextStyle(color: Colors.white70)),
          ),
          IconButton(
            tooltip: 'Copy clinical summary',
            onPressed: _copySummary,
            icon: const Icon(Icons.copy_all_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFF1E7D2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              'Educational support â€” not an order set. Do not enter identifiers. Verify every result.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF664E29)),
            ),
          ),
          _tabBar(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 1080;
                final main = _selectedPage(result);
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 50),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: desktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: main),
                                const SizedBox(width: 24),
                                SizedBox(width: 350, child: _summaryRail(result)),
                              ],
                            )
                          : Column(
                              children: [
                                _summaryRail(result, compact: true),
                                const SizedBox(height: 18),
                                main,
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    const labels = ['Assess', 'Treat', 'Monitor', 'Cerebral injury', 'Guide'];
    const icons = [
      Icons.fact_check_outlined,
      Icons.medical_services_outlined,
      Icons.monitor_heart_outlined,
      Icons.emergency_outlined,
      Icons.menu_book_outlined,
    ];
    return Material(
      color: _paper,
      elevation: 1,
      child: SizedBox(
        height: 64,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          itemCount: labels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final selected = index == _selectedTab;
            return ChoiceChip(
              selected: selected,
              onSelected: (_) => setState(() => _selectedTab = index),
              avatar: Icon(icons[index], size: 17, color: selected ? Colors.white : _teal),
              label: Text('${index + 1}. ${labels[index]}'),
              labelStyle: TextStyle(
                color: selected ? Colors.white : _navy,
                fontWeight: FontWeight.w700,
              ),
              selectedColor: _teal,
              backgroundColor: Colors.white,
              side: BorderSide(color: selected ? _teal : const Color(0xFFDCE3E3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            );
          },
        ),
      ),
    );
  }

  Widget _selectedPage(DkaResults result) {
    switch (_selectedTab) {
      case 0:
        return _assessmentPage(result);
      case 1:
        return _treatmentPage(result);
      case 2:
        return _monitoringPage();
      case 3:
        return _cerebralInjuryPage(result);
      default:
        return _guidePage();
    }
  }

  Widget _heading(String eyebrow, String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: const TextStyle(
                    color: _teal,
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 30,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing],
        ],
      ),
    );
  }

  Widget _clinicalCard(String title, Widget child, {String? note, Color? accent}) {
    return Card(
      color: _paper,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accent ?? const Color(0xFFDCE3E3), width: accent == null ? 1 : 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (note != null)
                  Flexible(
                    child: Text(
                      note,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }

  Widget _field(String key, String label, {String? unit, String? hint}) {
    return SizedBox(
      width: 220,
      child: TextField(
        controller: _controllers[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          helperText: hint,
          helperMaxLines: 2,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
        ),
      ),
    );
  }

  Widget _assessmentPage(DkaResults result) {
    return Column(
      children: [
        _heading(
          'Biochemical assessment',
          'Confirm the triad before treating as DKA',
          trailing: _pill(result.diagnosisLabel, _diagnosisColor(result.diagnosis)),
        ),
        if (result.validationMessages.isNotEmpty)
          _alert(
            'Review inputs',
            result.validationMessages.join(' '),
            _red,
            Icons.error_outline,
          ),
        _clinicalCard(
          'Patient',
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _field('age', 'Age', unit: 'years'),
              _field('weight', 'Weight *', unit: 'kg'),
              SizedBox(
                width: 260,
                child: SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: const Text('Altered mental status'),
                  subtitle: const Text('Urgent cerebral injury assessment'),
                  value: _alteredMentalStatus,
                  activeThumbColor: _red,
                  onChanged: (value) => setState(() => _alteredMentalStatus = value),
                ),
              ),
            ],
          ),
        ),
        _clinicalCard(
          'Glucose, ketones and acidosis',
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _field('glucose', 'Current glucose *', unit: 'mmol/L'),
              _field(
                'previousGlucose',
                'Glucose 1 hour ago',
                unit: 'mmol/L',
                hint: 'For rate-of-fall alert',
              ),
              _field('bohb', 'Î²-hydroxybutyrate', unit: 'mmol/L'),
              SizedBox(
                width: 250,
                child: DropdownButtonFormField<UrineKetones>(
                  initialValue: _urineKetones,
                  decoration: const InputDecoration(labelText: 'Urine ketones'),
                  items: const [
                    DropdownMenuItem(value: UrineKetones.unknown, child: Text('Not provided')),
                    DropdownMenuItem(
                      value: UrineKetones.negativeTraceSmall,
                      child: Text('Negative / trace / small'),
                    ),
                    DropdownMenuItem(value: UrineKetones.moderate, child: Text('Moderate')),
                    DropdownMenuItem(value: UrineKetones.large, child: Text('Large')),
                  ],
                  onChanged: (value) => setState(() => _urineKetones = value!),
                ),
              ),
              _field('ph', 'Venous pH'),
              _field('bicarbonate', 'Measured bicarbonate', unit: 'mmol/L'),
            ],
          ),
        ),
        _clinicalCard(
          'Electrolytes and renal markers',
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _field('sodium', 'Sodium', unit: 'mmol/L'),
              _field('chloride', 'Chloride', unit: 'mmol/L'),
              _field('potassium', 'Potassium *', unit: 'mmol/L'),
              _field('phosphate', 'Phosphate', unit: 'mmol/L'),
              _field('urea', 'Urea', unit: 'mmol/L'),
              SizedBox(
                width: 250,
                child: DropdownButtonFormField<UrineOutput>(
                  initialValue: _urineOutput,
                  decoration: const InputDecoration(labelText: 'Recent urine output'),
                  items: const [
                    DropdownMenuItem(value: UrineOutput.unknown, child: Text('Not confirmed')),
                    DropdownMenuItem(value: UrineOutput.documented, child: Text('Documented')),
                    DropdownMenuItem(value: UrineOutput.absent, child: Text('No urine output')),
                  ],
                  onChanged: (value) => setState(() => _urineOutput = value!),
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 760
                ? (constraints.maxWidth - 36) / 4
                : (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _criterionCard('Hyperglycemia', result.hyperglycemia, '>11 mmol/L', width),
                _criterionCard('Ketosis', result.ketosis, 'Î²-OHB â‰¥3 or urine mod/large', width),
                _criterionCard('Acidosis', result.acidosis, 'pH <7.3 or HCOâ‚ƒ <18', width),
                _criterionCard(
                  'Anion gap',
                  result.highAnionGap,
                  '${_one(result.anionGap)} mmol/L Â· target >12',
                  width,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _treatmentPage(DkaResults result) {
    final potassium = _inputs.potassium;
    final phosphate = _inputs.phosphate;
    return Column(
      children: [
        _heading(
          'Fluids, insulin and electrolytes',
          'CPS-aligned initial treatment',
          trailing: _pill(
            result.holdInsulin ? 'Insulin hold' : 'Eligible after â‰¥1 h fluids',
            result.holdInsulin ? _red : _green,
          ),
        ),
        _clinicalCard(
          'Initial isotonic fluid',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [10, 20]
                    .map(
                      (dose) => ChoiceChip(
                        label: Text('$dose mL/kg'),
                        selected: _bolusMlPerKg == dose,
                        onSelected: (_) => setState(() => _bolusMlPerKg = dose),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              _metricWrap([
                _MetricData('Selected bolus', '${_zero(result.initialBolusMl)} mL',
                    '$_bolusMlPerKg mL/kg Â· max 1000 mL'),
                const _MetricData('Give over', '20â€“30 min', 'For all DKA patients'),
                const _MetricData(
                  'Shock pathway',
                  '10 mL/kg increments',
                  'Rapidly to max 40 mL/kg with intensivist',
                  tone: _orange,
                ),
              ]),
            ],
          ),
          note: '0.9% NaCl or balanced crystalloid',
          accent: _teal,
        ),
        _clinicalCard(
          'Ongoing total IV fluid',
          _metricWrap([
            _MetricData(
              'Total hourly rate',
              '${_one(result.cpsFluid.rateMlHour)} mL/h',
              '${_one(result.cpsFluid.factorMlKgHour)} mL/kg/h',
              tone: result.cpsFluid.rateMlHour == null ? _red : _green,
            ),
            _MetricData('Weight band', result.cpsFluid.band, 'CPS Table 5'),
            const _MetricData(
              'Temporary option',
              'Twice maintenance',
              'Generally safe until detailed calculation',
            ),
          ]),
          note: 'Assumed 10% deficit over 36 h',
        ),
        _clinicalCard(
          'Two-bag dextrose mixer',
          Column(
            children: [
              Wrap(
                spacing: 14,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 250,
                    child: DropdownButtonFormField<double>(
                      initialValue: _bagBConcentration,
                      decoration: const InputDecoration(labelText: 'Bag B concentration'),
                      items: const [
                        DropdownMenuItem(value: 12.5, child: Text('D12.5 (preferred)')),
                        DropdownMenuItem(value: 10, child: Text('D10')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _bagBConcentration = value!;
                          if (_desiredDextrose > value) _desiredDextrose = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: DropdownButtonFormField<double>(
                      initialValue: _desiredDextrose,
                      decoration: const InputDecoration(labelText: 'Desired final dextrose'),
                      items: [0.0, 5.0, 7.5, 10.0, 12.5]
                          .where((value) => value <= _bagBConcentration)
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                value == 0 ? 'No dextrose' : 'D${_formatDex(value)}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _desiredDextrose = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _metricWrap([
                _MetricData(
                  'Bag A Â· no dextrose',
                  '${_one(result.bagARateMlHour)} mL/h',
                  '${_one(result.bagAPercent)}% of total',
                ),
                _MetricData(
                  'Bag B Â· D${_formatDex(_bagBConcentration)}',
                  '${_one(result.bagBRateMlHour)} mL/h',
                  '${_one(result.bagBPercent)}% of total',
                ),
                _MetricData(
                  'Combined',
                  '${_one(result.cpsFluid.rateMlHour)} mL/h',
                  'Effective D${_formatDex(_desiredDextrose)}',
                  tone: _green,
                ),
              ]),
              const SizedBox(height: 12),
              _alert(
                'When to add dextrose',
                'Continue dextrose-free isotonic fluid until glucose is 15â€“17 mmol/L. '
                    'Then add D5 and adjust to maintain glucose 7â€“11 mmol/L.',
                _teal,
                Icons.info_outline,
              ),
            ],
          ),
          note: 'Both bags require identical electrolytes',
        ),
        _clinicalCard(
          'Insulin and potassium',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 300,
                child: DropdownButtonFormField<double>(
                  initialValue: _insulinFactor,
                  decoration: const InputDecoration(labelText: 'Selected insulin rate'),
                  items: const [
                    DropdownMenuItem(value: 0.05, child: Text('0.05 unit/kg/h')),
                    DropdownMenuItem(value: 0.1, child: Text('0.1 unit/kg/h')),
                    DropdownMenuItem(
                      value: 0.025,
                      child: Text('0.025 unit/kg/h Â· special circumstance'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _insulinFactor = value!),
                ),
              ),
              const SizedBox(height: 16),
              _metricWrap([
                _MetricData(
                  'Calculated range',
                  '${_one(result.insulinLowUnitsHour)}â€“${_one(result.insulinHighUnitsHour)} U/h',
                  '0.05â€“0.1 unit/kg/h',
                ),
                _MetricData(
                  'Selected rate',
                  result.holdInsulin ? 'HOLD' : '${_one(result.selectedInsulinUnitsHour)} U/h',
                  result.holdInsulin ? 'Requires K >3.0' : 'Separate pump Â· no IV bolus',
                  tone: result.holdInsulin ? _red : _green,
                ),
                _MetricData(
                  'At 1 unit/mL',
                  result.holdInsulin ? 'â€”' : '${_one(result.selectedInsulinUnitsHour)} mL/h',
                  'Confirm local pump concentration',
                ),
              ]),
              if (potassium == null)
                _alert(
                  'Potassium required',
                  'Do not start insulin until potassium is known and greater than 3.0 mmol/L.',
                  _red,
                  Icons.block,
                )
              else if (potassium <= 3)
                _alert(
                  'Hard stop â€” K â‰¤3.0 mmol/L',
                  'Replace potassium before insulin. Use cardiac monitoring and urgent local/expert guidance.',
                  _red,
                  Icons.block,
                )
              else if (potassium < 5 && _urineOutput == UrineOutput.documented)
                _alert(
                  'Add potassium to fluids',
                  'CPS recommends at least 40 mmol/L when K is <5 and recent urine output is documented.',
                  _green,
                  Icons.check_circle_outline,
                )
              else if (potassium < 5)
                _alert(
                  'Confirm urine output first',
                  'Potassium supplementation is indicated by the level, but recent urine output is not documented.',
                  _orange,
                  Icons.warning_amber,
                )
              else
                _alert(
                  'Defer potassium initially',
                  'Recheck frequently; add when K falls below 5 mmol/L and urine output is documented.',
                  _orange,
                  Icons.warning_amber,
                ),
              if (phosphate != null && phosphate < 0.5)
                _alert(
                  'Severe hypophosphatemia',
                  'Consider replacement per local protocol and clinical context.',
                  _orange,
                  Icons.warning_amber,
                ),
            ],
          ),
          note: 'Start only after â‰¥1 hour of fluids Â· never bolus',
        ),
      ],
    );
  }

  Widget _monitoringPage() {
    final flags = _trendFlags();
    return Column(
      children: [
        _heading('Trajectory', 'Trend what changes management'),
        _metricWrap(const [
          _MetricData('Hourly', 'Glucose', 'Neurologic status Â· vitals Â· fluid balance'),
          _MetricData('At least q2h', 'Labs', 'Gas Â· electrolytes Â· anion gap Â· ketones'),
          _MetricData('As indicated', 'Cardiac monitor', 'Dangerous potassium/calcium derangement'),
        ]),
        const SizedBox(height: 16),
        for (final flag in flags) flag,
        _clinicalCard(
          'Biochemistry trend',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _addTrendReading,
                    icon: const Icon(Icons.add),
                    label: const Text('Add reading'),
                  ),
                  OutlinedButton(
                    onPressed: () => setState(() => _trendReadings.clear()),
                    child: const Text('Clear trend'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 10,
                  columns: const [
                    DataColumn(label: Text('Time')),
                    DataColumn(label: Text('BG')),
                    DataColumn(label: Text('Na')),
                    DataColumn(label: Text('Cl')),
                    DataColumn(label: Text('HCOâ‚ƒ')),
                    DataColumn(label: Text('pH')),
                    DataColumn(label: Text('K')),
                    DataColumn(label: Text('Î²-OHB')),
                    DataColumn(label: Text('Corr Na')),
                    DataColumn(label: Text('AG')),
                    DataColumn(label: Text('')),
                  ],
                  rows: _trendReadings.map(_trendRow).toList(),
                ),
              ),
              if (_trendReadings.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: Text('No readings yet. Add the first treatment snapshot.')),
                ),
            ],
          ),
        ),
        _clinicalCard(
          'Resolution and transition checklist',
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: const [
              _ChecklistItem('Clinically well and tolerating oral intake'),
              _ChecklistItem('Ketosis/acidosis resolved by local criteria'),
              _ChecklistItem('Subcutaneous insulin plan confirmed'),
              _ChecklistItem('IV insulin overlap timed per local protocol'),
              _ChecklistItem('Precipitating cause addressed'),
              _ChecklistItem('Education and follow-up arranged'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cerebralInjuryPage(DkaResults result) {
    return Column(
      children: [
        _heading(
          'Time-critical complication',
          'Suspected cerebral injury: treat now',
          trailing: _pill('Do not wait for imaging', _red),
        ),
        Card(
          color: _red,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: const Padding(
            padding: EdgeInsets.all(22),
            child: Wrap(
              spacing: 40,
              runSpacing: 20,
              children: [
                SizedBox(
                  width: 360,
                  child: _EmergencyList(
                    title: 'Warning signs',
                    items: [
                      'Altered consciousness after initial improvement',
                      'New or worsening severe headache',
                      'Vomiting or irritability',
                      'Hypertension with unexplained bradycardia',
                      'Respiratory depression or desaturation',
                      'Cranial nerve palsy or urinary incontinence',
                    ],
                  ),
                ),
                SizedBox(
                  width: 430,
                  child: _EmergencyList(
                    title: 'Immediate actions',
                    numbered: true,
                    items: [
                      'Call paediatric critical care / resuscitation support',
                      'Minimize movement; head midline and bed at 30Â°',
                      'Use isotonic fluid; consider 75% rate if perfusion allows',
                      'Give osmolar therapy immediately',
                      'Avoid intubation if possible; maintain baseline hyperventilation if required',
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _clinicalCard(
          'Immediate osmolar therapy',
          _metricWrap([
            _MetricData(
              '3% hypertonic saline',
              '${_one(result.hypertonicSaline3PercentMl)} mL',
              '5 mL/kg over 10â€“15 min Â· max 250 mL',
              tone: _teal,
            ),
            _MetricData(
              'OR mannitol',
              '${_one(result.mannitolLowG)}â€“${_one(result.mannitolHighG)} g',
              '0.5â€“1 g/kg over 15â€“20 min Â· max 100 g',
              tone: _orange,
            ),
            _MetricData(
              'Mannitol 20% volume',
              '${_one(result.mannitol20PercentLowMl)}â€“${_one(result.mannitol20PercentHighMl)} mL',
              '20% = 0.2 g/mL',
            ),
          ]),
          accent: _red,
        ),
        _alert(
          _alteredMentalStatus ? 'Current flag: altered mental status' : 'Continue surveillance',
          _alteredMentalStatus
              ? 'Urgent bedside assessment, tertiary referral, and critical care involvement are required.'
              : 'Mental status is recorded as baseline. Continue frequent neurologic reassessment.',
          _alteredMentalStatus ? _red : _teal,
          _alteredMentalStatus ? Icons.emergency : Icons.visibility_outlined,
        ),
      ],
    );
  }

  Widget _guidePage() {
    return Column(
      children: [
        _heading('Method and provenance', 'Transparent calculations and limits'),
        _clinicalCard(
          'Calculation definitions',
          const Column(
            children: [
              _DefinitionRow(
                'DKA',
                'Glucose >11; Î²-OHB â‰¥3 and/or moderate/large ketonuria; pH <7.3 or measured HCOâ‚ƒ <18; anion gap >12.',
              ),
              _DefinitionRow(
                'Corrected sodium',
                'Measured Na + (glucose âˆ’ 5) Ã— 0.3.',
              ),
              _DefinitionRow('Anion gap', 'Measured Na âˆ’ chloride âˆ’ measured bicarbonate.'),
              _DefinitionRow(
                'Effective osmolality',
                '2 Ã— measured Na + glucose. Used as a hyperosmolar physiology screen.',
              ),
              _DefinitionRow(
                'Two-bag rates',
                'Bag B fraction = desired dextrose Ã· Bag B concentration; Bag A fraction = 1 âˆ’ Bag B fraction.',
              ),
            ],
          ),
        ),
        _clinicalCard(
          'Clinical sources',
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Canadian Paediatric Society: Current recommendations for management of paediatric diabetic ketoacidosis.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              SelectableText(
                'https://cps.ca/en/documents/position/current-recommendations-for-management-of-paediatric-diabetic-ketoacidosis',
                style: TextStyle(color: _teal),
              ),
              SizedBox(height: 18),
              Text(
                'TREKK: Bottom Line Recommendations â€” Diabetic Ketoacidosis.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              SelectableText(
                'https://trekk.ca/resources/bottom-line-recommendations-diabetic-ketoacidosis',
                style: TextStyle(color: _teal),
              ),
            ],
          ),
        ),
        _alert(
          'Important limitation',
          'This educational module has not been validated or certified as a medical device. '
              'It does not replace bedside assessment, a local order set, endocrinology, pharmacy, '
              'or critical care. Special populations require expert guidance.',
          _orange,
          Icons.gpp_maybe_outlined,
        ),
      ],
    );
  }

  Widget _summaryRail(DkaResults result, {bool compact = false}) {
    final items = [
      _MetricData('Corrected Na', '${_one(result.correctedSodium)} mmol/L', ''),
      _MetricData('Anion gap', '${_one(result.anionGap)} mmol/L', ''),
      _MetricData('Effective osm', '${_one(result.effectiveOsmolality)} mOsm/kg', ''),
      _MetricData('BG fall', '${_one(result.glucoseFallPerHour)} mmol/L/h', ''),
    ];
    return Card(
      color: _navy,
      elevation: 5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LIVE CARE BRIEF',
              style: TextStyle(color: Colors.white60, letterSpacing: 1.4, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              '${_one(_inputs.weightKg)} kg child',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Divider(height: 28, color: Colors.white24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _diagnosisColor(result.diagnosis).withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.diagnosisLabel,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  Text(result.severityLabel, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: compact ? 4 : 2,
                childAspectRatio: compact ? 1.45 : 1.55,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.label.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 8)),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.value,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (result.possibleHhs)
              _darkAlert(
                'Possible HHS / mixed physiology',
                'Glucose >33 and effective osmolality >320. Obtain urgent specialist guidance.',
                _red,
              ),
            if ((result.glucoseFallPerHour ?? 0) > 5)
              _darkAlert(
                'Rapid glucose decline',
                'Falling >5 mmol/L/h. Review dextrose and insulin now.',
                _orange,
              ),
            if (_alteredMentalStatus)
              _darkAlert(
                'Altered mental status',
                'Urgent cerebral injury assessment and critical care involvement.',
                _red,
              ),
            const SizedBox(height: 16),
            _quickPlanRow('Initial bolus', '${_zero(result.initialBolusMl)} mL',
                '$_bolusMlPerKg mL/kg isotonic over 20â€“30 min'),
            _quickPlanRow('Ongoing fluid', '${_one(result.cpsFluid.rateMlHour)} mL/h',
                'CPS weight-band rate'),
            _quickPlanRow(
              'Insulin after â‰¥1 h',
              result.holdInsulin ? 'HOLD' : '${_one(result.selectedInsulinUnitsHour)} U/h',
              result.holdInsulin ? 'Requires K >3.0' : 'Separate pump Â· no bolus',
              danger: result.holdInsulin,
            ),
            _quickPlanRow(
              'Two-bag split',
              '${_one(result.bagARateMlHour)} + ${_one(result.bagBRateMlHour)}',
              'Bag A + D${_formatDex(_bagBConcentration)} B â†’ D${_formatDex(_desiredDextrose)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickPlanRow(String label, String value, String note, {bool danger = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11))),
              Text(
                value,
                style: TextStyle(
                  color: danger ? const Color(0xFFFF9E98) : Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(note, style: const TextStyle(color: Colors.white38, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _criterionCard(String label, ClinicalCriterion criterion, String note, double width) {
    final met = criterion == ClinicalCriterion.met;
    final text = criterion == ClinicalCriterion.unknown
        ? 'Unknown'
        : met
            ? 'Met'
            : 'Not met';
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 115),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: met ? const Color(0xFFFFF0EE) : Colors.white,
        border: Border.all(color: met ? const Color(0xFFEFBFBB) : const Color(0xFFDCE3E3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, letterSpacing: 1, color: Colors.black54)),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: met ? _red : _navy, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(note, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _metricWrap(List<_MetricData> metrics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 720 ? 3 : 1;
        final width = count == 3 ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: metrics.map((metric) => _metricCard(metric, width)).toList(),
        );
      },
    );
  }

  Widget _metricCard(_MetricData metric, double width) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: metric.tone == null ? Colors.white : metric.tone!.withValues(alpha: 0.08),
        border: Border.all(color: metric.tone?.withValues(alpha: 0.35) ?? const Color(0xFFDCE3E3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(metric.label.toUpperCase(), style: const TextStyle(fontSize: 9, letterSpacing: 1, color: Colors.black54)),
          const SizedBox(height: 9),
          Text(
            metric.value,
            style: TextStyle(color: metric.tone ?? _navy, fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(metric.note, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _alert(String title, String body, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(body, style: TextStyle(color: color, fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkAlert(String title, String body, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
          const SizedBox(height: 3),
          Text(body, style: const TextStyle(color: Colors.white70, fontSize: 9, height: 1.35)),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Color _diagnosisColor(DkaDiagnosis diagnosis) {
    switch (diagnosis) {
      case DkaDiagnosis.criteriaMet:
        return _red;
      case DkaDiagnosis.triadMetGapUnavailable:
        return _orange;
      case DkaDiagnosis.notFullyMet:
        return _green;
      case DkaDiagnosis.incomplete:
        return Colors.blueGrey;
    }
  }

  String _formatDex(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);

  void _addTrendReading() {
    setState(() {
      _trendReadings.add(_TrendReading(id: _nextTrendId++, time: '${_trendReadings.length} h'));
    });
  }

  DataRow _trendRow(_TrendReading reading) {
    return DataRow(
      key: ValueKey(reading.id),
      cells: [
        _trendCell(reading, 'time'),
        _trendCell(reading, 'bg'),
        _trendCell(reading, 'na'),
        _trendCell(reading, 'cl'),
        _trendCell(reading, 'hco3'),
        _trendCell(reading, 'ph'),
        _trendCell(reading, 'k'),
        _trendCell(reading, 'bohb'),
        DataCell(Text(_one(reading.correctedSodium), style: const TextStyle(fontWeight: FontWeight.w800))),
        DataCell(Text(_one(reading.anionGap), style: const TextStyle(fontWeight: FontWeight.w800))),
        DataCell(
          IconButton(
            tooltip: 'Remove reading',
            onPressed: () => setState(() => _trendReadings.remove(reading)),
            icon: const Icon(Icons.close, size: 18),
          ),
        ),
      ],
    );
  }

  DataCell _trendCell(_TrendReading reading, String field) {
    return DataCell(
      SizedBox(
        width: field == 'time' ? 70 : 58,
        child: TextFormField(
          key: ValueKey('${reading.id}-$field'),
          initialValue: reading.value(field),
          keyboardType: field == 'time'
              ? TextInputType.text
              : const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(7)),
          onChanged: (value) {
            reading.setValue(field, value);
            setState(() {});
          },
        ),
      ),
    );
  }

  List<Widget> _trendFlags() {
    if (_trendReadings.length < 2) return const [];
    final previous = _trendReadings[_trendReadings.length - 2];
    final current = _trendReadings.last;
    final flags = <Widget>[];
    if (previous.glucose != null && current.glucose != null) {
      final fall = previous.glucose! - current.glucose!;
      if (fall > 5) {
        flags.add(
          _alert(
            'Glucose falling >5 mmol/L/h',
            'Increase dextrose. If dextrose is maximized, review insulin reduction per CPS/local protocol.',
            _orange,
            Icons.warning_amber,
          ),
        );
      }
    }
    if (previous.correctedSodium != null && current.correctedSodium != null) {
      final change = current.correctedSodium! - previous.correctedSodium!;
      if (change.abs() > 3) {
        flags.add(
          _alert(
            'Corrected sodium changing >3 mmol/L/h',
            'Urgently reassess the patient, fluid plan, neurologic status, and local protocol.',
            _red,
            Icons.error_outline,
          ),
        );
      }
    }
    return flags;
  }
}

class _MetricData {
  const _MetricData(this.label, this.value, this.note, {this.tone});
  final String label;
  final String value;
  final String note;
  final Color? tone;
}

class _TrendReading {
  _TrendReading({required this.id, required this.time});
  final int id;
  String time;
  String bg = '';
  String na = '';
  String cl = '';
  String hco3 = '';
  String ph = '';
  String k = '';
  String bohb = '';

  double? _number(String value) => value.trim().isEmpty ? null : double.tryParse(value);
  double? get glucose => _number(bg);
  double? get correctedSodium => DkaEngine.correctedSodium(_number(na), _number(bg));
  double? get anionGap => DkaEngine.anionGap(_number(na), _number(cl), _number(hco3));

  String value(String field) {
    switch (field) {
      case 'time': return time;
      case 'bg': return bg;
      case 'na': return na;
      case 'cl': return cl;
      case 'hco3': return hco3;
      case 'ph': return ph;
      case 'k': return k;
      case 'bohb': return bohb;
      default: return '';
    }
  }

  void setValue(String field, String value) {
    switch (field) {
      case 'time': time = value; break;
      case 'bg': bg = value; break;
      case 'na': na = value; break;
      case 'cl': cl = value; break;
      case 'hco3': hco3 = value; break;
      case 'ph': ph = value; break;
      case 'k': k = value; break;
      case 'bohb': bohb = value; break;
    }
  }
}

class _ChecklistItem extends StatefulWidget {
  const _ChecklistItem(this.label);
  final String label;

  @override
  State<_ChecklistItem> createState() => _ChecklistItemState();
}

class _ChecklistItemState extends State<_ChecklistItem> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      child: CheckboxListTile(
        value: checked,
        onChanged: (value) => setState(() => checked = value ?? false),
        title: Text(widget.label, style: const TextStyle(fontSize: 12)),
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFDCE3E3)),
        ),
      ),
    );
  }
}

class _EmergencyList extends StatelessWidget {
  const _EmergencyList({required this.title, required this.items, this.numbered = false});
  final String title;
  final List<String> items;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 10),
        for (var index = 0; index < items.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(
              '${numbered ? '${index + 1}.' : 'â€¢'} ${items[index]}',
              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.35),
            ),
          ),
      ],
    );
  }
}

class _DefinitionRow extends StatelessWidget {
  const _DefinitionRow(this.term, this.definition);
  final String term;
  final String definition;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 160, child: Text(term, style: const TextStyle(fontWeight: FontWeight.w900))),
          Expanded(child: Text(definition, style: const TextStyle(height: 1.45))),
        ],
      ),
    );
  }
}

