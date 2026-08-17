// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _verification =
    'Verify with local institutional protocols, formulary, pharmacist, and attending physician before implementation.';

class IntegratedClinicalSupportScreen extends StatefulWidget {
  const IntegratedClinicalSupportScreen({super.key});

  @override
  State<IntegratedClinicalSupportScreen> createState() =>
      _IntegratedClinicalSupportScreenState();
}

class _IntegratedClinicalSupportScreenState
    extends State<IntegratedClinicalSupportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ED/PICU Decision Support'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const <Tab>[
            Tab(text: 'Electrolytes', icon: Icon(Icons.science_outlined)),
            Tab(text: 'Order sets', icon: Icon(Icons.playlist_add_check)),
            Tab(text: 'Antibiotics', icon: Icon(Icons.biotech_outlined)),
            Tab(text: 'ED / PICU', icon: Icon(Icons.emergency_outlined)),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          const _SafetyBanner(),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const <Widget>[
                ElectrolyteSupportView(),
                AdmissionOrderSetsView(),
                AntibioticDecisionSupportView(),
                EmergencyPicuView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.all(12),
      child: Text(
        _verification,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ElectrolyteSupportView extends StatelessWidget {
  const ElectrolyteSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_LaunchItem>[
      _LaunchItem('Potassium replacement', 'Route, access, ECG and renal safety', Icons.bolt, const ElectrolyteCalculator(type: ElectrolyteType.potassium)),
      _LaunchItem('Phosphate replacement', 'Na/K phosphate selection and monitoring', Icons.science, const ElectrolyteCalculator(type: ElectrolyteType.phosphate)),
      _LaunchItem('Magnesium replacement', 'QT, renal function and symptom checks', Icons.monitor_heart, const ElectrolyteCalculator(type: ElectrolyteType.magnesium)),
      _LaunchItem('Calcium replacement', 'Ionized calcium, access and ECG safety', Icons.biotech, const ElectrolyteCalculator(type: ElectrolyteType.calcium)),
      _LaunchItem('Sodium correction', 'Hyponatremia and hypernatremia framework', Icons.water_drop, const ElectrolyteCalculator(type: ElectrolyteType.sodium)),
    ];
    return _LaunchList(title: 'v13 Electrolyte calculators', items: items);
  }
}

enum ElectrolyteType { potassium, phosphate, magnesium, calcium, sodium }

class ElectrolyteCalculator extends StatefulWidget {
  final ElectrolyteType type;
  const ElectrolyteCalculator({super.key, required this.type});

  @override
  State<ElectrolyteCalculator> createState() => _ElectrolyteCalculatorState();
}

class _ElectrolyteCalculatorState extends State<ElectrolyteCalculator> {
  final age = TextEditingController();
  final diagnosis = TextEditingController();
  final allergies = TextEditingController();
  final hepatic = TextEditingController();
  final medications = TextEditingController();
  final vitals = TextEditingController();
  final weight = TextEditingController();
  final current = TextEditingController();
  final previous = TextEditingController();
  final renal = TextEditingController();
  final urine = TextEditingController();
  final notes = TextEditingController();
  String access = 'Enteral';
  String acuity = 'Stable';
  bool ecgChanges = false;
  bool alteredMentalStatus = false;
  bool arrhythmia = false;
  bool severeRenalFailure = false;
  bool symptomatic = false;
  String output = '';

  String get title => switch (widget.type) {
        ElectrolyteType.potassium => 'Potassium Replacement Calculator',
        ElectrolyteType.phosphate => 'Phosphate Replacement Calculator',
        ElectrolyteType.magnesium => 'Magnesium Replacement Calculator',
        ElectrolyteType.calcium => 'Calcium Replacement Calculator',
        ElectrolyteType.sodium => 'Sodium Correction Calculator',
      };

  @override
  void dispose() {
    age.dispose(); diagnosis.dispose(); allergies.dispose(); hepatic.dispose(); medications.dispose(); vitals.dispose();
    weight.dispose(); current.dispose(); previous.dispose(); renal.dispose(); urine.dispose(); notes.dispose();
    super.dispose();
  }

  void calculate() {
    final w = double.tryParse(weight.text);
    final value = double.tryParse(current.text);
    if (age.text.trim().isEmpty || diagnosis.text.trim().isEmpty ||
        allergies.text.trim().isEmpty || renal.text.trim().isEmpty ||
        urine.text.trim().isEmpty || w == null || w <= 0 || value == null) {
      setState(() => output = 'Complete age, diagnosis, allergies, renal function, urine output, verified weight and the current laboratory value before generating a recommendation.');
      return;
    }
    final hardStop = ecgChanges || arrhythmia || severeRenalFailure ||
        (widget.type == ElectrolyteType.sodium && alteredMentalStatus);
    final buffer = StringBuffer();
    buffer.writeln(title);
    buffer.writeln('Age: ${age.text} | Diagnosis: ${diagnosis.text}');
    buffer.writeln('Allergies: ${allergies.text}');
    buffer.writeln('Weight: ${w.toStringAsFixed(1)} kg');
    buffer.writeln('Current value: $value');
    buffer.writeln('Access: $access | Acuity: $acuity');
    buffer.writeln('Renal function: ${renal.text.isEmpty ? '<REQUIRED>' : renal.text}');
    buffer.writeln('Urine output: ${urine.text.isEmpty ? '<REQUIRED>' : urine.text}');
    if (hardStop) {
      buffer.writeln('\nHARD STOP: high-risk feature detected. Do not use routine replacement logic. Notify senior clinician/PICU and pharmacy now.');
    } else {
      buffer.writeln('\nSuggested strategy category: ${_strategy(value)}');
      buffer.writeln(_logic());
      buffer.writeln('\nRoute/rate: use the institution-approved weight-based dose, maximum concentration and maximum infusion rate for $access access. High-risk IV therapy requires pharmacy verification and independent pump check.');
      buffer.writeln('\nMonitoring: ${_monitoring()}');
      buffer.writeln('Recheck: ${_recheck()}');
      buffer.writeln('Cautions: ${_cautions()}');
    }
    buffer.writeln('\n$_verification');
    setState(() => output = buffer.toString());
  }

  String _strategy(double value) {
    if (symptomatic || acuity == 'Severe') return 'Urgent monitored correction with specialist escalation';
    if (access == 'Enteral') return 'Prefer enteral replacement when clinically appropriate';
    return 'IV replacement using local concentration/rate limits';
  }

  String _logic() => switch (widget.type) {
    ElectrolyteType.potassium => 'Logic: confirm urine output, renal function, magnesium and acid-base status. Do not predict the final serum K from a replacement dose. Correct magnesium when low.',
    ElectrolyteType.phosphate => 'Logic: choose sodium phosphate when potassium load is undesirable; choose potassium phosphate only when additional potassium is appropriate. Display both phosphate and accompanying cation load.',
    ElectrolyteType.magnesium => 'Logic: enteral therapy for stable patients; IV pathway for severe symptoms, QT-related arrhythmia or inability to absorb. Adjust for renal dysfunction.',
    ElectrolyteType.calcium => 'Logic: use ionized calcium for acute decisions. Calcium gluconate is generally preferred peripherally; calcium chloride requires secure access and emergency/local protocol review.',
    ElectrolyteType.sodium => 'Logic: define acute versus chronic/unknown, symptoms and volume status. Correct perfusion first in hypernatremic shock. Symptomatic hyponatremia requires the emergency hypertonic-saline pathway.',
  };

  String _monitoring() => switch (widget.type) {
    ElectrolyteType.potassium => 'ECG when severe or IV high-risk replacement; serum K, Mg, creatinine, urine output and infusion site.',
    ElectrolyteType.phosphate => 'Phosphate, calcium, potassium, magnesium, creatinine, symptoms and ECG when potassium load is significant.',
    ElectrolyteType.magnesium => 'BP, HR, respiratory status, ECG/QT, Mg, K, Ca and creatinine.',
    ElectrolyteType.calcium => 'Continuous ECG for urgent IV therapy; ionized Ca, Mg, phosphate, renal function and infusion site.',
    ElectrolyteType.sodium => 'Serial sodium, neurologic checks, glucose, urine output, fluid balance, weight and osmolality when indicated.',
  };

  String _recheck() => switch (widget.type) {
    ElectrolyteType.sodium => 'Set an explicit sodium recheck interval based on symptoms and correction risk; recheck after each emergency hypertonic intervention.',
    _ => 'After the dose/infusion and local redistribution interval; earlier for severe symptoms, rapid infusion, renal dysfunction or active losses. Do not redose before reviewing the result.',
  };

  String _cautions() => switch (widget.type) {
    ElectrolyteType.potassium => 'Anuria, renal failure, ECG changes, arrhythmia, incompatible fluids and concentrated peripheral infusions.',
    ElectrolyteType.phosphate => 'Renal failure, hypocalcemia, sodium/potassium load, calcium incompatibility and product concentration errors.',
    ElectrolyteType.magnesium => 'Renal failure, hypotension, bradycardia, heart block and respiratory depression.',
    ElectrolyteType.calcium => 'Extravasation, digoxin toxicity, hyperphosphatemia and bicarbonate/phosphate incompatibility.',
    ElectrolyteType.sodium => 'Unknown chronicity, rapid correction, severe neurologic symptoms, diabetes insipidus and renal failure.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const _RequiredInputsCard(),
          const SizedBox(height: 12),
          _field(age, 'Age', ''),
          _field(diagnosis, 'Diagnosis / syndrome', ''),
          _field(allergies, 'Allergies and reaction', ''),
          _field(weight, 'Verified weight', 'kg'),
          _field(current, 'Current laboratory value', ''),
          _field(previous, 'Previous value and time', ''),
          _field(renal, 'Renal function / creatinine / eGFR', ''),
          _field(hepatic, 'Hepatic dysfunction if relevant', ''),
          _field(medications, 'Current medications', ''),
          _field(vitals, 'Relevant vitals / ECG / labs', ''),
          _field(urine, 'Urine output', 'mL/kg/h'),
          DropdownButtonFormField<String>(
            initialValue: access,
            decoration: const InputDecoration(labelText: 'Available access'),
            items: const ['Enteral', 'Peripheral IV', 'Central IV', 'IO']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => access = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: acuity,
            decoration: const InputDecoration(labelText: 'Severity / acuity'),
            items: const ['Stable', 'Moderate', 'Severe', 'Peri-arrest']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => acuity = v!),
          ),
          _check('Symptoms present', symptomatic, (v) => symptomatic = v),
          _check('ECG changes', ecgChanges, (v) => ecgChanges = v),
          _check('Arrhythmia risk/present', arrhythmia, (v) => arrhythmia = v),
          _check('Severe renal failure/anuria', severeRenalFailure, (v) => severeRenalFailure = v),
          if (widget.type == ElectrolyteType.sodium)
            _check('Altered mental status/seizure', alteredMentalStatus, (v) => alteredMentalStatus = v),
          _field(notes, 'Relevant labs, medications and clinical notes', ''),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: calculate, icon: const Icon(Icons.calculate), label: const Text('Generate safe framework')),
          if (output.isNotEmpty) ...[
            const SizedBox(height: 16),
            _OutputCard(text: output),
          ],
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String suffix) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(controller: c, keyboardType: label.contains('weight') || label.contains('value') ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label, suffixText: suffix.isEmpty ? null : suffix, border: const OutlineInputBorder())),
  );

  Widget _check(String label, bool value, void Function(bool) assign) => CheckboxListTile(
    contentPadding: EdgeInsets.zero,
    value: value,
    title: Text(label),
    onChanged: (v) => setState(() => assign(v ?? false)),
  );
}

class AdmissionOrderSetsView extends StatelessWidget {
  const AdmissionOrderSetsView({super.key});
  @override
  Widget build(BuildContext context) {
    final items = <_LaunchItem>[
      for (final entry in _orderSets.entries)
        _LaunchItem(entry.key, 'EMR-copyable admission template', Icons.assignment_add, TextProtocolScreen(title: entry.key, text: entry.value)),
    ];
    return _LaunchList(title: 'v14 Admission order sets', items: items);
  }
}

class AntibioticDecisionSupportView extends StatelessWidget {
  const AntibioticDecisionSupportView({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const _RequiredInputsCard(),
        const SizedBox(height: 12),
        const _InfoSection(title: 'Spectrum symbols', body: '● expected activity   ◐ variable/context-dependent   ○ generally unreliable\nG+ Gram-positive | MRSA | G- Gram-negative | PsA Pseudomonas | AN anaerobes | AT atypicals | F fungal'),
        const SizedBox(height: 12),
        ..._antibioticSyndromes.entries.map((e) => Card(child: ExpansionTile(title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700)), childrenPadding: const EdgeInsets.all(16), children: [SelectableText(e.value)]))),
        const SizedBox(height: 12),
        const _InfoSection(title: 'Allergy logic', body: 'Classify the reaction: intolerance, benign delayed rash, immediate urticaria/angioedema, anaphylaxis, severe cutaneous adverse reaction, or unknown. Never re-expose after SJS/TEN or DRESS without specialist review. Use local beta-lactam de-labelling pathways for low-risk histories.'),
        const _InfoSection(title: 'Stewardship hard checks', body: 'Cultures before antibiotics when this does not meaningfully delay care; review prior organisms; confirm renal/hepatic dosing; identify source control; document 24–48 h review and stop date; remove duplicate MRSA, anaerobic, atypical or antipseudomonal coverage unless justified.'),
      ],
    );
  }
}

class EmergencyPicuView extends StatelessWidget {
  const EmergencyPicuView({super.key});
  @override
  Widget build(BuildContext context) {
    final items = <_LaunchItem>[
      for (final entry in _emergencyProtocols.entries)
        _LaunchItem(entry.key, 'Pediatric emergency/PICU framework', Icons.emergency, TextProtocolScreen(title: entry.key, text: entry.value)),
    ];
    return _LaunchList(title: 'v16 Pediatric emergency & PICU', items: items);
  }
}

class TextProtocolScreen extends StatelessWidget {
  final String title;
  final String text;
  const TextProtocolScreen({super.key, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: [IconButton(tooltip: 'Copy', onPressed: () => _copy(context, text), icon: const Icon(Icons.copy))]),
    body: ListView(padding: const EdgeInsets.all(16), children: [SelectableText(text), const SizedBox(height: 20), Text(_verification, style: const TextStyle(fontWeight: FontWeight.w700))]),
  );
}

void _copy(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
}

class _LaunchItem {
  final String title; final String subtitle; final IconData icon; final Widget screen;
  const _LaunchItem(this.title, this.subtitle, this.icon, this.screen);
}

class _LaunchList extends StatelessWidget {
  final String title; final List<_LaunchItem> items;
  const _LaunchList({required this.title, required this.items});
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: items.length + 1,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      if (index == 0) return Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800));
      final item = items[index - 1];
      return Card(child: ListTile(leading: CircleAvatar(child: Icon(item.icon)), title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(item.subtitle), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => item.screen))));
    },
  );
}

class _RequiredInputsCard extends StatelessWidget {
  const _RequiredInputsCard();
  @override
  Widget build(BuildContext context) => const _InfoSection(
    title: 'Minimum patient inputs required',
    body: 'Age; verified weight in kg; diagnosis/syndrome; severity; allergies and reaction; renal function and urine output; hepatic dysfunction when relevant; pregnancy status when relevant; current medications; relevant labs/vitals; and access type. Missing inputs must be documented before implementation.',
  );
}

class _InfoSection extends StatelessWidget {
  final String title; final String body;
  const _InfoSection({required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), SelectableText(body)])));
}

class _OutputCard extends StatelessWidget {
  final String text; const _OutputCard({required this.text});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [SelectableText(text), const SizedBox(height: 12), OutlinedButton.icon(onPressed: () => _copy(context, text), icon: const Icon(Icons.copy), label: const Text('Copy EMR text'))])));
}

const Map<String, String> _orderSets = {
  'General pediatric admission': '''PATIENT: <PATIENT_IDENTIFIER>\nAGE: <AGE>\nWEIGHT: <PATIENT_WEIGHT_KG> kg\nDIAGNOSIS: <DIAGNOSIS>\nALLERGIES/REACTION: <ALLERGIES>\nRENAL FUNCTION: <RENAL_FUNCTION>\nLOCAL PROTOCOL: <LOCAL_PROTOCOL>\n\nADMIT: <WARD/STEP-DOWN/PICU>; condition <STABLE/GUARDED/CRITICAL>.\nVITALS/MONITORING: Vitals q<FREQUENCY>; pulse oximetry <YES/NO>; cardiorespiratory monitoring <YES/NO>; neurologic checks q<FREQUENCY>; strict I/O.\nNURSING: Notify physician for age-specific vital-sign thresholds, SpO2 below <TARGET>, urine output below <THRESHOLD>, altered mental status, seizure, increased work of breathing or poor perfusion.\nLABS: <LABS>; repeat at <TIME>.\nIMAGING: <IMAGING/NONE ROUTINELY>.\nFLUIDS: <TYPE/RATE>; add potassium only after urine output and renal function confirmed.\nMEDICATIONS: <MEDICATIONS>; continue time-critical home medications after reconciliation.\nRESPIRATORY: <DEVICE>; target SpO2 <LOCAL_TARGET>; RT <YES/NO>.\nISOLATION: <PRECAUTIONS>.\nDIET/ACTIVITY: <REGULAR/NPO/OTHER>.\nCONSULTS: <CONSULTS>.\nREASSESSMENT: Physician reassessment by <TIME> and after every significant intervention.\nSTEP-DOWN/DISCHARGE: <CRITERIA>.''',
  'Sepsis / septic shock': '''ADMIT: PICU/ED resuscitation area. Diagnosis <SOURCE> sepsis/septic shock.\nIMMEDIATE: ABCs; oxygen/ventilation; two IVs or IV+IO; senior/PICU notification; sepsis huddle at <TIME>.\nMONITORING: Continuous ECG/SpO2; BP q5–15 min during resuscitation; strict I/O; reassess perfusion after every intervention.\nLABS: Cultures before antibiotics if no meaningful delay; lactate; CBC; electrolytes/glucose; renal/liver profile; gas; coagulation; source-specific specimens.\nFLUIDS: Balanced/local crystalloid in reassessed <10–20 mL/kg> aliquots only when shock physiology supports fluid; stop for improvement or fluid overload.\nANTIBIOTICS: <LOCAL_SEPSIS_REGIMEN>; record administration time; adjust for age, source, immune status, allergy and renal function.\nVASOACTIVE: Activate local pathway for fluid-refractory shock.\nSOURCE CONTROL: Evaluate line, abscess, empyema, abdomen, device, bone/joint and surgical sources.\nREASSESS: Formal response assessment q<15–30 MIN> and after every bolus/vasoactive change.''',
  'DKA': '''ADMIT: <WARD/STEP-DOWN/PICU> per severity and local DKA pathway.\nMONITORING: Vitals q1h; neurologic checks q1h; bedside glucose q1h; strict I/O; continuous ECG for severe K abnormality.\nLABS: VBG, electrolytes, glucose, renal function, beta-hydroxybutyrate, Mg, phosphate; repeat q2–4h per severity.\nFLUIDS: Institutional pediatric DKA calculator including maintenance, deficit, prior boluses and correction duration.\nINSULIN: Continuous regular insulin per <LOCAL_PROTOCOL> after initial fluid and potassium review; no routine bolus.\nPOTASSIUM: Add only after urine output/renal function established; select salts based on chloride/phosphate.\nCEREBRAL INJURY: Treat immediately for headache, bradycardia, altered consciousness, vomiting, cranial nerve signs or abnormal breathing; do not delay therapy for imaging.\nCONSULTS: Endocrinology; PICU for severe DKA or neurologic concern.''',
  'Status epilepticus': '''ADMIT: Resuscitation bay/PICU.\nIMMEDIATE: Airway positioning, oxygen, suction, continuous monitoring, bedside glucose, IV/IO, record seizure onset.\nMEDICATIONS: First-line benzodiazepine <LOCAL_WEIGHT_BASED_DOSE>; confirm cumulative dose before repeat. If persistent, second-line antiseizure agent <AGENT/LOCAL_PROTOCOL>. Refractory status requires PICU/anesthesia and continuous EEG.\nLABS: Glucose, electrolytes, Ca, Mg, drug levels and targeted toxicology/infectious/metabolic tests.\nAIRWAY: Prepare assisted ventilation after repeated benzodiazepines.\nREASSESS: Every 5 min during active seizure; document cessation and postictal examination.''',
  'Pneumonia / respiratory distress': '''ADMIT: <WARD/STEP-DOWN/PICU>; diagnosis <CAP/COMPLICATED/ASPIRATION/OTHER>.\nMONITORING: Vitals q2–4h; continuous oximetry while oxygen-dependent; respiratory score q<FREQUENCY>.\nRESPIRATORY: Oxygen <DEVICE>; target <LOCAL_TARGET>; suction/airway clearance; RT; escalation low-flow→HFNC/NIV→intubation.\nLABS/IMAGING: Target to severity; CXR for significant distress/complication; ultrasound for effusion.\nANTIBIOTICS: <LOCAL_CAP_REGIMEN>; add MRSA/atypical coverage only when justified; review date <DATE>.\nSOURCE CONTROL: Drainage consultation for large/purulent/significant effusion.\nDIET: Oral as tolerated; NPO for severe distress/procedure.\nREASSESS: Oxygen need and work of breathing within <1–2 HOURS>.''',
  'Dehydration / electrolyte abnormality': '''ADMIT: Level of care based on perfusion, neurologic status and correction risk.\nMONITORING: Vitals q<FREQUENCY>; strict I/O; daily weight; ECG for severe K/Ca/Mg disturbance.\nLABS: Electrolytes, glucose, renal function, Mg, phosphate, Ca, gas as indicated; repeat at <TIME>.\nFLUIDS: Resuscitation only for impaired perfusion; document maintenance+deficit+ongoing losses−prior fluids.\nELECTROLYTE: Use v13 calculator; record product, dose logic, route, access, rate limit, monitoring and recheck.\nDIET: Oral rehydration preferred when safe.\nCONSULTS: Nephrology/PICU/pharmacy based on severity.''',
  'Toxic ingestion': '''ADMIT: <OBSERVATION/WARD/PICU>; suspected <SUBSTANCE>.\nIMMEDIATE: ABCs, bedside glucose, ECG, IV access; Poison Centre contacted at <TIME>.\nMONITORING: Continuous ECG/SpO2 when cardiotoxic, sedating or unstable; serial neurologic checks; strict I/O.\nLABS: Targeted toxicology; acetaminophen/salicylate for intentional/unknown ingestion when indicated; electrolytes, renal/liver profile, gas/lactate.\nDECONTAMINATION: Only after Poison Centre discussion; do not induce vomiting.\nANTIDOTE: <ANTIDOTE/LOCAL_PROTOCOL>; pharmacy verification.\nREASSESS: Repeat ECG/labs at <TIME>; escalate for QRS/QT abnormality, hypotension, seizure, respiratory depression, acidosis or altered mental status.''',
  'PICU admission': '''ADMIT: PICU; primary diagnosis <DIAGNOSIS>; organ support <RESP/CV/NEURO/RENAL>.\nMONITORING: Continuous ECG/SpO2/BP; temperature and neurologic monitoring; strict I/O; daily weight; device bundle.\nAIRWAY/VENTILATION: Mode <MODE>; settings <SETTINGS>; gas target/repeat <TARGET/TIME>; sedation/analgesia; harm-prevention bundle.\nHEMODYNAMICS: Perfusion goals <GOALS>; fluid strategy <STRATEGY>; vasoactive <AGENT/LOCAL_RATE>; lactate/echo strategy.\nLABS: <SCHEDULE>; blood-conservation plan.\nNUTRITION: Enteral assessment within <TIME>; NPO reason if applicable.\nDAILY GOALS: Sedation, ventilator, fluid balance, device removal, antibiotic review, family communication.''',
};

const Map<String, String> _antibioticSyndromes = {
  'Sepsis / meningitis': 'Targets: G+, G-, age-specific organisms; MRSA and PsA only when risk justifies. Framework: broad antipseudomonal beta-lactam ± MRSA agent for septic shock; third-generation cephalosporin + vancomycin for bacterial meningitis with age-specific additions. Obtain cultures when this does not delay therapy. Confirm meningitis dosing, renal adjustment, HSV criteria and source control.',
  'Pneumonia': 'Uncomplicated CAP: narrow pneumococcal-active beta-lactam when appropriate. Severe/post-influenza: consider S. aureus/MRSA based on features. Add atypical coverage selectively. Evaluate effusion/empyema and drainage. Spectrum: G+ ● | MRSA ○/risk-based | G- ◐ | PsA ○ unless healthcare-associated | AN ○ unless aspiration syndrome | AT agent-dependent.',
  'UTI / pyelonephritis': 'Target enteric G-. Obtain urine before antibiotics. Choose local cephalosporin/aminoglycoside pathway based on age, severity, renal function, prior ESBL and urologic history. Narrow to culture and susceptibility.',
  'Skin / soft tissue': 'Nonpurulent cellulitis: streptococci ± MSSA. Purulent abscess: drainage first; MRSA therapy by severity/local prevalence. Necrotizing infection: urgent surgery plus broad therapy and toxin suppression.',
  'Bone / joint': 'Target S. aureus, streptococci and age-specific organisms. Obtain blood/joint cultures; involve orthopedics for aspiration/drainage; choose MSSA-active therapy ± MRSA based on risk and local susceptibility.',
  'Intra-abdominal': 'Target G- and anaerobes; enterococcal coverage only when clinically indicated. Source control is mandatory. Avoid duplicate anaerobic therapy.',
  'Febrile neutropenia': 'Immediate antipseudomonal beta-lactam per oncology protocol. Add Gram-positive coverage only for defined indications. Review prophylaxis, prior resistant organisms and line status.',
  'Toxic shock': 'Broad staphylococcal/streptococcal coverage plus toxin-suppressive agent; urgent source control. IVIG requires case-specific specialist review.',
  'CNS infection': 'Select by age, immune status, device presence and exposure. Verify CNS penetration and meningitis dosing. Add acyclovir when HSV criteria are present. Device infection requires neurosurgical source control.',
  'Device / line infection': 'Obtain peripheral and line cultures. Cover staphylococci; add G- or PsA according to host/severity. Remove infected device when indicated; do not treat colonization alone.',
  'Neonatal fever': 'Target GBS, enteric G- and Listeria; assess HSV risk. Use neonatal gestational/postnatal-age dosing and local aminoglycoside/cefotaxime strategy. Avoid ceftriaxone where contraindicated.',
};

const Map<String, String> _emergencyProtocols = {
  'Initial stabilization': '1. Pediatric assessment triangle: appearance, work of breathing, circulation.\n2. Call for help and activate the appropriate team.\n3. Airway position, suction, oxygen and ventilation.\n4. Continuous monitoring and bedside glucose.\n5. IV/IO access.\n6. Identify immediate reversible causes.\n7. Obtain verified weight or resuscitation-length estimate.\n8. Treat life threats.\n9. Reassess after every intervention.\n10. Document times, doses and response.\n\nHard stops: impending arrest, respiratory failure, shock, altered mental status, severe electrolyte derangement or arrhythmia.',
  'Ventilator starting settings': 'Required: weight/ideal body weight, physiology, compliance/resistance, blood gas, oxygenation target, hemodynamics, air leak, ICP and pulmonary hypertension concerns.\n\nOBSTRUCTIVE: long expiratory time, lower rate, high inspiratory flow, avoid breath stacking, monitor auto-PEEP and hypotension; permissive hypercapnia only when appropriate.\n\nRESTRICTIVE/PARDS: lung-protective physiologic tidal volume, pressure limits, PEEP titrated to oxygenation/hemodynamics, avoid excessive tidal volume.\n\nOUTPUT: mode <MODE>; Vt/pressure <LOCAL_PROTOCOL>; rate <RATE>; PEEP <PEEP>; FiO2 <FIO2>; I-time/flow <SETTING>; SpO2 and CO2/pH targets; repeat gas <TIME>. RT/PICU verification required.',
  'Vasoactive medication selection': 'Assess BP/perfusion, fluid already given, cardiac function, warm/cold phenotype, lactate, access, arrhythmia and pulmonary hypertension.\n• Persistent shock after carefully reassessed fluid: start vasoactive support without waiting for central access when local policy permits.\n• Low SVR/warm shock: vasoconstrictor-dominant pathway.\n• Low output/cold shock: inotrope/vasoactive selection based on BP and echo.\n• Cardiogenic shock: avoid repeated empiric boluses.\nOutput must include agent, local weight-based starting rate, access, titration target, continuous ECG/BP and reassessment q5–15 min.',
  'Status epilepticus': '0–5 min: ABCs, oxygen/suction, glucose, IV/IO, record onset, first-line benzodiazepine per local weight-based protocol.\n5–10 min: confirm adequate dose, repeat only per pathway, prepare ventilation, correct glucose.\n10–20 min: second-line antiseizure agent selected by contraindications and formulary.\nPersistent: refractory pathway, PICU/anesthesia, intubation/anesthetic therapy, continuous EEG and etiologic evaluation.\nPitfall: repeated benzodiazepines without cumulative-dose and ventilation review.',
  'DKA': 'Confirm hyperglycemia + ketosis + metabolic acidosis. Assess perfusion, neurologic status, K, sodium trend, renal function and prior fluids. Restore perfusion if needed; calculate maintenance + deficit − prior fluids using local pediatric protocol. Start continuous insulin after initial fluid and K review; no routine bolus. Add K only with renal/urine-output assessment. Increase dextrose as glucose falls so insulin continues until ketoacidosis resolves. Hourly glucose/neuro checks; labs q2–4h. Treat cerebral injury immediately without delaying for imaging.',
  'Sepsis / septic shock': 'Recognize suspected infection with organ dysfunction/shock. ABCs, lactate, IV/IO, cultures if no meaningful delay, prompt broad empiric antibiotics and source search. Give reassessed 10–20 mL/kg fluid aliquots only when indicated; stop for improvement or fluid overload. Start vasoactive support for fluid-refractory shock. Trend perfusion/lactate, narrow therapy and pursue source control.',
  'Toxicology': 'ABCs, glucose and ECG. Identify toxidrome. Determine substance, dose, time, formulation and co-ingestants. Contact Poison Centre. Obtain targeted tests. Decontamination only after risk assessment. Antidote only through substance-specific protocol. Repeat ECG/labs and determine observation/mental-health needs. Hard stops: QRS/QT abnormality, hypotension, bradycardia, seizure, respiratory depression, severe acidosis, hypoglycemia, hyperthermia or delirium.',
  'PALS resuscitation structure': 'Unresponsive/no normal breathing: activate response, rapid pulse/breathing check, start high-quality CPR when indicated, attach monitor/defibrillator and use current weight-based PALS reference.\nShockable: defibrillation pathway. Non-shockable: CPR + epinephrine pathway.\nReversible causes: hypovolemia, hypoxia, acidosis, hypo/hyperkalemia/metabolic, hypothermia, tension pneumothorax, tamponade, toxins and thrombosis.\nPost-ROSC: avoid hypoxemia/hypotension, control ventilation, identify cause, manage glucose/temperature, neurologic monitoring and PICU transfer. Exact doses/energies must come from the current institutional PALS reference.',
};
