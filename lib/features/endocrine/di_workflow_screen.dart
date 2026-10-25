// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
import 'package:flutter/material.dart';
import 'di_math.dart';

class DiWorkflowScreen extends StatefulWidget {
  const DiWorkflowScreen({super.key});
  @override
  State<DiWorkflowScreen> createState() => _DiWorkflowScreenState();
}

class _DiWorkflowScreenState extends State<DiWorkflowScreen> {
  final _weight = TextEditingController();
  final _urine = TextEditingController();
  final _hours = TextEditingController();
  final _na = TextEditingController();
  final _serumOsm = TextEditingController();
  final _urineOsm = TextEditingController();
  final _urineSg = TextEditingController();
  @override
  void dispose() {
    for (final c in [_weight, _urine, _hours, _na, _serumOsm,
                     _urineOsm, _urineSg]) { c.dispose(); }
    super.dispose();
  }

  double? _number(TextEditingController c) {
    final d = double.tryParse(c.text.trim());
    return d != null && d.isFinite ? d : null;
  }

  Widget _field(TextEditingController c, String label, String unit) =>
      SizedBox(width: 225, child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, suffixText: unit,
            border: const OutlineInputBorder()),
        onChanged: (_) => setState(() {}),
      ));

  Widget _card(String heading, List<Widget> content, {IconData? icon}) =>
      Card(child: Padding(padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
            Expanded(child: Text(heading,
              style: Theme.of(context).textTheme.titleLarge)),
          ]),
          const SizedBox(height: 12),
          ...content.map((w) => Padding(padding: const EdgeInsets.only(bottom: 10),
              child: w)),
        ])));

  @override
  Widget build(BuildContext context) {
    final na = _number(_na);
    final serum = _number(_serumOsm);
    final urineOsm = _number(_urineOsm);
    final sg = _number(_urineSg);
    final hours = _number(_hours);
    final uop = DiMath.urineOutputMlKgHour(
      urineMl: _number(_urine),
      weightKg: _number(_weight),
      hours: hours,
    );
    final flag = DiMath.hypotonicPolyuriaPattern(
      serumOsm: serum,
      urineOsm: urineOsm,
      urineMlKgHour: uop,
      observationHours: hours,
    );
    final invalidSodium = na != null && (na < 80 || na > 220);
    final invalidSerum = serum != null && (serum < 100 || serum > 500);
    final invalidUrine = urineOsm != null && (urineOsm < 0 || urineOsm > 2000);
    final invalidSg = sg != null && (sg < 1 || sg > 1.05);

    return Scaffold(
      appBar: AppBar(title: const Text('DI / AVP deficiency & resistance'),
        actions: [TextButton.icon(
          onPressed: () {
            for (final c in [_weight, _urine, _hours, _na, _serumOsm,
                              _urineOsm, _urineSg]) { c.clear(); }
            setState(() {});
          },
          icon: const Icon(Icons.refresh), label: const Text('Reset'),
        )]),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        _card('Immediate precautions', const [
          Text('Suspected or confirmed DI: maintain free access to water '
               'when alert and able to drink. Do not perform an unsupervised '
               'water deprivation test. Infants, sedated or NPO children, '
               'patients with impaired thirst, and significant dysnatremia '
               'need urgent specialist planning.'),
          Text('Central AVP deficiency (AVP-D) and renal AVP resistance '
               '(AVP-R, nephrogenic DI) require different management. '
               'Do not use this module to prescribe fluids or desmopressin.'),
        ], icon: Icons.warning_amber_outlined),
        _card('1. Record water-balance observations', [
          Wrap(spacing: 12, runSpacing: 12, children: [
            _field(_weight, 'Weight', 'kg'),
            _field(_urine, 'Observed urine volume', 'mL'),
            _field(_hours, 'Observation interval', 'h'),
            _field(_na, 'Serum Na', 'mmol/L'),
            _field(_serumOsm, 'Paired serum osmolality', 'mOsm/kg'),
            _field(_urineOsm, 'Paired urine osmolality', 'mOsm/kg'),
            _field(_urineSg, 'Urine specific gravity', ''),
          ]),
          if (uop != null)
            Text('Observed urine output: ${uop.toStringAsFixed(2)} mL/kg/h '
                 '= ${_number(_urine)} mL / ${_number(_weight)} kg / '
                 '${hours} h.',
              style: const TextStyle(fontWeight: FontWeight.w700))
          else
            const Text('Enter volume, weight and observation hours '
                       'to calculate urine output.'),
          if (uop != null && DiMath.polyuriaFlag(uop, hours))
            const Text('POLYURIA FLAG: >4 mL/kg/h averaged over at least '
                '6 hours. Neonates have different expected urine output: '
                'seek specialist interpretation.'),
          if (hours != null && hours < 6)
            const Text('Observation is <6 hours: do not apply the '
                'RCH six-hour polyuria threshold.'),
          if (invalidSodium || invalidSerum || invalidUrine || invalidSg)
            const Text('One or more entered laboratory values fall outside '
                'the accepted display limits. Verify units and re-enter.'),
          if (DiMath.severeHypernatremia(na))
            const Text('EMERGENCY: Na >=170 mmol/L; urgent endocrinology, '
                'nephrology and PICU review.'),
          if (na != null && !invalidSodium && DiMath.sodiumHigh(na) &&
              !DiMath.severeHypernatremia(na))
            const Text('Hypernatremia: verify hydration, trends, route of '
                'fluid replacement and seek specialist advice.'),
          if (DiMath.sodiumLow(na))
            const Text('Hyponatremia: assess symptoms and recent desmopressin/'
                'fluid exposure; symptomatic cases require urgent management.'),
          if (flag && !invalidSodium && !invalidSerum && !invalidUrine)
            const Text('PATTERN OF CONCERN: high measured serum osmolality '
                'with inappropriately dilute urine and sustained polyuria. '
                'Possible DI physiology; paired values do NOT establish '
                'central versus nephrogenic subtype.'),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Interpretation limits / source'),
            children: const [
              Text('RCH: in children, urine output >4 mL/kg/h averaged '
                  'over six hours suggests polyuria; urine osmolality '
                  '<300 mOsm/kg with serum osmolality >300 mOsm/kg '
                  'is concerning in context. Partial DI can be less clear. '
                  'Do not diagnose subtype from a single sample.'),
            ],
          ),
        ], icon: Icons.calculate_outlined),
        _card('2. Assessment and differential', const [
          Text('History: polyuria/nocturia/new enuresis, water-seeking, '
               'access to water, poor feeding/failure to thrive, head injury, '
               'neurosurgery/CNS lesions, medicines (including diuretics), '
               'family history and developmental status.'),
          Text('Examination: perfusion, hydration, weight trend, thirst, '
               'mental status and neurological/visual findings.'),
          Text('Obtain paired serum Na/osmolality and urine osmolality; '
               'urine specific gravity; blood glucose to exclude osmotic '
               'diuresis; urea, creatinine, electrolytes, calcium and '
               'potassium. Consider urine glucose, medication effects, '
               'solute diuresis and primary polydipsia.'),
          Text('Central AVP-D: reduced release. AVP-R: renal nonresponse. '
               'Consider pituitary MRI/hormone testing when central disease '
               'is suspected, guided by endocrinology.'),
        ], icon: Icons.fact_check_outlined),
        _card('3. Monitoring and treatment safety', const [
          Text('Document hourly urine output, strict intake/output and '
               'fluid balance, daily (or more frequent) weight, paired '
               'electrolyte trends and neurological status. Frequency '
               'depends on acuity and specialist plan.'),
          Text('Central DI: desmopressin is high risk for rapid water '
               'retention and hyponatremia. Routes are NOT interchangeable. '
               'All initiation, dose changes or withholding require '
               'endocrinology review. Monitor sodium and breakthrough '
               'diuresis per plan. Never convert DDAVP routes yourself.'),
          Text('Nephrogenic DI: engage nephrology and dietetics. '
               'Free-water and low-solute approaches, and selected thiazide '
               'use, need an individualized plan. Avoid routine '
               'sodium-containing replacement without nephrology input.'),
          Text('After pituitary surgery, a triphasic DI/SIADH pattern '
               'may occur. Review sodium and urine output closely.'),
        ], icon: Icons.monitor_heart_outlined),
        _card('4. SIADH distinction', const [
          Text('SIADH may cause low serum sodium/osmolality and '
               'inappropriately concentrated urine, typically without '
               'hypovolemia. Exclude adrenal insufficiency, hypothyroidism, '
               'renal causes, and medication effects before labeling SIADH.'),
          Text('Do not apply DI free-water advice to established SIADH. '
               'Symptomatic hyponatremia requires emergency escalation and '
               'a local protocol.'),
        ], icon: Icons.water_drop_outlined),
        const Padding(padding: EdgeInsets.all(12), child:
            Text('Source: Royal Children\'s Hospital Melbourne, '
                 'Clinical Practice Guideline: Diabetes insipidus '
                 '(updated July 2022). Content reviewed 25 Oct 2026. '
                 'SickKids-specific fluid/DDAVP guidance not verified.')),
      ]),
    );
  }
}
