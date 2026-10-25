// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
import 'package:flutter/material.dart';
import 'insulin_math.dart';

class InsulinWorkspaceScreen extends StatefulWidget {
  const InsulinWorkspaceScreen({super.key});
  @override
  State<InsulinWorkspaceScreen> createState() => _InsulinWorkspaceScreenState();
}

class _InsulinWorkspaceScreenState extends State<InsulinWorkspaceScreen> {
  final _tdd = TextEditingController();
  final _icr = TextEditingController();
  final _isf = TextEditingController();
  final _carbs = TextEditingController();
  final _glucose = TextEditingController();
  final _target = TextEditingController();
  int _icrRule = 500;
  double? _doseStep;
  bool _reviewed = false;

  @override
  void dispose() {
    for (final c in [_tdd, _icr, _isf, _carbs, _glucose, _target]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _read(TextEditingController c) {
    final value = double.tryParse(c.text.trim());
    return value != null && value.isFinite ? value : null;
  }

  void _reset() {
    for (final c in [_tdd, _icr, _isf, _carbs, _glucose, _target]) {
      c.clear();
    }
    setState(() {
      _icrRule = 500;
      _doseStep = null;
      _reviewed = false;
    });
  }

  Widget _field(TextEditingController controller, String name, String unit,
      {String? hint}) {
    return SizedBox(
      width: 225,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: name,
          hintText: hint,
          suffixText: unit,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {_reviewed = false;}),
      ),
    );
  }

  Widget _panel(String title, List<Widget> contents, {IconData? icon}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          ]),
          const SizedBox(height: 12),
          ...contents.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: w,
              )),
        ]),
      ),
    );
  }

  Widget _result(String label, String value) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
  );

  @override
  Widget build(BuildContext context) {
    final total = _read(_tdd);
    final icrEstimate = InsulinMath.estimatedIcr(total, rule: _icrRule);
    final isfEstimate = InsulinMath.estimatedIsf(total);
    final meal = InsulinMath.mealUnits(
      carbohydrateGrams: _read(_carbs),
      prescribedIcrGramsPerUnit: _read(_icr),
    );
    final current = _read(_glucose);
    final target = _read(_target);
    final correction = InsulinMath.correctionUnits(
      currentMmolL: current,
      targetMmolL: target,
      prescribedIsfMmolLPerUnit: _read(_isf),
    );
    final low = current != null && current < 3.9;
    final canCombine = _reviewed && !low &&
        meal != null && correction != null;
    final combined = canCombine ? meal + correction : null;
    final rounded = InsulinMath.nearestIncrement(combined, _doseStep);
    return Scaffold(
      appBar: AppBar(title: const Text('ICR / ISF workspace'),
        actions: [TextButton.icon(onPressed: _reset,
          icon: const Icon(Icons.refresh), label: const Text('Reset'))]),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        _panel('Clinical safety', [
          const Text('Educational calculation display only. No patient settings are pre-filled. '
              'An ISPAD estimate is never automatically used as a prescribed setting. '
              'Confirm all orders with the pediatric diabetes team.'),
          const Text('Units: carbohydrate g; insulin U; glucose mmol/L; '
              'ICR g/U; ISF mmol/L per U. Pump bolus calculators and AID algorithms '
              'may calculate differently.'),
        ], icon: Icons.verified_user_outlined),
        _panel('1. Explore initial estimates (not a prescription)', [
          Wrap(spacing: 12, runSpacing: 12, children: [
            _field(_tdd, 'Known total daily insulin', 'U/day'),
            SizedBox(width: 225, child: DropdownButtonFormField<int>(
              initialValue: _icrRule,
              decoration: const InputDecoration(labelText: 'ICR estimation rule',
                border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 500, child: Text('500 / TDD')),
                DropdownMenuItem(value: 330, child: Text('330 / TDD (preschool)')),
                DropdownMenuItem(value: 250, child: Text('250 / TDD (preschool)')),
              ],
              onChanged: (v) => setState(() => _icrRule = v ?? 500),
            )),
          ]),
          if (icrEstimate != null) ...[
            _result('Estimated ICR', '1 U per ${icrEstimate.toStringAsFixed(1)} g carbohydrate'),
            _result('Estimated ISF (100-rule)',
              '${isfEstimate!.toStringAsFixed(2)} mmol/L per U '
              '(~${(isfEstimate! * 18.0182).toStringAsFixed(1)} mg/dL per U)'),
          ] else
            const Text('Enter a valid, known TDD to view estimates. '
                'TDD is not inferred from weight.'),
          if (_icrRule != 500)
            const Text('The 330/250 rules are preschool-specific alternatives, '
                'not universal pediatric defaults.'),
          ExpansionTile(title: const Text('Why these formulas?'),
            tilePadding: EdgeInsets.zero, children: [
              Text('ICR = $_icrRule / TDD in U/day (g per U). '
                  'ISF = 100 / TDD in U/day (mmol/L per U). '
                  'These are starting rules; breakfast, exercise, puberty, '
                  'honeymoon phase and other circumstances may change requirements.'),
              const SizedBox(height: 8),
              const Text('ISPAD 2024, Insulin and Adjunctive Treatments, '
                  'pp. 596-597. Local SickKids starting-rule policy not verified.'),
            ]),
        ], icon: Icons.auto_graph_outlined),
        _panel('2. Calculate using established patient settings', [
          const Text('Enter the patient-specific ICR and ISF documented in '
              'their current diabetes plan. Leave a field blank if unknown.'),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _field(_icr, 'Prescribed ICR', 'g/U'),
            _field(_isf, 'Prescribed ISF', 'mmol/L/U'),
            _field(_carbs, 'Meal carbohydrate', 'g'),
            _field(_glucose, 'Current glucose', 'mmol/L'),
            _field(_target, 'Individualized target', 'mmol/L'),
          ]),
          if (low)
            const Text('LOW GLUCOSE: follow the patient-specific hypoglycemia '
                'protocol. A positive combined bolus is suppressed.'),
          if (meal != null)
            _result('Carbohydrate component (unrounded)',
                '${meal.toStringAsFixed(2)} U = ${_read(_carbs)} g / ${_read(_icr)} g/U'),
          if (correction != null && !low)
            _result('Correction component (unrounded)',
                '${correction.toStringAsFixed(2)} U = max(0, '
                '(${current} - ${target}) mmol/L / ${_read(_isf)} mmol/L/U)'),
          if (current != null && target != null && current < target)
            const Text('Glucose is below the selected target. Zero correction '
                'does not mean the meal dose is appropriate; use the individual plan.'),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('I reviewed active insulin, recent boluses, '
                'ketones/illness, exercise, delivery method and the local plan.'),
            subtitle: const Text('Required to show the combined arithmetic result. '
                'This is not a prescribing confirmation.'),
            value: _reviewed,
            onChanged: (v) => setState(() => _reviewed = v ?? false),
          ),
          if (combined != null) ...[
            _result('Combined arithmetic only — NOT an order',
                '${combined.toStringAsFixed(2)} U before IOB and device algorithm adjustments'),
            DropdownButtonFormField<double>(
              key: ValueKey(_doseStep),
              initialValue: _doseStep,
              decoration: const InputDecoration(
                labelText: 'Select actual device dose increment (optional)',
                border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 U')),
                DropdownMenuItem(value: 0.5, child: Text('0.5 U')),
                DropdownMenuItem(value: 0.1, child: Text('0.1 U')),
                DropdownMenuItem(value: 0.05, child: Text('0.05 U')),
              ],
              onChanged: (v) => setState(() => _doseStep = v),
            ),
            if (rounded != null)
              _result('Nearest-increment illustration — NOT an order',
                '${rounded.toStringAsFixed(2)} U (increment $_doseStep U). '
                'Rounding up can increase hypoglycemia risk.'),
          ] else
            const Text('The combined result stays hidden until all required '
                'patient-specific fields are valid and the safety review is checked.'),
          const Text('Do not use arithmetic for automated insulin delivery. '
              'Pump users must use the device algorithm and current diabetes '
              'team plan; do not manually double-count correction insulin.'),
        ], icon: Icons.calculate_outlined),
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Reviewed 25 Oct 2026 • ISPAD 2024 Chapter 9, '
              'DOI 10.1159/000543169 • Verify SickKids protocol locally.'),
        ),
      ]),
    );
  }
}
