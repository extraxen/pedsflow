// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
import 'package:flutter/material.dart';
import 'insulin_math.dart';

class SubcutaneousTransitionScreen extends StatefulWidget {
  const SubcutaneousTransitionScreen({super.key});
  @override
  State<SubcutaneousTransitionScreen> createState() => _SubcutaneousTransitionScreenState();
}

class _SubcutaneousTransitionScreenState extends State<SubcutaneousTransitionScreen> {
  final _approvedTdd = TextEditingController();
  final _basalPct = TextEditingController();
  @override
  void dispose() {
    _approvedTdd.dispose();
    _basalPct.dispose();
    super.dispose();
  }

  double? _number(TextEditingController c) {
    final n = double.tryParse(c.text.trim());
    return n != null && n.isFinite ? n : null;
  }

  Widget _card(String heading, List<Widget> items) =>
      Card(child: Padding(padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(heading, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...items.map((x) => Padding(padding: const EdgeInsets.only(bottom: 12),
              child: x)),
        ])));

  @override
  Widget build(BuildContext context) {
    final approved = _number(_approvedTdd);
    final selectedPct = _number(_basalPct);
    final basal = InsulinMath.basalFromApprovedPercentage(approved, selectedPct);
    return Scaffold(
      appBar: AppBar(title: const Text('Transition IV to SC insulin')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        _card('1. Readiness to transition', const [
          Text('For DKA: do not transition solely because glucose is lower. '
              'Confirm resolving ketosis/acidosis, clinical stability, '
              'alertness and ability to tolerate oral intake, with the '
              'responsible pediatric team. Review potassium, fluids, '
              'sick-day needs and precipitating cause.'),
          Text('Not ready: ongoing DKA or evolving HHS, altered consciousness, '
              'vomiting or inability to tolerate feeds, unstable physiology, '
              'uncertain regimen or unsafe nursing/caregiver support. '
              'Escalate to diabetes/endocrinology and PICU as appropriate.'),
        ]),
        _card('2. Confirm the individualized basal-bolus plan', const [
          Text('Confirm an APPROVED total daily insulin dose (TDD), '
              'long-acting basal type and timing, scheduled prandial coverage, '
              'ICR and ISF by time of day, glucose targets, monitoring and '
              'hypoglycemia rescue plan. Never omit basal insulin in T1D.'),
          Text('ISPAD 2024 notes basal insulin commonly accounts for '
              'approximately 30%-50% of basal-bolus TDD in children, '
              'but an individual starting percentage and dose require '
              'pediatric diabetes team approval. This is not an '
              'automatic weight-to-dose calculator.'),
        ]),
        _card('3. Basal split arithmetic (approved inputs only)', [
          Wrap(spacing: 12, runSpacing: 12, children: [
            SizedBox(width: 245, child: TextField(controller: _approvedTdd,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Clinician-approved TDD', suffixText: 'U/day',
                border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            )),
            SizedBox(width: 245, child: TextField(controller: _basalPct,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Clinician-selected basal fraction',
                suffixText: '%', border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            )),
          ]),
          if (basal != null)
            Text('Basal arithmetic: ${approved} U/day × ${selectedPct}% '
                '= ${basal.toStringAsFixed(2)} U/day (unrounded). '
                'Remaining TDD: ${(approved! - basal).toStringAsFixed(2)} U/day. '
                'NOT a prescribed schedule.')
          else
            const Text('Both approved inputs must be provided. '
                'No values are inferred from weight.'),
          const Text('This does NOT establish meal-by-meal doses, '
              'basal pharmacokinetics or how to round/administer them.'),
        ]),
        _card('4. Transition overlap: use institutional protocol', const [
          Text('Avoid an insulin gap. Plan the FIRST SC dose(s) and exact '
              'time that IV insulin will stop with bedside nursing '
              'and the diabetes team. Long-acting basal timing differs '
              'from a rapid-acting meal bolus.'),
          Text('NICE NG18 (children/young people, DKA): SC insulin at '
              'least 30 minutes BEFORE stopping IV insulin; if restarting '
              'a pump, at least 60 minutes of overlap plus new infusion '
              'set, cannula/site and cartridge. These are UK reference '
              'minimums, NOT a verified SickKids order set.'),
          Text('Do not import the adult ADA basal overlap interval into '
              'a pediatric SickKids order without checking local guidance. '
              'If basal was given during IV therapy, check for duplication.'),
        ]),
        _card('5. Bedside handover and follow-up', const [
          Text('Record last IV insulin rate, planned SC doses/times, '
              'meal status, capillary glucose frequency, ketone checks, '
              'ongoing fluids, exact infusion stop time and the person '
              'responsible for each action.'),
          Text('Recheck glucose and ketones after transition per local '
              'policy. Reassess if hyperglycemia persists, vomiting '
              'develops, ketones recur or oral intake falls.'),
          ExpansionTile(title: Text('Fictional teaching example'),
            children: [
              Text('Example only: an imaginary adolescent has a team-approved '
                  'TDD of 40 U/day and a team-selected 40% basal split. '
                  '40 × 0.40 = 16 U basal (arithmetic only). '
                  'With an independently established ICR 15 g/U, '
                  '60 g carbohydrate = 60/15 = 4 U. '
                  'With established ISF 3 mmol/L/U, glucose 12 mmol/L '
                  'and target 6 mmol/L, correction = (12-6)/3 = 2 U. '
                  'Arithmetic sum = 6 U BEFORE IOB, illness, device '
                  'settings and rounding. These are not starting orders.'),
            ],
          ),
        ]),
        const Padding(padding: EdgeInsets.all(12), child: Text(
            'Sources: ISPAD 2024 Insulin/Adjunctive Treatment pp. 593, 596-597; '
            'NICE NG18 §§1.4.42-1.4.45. Reviewed 25 Oct 2026. '
            'Local SickKids IV-to-SC protocol requires verification.')),
      ]),
    );
  }
}

class InsulinPumpSupportScreen extends StatelessWidget {
  const InsulinPumpSupportScreen({super.key});

  Widget _card(BuildContext context, String title, String detail, IconData icon) =>
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon), const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(detail),
            ])),
        ],
      )));
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Insulin pump safety / transition')),
    body: ListView(padding: const EdgeInsets.all(12), children: [
      _card(context, 'Before initiation or restarting',
        'Confirm diabetes-team pump plan, model and insulin type; '
        'prescribed basal profile, time-dependent ICR and ISF, '
        'target glucose, duration of insulin action, active insulin/IOB '
        'and any AID-mode parameters. Verify prior long-acting insulin '
        'to avoid basal overlap. No pump settings are generated here.',
        Icons.fact_check_outlined),
      _card(context, 'Basal rate and bolus concepts',
        'Basal rates are U/hour and may change throughout the day. '
        'ICR is g/U and ISF is mmol/L/U. Meal bolus and correction '
        'bolus depend on individual targets, glucose trends, device '
        'algorithm and IOB. Changing one setting can affect other '
        'settings. Use device-specific team education.',
        Icons.settings_outlined),
      _card(context, 'Pump interruption / failure',
        'Most pumps deliver only rapid-acting insulin. A blocked or '
        'dislodged infusion set may rapidly cause insulin deficiency '
        'and DKA. Persistent unexpected hyperglycemia: check '
        'capillary glucose, blood/urine ketones, tubing/site, '
        'cartridge and delivery alerts; follow the team\'s '
        'written backup injection and sick-day plan. Do not wait '
        'for the pump to correct ketones automatically.',
        Icons.warning_amber_outlined),
      _card(context, 'Sick-day / emergency escalation',
        'Vomiting, significant ketones, abdominal pain, deep/fast '
        'breathing, dehydration, altered mental status or persistent '
        'hyperglycemia require urgent assessment using the local '
        'pediatric diabetes/DKA pathway. Maintain access to '
        'rapid-acting injection supplies and prescribed basal backup.',
        Icons.emergency_outlined),
      _card(context, 'IV insulin to pump',
        'After DKA, never restart a pump before metabolic recovery '
        'and specialist review. NICE NG18 advises a NEW infusion '
        'set, cannula/site and cartridge and restarting the pump '
        'at least 60 min before IV insulin is discontinued. '
        'Local SickKids procedure and device-specific requirements '
        'must override this external reference.',
        Icons.compare_arrows_outlined),
      const Padding(padding: EdgeInsets.all(12),
        child: Text('Source: ISPAD Clinical Practice Consensus Guidelines '
          '2024, Diabetes Technologies - Insulin Delivery; NICE NG18 '
          '§1.4.45. Reviewed 25 Oct 2026. '
          'Clinical reference only; not an autonomous bolus calculator.')),
    ]),
  );
}
