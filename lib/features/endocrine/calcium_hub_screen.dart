// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// Public educational synthesis; no private hospital order sets or patient data.
import 'package:flutter/material.dart';
import 'calcium_hub_math.dart';

class CalciumHubScreen extends StatelessWidget {
  const CalciumHubScreen({super.key});

  Widget _tile(BuildContext context, String name, String summary,
      IconData icon, Widget page) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(summary),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => page)),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Calcium & Bone Health')),
    body: ListView(padding: const EdgeInsets.all(12), children: [
      const _CalciumNotice('Clinical reference, not a prescribing tool. '
        'Symptomatic or severe calcium abnormalities need urgent '
        'monitored evaluation. Use the current local protocol for '
        'IV calcium, fluids and specialist medications.'),
      _tile(context, 'Hypocalcemia',
        'Recognize, investigate and interpret calcium/PTH',
        Icons.monitor_heart_outlined,
        const _CalciumTopicPage('Hypocalcemia', [
          _CalciumSection('Emergency recognition', [
            'Seizures, stridor, tetany, arrhythmias, altered mental status '
              'or prolonged QT require immediate monitored assessment.',
            'Check ionized calcium where possible, with pH and specimen '
              'handling context. Obtain ECG and resuscitate as indicated.',
            'Do not delay lifesaving therapy for a critical sample. '
              'IV calcium requires current hospital concentration, '
              'line, rate and extravasation policies.',
          ]),
          _CalciumSection('Paired investigations', [
            'Total and ionized calcium, albumin, phosphate, magnesium, '
              'PTH, ALP, 25-OH vitamin D, creatinine/electrolytes; '
              'consider blood gas/pH and urine calcium/creatinine.',
            'Assess prematurity, diet, vitamin D, maternal history, '
              'neck/cardiac surgery, renal disease and medications.',
          ]),
          _CalciumSection('PTH framework', [
            'Low Ca with low or inappropriately normal PTH: consider '
              'hypoparathyroidism, CaSR disorders or hypomagnesemia.',
            'Low Ca with elevated PTH: consider vitamin D deficiency, '
              'malabsorption, renal/phosphate disorders or PTH resistance.',
            'Check magnesium and phosphate; chronic calcium/active '
              'vitamin D plans require endocrine supervision.',
          ]),
          _CalciumSection('Sources', [
            'User-provided calcium clinic teaching and hypocalcemia '
              'handouts (historical).',
            'External: Pediatric Endocrine Society — Child with '
              'Suspected Hypocalcemia; NHS Tayside acute pathway.',
          ]),
        ])),
      _tile(context, 'Hypercalcemia & SCFN',
        'Symptoms, PTH-dependent causes and infant surveillance',
        Icons.water_drop_outlined,
        const _CalciumTopicPage('Hypercalcemia & SCFN', [
          _CalciumSection('Recognize and escalate', [
            'Poor feeding, vomiting, constipation, lethargy, irritability, '
              'polyuria, dehydration, weakness or seizure may occur.',
            'Marked/symptomatic hypercalcemia warrants urgent '
              'endocrinology/pediatric review, ECG and renal assessment. '
              'Fluid treatment must account for cardiac/renal status.',
            'Do not independently prescribe calcitonin, bisphosphonates, '
              'diuretics or low-calcium feeds from this reference.',
          ]),
          _CalciumSection('Laboratory approach', [
            'Confirm total and/or ionized calcium, albumin, phosphate, '
              'Mg, ALP, creatinine, PTH, 25-OH vitamin D and spot '
              'urine calcium/creatinine.',
            'Consider 1,25-(OH)2 vitamin D, targeted genetic tests and '
              'renal ultrasound for persistent hypercalcemia/hypercalciuria.',
            'Suppressed PTH suggests a non-PTH-mediated cause; '
              'non-suppressed PTH during hypercalcemia is inappropriate '
              'and warrants targeted evaluation.',
          ]),
          _CalciumSection('Subcutaneous fat necrosis of the newborn', [
            'SCFN-associated hypercalcemia may appear after skin lesions '
              'start improving; normal initial calcium does not exclude '
              'later elevation.',
            'Arrange serial calcium checks, symptom education and '
              'renal assessment through the neonatal/endocrine plan.',
            'The supplied SCFN algorithm is marked DRAFT. Its numeric '
              'drug, feeding and hydration orders are NOT reproduced.',
          ]),
          _CalciumSection('Sources', [
            'User-provided calcium clinic materials and draft SCFN chart.',
            'External: CHOP Hypercalcemia and pediatric calcium '
              'disorder reviews.',
          ]),
        ])),
      _tile(context, 'Neonatal hypoparathyroidism / 22q11',
        'Cardiac infants, critical samples and delayed hypocalcemia',
        Icons.child_care_outlined,
        const _CalciumTopicPage('Neonatal Calcium & 22q11', [
          _CalciumSection('At-risk infants', [
            'Consider congenital heart disease with possible 22q11.2 '
              'deletion, other hypoparathyroid syndromes and post-operative '
              'or critically ill neonates.',
            'Calcium may decrease early or later; one normal test does '
              'not eliminate the need for an individualized repeat plan.',
          ]),
          _CalciumSection('Assessment and handover', [
            'Obtain total/ionized calcium, albumin, phosphate, Mg, ALP, '
              'PTH, 25-OH vitamin D, creatinine and spot urine '
              'calcium/creatinine when indicated.',
            'Interpret PTH simultaneously with calcium and phosphate. '
              'Communicate any persistent risk and repeat screening '
              'requirements to discharge and primary-care teams.',
            'Symptomatic or significantly low calcium requires '
              'monitored assessment and pediatric endocrinology review.',
          ]),
          _CalciumSection('Restricted protocol caution', [
            'An internally labelled 2025 cardiac-neonate algorithm '
              'was supplied privately. Its local medication orders, '
              'numeric cutoffs and scheduled test frequencies are '
              'not included in this public reference.',
          ]),
        ])),
      _tile(context, 'Calcium / PTH pattern',
        'Select lab-reported high/normal/low results',
        Icons.account_tree_outlined, const _CalciumPatternScreen()),
      _tile(context, 'Calcium intake & urine Ca/Cr',
        'Age-based targets, urinary ratio and elemental label math',
        Icons.calculate_outlined, const _CalciumCalculatorScreen()),
      _tile(context, 'Bone fragility & rickets',
        'Fractures, DXA, biochemical workup and referral',
        Icons.accessibility_new_outlined,
        const _CalciumTopicPage('Bone Fragility & Rickets', [
          _CalciumSection('History, exam and workup', [
            'Review fracture mechanism, spine pain, growth, nutrition, '
              'mobility, puberty, medications (especially glucocorticoids), '
              'genetics and chronic illnesses.',
            'Consider Ca, phosphate, ALP, PTH, 25-OH vitamin D, '
              'creatinine and urine Ca/Cr; tailor other testing to '
              'possible malabsorption, renal or metabolic bone disease.',
            'Suspected rickets may need wrist/knee radiographs and '
              'phosphate handling assessment under specialist advice.',
          ]),
          _CalciumSection('ISCD pediatric osteoporosis criteria', [
            'A non-traumatic vertebral compression fracture (without '
              'local bone disease) can establish osteoporosis '
              'independently of DXA.',
            'Without vertebral compression, BOTH a clinically '
              'significant history (at least 2 long-bone fractures '
              'by age 10, or 3 by age 19) AND a BMD Z-score of '
              '−2.0 or lower are required.',
            'A low BMD alone is not osteoporosis; a Z-score above '
              '−2.0 does not exclude clinical bone fragility.',
          ]),
          _CalciumSection('Ongoing bone health', [
            'Optimize adequate age-appropriate calcium and vitamin D, '
              'safe weight-bearing movement, growth and risk factors.',
            'Seek bone-health specialist input for vertebral fractures, '
              'recurrent low-trauma fractures or persistent '
              'abnormal biochemistry.',
            'Sources: provided bone health handouts and ISCD 2019 '
              'Official Pediatric Positions.',
          ]),
        ])),
      _tile(context, 'Bisphosphonate safety',
        'Review readiness, renal function and infusion monitoring',
        Icons.medication_outlined,
        const _CalciumTopicPage('Bisphosphonate Safety', [
          _CalciumSection('Pre-infusion review', [
            'Confirm the specialist indication, actual approved '
              'medication order set and most recent renal function.',
            'Check calcium, phosphate, magnesium, vitamin D status, '
              'dietary intake and prescriber-directed peri-infusion '
              'supplement plan; address dental concerns.',
            'Older supplied documents differ regarding renal thresholds '
              'and dose adjustments. None are imported as current orders.',
          ]),
          _CalciumSection('Monitoring and counseling', [
            'Watch for acute-phase fever/flu symptoms, post-infusion '
              'hypocalcemia/hypophosphatemia and renal effects.',
            'Track fracture burden, vertebral morphology, mobility '
              'and growth; arrange follow-up per specialist plan.',
            'No zoledronate/pamidronate dose, infusion concentration, '
              'renal adjustment or supplementation regimen is '
              'generated by PedsFlow.',
          ]),
        ])),
      const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Educational content only • Source ZIP was reviewed '
          'privately. No patient data or restricted source files have '
          'been uploaded to the public app. External standards '
          'and original institutional protocols should be checked '
          'before clinical decisions.'),
      ),
    ]),
  );
}

class _CalciumSection {
  const _CalciumSection(this.title, this.bullets);
  final String title;
  final List<String> bullets;
}

class _CalciumTopicPage extends StatelessWidget {
  const _CalciumTopicPage(this.title, this.sections);
  final String title;
  final List<_CalciumSection> sections;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
      children: [
        const _CalciumNotice('Use local age/assay-specific reference '
          'ranges. Urgent symptoms override numeric interpretation.'),
        ...sections.map((s) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.title, style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...s.bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(child: Text(b)),
                    ]),
                )),
              ]),
          ),
        )),
      ]),
  );
}

class _CalciumNotice extends StatelessWidget {
  const _CalciumNotice(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety_outlined),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ]),
    ),
  );
}

class _CalciumPatternScreen extends StatefulWidget {
  const _CalciumPatternScreen();
  @override
  State<_CalciumPatternScreen> createState() => _CalciumPatternScreenState();
}

class _CalciumPatternScreenState extends State<_CalciumPatternScreen> {
  CalciumStatus calcium = CalciumStatus.unknown;
  PthStatus pth = PthStatus.unknown;
  bool serious = false;

  @override
  Widget build(BuildContext context) {
    final r = CalciumHubMath.interpretation(
      calcium: calcium, pth: pth, seriousSymptoms: serious);
    return Scaffold(
      appBar: AppBar(title: const Text('Calcium / PTH Pattern')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        const _CalciumNotice('Select lab-reported categories using '
          'the age-specific assay ranges. This is an explanatory '
          'pattern, not an automated diagnosis.'),
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            DropdownButtonFormField<CalciumStatus>(
              initialValue: calcium,
              decoration: const InputDecoration(
                labelText: 'Serum calcium interpretation',
                border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: CalciumStatus.unknown,
                  child: Text('Not available')),
                DropdownMenuItem(value: CalciumStatus.low,
                  child: Text('Low')),
                DropdownMenuItem(value: CalciumStatus.withinRange,
                  child: Text('Within local range')),
                DropdownMenuItem(value: CalciumStatus.high,
                  child: Text('High')),
              ],
              onChanged: (v) => setState(() =>
                calcium = v ?? CalciumStatus.unknown),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PthStatus>(
              initialValue: pth,
              decoration: const InputDecoration(
                labelText: 'Paired PTH interpretation',
                border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: PthStatus.unknown,
                  child: Text('Not available')),
                DropdownMenuItem(value: PthStatus.low,
                  child: Text('Low')),
                DropdownMenuItem(value: PthStatus.withinRange,
                  child: Text('Within local range')),
                DropdownMenuItem(value: PthStatus.high,
                  child: Text('High')),
              ],
              onChanged: (v) => setState(() =>
                pth = v ?? PthStatus.unknown),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: serious,
              title: const Text('Severe symptoms or ECG concern'),
              subtitle: const Text('Seizure, tetany/stridor, arrhythmia, '
                'altered consciousness or marked dehydration'),
              onChanged: (v) => setState(() => serious = v),
            ),
          ]),
        )),
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.heading,
                style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(r.interpretation),
              if (r.needsUrgentClinicalAssessment)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('Urgent monitored pediatric assessment '
                    'is required.', style: TextStyle(
                      fontWeight: FontWeight.bold)),
                ),
            ]),
        )),
        const _CalciumNotice('Interpret PTH relative to paired calcium: '
          'a "normal" PTH can be inappropriate during hypo- or '
          'hypercalcemia. Consider magnesium, phosphate, renal function '
          'and vitamin D before reaching a diagnosis.'),
      ]),
    );
  }
}

class _CalciumCalculatorScreen extends StatefulWidget {
  const _CalciumCalculatorScreen();
  @override
  State<_CalciumCalculatorScreen> createState() =>
      _CalciumCalculatorScreenState();
}

class _CalciumCalculatorScreenState extends State<_CalciumCalculatorScreen> {
  final months = TextEditingController();
  final intake = TextEditingController();
  final urineCa = TextEditingController();
  final urineCr = TextEditingController();
  final saltMass = TextEditingController();
  final elementalPercent = TextEditingController();

  @override
  void dispose() {
    for (final c in [months, intake, urineCa, urineCr,
                     saltMass, elementalPercent]) { c.dispose(); }
    super.dispose();
  }

  void reset() {
    for (final c in [months, intake, urineCa, urineCr,
                     saltMass, elementalPercent]) { c.clear(); }
    setState(() {});
  }

  double? value(TextEditingController c) {
    final n = double.tryParse(c.text.trim());
    return n != null && n.isFinite ? n : null;
  }

  Widget field(TextEditingController c, String name, String unit) =>
    SizedBox(width: 225, child: TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: name, suffixText: unit,
        border: const OutlineInputBorder()),
      onChanged: (_) => setState(() {}),
    ));

  Widget answer(BuildContext context, String title,
      String result, String detail) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 6),
      Text(result, style: Theme.of(context).textTheme.headlineSmall
        ?.copyWith(fontWeight: FontWeight.bold)),
      Text(detail),
    ]),
  );

  Widget panel(BuildContext context, String title,
      List<Widget> children) => Card(
    child: Padding(padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 12), child: w)),
        ]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final age = int.tryParse(months.text.trim());
    final target = CalciumHubMath.ageCalciumTargetMgPerDay(age);
    final delta = CalciumHubMath.dailyCalciumDifferenceMg(
      ageMonths: age, reportedDailyIntakeMg: value(intake));
    final pct = CalciumHubMath.percentOfCalciumTarget(
      ageMonths: age, reportedDailyIntakeMg: value(intake));
    final ratio = CalciumHubMath.urineCalciumCreatinineRatioMmolPerMmol(
      calciumMmolL: value(urineCa), creatinineMmolL: value(urineCr));
    final elemental = CalciumHubMath.elementalCalciumFromLabel(
      saltMassMg: value(saltMass),
      labelledElementalPercent: value(elementalPercent));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calcium Intake & Ratios'),
        actions: [TextButton.icon(
          onPressed: reset, icon: const Icon(Icons.refresh),
          label: const Text('Reset'))]),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        const _CalciumNotice('Total calcium intake target is NOT an '
          'automatic supplement dose. Infant values are Adequate '
          'Intakes (AI); children’s values are RDAs.'),
        panel(context, 'Age-based dietary calcium intake', [
          Wrap(spacing: 12, runSpacing: 12, children: [
            field(months, 'Age (completed months)', 'mo'),
            field(intake, 'Estimated total intake', 'mg/day'),
          ]),
          if (target != null)
            answer(context,
              CalciumHubMath.infantAdequateIntake(age)
                ? 'Health Canada adequate intake (AI)'
                : 'Health Canada recommended intake (RDA)',
              '$target mg/day',
              'Total from diet, formula and any existing supplements.'),
          if (delta != null && pct != null)
            answer(context, 'Descriptive comparison',
              '${pct.toStringAsFixed(0)}% of reference',
              delta > 0
                ? 'Estimated intake ${delta.toStringAsFixed(0)} mg/day '
                  'below reference.'
                : delta < 0
                  ? 'Estimated intake ${(-delta).toStringAsFixed(0)} '
                    'mg/day above reference.'
                  : 'Intake equals the reference amount.'),
          const Text('The historical archive lists infant intake '
            'targets of 210 and 270 mg/day. Current Health Canada '
            'values are 200 mg/day for 0–6 months and '
            '260 mg/day for 7–12 months.'),
        ]),
        panel(context, 'Spot urine Ca/Cr concentration ratio', [
          const Text('Both urine calcium and urine creatinine '
            'must be from the SAME sample in mmol/L. '
            'Do not enter mg/dL or mg/mg.'),
          Wrap(spacing: 12, runSpacing: 12, children: [
            field(urineCa, 'Urine calcium', 'mmol/L'),
            field(urineCr, 'Urine creatinine', 'mmol/L'),
          ]),
          if (ratio != null)
            answer(context, 'Urine calcium/creatinine',
              '${ratio.toStringAsFixed(3)} mmol/mmol',
              'Concentration ratio only. '
                'Interpret using age-specific local standards.'),
          const Text('No universal high/low threshold is applied. '
            'Infant urine calcium excretion differs from older children.'),
        ]),
        panel(context, 'Elemental calcium label arithmetic', [
          const Text('Use ONLY when the actual product label specifies '
            'an elemental percentage. If it already lists elemental '
            'calcium mg, use that figure directly.'),
          Wrap(spacing: 12, runSpacing: 12, children: [
            field(saltMass, 'Calcium salt amount', 'mg'),
            field(elementalPercent, 'Label-stated elemental', '%'),
          ]),
          if (elemental != null)
            answer(context, 'Calculated elemental content',
              '${elemental.toStringAsFixed(1)} mg',
              'Salt mass × label-provided fraction; NOT a dose.'),
        ]),
        const _CalciumNotice('Source: current Health Canada DRI '
          'tables, public pediatric references and provided historical '
          'bone-health nutrition materials. No automatic supplement '
          'order or dose adjustment.'),
      ]),
    );
  }
}
