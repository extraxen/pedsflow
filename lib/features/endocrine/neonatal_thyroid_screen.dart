// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
import 'package:flutter/material.dart';
import 'neonatal_thyroid_engine.dart';

class NeonatalThyroidScreen extends StatefulWidget {
  const NeonatalThyroidScreen({super.key});
  @override
  State<NeonatalThyroidScreen> createState() => _NeonatalThyroidScreenState();
}

class _NeonatalThyroidScreenState extends State<NeonatalThyroidScreen> {
  final _age = TextEditingController();
  final _tsh = TextEditingController();
  final _ft4 = TextEditingController();
  bool _serumConfirmed = false;
  bool _preterm = false;
  bool _pituitaryConcern = false;
  bool _onLt4 = false;
  ThyroidScreenStatus _screen = ThyroidScreenStatus.unknown;

  @override
  void dispose() {
    _age.dispose();
    _tsh.dispose();
    _ft4.dispose();
    super.dispose();
  }

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());
  double? _double(TextEditingController c) =>
      double.tryParse(c.text.trim());

  void _reset() {
    _age.clear();
    _tsh.clear();
    _ft4.clear();
    setState(() {
      _serumConfirmed = false;
      _preterm = false;
      _pituitaryConcern = false;
      _onLt4 = false;
      _screen = ThyroidScreenStatus.unknown;
    });
  }

  Widget _field(TextEditingController c, String label, String unit) =>
      SizedBox(
        width: 230,
        child: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            suffixText: unit,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
      );

  Widget _panel(String heading, List<Widget> children, {IconData? icon}) =>
      Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                if (icon != null) ...[
                  Icon(icon), const SizedBox(width: 10),
                ],
                Expanded(child: Text(
                  heading,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                )),
              ]),
              const SizedBox(height: 12),
              ...children.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: w,
                  )),
            ],
          ),
        ),
      );

  String _flag(ThyroidValueFlag flag) {
    switch (flag) {
      case ThyroidValueFlag.below: return 'Below chart range';
      case ThyroidValueFlag.within: return 'Within chart range';
      case ThyroidValueFlag.above: return 'Above chart range';
      case ThyroidValueFlag.unavailable: return 'Not classifiable';
    }
  }

  Widget _resultRow(String label, double? value, String unit,
      ThyroidReference? reference, ThyroidValueFlag flag) {
    final range = reference == null
        ? 'No reference in supplied table for this age'
        : '${reference.formatted} ${unit}  •  ${reference.ageLabel}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(value == null ? 'Not entered' : '${value.toStringAsFixed(2)} ${unit}',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(_flag(flag), style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(range, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }

  Widget _referenceTable(String name, List<List<String>> rows) =>
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(name),
        subtitle: const Text('Transcribed from supplied image'),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Age band')),
                DataColumn(label: Text('Reference interval')),
              ],
              rows: rows.map((row) => DataRow(
                cells: [
                  DataCell(Text(row[0])),
                  DataCell(Text(row[1])),
                ],
              )).toList(),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final age = _int(_age);
    final tsh = _double(_tsh);
    final ft4 = _double(_ft4);
    final assessment = NeonatalThyroidEngine.assess(
      ThyroidTriageInput(
        ageDays: age,
        tshMiuL: tsh,
        freeT4PmolL: ft4,
        serumConfirmed: _serumConfirmed,
        newbornScreen: _screen,
        pretermOrNicu: _preterm,
        pituitaryConcern: _pituitaryConcern,
        onLevothyroxine: _onLt4,
      ),
    );

    final urgent = assessment.priority == ThyroidPriority.urgent;
    final resultIcon = urgent
        ? Icons.warning_amber_outlined
        : assessment.priority == ThyroidPriority.chartOnly
            ? Icons.fact_check_outlined : Icons.info_outline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Neonatal Thyroid (TSH / FT4)'),
        actions: [
          TextButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 30),
        children: [
          _panel('Use and limitations', [
            const Text('Enter postnatal age and paired serum TSH/free T4. '
                'The slide supplies age-specific intervals, but normal '
                'ranges are laboratory and assay dependent. '
                'They are NOT themselves treatment thresholds.'),
            const Text('The guidance below is for possible congenital '
                'hypothyroidism; it does not replace the newborn-screen '
                'program, endocrine staff, clinical examination or the '
                'performing laboratory’s official reference intervals.'),
          ], icon: Icons.health_and_safety_outlined),
          _panel('1. Serum laboratory values', [
            Wrap(spacing: 12, runSpacing: 12, children: [
              _field(_age, 'Postnatal age (completed days)', 'days'),
              _field(_tsh, 'Serum TSH', 'mIU/L'),
              _field(_ft4, 'Serum free T4', 'pmol/L'),
            ]),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _serumConfirmed,
              onChanged: (v) => setState(() => _serumConfirmed = v ?? false),
              title: const Text('These are SERUM measurements'),
              subtitle: const Text('Not a dried-blood-spot newborn screen. '
                  'Serum and screening TSH thresholds are different.'),
            ),
            DropdownButtonFormField<ThyroidScreenStatus>(
              initialValue: _screen,
              decoration: const InputDecoration(
                labelText: 'Newborn screening result',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: ThyroidScreenStatus.unknown,
                  child: Text('Unknown / not available')),
                DropdownMenuItem(value: ThyroidScreenStatus.reportedNormal,
                  child: Text('Reported normal')),
                DropdownMenuItem(value: ThyroidScreenStatus.reportedAbnormal,
                  child: Text('Abnormal / positive')),
              ],
              onChanged: (v) => setState(() =>
                  _screen = v ?? ThyroidScreenStatus.unknown),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _preterm,
              onChanged: (v) => setState(() => _preterm = v),
              title: const Text('Preterm or NICU / critically ill'),
              subtitle: const Text('Delayed TSH rise and different '
                  'screening follow-up may apply'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _pituitaryConcern,
              onChanged: (v) => setState(() => _pituitaryConcern = v),
              title: const Text('Concern for pituitary / central disease'),
              subtitle: const Text('Midline CNS anomaly, hypoglycemia, '
                  'micropenis or multiple pituitary deficits'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _onLt4,
              onChanged: (v) => setState(() => _onLt4 = v),
              title: const Text('Already taking levothyroxine'),
              subtitle: const Text('Use treated-patient endocrine '
                  'monitoring, not the initial diagnostic pathway'),
            ),
          ], icon: Icons.science_outlined),
          _panel('2. Age-specific interpretation', [
            _resultRow('TSH', tsh, 'mIU/L',
                assessment.tshReference, assessment.tshFlag),
            _resultRow('Free T4', ft4, 'pmol/L',
                assessment.freeT4Reference, assessment.freeT4Flag),
          ], icon: Icons.analytics_outlined),
          _panel('3. Suggested next step', [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(resultIcon, color: urgent
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(assessment.heading,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: urgent
                      ? Theme.of(context).colorScheme.error
                      : null,
                ))),
            ]),
            ...assessment.steps.asMap().entries.map((entry) =>
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${entry.key + 1}.  ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(entry.value)),
              ])),
          ], icon: Icons.fact_check_outlined),
          _panel('Clinical cautions', [
            ...assessment.notes.map((note) =>
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(note)),
                ])),
          ]),
          _panel('Reference table', [
            _referenceTable('Free T4 (pmol/L)', const [
              ['3 d – <15 d', '13.0–52.2'],
              ['15 d – <30 d', '10.5–30.0'],
              ['30 d – <4 mo', '10.5–22.7'],
              ['4 mo – <1 y', '10.0–22.0'],
              ['1 y – <19 y', '10.0–17.6'],
            ]),
            _referenceTable('TSH (mIU/L)', const [
              ['<5 days', '3.2–19'],
              ['6–31 days', '1.7–9.1'],
              ['1–2 months', '0.5–6.3'],
              ['3 – <6 months', '0.5–4.77'],
              ['6 months – <1 year', '0.61–4.58'],
              ['1 – <14 years', '0.73–4.09'],
              ['14 – <19 years', '0.47–4.00'],
            ]),
            const Text('The slide has no FT4 interval before day 3 '
                'and no TSH interval specifically at day 5. '
                'For age >31 days, month/year cutoffs from age-in-days '
                'are approximate. Verify birth/specimen dates and '
                'the local performing laboratory.'),
          ], icon: Icons.table_chart_outlined),
          _panel('Guideline basis', const [
            Text('ENDO-ERN/ESPE 2020–2021 consensus: paired serum testing '
                'after abnormal screen; low FT4 with clearly high TSH '
                'requires prompt specialist-directed LT4. '
                'Serum TSH >20 mIU/L in approximately the second week '
                'is a treatment indication even when FT4 is normal.'),
            Text('For a well infant beyond 21 days with TSH '
                '6–20 mIU/L and age-normal FT4, evidence is uncertain: '
                'endocrinology may choose treatment or repeat testing '
                'in 1–2 weeks. Low FT4 with an inappropriately normal '
                'TSH suggests possible CENTRAL hypothyroidism; adrenal '
                'status must be assessed before LT4.'),
            Text('AAP Pediatrics 2023: selected preterm/NICU/very-low-'
                'birth-weight infants need a repeat newborn screen '
                'at 2–4 weeks under the screening program.'),
            Text('Sources: ENDO-ERN 2021 (PMCID: PMC8001676); '
                'AAP Congenital Hypothyroidism: Screening and '
                'Management (2023).'),
          ], icon: Icons.menu_book_outlined),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('PedsFlow educational decision support • '
                'Age-specific limits from user-provided reference image, '
                'not independently validated for SickKids assay. '
                'No automated levothyroxine dose or medication order. '
                'Review date: 4 Nov 2026.'),
          ),
        ],
      ),
    );
  }
}
