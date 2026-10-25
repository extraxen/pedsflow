// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
import 'package:flutter/material.dart';
import 'insulin_math.dart';

/// A task-first front end for the existing pure, tested insulin arithmetic.
/// Estimated starting settings are never copied to patient-specific fields.
class InsulinWorkspaceScreen extends StatefulWidget {
  const InsulinWorkspaceScreen({super.key});

  @override
  State<InsulinWorkspaceScreen> createState() => _InsulinWorkspaceScreenState();
}

class _InsulinWorkspaceScreenState extends State<InsulinWorkspaceScreen> {
  final _tdd = TextEditingController();
  final _weight = TextEditingController();
  final _perKg = TextEditingController();
  final _basalPercent = TextEditingController();
  final _actualBasal = TextEditingController();
  final _actualRapid = TextEditingController();
  final _icr = TextEditingController();
  final _isf = TextEditingController();
  final _carbs = TextEditingController();
  final _glucose = TextEditingController();
  final _target = TextEditingController();

  int _selectedTool = 0;
  bool _historyMode = false;
  int? _icrRule;
  double? _doseStep;
  bool _reviewed = false;

  @override
  void dispose() {
    for (final c in [_tdd, _weight, _perKg, _basalPercent,
                     _actualBasal, _actualRapid,
                     _icr, _isf, _carbs, _glucose, _target]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _value(TextEditingController controller) {
    final number = double.tryParse(controller.text.trim());
    return number != null && number.isFinite ? number : null;
  }

  void _reset() {
    for (final c in [_tdd, _icr, _isf, _carbs, _glucose, _target]) {
      c.clear();
    }
    setState(() {
      _icrRule = null;
      _historyMode = false;
      _doseStep = null;
      _reviewed = false;
    });
  }

  Widget _field(TextEditingController controller, String title, String unit) {
    return SizedBox(
      width: 225,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: title,
          suffixText: unit,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() => _reviewed = false),
      ),
    );
  }

  Widget _card(String title, List<Widget> children, {IconData? icon}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (icon != null) ...[
                Icon(icon),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            ...children.map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: child,
                )),
          ],
        ),
      ),
    );
  }

  Widget _answer(String label, String value, String explanation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Text(value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        const SizedBox(height: 6),
        Text(explanation, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }


  Widget _startingPlanCalculator() {
    final weight = _value(_weight);
    final factor = _value(_perKg);
    final basalPercent = _value(_basalPercent);
    final observedBasal = _value(_actualBasal);
    final observedRapid = _value(_actualRapid);
    final total = _historyMode
        ? InsulinMath.observedTdd(
            basalUnitsLast24h: observedBasal,
            rapidBolusUnitsLast24h: observedRapid,
          )
        : InsulinMath.estimatedTddFromWeight(
            weightKg: weight,
            clinicianSelectedUnitsPerKgDay: factor,
          );
    final basal = _historyMode
        ? observedBasal
        : InsulinMath.basalFromApprovedPercentage(total, basalPercent);
    final bolus = InsulinMath.bolusFromTotalAndBasal(total, basal);
    final actualBasalFraction = _historyMode
        ? InsulinMath.basalPercentOfTdd(total, basal)
        : null;
    final perKg = InsulinMath.tddPerKg(total, weight);
    final estimatedIcr =
        InsulinMath.estimatedIcr(total, rule: _icrRule ?? -1);
    final estimatedIsf = InsulinMath.estimatedIsf(total);

    return _card('Starting Insulin Plan / TDD', [
      const Text(
        'Calculate total daily insulin and its basal/bolus components. '
        'All quantities below are arithmetic estimates or previously '
        'delivered insulin, not new orders.',
      ),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ChoiceChip(
          label: const Text('Weight-based estimate'),
          selected: !_historyMode,
          onSelected: (_) => setState(() => _historyMode = false),
        ),
        ChoiceChip(
          label: const Text('Actual past 24 hours'),
          selected: _historyMode,
          onSelected: (_) => setState(() => _historyMode = true),
        ),
      ]),
      if (!_historyMode) ...[
        const Text(
          'The clinician must choose the U/kg/day factor based on '
          'puberty, new diagnosis versus established T1D, remission '
          '(honeymoon), illness and individual insulin needs. '
          'No starting factor is pre-selected.',
        ),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _field(_weight, 'Patient weight', 'kg'),
          _field(_perKg, 'Clinician-selected daily factor', 'U/kg/day'),
          _field(_basalPercent, 'Clinician-selected basal fraction', '%'),
        ]),
        const Text(
          'ISPAD 2024 describes usual daily requirements around '
          '0.7-1.0 U/kg/day in prepubertal children outside remission; '
          'pubertal requirements can reach 1-2 U/kg/day or more. '
          'Partial remission is often below 0.5 U/kg/day. '
          'These are population descriptions, NOT default starting orders.',
        ),
        if (total != null)
          _answer(
            'Estimated TDD — NOT a prescription',
            '${total.toStringAsFixed(2)} U/day',
            '${weight!.toStringAsFixed(2)} kg × '
                '${factor!.toStringAsFixed(2)} U/kg/day',
          ),
        if (basal != null && bolus != null) ...[
          _answer(
            'Estimated daily basal — NOT an order',
            '${basal.toStringAsFixed(2)} U/day',
            '${total!.toStringAsFixed(2)} U/day × '
                '${basalPercent!.toStringAsFixed(1)}%',
          ),
          _answer(
            'Remaining daily bolus allocation — NOT an order',
            '${bolus.toStringAsFixed(2)} U/day',
            '${total.toStringAsFixed(2)} U/day − '
                '${basal.toStringAsFixed(2)} U/day. '
                'Not automatically divided into meal doses.',
          ),
        ],
        if (total == null || basal == null)
          const Text(
            'Enter valid weight, clinician-selected U/kg/day factor and '
            'basal percentage. Both values must be selected deliberately.',
          ),
      ] else ...[
        const Text(
          'Enter ALL insulin actually delivered during the last 24 hours, '
          'including basal and meal/correction boluses. For pumps, use '
          'delivered basal and all delivered boluses rather than the '
          'programmed basal profile. An incomplete history is not a TDD.',
        ),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _field(_actualBasal, 'Basal delivered in 24 h', 'U'),
          _field(_actualRapid, 'All boluses delivered in 24 h', 'U'),
          _field(_weight, 'Patient weight (optional)', 'kg'),
        ]),
        if (total != null && bolus != null) ...[
          _answer(
            'Observed 24-hour TDD',
            '${total.toStringAsFixed(2)} U/day',
            '${observedBasal!.toStringAsFixed(2)} U basal + '
                '${observedRapid!.toStringAsFixed(2)} U bolus',
          ),
          _answer(
            'Delivered basal and bolus distribution',
            '${actualBasalFraction!.toStringAsFixed(1)}% basal',
            '${observedBasal.toStringAsFixed(2)} U basal; '
                '${bolus.toStringAsFixed(2)} U bolus; '
                '${(100 - actualBasalFraction).toStringAsFixed(1)}% bolus',
          ),
          if (perKg != null)
            _answer(
              'Observed weight-normalized TDD',
              '${perKg.toStringAsFixed(2)} U/kg/day',
              '${total.toStringAsFixed(2)} U/day ÷ '
                  '${weight!.toStringAsFixed(2)} kg',
            ),
        ] else
          const Text('Enter complete delivered basal and bolus totals '
              'from the same 24-hour interval.'),
      ],
      if (total != null) ...[
        const Divider(),
        const Text('Optional ICR / ISF estimates from this TDD — '
            'never transferred into prescribed patient settings.'),
        DropdownButtonFormField<int>(
          key: ValueKey(_icrRule),
          initialValue: _icrRule,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Select ICR estimation rule (optional)',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 500, child: Text('500 / TDD')),
            DropdownMenuItem(value: 330, child: Text('330 / TDD (preschool)')),
            DropdownMenuItem(value: 250, child: Text('250 / TDD (preschool)')),
          ],
          onChanged: (rule) => setState(() => _icrRule = rule),
        ),
        if (estimatedIcr != null)
          _answer(
            'Estimated ICR — not prescribed',
            '1 U : ${estimatedIcr.toStringAsFixed(1)} g',
            '$_icrRule / ${total.toStringAsFixed(2)} U/day',
          ),
        if (estimatedIsf != null)
          _answer(
            'Estimated ISF — not prescribed',
            '${estimatedIsf.toStringAsFixed(2)} mmol/L/U',
            '100 / ${total.toStringAsFixed(2)} U/day',
          ),
      ],
      ExpansionTile(
        title: const Text('Clinical limitations and source'),
        tilePadding: EdgeInsets.zero,
        children: const [
          Text('ISPAD 2024 Chapter 9 pp. 594 and 596: actual daily insulin '
              'requirements vary significantly. Basal may comprise '
              '30-50% of TDD on basal-bolus regimens, but '
              'no basal percentage is auto-selected here. '
              'Do not use this tool to independently prescribe '
              'new-onset insulin, choose IV-to-SC transition doses '
              'or create pump settings. Review with the diabetes team.'),
        ],
      ),
    ], icon: Icons.medication_outlined);
  }

  Widget _icrCalculator() {
    final tdd = _value(_tdd);
    final icr = InsulinMath.estimatedIcr(tdd, rule: _icrRule ?? -1);
    return _card('Carb Ratio (ICR)', [
      const Text(
        'How many grams of carbohydrate are covered by 1 unit of rapid-acting insulin?',
      ),
      _field(_tdd, 'Known total daily insulin', 'U/day'),
      DropdownButtonFormField<int>(
        key: ValueKey(_icrRule),
        initialValue: _icrRule,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Choose an estimation rule',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 500, child: Text('500 / TDD')),
          DropdownMenuItem(value: 330, child: Text('330 / TDD (preschool alternative)')),
          DropdownMenuItem(value: 250, child: Text('250 / TDD (preschool alternative)')),
        ],
        onChanged: (rule) => setState(() => _icrRule = rule),
      ),
      if (icr != null)
        _answer(
          'Estimated carb ratio — not a prescription',
          '1 U : ${icr.toStringAsFixed(1)} g',
          '$_icrRule ÷ ${tdd!.toStringAsFixed(2)} U/day = '
              '${icr.toStringAsFixed(2)} g/U',
        )
      else
        const Text('Enter a valid known TDD and choose a rule to display an estimate.'),
      const Text(
        'An initial ratio is not a patient-specific ICR. Breakfast, age, '
        'insulin resistance, physical activity and the honeymoon phase may '
        'require different settings. Do not calculate a patient dose directly '
        'from this estimate.',
      ),
      ExpansionTile(
        title: const Text('Why these rules?'),
        tilePadding: EdgeInsets.zero,
        children: const [
          Text('ISPAD 2024, Insulin and Adjunctive Treatments, p. 596: '
              '500/TDD is a rough starting guide; 330/TDD and 250/TDD '
              'are discussed as alternatives for younger children. '
              'SickKids-specific starting rules have not been verified.'),
        ],
      ),
    ], icon: Icons.restaurant_outlined);
  }

  Widget _isfCalculator() {
    final tdd = _value(_tdd);
    final isf = InsulinMath.estimatedIsf(tdd);
    return _card('Correction Factor (ISF)', [
      const Text(
        'How much does 1 unit of rapid-acting insulin approximately lower glucose?',
      ),
      _field(_tdd, 'Known total daily insulin', 'U/day'),
      if (isf != null)
        _answer(
          'Estimated insulin sensitivity — not a prescription',
          '${isf.toStringAsFixed(2)} mmol/L per U',
          '100 ÷ ${tdd!.toStringAsFixed(2)} U/day = '
              '${isf.toStringAsFixed(2)} mmol/L per U '
              '(approximately ${(isf * 18.0182).toStringAsFixed(1)} mg/dL per U)',
        )
      else
        const Text('Enter a valid known TDD to display a 100-rule estimate.'),
      const Text(
        'This is an estimate only. A prescribed correction factor may '
        'vary by time of day, age and clinical circumstances. '
        'It does not include insulin on board or pump algorithm adjustments.',
      ),
      ExpansionTile(
        title: const Text('Why this formula?'),
        tilePadding: EdgeInsets.zero,
        children: const [
          Text('ISPAD 2024, Insulin and Adjunctive Treatments, p. 597: '
              '100/TDD gives an approximate rapid-acting insulin '
              'sensitivity in mmol/L per unit. The guideline discusses '
              'other rules in particular clinical settings. '
              'SickKids-specific starting rules have not been verified.'),
        ],
      ),
    ], icon: Icons.show_chart_outlined);
  }

  Widget _mealCalculator() {
    final carbs = _value(_carbs);
    final icr = _value(_icr);
    final isf = _value(_isf);
    final current = _value(_glucose);
    final target = _value(_target);
    final meal = InsulinMath.mealUnits(
      carbohydrateGrams: carbs,
      prescribedIcrGramsPerUnit: icr,
    );
    final correction = InsulinMath.correctionUnits(
      currentMmolL: current,
      targetMmolL: target,
      prescribedIsfMmolLPerUnit: isf,
    );
    final low = current != null && current < 3.9;
    final belowTarget = current != null && target != null && current < target;
    final combined = _reviewed && !low && !belowTarget &&
            meal != null && correction != null
        ? meal + correction
        : null;
    final rounded = InsulinMath.nearestIncrement(combined, _doseStep);
    return _card('Meal & Correction Calculation', [
      const Text(
        'Use ONLY established, patient-specific settings from the current '
        'diabetes plan. Starting ICR/ISF estimates are not transferred here.',
      ),
      Wrap(spacing: 12, runSpacing: 12, children: [
        _field(_carbs, 'Meal carbohydrates', 'g'),
        _field(_icr, 'Prescribed carb ratio', 'g/U'),
        _field(_glucose, 'Current glucose', 'mmol/L'),
        _field(_target, 'Prescribed glucose target', 'mmol/L'),
        _field(_isf, 'Prescribed correction factor', 'mmol/L/U'),
      ]),
      if (low)
        const Text('LOW GLUCOSE: use the individual hypoglycemia plan. '
            'No positive combined result will be displayed.'),
      if (belowTarget && !low)
        const Text('Glucose is below target. Review the individual plan; '
            'no positive combined result will be displayed.'),
      if (meal != null)
        _answer(
          'Carbohydrate component (unrounded)',
          '${meal.toStringAsFixed(2)} U',
          '${carbs!.toStringAsFixed(1)} g ÷ ${icr!.toStringAsFixed(2)} g/U',
        ),
      if (correction != null && !low)
        _answer(
          'Correction component (unrounded)',
          '${correction.toStringAsFixed(2)} U',
          'max(0, (${current!.toStringAsFixed(2)} - '
              '${target!.toStringAsFixed(2)}) mmol/L ÷ '
              '${isf!.toStringAsFixed(2)} mmol/L/U)',
        ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: _reviewed,
        onChanged: (checked) => setState(() => _reviewed = checked ?? false),
        title: const Text('I have checked the patient-specific plan, '
            'recent insulin, active insulin (IOB), ketones/illness, '
            'exercise and delivery method.'),
        subtitle: const Text('Required before showing the combined arithmetic.'),
      ),
      if (combined != null) ...[
        _answer(
          'Combined arithmetic — NOT an insulin order',
          '${combined.toStringAsFixed(2)} U',
          '${meal!.toStringAsFixed(2)} U (meal) + '
              '${correction!.toStringAsFixed(2)} U (correction); '
              'before IOB/device algorithm adjustment.',
        ),
        DropdownButtonFormField<double>(
          key: ValueKey(_doseStep),
          initialValue: _doseStep,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Actual device increment (optional)',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 U')),
            DropdownMenuItem(value: 0.5, child: Text('0.5 U')),
            DropdownMenuItem(value: 0.1, child: Text('0.1 U')),
            DropdownMenuItem(value: 0.05, child: Text('0.05 U')),
          ],
          onChanged: (increment) => setState(() => _doseStep = increment),
        ),
        if (rounded != null)
          _answer(
            'Nearest increment — illustration only',
            '${rounded.toStringAsFixed(2)} U',
            'Increment ${_doseStep!.toStringAsFixed(2)} U. '
                'Rounding can increase hypoglycemia risk.',
          ),
      ] else
        const Text('The combined result is hidden until prescribed values '
            'are valid and the safety review is acknowledged.'),
      const Text(
        'Do not use this arithmetic to override an automated insulin '
        'delivery system or pump bolus calculator. Device settings and IOB '
        'may change an appropriate dose. Review all treatment decisions '
        'with the pediatric diabetes team.',
      ),
    ], icon: Icons.calculate_outlined);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insulin Dose Calculator'),
        actions: [
          TextButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Choose what you want to calculate. '
                'All values are entered manually; nothing is prescribed automatically.'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              ChoiceChip(
                label: const Text('TDD / Basal'),
                selected: _selectedTool == 0,
                onSelected: (_) => setState(() => _selectedTool = 0),
              ),
              ChoiceChip(
                label: const Text('Carb Ratio'),
                selected: _selectedTool == 1,
                onSelected: (_) => setState(() => _selectedTool = 1),
              ),
              ChoiceChip(
                label: const Text('Correction Factor'),
                selected: _selectedTool == 2,
                onSelected: (_) => setState(() => _selectedTool = 2),
              ),
              ChoiceChip(
                label: const Text('Meal Dose'),
                selected: _selectedTool == 3,
                onSelected: (_) => setState(() => _selectedTool = 3),
              ),
            ]),
          ),
          if (_selectedTool == 0)
            _startingPlanCalculator()
          else if (_selectedTool == 1)
            _icrCalculator()
          else if (_selectedTool == 2)
            _isfCalculator()
          else
            _mealCalculator(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'Clinical calculation aid only. Verify patient-specific '
              'insulin orders and local guidance. '
              'Source: ISPAD 2024 chapter 9, DOI 10.1159/000543169. '
              'SickKids dosing conventions require local review. '
              'Content reviewed 25 Oct 2026.',
            ),
          ),
        ],
      ),
    );
  }
}
