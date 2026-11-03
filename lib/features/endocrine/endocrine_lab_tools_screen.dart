// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in repository root.
import 'package:flutter/material.dart';
import 'endocrine_lab_math.dart';

double? _number(TextEditingController c) {
  final n = double.tryParse(c.text.trim());
  return n != null && n.isFinite ? n : null;
}

Widget _labField(TextEditingController controller, String label, String unit,
    VoidCallback changed) => SizedBox(
  width: 230,
  child: TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      suffixText: unit.isEmpty ? null : unit,
      border: const OutlineInputBorder(),
    ),
    onChanged: (_) => changed(),
  ),
);

Widget _labCard(BuildContext context, String title, List<Widget> children,
    {IconData icon = Icons.calculate_outlined}) => Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold))),
      ]),
      const SizedBox(height: 14),
      ...children.map((w) => Padding(
        padding: const EdgeInsets.only(bottom: 12), child: w)),
    ]),
  ),
);

Widget _labAnswer(BuildContext context, String title, String result, String detail) =>
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 5),
      Text(result, style: Theme.of(context).textTheme.headlineSmall
          ?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Text(detail, style: Theme.of(context).textTheme.bodySmall),
    ]),
  );

Widget _labSafety(String s) => Row(crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Icon(Icons.warning_amber_outlined, size: 20),
    const SizedBox(width: 9),
    Expanded(child: Text(s)),
  ]);

Widget _labPage(String title, VoidCallback clear, List<Widget> sections) =>
  Scaffold(
    appBar: AppBar(title: Text(title, style: const TextStyle(
      fontWeight: FontWeight.w800)),
      actions: [TextButton.icon(
        onPressed: clear,
        icon: const Icon(Icons.refresh),
        label: const Text('Reset'),
      )]),
    body: ListView(padding: const EdgeInsets.fromLTRB(12, 12, 12, 30),
      children: sections.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 12), child: s)).toList()),
  );

class SteroidConversionScreen extends StatefulWidget {
  const SteroidConversionScreen({super.key});
  @override
  State<SteroidConversionScreen> createState() => _SteroidConversionScreenState();
}

class _SteroidConversionScreenState extends State<SteroidConversionScreen> {
  final _dose = TextEditingController();
  final _frequency = TextEditingController();
  SteroidAgent? _from, _to;

  @override
  void dispose() {
    _dose.dispose();
    _frequency.dispose();
    super.dispose();
  }

  void _clear() => setState(() {
    _dose.clear();
    _frequency.clear();
    _from = null;
    _to = null;
  });

  @override
  Widget build(BuildContext context) {
    final dose = _number(_dose);
    final times = int.tryParse(_frequency.text.trim());
    final result = (_from != null && _to != null)
        ? EndocrineLabMath.steroidEquivalent(
            sourceDoseMg: dose, from: _from!, to: _to!)
        : null;
    final daily = (_from != null && _to != null)
        ? EndocrineLabMath.steroidDailyEquivalent(
            sourceDoseMg: dose, administrationsPerDay: times,
            from: _from!, to: _to!)
        : null;
    Widget agentSelector(String label, SteroidAgent? selected,
        void Function(SteroidAgent?) changed) =>
      DropdownButtonFormField<SteroidAgent>(
        initialValue: selected,
        isExpanded: true,
        decoration: InputDecoration(labelText: label,
          border: const OutlineInputBorder()),
        items: SteroidAgent.values.map((a) => DropdownMenuItem(
          value: a, child: Text(a.label))).toList(),
        onChanged: (v) => setState(() => changed(v)),
      );

    return _labPage('Steroid Conversion', _clear, [
      _labCard(context, 'When to use', [
        const Text('Estimate relative systemic glucocorticoid '
            'anti-inflammatory potency when comparing two agents. '
            'Use verified institutional orders for any actual switch.'),
        _labSafety('NOT for adrenal-crisis stress dosing, automatic '
            'maintenance replacement, taper schedules, or converting '
            'inhaled, topical, intranasal, depot or intra-articular steroids.'),
      ], icon: Icons.info_outline),
      _labCard(context, 'Conversion inputs', [
        agentSelector('Converting from', _from, (v) => _from = v),
        if (_from != null) Text('Source: ${_from!.routeNote}'),
        _labField(_dose, 'Dose per administration', 'mg',
            () => setState(() {})),
        agentSelector('Converting to', _to, (v) => _to = v),
        if (_to != null) Text('Target: ${_to!.routeNote}'),
        _labField(_frequency, 'Administrations per 24 h (optional)',
            'times', () => setState(() {})),
        if (result != null)
          _labAnswer(context, 'Approximate equivalent per administration',
            '${result.toStringAsFixed(3)} mg',
            '${dose!.toStringAsFixed(3)} mg ÷ '
            '${_from!.equivalentMg} mg × ${_to!.equivalentMg} mg. '
            'Potency equivalence only; frequency and route must be reviewed.'),
        if (daily != null)
          _labAnswer(context, 'Approximate 24-hour equivalent total',
            '${daily.toStringAsFixed(3)} mg/24 h',
            '${result!.toStringAsFixed(3)} mg-equivalent × ${times!} '
            'source administrations. This does not establish a target '
            'schedule or route.'),
        if (result == null)
          const Text('Select two agents and enter a positive source dose. '
              'No patient-specific values are pre-filled.'),
      ]),
      _labCard(context, 'Steroid comparison reference', [
        const Text('Approximate systemic anti-inflammatory equivalence '
            'relative to hydrocortisone 20 mg:'),
        ...SteroidAgent.values.map((a) => Row(children: [
          Expanded(child: Text(a.label)),
          Text('${a.equivalentMg} mg',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ])),
        const Divider(),
        _labSafety('The 0.75 mg dexamethasone and 0.6 mg betamethasone '
            'conventions are historical approximations. Other recent '
            'tables use 0.5 mg or 0.8 mg. Duration, mineralocorticoid '
            'effect and pharmacokinetics differ; not dose-equivalent for '
            'all indications. Check pharmacy and endocrine guidance.'),
        const ExpansionTile(
          title: Text('Evidence and clinical limits'),
          tilePadding: EdgeInsets.zero,
          children: [
            Text('Endotext: Glucocorticoid Therapy and Adrenal Suppression, '
                'Table 1 (2018); Endocrine Reviews 2024 Table 1. '
                'Oral and IV bioavailability may differ. Prednisone '
                'requires hepatic activation. Fludrocortisone is excluded '
                'because its main role is mineralocorticoid replacement. '
                'This table does not assess HPA suppression or tapering.'),
          ],
        ),
      ], icon: Icons.menu_book_outlined),
      const Text('Educational calculation only • Clinical content reviewed '
          '3 Nov 2026 • SickKids/local protocol not verified.'),
    ]);
  }
}

class HyperglycemiaSodiumScreen extends StatefulWidget {
  const HyperglycemiaSodiumScreen({super.key});
  @override
  State<HyperglycemiaSodiumScreen> createState() => _HyperglycemiaSodiumScreenState();
}

class _HyperglycemiaSodiumScreenState extends State<HyperglycemiaSodiumScreen> {
  final _sodium = TextEditingController();
  final _glucose = TextEditingController();
  bool _mmol = true;

  @override
  void dispose() {
    _sodium.dispose();
    _glucose.dispose();
    super.dispose();
  }

  void _clear() => setState(() {
    _sodium.clear();
    _glucose.clear();
    _mmol = true;
  });

  @override
  Widget build(BuildContext context) {
    final na = _number(_sodium);
    final g = _number(_glucose);
    final mg = _mmol ? EndocrineLabMath.glucoseMgDl(g) : g;
    final mmol = _mmol ? g : (g != null && g >= 0) ? g / 18.0182 : null;
    final kats = EndocrineLabMath.correctedSodium(
      measuredNaMmolL: na, glucoseMgDl: mg, correctionPer100MgDl: 1.6);
    final hillier = EndocrineLabMath.correctedSodium(
      measuredNaMmolL: na, glucoseMgDl: mg, correctionPer100MgDl: 2.4);
    final cps = EndocrineLabMath.cpsDkaCorrectedSodium(
      measuredNaMmolL: na, glucoseMmolL: mmol);
    final highGlucose = mg != null && mg > 400;
    return _labPage('Sodium Correction for Hyperglycemia', _clear, [
      _labCard(context, 'When to use', [
        const Text('Estimate how sodium may change as glucose returns '
            'toward normal. This is a calculated estimate, not a '
            'measurement of the patient’s "true" sodium.'),
        _labSafety('For pediatric DKA, Canadian Paediatric Society '
            'corrected-sodium guidance is shown separately. '
            'Use measured sodium for anion-gap and osmolarity calculations.'),
      ], icon: Icons.info_outline),
      _labCard(context, 'Laboratory values', [
        _labField(_sodium, 'Measured serum sodium', 'mmol/L',
            () => setState(() {})),
        Wrap(spacing: 8, children: [
          ChoiceChip(label: const Text('Glucose mmol/L'),
            selected: _mmol, onSelected: (_) => setState(() {
              if (!_mmol) _glucose.clear();
              _mmol = true;
            })),
          ChoiceChip(label: const Text('Glucose mg/dL'),
            selected: !_mmol, onSelected: (_) => setState(() {
              if (_mmol) _glucose.clear();
              _mmol = false;
            })),
        ]),
        _labField(_glucose, 'Serum glucose', _mmol ? 'mmol/L' : 'mg/dL',
            () => setState(() {})),
        if (kats != null && hillier != null) ...[
          _labAnswer(context, 'Katz (1973) — 1.6 correction',
            '${kats.toStringAsFixed(1)} mmol/L',
            'Na + 1.6 × (glucose [mg/dL] − 100) / 100'),
          _labAnswer(context, 'Hillier (1999) — 2.4 correction',
            '${hillier.toStringAsFixed(1)} mmol/L',
            'Na + 2.4 × (glucose [mg/dL] − 100) / 100'),
        ] else
          const Text('Enter a valid measured sodium and glucose '
              'at or above 100 mg/dL (approximately 5.55 mmol/L). '
              'These corrections are not extrapolated into hypoglycemia.'),
        if (cps != null)
          _labAnswer(context, 'CPS pediatric DKA (separate protocol)',
            '${cps.toStringAsFixed(1)} mmol/L',
            'Measured Na + (glucose [mmol/L] − 5) × 0.3'),
        if (highGlucose)
          _labSafety('Glucose above 400 mg/dL (22.2 mmol/L): '
              'the observed relation may not be linear. Hillier found '
              'a larger sodium change at very high glucose; '
              'avoid treating the linear result as a definitive target.'),
      ], icon: Icons.science_outlined),
      _labCard(context, 'Evidence and interpretation', [
        const Text('Katz M, NEJM 1973; Hillier et al., Am J Med 1999. '
            'Hillier’s 2.4 factor came from a small study in healthy '
            'volunteers, not a universal pediatric DKA treatment rule.'),
        const Text('Canadian Paediatric Society: Current recommendations '
            'for management of paediatric DKA (2023). Corrected Na '
            'trends matter clinically; interpret together with glucose, '
            'volume status, neurological examination and local pathway.'),
        const Text('At high glucose, measured and corrected sodium '
            'can diverge markedly. Do not prescribe fluids or sodium '
            'correction rates from these outputs alone.'),
      ], icon: Icons.menu_book_outlined),
      const Text('Educational calculator • Reviewed 3 Nov 2026. '
          'Verify local SickKids DKA policy.'),
    ]);
  }
}

class SerumAnionGapScreen extends StatefulWidget {
  const SerumAnionGapScreen({super.key});
  @override
  State<SerumAnionGapScreen> createState() => _SerumAnionGapScreenState();
}

class _SerumAnionGapScreenState extends State<SerumAnionGapScreen> {
  final _na = TextEditingController();
  final _cl = TextEditingController();
  final _hco3 = TextEditingController();
  final _albumin = TextEditingController();

  @override
  void dispose() {
    for (final c in [_na, _cl, _hco3, _albumin]) { c.dispose(); }
    super.dispose();
  }

  void _clear() => setState(() {
    for (final c in [_na, _cl, _hco3, _albumin]) { c.clear(); }
  });

  @override
  Widget build(BuildContext context) {
    final na = _number(_na), cl = _number(_cl);
    final hco3 = _number(_hco3), albumin = _number(_albumin);
    final ag = EndocrineLabMath.serumAnionGap(
      sodiumMmolL: na, chlorideMmolL: cl, bicarbonateMmolL: hco3);
    final adjusted = EndocrineLabMath.albuminAdjustedAnionGap(
      anionGapMmolL: ag, albuminGL: albumin);
    return _labPage('Serum Anion Gap', _clear, [
      _labCard(context, 'When to use', [
        const Text('Evaluate metabolic acidosis and look for '
            'unmeasured anions. Interpret with pH, bicarbonate, '
            'lactate, ketones, renal function and clinical context.'),
        _labSafety('Use measured serum sodium, not hyperglycemia-corrected '
            'sodium. Enter contemporaneous laboratory values.'),
      ], icon: Icons.info_outline),
      _labCard(context, 'Laboratory values', [
        Wrap(spacing: 12, runSpacing: 12, children: [
          _labField(_na, 'Sodium', 'mmol/L', () => setState(() {})),
          _labField(_cl, 'Chloride', 'mmol/L', () => setState(() {})),
          _labField(_hco3, 'Bicarbonate / total CO₂', 'mmol/L',
              () => setState(() {})),
          _labField(_albumin, 'Albumin (optional)', 'g/L',
              () => setState(() {})),
        ]),
        if (ag != null)
          _labAnswer(context, 'Serum anion gap (without potassium)',
            '${ag.toStringAsFixed(1)} mmol/L',
            '${na!.toStringAsFixed(1)} − (${cl!.toStringAsFixed(1)} '
            '+ ${hco3!.toStringAsFixed(1)})')
        else
          const Text('Enter valid sodium, chloride and bicarbonate '
              'to calculate the anion gap.'),
        if (adjusted != null)
          _labAnswer(context, 'Albumin-adjusted anion gap (approximate)',
            '${adjusted.toStringAsFixed(1)} mmol/L',
            'AG + 0.25 × (40 − albumin [g/L])')
        else if (albumin != null && albumin > 40)
          const Text('Albumin correction displayed only for '
              'albumin values up to 40 g/L, to avoid extrapolation.'),
      ], icon: Icons.calculate_outlined),
      _labCard(context, 'Interpretation', [
        const Text('Reference intervals are laboratory dependent and '
            'may differ by analyser and whether potassium is included. '
            'A low albumin can conceal an elevated anion gap. '
            'Do not label a result "normal" without the local '
            'laboratory reference interval.'),
        const Text('Albumin adjustment: add approximately '
            '2.5 mmol/L for each 10 g/L that albumin is below 40 g/L. '
            'This is an estimate, not a corrected laboratory result.'),
        const Text('Source: American Thoracic Society ABG interpretation; '
            'Haber et al., Cleveland Clinic Journal of Medicine 2023.'),
      ], icon: Icons.menu_book_outlined),
      const Text('Educational calculator • Reviewed 3 Nov 2026.'),
    ]);
  }
}

class SerumOsmolarityScreen extends StatefulWidget {
  const SerumOsmolarityScreen({super.key});
  @override
  State<SerumOsmolarityScreen> createState() => _SerumOsmolarityScreenState();
}

class _SerumOsmolarityScreenState extends State<SerumOsmolarityScreen> {
  final _na = TextEditingController();
  final _glucose = TextEditingController();
  final _urea = TextEditingController();
  final _measured = TextEditingController();

  @override
  void dispose() {
    for (final c in [_na, _glucose, _urea, _measured]) { c.dispose(); }
    super.dispose();
  }

  void _clear() => setState(() {
    for (final c in [_na, _glucose, _urea, _measured]) { c.clear(); }
  });

  @override
  Widget build(BuildContext context) {
    final na = _number(_na), glucose = _number(_glucose);
    final urea = _number(_urea), measured = _number(_measured);
    final effective = EndocrineLabMath.effectiveOsmolarity(
      sodiumMmolL: na, glucoseMmolL: glucose);
    final total = EndocrineLabMath.calculatedTotalOsmolarity(
      sodiumMmolL: na, glucoseMmolL: glucose, ureaMmolL: urea);
    final gap = EndocrineLabMath.osmolalGap(
      measuredOsmolalityMOsmKg: measured,
      calculatedTotalOsmolarity: total);
    return _labPage('Serum Osmolality / Osmolarity', _clear, [
      _labCard(context, 'When to use', [
        const Text('Calculate effective osmolarity (tonicity), '
            'total calculated osmolarity and an optional osmolal gap.'),
        _labSafety('Calculated osmolarity is not directly measured '
            'osmolality. In clinical practice these numbers are often '
            'compared approximately, but units differ (mOsm/L versus '
            'mOsm/kg). Use measured laboratory osmolality when needed.'),
      ], icon: Icons.info_outline),
      _labCard(context, 'Laboratory values — Canadian SI', [
        Wrap(spacing: 12, runSpacing: 12, children: [
          _labField(_na, 'Measured sodium', 'mmol/L', () => setState(() {})),
          _labField(_glucose, 'Glucose', 'mmol/L',
              () => setState(() {})),
          _labField(_urea, 'Urea (NOT BUN)', 'mmol/L',
              () => setState(() {})),
          _labField(_measured, 'Measured osmolality (optional)',
              'mOsm/kg', () => setState(() {})),
        ]),
        if (effective != null)
          _labAnswer(context, 'Effective calculated osmolarity / tonicity',
            '${effective.toStringAsFixed(1)} mOsm/L',
            '2 × Na + glucose = 2 × ${na!.toStringAsFixed(1)} '
            '+ ${glucose!.toStringAsFixed(1)}')
        else
          const Text('Enter valid measured Na and glucose to '
              'calculate effective osmolarity.'),
        if (total != null)
          _labAnswer(context, 'Total calculated osmolarity',
            '${total.toStringAsFixed(1)} mOsm/L',
            '2 × Na + glucose + urea (all mmol/L)')
        else if (effective != null)
          const Text('Add serum urea in mmol/L for total osmolarity.'),
        if (gap != null)
          _labAnswer(context, 'Approximate osmolal gap',
            '${gap.toStringAsFixed(1)}',
            'Measured osmolality − total calculated osmolarity. '
            'Approximate comparison of mOsm/kg and mOsm/L.'),
      ], icon: Icons.calculate_outlined),
      _labCard(context, 'Important limitations', [
        const Text('Urea contributes to total osmolarity but is generally '
            'an ineffective osmole for tonicity. The total formula is '
            '2 × Na + glucose + urea; effective is 2 × Na + glucose.'),
        const Text('Do not enter BUN mg/dL as urea mmol/L. '
            'Use measured sodium even in hyperglycemia.'),
        const Text('Unmeasured osmoles, ethanol, mannitol, other '
            'osmotically active substances and assay differences can '
            'alter the osmolal gap. No automated toxicology diagnosis.'),
        const Text('Sources: Gloucestershire Hospitals NHS '
            'Clinical Biochemistry — Osmolality; '
            'ADA Standards of Care 2026, hyperglycemic crises.'),
      ], icon: Icons.menu_book_outlined),
      const Text('Educational calculator • Reviewed 3 Nov 2026. '
          'Use local laboratory reference intervals.'),
    ]);
  }
}
