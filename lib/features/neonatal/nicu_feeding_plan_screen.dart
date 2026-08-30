// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.

import 'package:flutter/material.dart';

import 'nicu_feeding_plan_engine.dart';

enum _PlanMode { newborn, alreadyStarted }

class NicuSpecificFeedingPlanScreen extends StatefulWidget {
  const NicuSpecificFeedingPlanScreen({super.key});

  @override
  State<NicuSpecificFeedingPlanScreen> createState() =>
      _NicuSpecificFeedingPlanScreenState();
}

class _NicuSpecificFeedingPlanScreenState
    extends State<NicuSpecificFeedingPlanScreen> {
  _PlanMode _mode = _PlanMode.newborn;

  final TextEditingController _newGaWeeks =
      TextEditingController(text: '25');
  final TextEditingController _newGaDays = TextEditingController(text: '4');
  final TextEditingController _newBirthWeightG =
      TextEditingController(text: '820');
  bool _newEbmAvailable = false;
  bool _newIvAvailable = true;
  bool _newHie = false;
  bool _newGi = false;
  bool _newCardiac = false;
  bool _newTwin = false;

  final TextEditingController _startedGaWeeks =
      TextEditingController(text: '27');
  final TextEditingController _startedGaDays =
      TextEditingController(text: '2');
  final TextEditingController _startedDol = TextEditingController(text: '8');
  final TextEditingController _startedBirthWeightG =
      TextEditingController(text: '1050');
  final TextEditingController _startedCurrentWeightG =
      TextEditingController(text: '1140');
  final TextEditingController _startedCgaWeeks =
      TextEditingController(text: '28');
  final TextEditingController _startedFeedMl =
      TextEditingController(text: '8');
  final TextEditingController _startedFeedPercent = TextEditingController();
  int _startedIntervalHours = 3;
  NicuMilkType _startedMilk = NicuMilkType.ebm;
  NicuIvStatus _startedIvStatus = NicuIvStatus.tpnSmof;
  bool _startedFortified = false;
  bool _startedHie = false;
  bool _startedNg = true;
  bool _startedRecentPrbc = false;

  bool _showPlan = false;

  @override
  void dispose() {
    for (final TextEditingController controller in <TextEditingController>[
      _newGaWeeks,
      _newGaDays,
      _newBirthWeightG,
      _startedGaWeeks,
      _startedGaDays,
      _startedDol,
      _startedBirthWeightG,
      _startedCurrentWeightG,
      _startedCgaWeeks,
      _startedFeedMl,
      _startedFeedPercent,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _double(TextEditingController controller) =>
      double.tryParse(controller.text.trim());

  int? _int(TextEditingController controller) =>
      int.tryParse(controller.text.trim());

  String _fmt(double value, {int decimals = 1}) =>
      value.toStringAsFixed(decimals);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Specific Patient Feeding Plan',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: <Widget>[
              _sourceBanner(context),
              const SizedBox(height: 14),
              _modePicker(context),
              const SizedBox(height: 14),
              if (_mode == _PlanMode.newborn)
                _newbornForm(context)
              else
                _alreadyStartedForm(context),
              if (_showPlan) ...<Widget>[
                const SizedBox(height: 18),
                if (_mode == _PlanMode.newborn)
                  _newbornPlan(context)
                else
                  _startedPlan(context),
              ],
              const SizedBox(height: 18),
              _limitations(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceBanner(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Text(
          'LHSC NICU nutrition decision support • Source: LHSC NICU Basic '
          'Nutrition Quick Guide / Neonatal TPN & Enteral quick-reference cards '
          '(updated 2024). Verify against the active full LHSC guideline, '
          'dietitian/pharmacy recommendations, and the infant’s clinical status.',
          style: TextStyle(fontWeight: FontWeight.w800, height: 1.4),
        ),
      ),
    );
  }

  Widget _modePicker(BuildContext context) {
    return SegmentedButton<_PlanMode>(
      segments: const <ButtonSegment<_PlanMode>>[
        ButtonSegment<_PlanMode>(
          value: _PlanMode.newborn,
          icon: Icon(Icons.child_care_outlined),
          label: Text('NEWBORN'),
        ),
        ButtonSegment<_PlanMode>(
          value: _PlanMode.alreadyStarted,
          icon: Icon(Icons.trending_up_outlined),
          label: Text('ALREADY ON FEEDS'),
        ),
      ],
      selected: <_PlanMode>{_mode},
      onSelectionChanged: (Set<_PlanMode> selection) {
        setState(() {
          _mode = selection.first;
          _showPlan = false;
        });
      },
    );
  }

  Widget _newbornForm(BuildContext context) {
    return _sectionCard(
      context,
      title: 'Build an initial feeding plan',
      subtitle:
          'Use before feeds or IV/TPN are started. Birth weight is entered in grams.',
      children: <Widget>[
        _responsive(<Widget>[
          _field(_newGaWeeks, 'GA at birth', 'weeks'),
          _field(_newGaDays, 'GA + days', 'days'),
          _field(_newBirthWeightG, 'Birth weight', 'g'),
        ]),
        _yesNoTile(
          'Mother’s EBM available',
          _newEbmAvailable,
          (bool value) => setState(() => _newEbmAvailable = value),
        ),
        _yesNoTile(
          'IV access available',
          _newIvAvailable,
          (bool value) => setState(() => _newIvAvailable = value),
        ),
        const Divider(),
        const Text(
          'Special circumstances',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        _checkTile(
          'Perinatal acidosis / HIE',
          _newHie,
          (bool value) => setState(() => _newHie = value),
        ),
        _checkTile(
          'GI surgery / NEC',
          _newGi,
          (bool value) => setState(() => _newGi = value),
        ),
        _checkTile(
          'Complex cardiac disease',
          _newCardiac,
          (bool value) => setState(() => _newCardiac = value),
        ),
        _checkTile(
          'Twin where sibling qualifies for donor EBM',
          _newTwin,
          (bool value) => setState(() => _newTwin = value),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => setState(() => _showPlan = true),
          icon: const Icon(Icons.auto_awesome_outlined),
          label: const Text('Generate initial feeding plan'),
        ),
      ],
    );
  }

  Widget _alreadyStartedForm(BuildContext context) {
    return _sectionCard(
      context,
      title: 'Current nutrition → next steps',
      subtitle:
          'Use after feeds have started. PedsFlow calculates the current '
          'mL/kg/day and highlights the next documented LHSC milestone.',
      children: <Widget>[
        _responsive(<Widget>[
          _field(_startedGaWeeks, 'GA at birth', 'weeks'),
          _field(_startedGaDays, 'GA + days', 'days'),
          _field(_startedDol, 'Day of life', 'day'),
          _field(_startedBirthWeightG, 'Birth weight', 'g'),
          _field(_startedCurrentWeightG, 'Current weight', 'g'),
          _field(_startedCgaWeeks, 'Corrected GA', 'weeks'),
        ]),
        const SizedBox(height: 8),
        _responsive(<Widget>[
          _field(_startedFeedMl, 'Current feed', 'mL/feed'),
          DropdownButtonFormField<int>(
            initialValue: _startedIntervalHours,
            decoration: const InputDecoration(
              labelText: 'Frequency',
              border: OutlineInputBorder(),
            ),
            items: const <int>[2, 3, 4]
                .map(
                  (int hours) => DropdownMenuItem<int>(
                    value: hours,
                    child: Text('q${hours}h'),
                  ),
                )
                .toList(),
            onChanged: (int? value) {
              if (value == null) return;
              setState(() => _startedIntervalHours = value);
            },
          ),
          DropdownButtonFormField<NicuMilkType>(
            initialValue: _startedMilk,
            decoration: const InputDecoration(
              labelText: 'Milk type',
              border: OutlineInputBorder(),
            ),
            items: const <DropdownMenuItem<NicuMilkType>>[
              DropdownMenuItem(
                value: NicuMilkType.ebm,
                child: Text('EBM'),
              ),
              DropdownMenuItem(
                value: NicuMilkType.donor,
                child: Text('Donor EBM / DBM'),
              ),
              DropdownMenuItem(
                value: NicuMilkType.formula,
                child: Text('Formula'),
              ),
              DropdownMenuItem(
                value: NicuMilkType.mixed,
                child: Text('Mixed'),
              ),
            ],
            onChanged: (NicuMilkType? value) {
              if (value == null) return;
              setState(() => _startedMilk = value);
            },
          ),
        ]),
        const SizedBox(height: 8),
        _responsive(<Widget>[
          DropdownButtonFormField<NicuIvStatus>(
            initialValue: _startedIvStatus,
            decoration: const InputDecoration(
              labelText: 'Current IV / TPN status',
              border: OutlineInputBorder(),
            ),
            items: const <DropdownMenuItem<NicuIvStatus>>[
              DropdownMenuItem(
                value: NicuIvStatus.tpnSmof,
                child: Text('TPN / SMOF running'),
              ),
              DropdownMenuItem(
                value: NicuIvStatus.ivOnly,
                child: Text('IV fluids only'),
              ),
              DropdownMenuItem(
                value: NicuIvStatus.none,
                child: Text('No IV fluids'),
              ),
            ],
            onChanged: (NicuIvStatus? value) {
              if (value == null) return;
              setState(() => _startedIvStatus = value);
            },
          ),
          _field(
            _startedFeedPercent,
            'Enteral % of total fluids',
            '% (optional)',
          ),
        ]),
        _checkTile(
          'Feeds are fortified and tolerated',
          _startedFortified,
          (bool value) => setState(() => _startedFortified = value),
        ),
        _checkTile(
          'Perinatal acidosis / HIE',
          _startedHie,
          (bool value) => setState(() => _startedHie = value),
        ),
        _checkTile(
          'NG feeds',
          _startedNg,
          (bool value) => setState(() => _startedNg = value),
        ),
        _checkTile(
          'PRBC transfusion within the last 7–10 days',
          _startedRecentPrbc,
          (bool value) => setState(() => _startedRecentPrbc = value),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => setState(() => _showPlan = true),
          icon: const Icon(Icons.route_outlined),
          label: const Text('Show current status + next steps'),
        ),
      ],
    );
  }

  Widget _newbornPlan(BuildContext context) {
    final int? gaWeeks = _int(_newGaWeeks);
    final int? gaDays = _int(_newGaDays);
    final double? birthWeightG = _double(_newBirthWeightG);

    if (gaWeeks == null ||
        gaDays == null ||
        gaDays < 0 ||
        gaDays > 6 ||
        birthWeightG == null ||
        birthWeightG <= 0) {
      return _warning(
        context,
        'Enter a valid gestational age and birth weight.',
      );
    }

    final double birthWeightKg = birthWeightG / 1000;
    final NicuStartingFeed starting =
        NicuFeedingPlanEngine.startingFeedForWeightKg(birthWeightKg);
    final double startingMlKgDay = starting.mlPerDay / birthWeightKg;
    final List<String> donorReasons =
        NicuFeedingPlanEngine.donorMilkEligibilityReasons(
      birthWeightKg: birthWeightKg,
      gaWeeks: gaWeeks,
      gaDays: gaDays,
      perinatalAcidosisOrHie: _newHie,
      giSurgeryOrNec: _newGi,
      complexCardiacDisease: _newCardiac,
      qualifyingTwin: _newTwin,
    );
    final NicuTpnPathway tpn = NicuFeedingPlanEngine.tpnPathway(
      gaWeeks: gaWeeks,
      gaDays: gaDays,
      birthWeightKg: birthWeightKg,
    );

    return _sectionCard(
      context,
      title: 'Initial NICU feeding plan',
      subtitle: '$gaWeeks+$gaDays weeks • ${birthWeightG.round()} g',
      children: <Widget>[
        _planBlock(
          context,
          icon: Icons.local_drink_outlined,
          title: 'ENTERAL FEEDS',
          children: <Widget>[
            _resultRow(
              'Quick-guide starting feed',
              '${_fmt(starting.mlPerFeed, decimals: 0)} mL q${starting.intervalHours}h',
            ),
            _resultRow(
              'Daily volume',
              '${_fmt(starting.mlPerDay, decimals: 0)} mL/day',
            ),
            _resultRow(
              'Equivalent',
              '${_fmt(startingMlKgDay)} mL/kg/day',
            ),
            if (_newHie)
              _warning(
                context,
                'Perinatal acidosis / HIE: the quick guide says to use cautious advancement of feeds.',
              ),
          ],
        ),
        _planBlock(
          context,
          icon: Icons.water_drop_outlined,
          title: 'MILK / DONOR EBM',
          children: <Widget>[
            if (_newEbmAvailable)
              const Text(
                'Mother’s EBM is available.',
                style: TextStyle(fontWeight: FontWeight.w800),
              )
            else if (donorReasons.isNotEmpty) ...<Widget>[
              const Text(
                'Donor EBM eligibility is triggered by the quick guide:',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              ...donorReasons.map((String reason) => Text('• $reason')),
              const SizedBox(height: 6),
              const Text(
                'Quick-guide note: donor EBM weaning is 1:1 with the appropriate formula ×48 h.',
              ),
            ] else
              const Text(
                'No donor-EBM criterion was triggered by the entered factors.',
              ),
          ],
        ),
        _planBlock(
          context,
          icon: Icons.medical_information_outlined,
          title: 'TPN / IV FLUID PATHWAY',
          children: <Widget>[
            Text(
              tpn.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            if (tpn.tfiMlKgDay != null) ...<Widget>[
              _resultRow(
                'TFI',
                '${_fmt(tpn.tfiMlKgDay!, decimals: 0)} mL/kg/day',
              ),
              _resultRow(
                'For this infant',
                '${_fmt(tpn.tfiMlKgDay! * birthWeightKg)} mL/day',
              ),
              _resultRow(
                'Equivalent total-fluid rate',
                '${_fmt(tpn.tfiMlKgDay! * birthWeightKg / 24, decimals: 2)} mL/hr',
              ),
            ],
            ...tpn.lines.map((String line) => Text('• $line')),
            if (tpn.boundaryNeedsVerification)
              _warning(
                context,
                'This gestational-age boundary is not unambiguous on the supplied quick card. Verify the full LHSC guideline.',
              ),
            if (!_newIvAvailable)
              _warning(
                context,
                'No IV access selected. The IV/TPN pathway cannot simply be executed as displayed; an individualized alternative plan is required.',
              ),
          ],
        ),
        _planBlock(
          context,
          icon: Icons.flag_outlined,
          title: 'NEXT DOCUMENTED MILESTONES',
          children: const <Widget>[
            Text('• Fortification: initiate at 100 mL/kg/day of feeds.'),
            Text(
              '• TPN/SMOF discontinuation: quick card lists 100–120 mL/kg/day OR 75–80% feeds.',
            ),
            Text(
              '• IV discontinuation: minimum 130–140 mL/kg/day AND fortified feeds tolerated.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _startedPlan(BuildContext context) {
    final int? gaWeeks = _int(_startedGaWeeks);
    final int? gaDays = _int(_startedGaDays);
    final int? dol = _int(_startedDol);
    final int? cgaWeeks = _int(_startedCgaWeeks);
    final double? birthWeightG = _double(_startedBirthWeightG);
    final double? currentWeightG = _double(_startedCurrentWeightG);
    final double? feedMl = _double(_startedFeedMl);
    final double? enteralPercent = _double(_startedFeedPercent);

    if (gaWeeks == null ||
        gaDays == null ||
        gaDays < 0 ||
        gaDays > 6 ||
        dol == null ||
        cgaWeeks == null ||
        birthWeightG == null ||
        birthWeightG <= 0 ||
        currentWeightG == null ||
        currentWeightG <= 0 ||
        feedMl == null ||
        feedMl < 0) {
      return _warning(
        context,
        'Enter valid gestational age, weights, day of life, and feed volume.',
      );
    }

    final double currentWeightKg = currentWeightG / 1000;
    final double enteralMlDay = NicuFeedingPlanEngine.enteralMlPerDay(
      mlPerFeed: feedMl,
      intervalHours: _startedIntervalHours,
    );
    final double enteralMlKgDay = NicuFeedingPlanEngine.enteralMlKgDay(
      weightKg: currentWeightKg,
      mlPerFeed: feedMl,
      intervalHours: _startedIntervalHours,
    );
    final double remainingFortification =
        NicuFeedingPlanEngine.remainingToFortification(enteralMlKgDay);
    final bool fortificationReached =
        NicuFeedingPlanEngine.fortificationMilestoneReached(
      enteralMlKgDay,
    );
    final bool tpnMilestone =
        NicuFeedingPlanEngine.tpnDiscontinuationMilestone(
      enteralMlKgDay: enteralMlKgDay,
      enteralPercentOfTotalFluids: enteralPercent,
    );
    final bool ivMilestone =
        NicuFeedingPlanEngine.ivDiscontinuationMilestone(
      enteralMlKgDay: enteralMlKgDay,
      fortifiedFeedsTolerated: _startedFortified,
    );

    return _sectionCard(
      context,
      title: 'Current status + next steps',
      subtitle:
          '${birthWeightG.round()} g at birth • ${currentWeightG.round()} g now • DOL $dol',
      children: <Widget>[
        _planBlock(
          context,
          icon: Icons.analytics_outlined,
          title: 'CURRENT ENTERAL INTAKE',
          children: <Widget>[
            _resultRow(
              'Current feeds',
              '${_fmt(feedMl)} mL q${_startedIntervalHours}h',
            ),
            _resultRow(
              'Daily enteral volume',
              '${_fmt(enteralMlDay)} mL/day',
            ),
            _resultRow(
              'Weight-normalized',
              '${_fmt(enteralMlKgDay)} mL/kg/day',
            ),
          ],
        ),
        _planBlock(
          context,
          icon: Icons.trending_up_outlined,
          title: 'NEXT FEEDING / FORTIFICATION MILESTONE',
          children: <Widget>[
            if (!_startedFortified && !fortificationReached) ...<Widget>[
              _resultRow(
                'Next documented milestone',
                '100 mL/kg/day → initiate fortifier',
              ),
              _resultRow(
                'Remaining',
                '${_fmt(remainingFortification)} mL/kg/day',
              ),
              _resultRow(
                'At current weight',
                '${_fmt(remainingFortification * currentWeightKg)} mL/day to the threshold',
              ),
            ] else if (!_startedFortified && fortificationReached)
              const Text(
                'Fortification milestone reached (≥100 mL/kg/day). Review/initiate the birth-weight-specific Liquid HMF pathway.',
                style: TextStyle(fontWeight: FontWeight.w900),
              )
            else
              const Text(
                'Feeds are entered as fortified and tolerated.',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            if (_startedHie)
              _warning(
                context,
                'HIE / perinatal acidosis selected: cautious feed advancement remains relevant.',
              ),
          ],
        ),
        _planBlock(
          context,
          icon: Icons.water_outlined,
          title: 'TPN / IV NEXT STEPS',
          children: <Widget>[
            if (_startedIvStatus == NicuIvStatus.tpnSmof) ...<Widget>[
              if (tpnMilestone)
                const Text(
                  'The quick-card TPN/SMOF discontinuation milestone may be reached: 100–120 mL/kg/day OR 75–80% feeds. Confirm tolerance and the active local plan.',
                  style: TextStyle(fontWeight: FontWeight.w900),
                )
              else ...<Widget>[
                _resultRow(
                  'Current enteral volume',
                  '${_fmt(enteralMlKgDay)} mL/kg/day',
                ),
                const Text(
                  'TPN/SMOF milestone: 100–120 mL/kg/day OR 75–80% feeds.',
                ),
              ],
            ] else
              const Text('TPN / SMOF is not selected as currently running.'),
            const SizedBox(height: 8),
            if (ivMilestone)
              const Text(
                'IV discontinuation milestone may be reached: ≥130 mL/kg/day and fortified feeds tolerated. Confirm the infant-specific plan.',
                style: TextStyle(fontWeight: FontWeight.w900),
              )
            else
              const Text(
                'IV discontinuation milestone on the quick card: minimum 130–140 mL/kg/day AND fortified feeds tolerated.',
              ),
          ],
        ),
        _planBlock(
          context,
          icon: Icons.medication_outlined,
          title: 'SUPPLEMENT / MONITORING PROMPTS',
          children: <Widget>[
            if (cgaWeeks < 37 && _startedNg)
              const Text(
                '• Probiotic eligibility pathway may apply (<36+6 weeks + NG feeds, as available).',
              ),
            if (dol >= 7 && gaWeeks < 37)
              const Text(
                '• Iron timing criteria are beginning to apply; the quick card also requires full feeds and the appropriate milk pathway.',
              ),
            if (_startedRecentPrbc)
              _warning(
                context,
                'Recent PRBC transfusion selected: quick guide says hold Fer-In-Sol for 7–10 days after transfusion.',
              ),
            if (cgaWeeks > 32)
              const Text(
                '• >32 weeks corrected age: add CBC/diff, reticulocyte count, and ferritin to the nutrition-lab pathway.',
              ),
          ],
        ),
        _warning(
          context,
          'Exact next feed increase is NOT automated yet. The supplied LHSC quick cards define starting volumes and major milestones but do not clearly specify a universal feed-advancement rate. PedsFlow will not invent one.',
        ),
      ],
    );
  }

  Widget _limitations(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.verified_user_outlined),
        title: const Text(
          'Source boundaries & safety',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: const <Widget>[
          Text(
            'This module digitizes the supplied LHSC NICU quick-reference cards. '
            'It is decision support, not an automatic prescribing system.',
          ),
          SizedBox(height: 8),
          Text(
            'Not automated from the supplied cards: a universal feed-advancement '
            'rate, individualized TPN electrolyte prescriptions, dietitian-driven '
            'fortification changes, and clinical decisions around intolerance, '
            'NEC risk, fluid restriction, renal dysfunction, or other instability.',
          ),
          SizedBox(height: 8),
          Text(
            'Source label: LHSC NICU Basic Nutrition Quick Guide / Neonatal TPN '
            'and Enteral quick-reference cards, updated 2024. The full active '
            'LHSC Neonatal TPN and Enteral Guideline remains authoritative.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _planBlock(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String suffix,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() => _showPlan = false),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _responsive(List<Widget> children) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 680) {
          return Column(
            children: children
                .map(
                  (Widget child) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: child,
                  ),
                )
                .toList(),
          );
        }
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: children
              .map(
                (Widget child) => SizedBox(
                  width: (constraints.maxWidth - 20) / 3,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _checkTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return CheckboxListTile(
      value: value,
      onChanged: (bool? next) => onChanged(next ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
    );
  }

  Widget _yesNoTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
    );
  }

  Widget _warning(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
          fontWeight: FontWeight.w800,
          height: 1.35,
        ),
      ),
    );
  }
}
