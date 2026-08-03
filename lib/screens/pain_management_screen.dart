import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PainManagementScreen extends StatelessWidget {
  const PainManagementScreen({super.key});

  static const List<_PainTopic> topics = <_PainTopic>[
    _PainTopic('Mild pain', Icons.sentiment_satisfied_outlined, <_PainSection>[
      _PainSection('Assessment', <String>['Use self-report whenever developmentally possible (numeric rating, Faces scale); use FLACC or another validated behavioural tool when self-report is not reliable.','Identify pain mechanism, severity, functional impact, prior analgesia, allergies, hepatic/renal disease and bleeding risk.']),
      _PainSection('Initial treatment', <String>['Comfort positioning, explanation, distraction, heat/ice when appropriate and caregiver involvement.','Acetaminophen 10–15 mg/kg PO every 4–6 hours as needed; do not exceed the lower of 75 mg/kg/day or the institutional maximum.','Ibuprofen 10 mg/kg PO every 6–8 hours as needed (usual maximum 400 mg/dose); avoid with significant dehydration, renal impairment, GI bleeding or NSAID contraindication.']),
      _PainSection('Reassessment', <String>['Reassess pain and function within 30–60 minutes after oral medication and after any clinical change.','Escalate if pain remains moderate/severe, diagnosis is uncertain, or red flags are present.']),
    ]),
    _PainTopic('Moderate pain', Icons.healing_outlined, <_PainSection>[
      _PainSection('Approach', <String>['Continue non-pharmacologic measures and schedule acetaminophen/NSAID when safe.','For acute moderate pain, intranasal fentanyl can provide rapid analgesia while IV access is being established.']),
      _PainSection('Medication options', <String>['Fentanyl intranasal 1–2 micrograms/kg (usual maximum 100 micrograms total), divided between nostrils; monitor sedation and respiration.','Morphine PO 0.2–0.5 mg/kg every 4–6 hours (usual maximum 15 mg/dose), starting at the lower end in opioid-naive patients.','Ketorolac 0.5 mg/kg IV every 6–8 hours may be used when appropriate; use local age/dose maximums and avoid renal/GI bleeding risk.']),
      _PainSection('Monitoring', <String>['Document pain score, sedation score, respiratory rate, oxygen saturation and response.','Avoid codeine in children and adolescents.']),
    ]),
    _PainTopic('Severe pain', Icons.warning_amber_outlined, <_PainSection>[
      _PainSection('Immediate priorities', <String>['Treat severe pain promptly while identifying time-critical causes such as compartment syndrome, ischemia, torsion, intracranial pathology, perforation or sepsis.','Use continuous pulse oximetry and frequent sedation/respiratory assessment when parenteral opioids are used.']),
      _PainSection('Parenteral options', <String>['Morphine IV 0.05–0.1 mg/kg slowly; reassess and titrate using local maximums and opioid-naive precautions.','Fentanyl IV 0.5–1 microgram/kg slowly may be preferred when rapid titration or less histamine release is desired.','Consider PCA or nurse-controlled analgesia with a standardized institutional protocol for ongoing severe pain.']),
      _PainSection('Escalation', <String>['Escalate to senior/PCCU/anesthesia or acute pain service for uncontrolled pain, increasing opioid requirement, respiratory depression, hemodynamic instability or diagnostic uncertainty.']),
    ]),
    _PainTopic('Oral versus IV options', Icons.compare_arrows_outlined, <_PainSection>[
      _PainSection('Choose the route', <String>['Prefer oral therapy when the child can absorb and tolerate it and rapid titration is not required.','Use intranasal analgesia when fast, needle-free treatment is needed.','Use IV therapy for severe pain, shock, persistent vomiting, impaired absorption or when rapid titration is required.']),
      _PainSection('Principles', <String>['Do not delay analgesia solely while waiting for IV access.','Use multimodal analgesia to reduce opioid exposure.','Convert to oral therapy as soon as pain and physiology permit.']),
    ]),
    _PainTopic('Sickle-cell vaso-occlusive pain', Icons.bloodtype_outlined, <_PainSection>[
      _PainSection('First hour', <String>['Assess promptly and initiate analgesia within 30–60 minutes. Exclude acute chest syndrome, infection, sequestration, osteomyelitis, avascular necrosis and other causes.','Give intranasal fentanyl 1–2 micrograms/kg (maximum 100 micrograms) when appropriate, followed by oral or IV opioid according to response.']),
      _PainSection('Ongoing treatment', <String>['Schedule acetaminophen and one NSAID when not contraindicated; do not combine oral and IV NSAIDs.','Morphine PO 0.2–0.5 mg/kg every 4–6 hours or IV 0.1 mg/kg slowly with reassessment; use patient-specific plans and local maxima.','Use maintenance—not hyperhydration—when IV fluids are needed; encourage oral intake, mobility, heat, incentive spirometry and bowel prophylaxis.']),
      _PainSection('Monitoring and escalation', <String>['Monitor SpO2, respiratory symptoms, fever and sedation. Chest, back or abdominal pain requires vigilance for acute chest syndrome.','Consult hematology for refractory pain, PCA/infusion, transfusion questions or complications.']),
    ]),
    _PainTopic('SJS/TEN pain', Icons.local_fire_department_outlined, <_PainSection>[
      _PainSection('Priorities', <String>['Treat as a dermatologic critical illness: stop suspected culprit drugs, involve dermatology/burn/PCCU early, protect skin and mucosa and minimize shear.','Pain may be severe and include cutaneous, ocular, oral and genitourinary components.']),
      _PainSection('Analgesia', <String>['Use scheduled acetaminophen when safe plus titrated IV opioid for severe pain.','Procedural pain (dressings, line care, examination) often requires anticipatory analgesia and sometimes procedural sedation.','Avoid NSAIDs when renal injury, bleeding or the suspected culprit medication makes them unsafe.']),
      _PainSection('Monitoring', <String>['Continuous respiratory monitoring with escalating opioids; assess hydration, temperature, infection, ocular pain and urinary retention.','Early ophthalmology and site-specific mucosal care are essential.']),
    ]),
    _PainTopic('Neuropathic pain', Icons.electric_bolt_outlined, <_PainSection>[
      _PainSection('Recognition', <String>['Burning, shooting, electric pain, allodynia or hyperalgesia suggests a neuropathic component.','Assess for nerve injury, infection, chemotherapy toxicity, spinal pathology and complex regional pain.']),
      _PainSection('Management', <String>['Use rehabilitation, sleep support and psychological strategies alongside medication.','Gabapentin or pregabalin may be considered with pain/neurology/pharmacy input; start low, titrate slowly and adjust for renal function.','Avoid abrupt discontinuation after sustained therapy.']),
      _PainSection('Escalation', <String>['Refer persistent or function-limiting pain to a pediatric chronic pain service.']),
    ]),
    _PainTopic('Post-operative pain', Icons.medical_services_outlined, <_PainSection>[
      _PainSection('Multimodal plan', <String>['Use scheduled acetaminophen and NSAID when permitted by the procedure and patient factors.','Use regional/local anesthetic techniques and non-pharmacologic measures when available.','Reserve opioids for breakthrough moderate–severe pain and use the lowest effective dose.']),
      _PainSection('Reassessment', <String>['Assess pain at rest and with movement, sedation, nausea, pruritus, urinary retention, bowel function and respiratory status.','Escalate unexpectedly severe or increasing pain because it may indicate a surgical complication.']),
    ]),
    _PainTopic('Opioid monitoring', Icons.monitor_heart_outlined, <_PainSection>[
      _PainSection('Before dosing', <String>['Confirm weight, opioid exposure, sleep-disordered breathing, neuromuscular disease, renal/hepatic function and concurrent sedatives.','Record baseline pain, sedation score, respiratory rate, SpO2 and blood pressure.']),
      _PainSection('After dosing', <String>['Reassess after IV dosing within minutes and after oral dosing within the expected onset window.','Use continuous pulse oximetry for high-risk children or repeated/parenteral dosing; capnography may be useful when deeply sedated or receiving PCA.','Sedation usually precedes respiratory arrest—hold opioid and escalate for increasing somnolence, snoring/obstruction, bradypnea or desaturation.']),
    ]),
    _PainTopic('Naloxone rescue', Icons.emergency_outlined, <_PainSection>[
      _PainSection('Immediate response', <String>['Call for help, open and support the airway, provide oxygen/ventilation and stop opioid administration.','For clinically significant opioid-induced respiratory depression, use naloxone according to the local resuscitation/formulary protocol.']),
      _PainSection('Dose concepts', <String>['A common emergency dose is 0.1 mg/kg IV/IM/IN in younger children or when complete reversal is required, subject to institutional maximums.','For iatrogenic oversedation where analgesia should be preserved, smaller titrated IV doses may be used under senior supervision.']),
      _PainSection('After reversal', <String>['Observe for recurrent toxicity because naloxone may wear off before the opioid. Repeat dosing or infusion may be required.','Expect acute pain, vomiting, agitation or withdrawal in opioid-tolerant patients.']),
    ]),
    _PainTopic('Opioid conversion', Icons.swap_horiz_outlined, <_PainSection>[
      _PainSection('Safety principles', <String>['Equianalgesic tables are estimates and vary by age, route, opioid exposure and clinical state.','Calculate the total opioid dose over the previous 24 hours, convert using an institutional pediatric table, then reduce the calculated new opioid dose for incomplete cross-tolerance—often by 25–50%—unless pain severity requires specialist adjustment.']),
      _PainSection('Do not automate', <String>['Avoid direct conversion of methadone, transdermal fentanyl or high-dose/chronic regimens without pain/palliative care/pharmacy expertise.','Reassess frequently after any conversion and provide a rescue-dose plan.']),
    ]),
    _PainTopic('Sedation and respiratory-risk check', Icons.air_outlined, <_PainSection>[
      _PainSection('High-risk features', <String>['Age under 6 months, obstructive sleep apnea, obesity, craniofacial anomaly, neuromuscular weakness, lung disease, renal/hepatic dysfunction, opioid naivety, concurrent benzodiazepine/antihistamine/gabapentinoid or escalating opioid dose.']),
      _PainSection('Actions', <String>['Use the lowest effective dose, avoid stacking sedatives, choose enhanced monitoring and ensure naloxone/airway equipment are available.','Obtain senior/PCCU/anesthesia review when risk is high or sedation is increasing.']),
    ]),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pediatric Pain Management')),
    body: ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: topics.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Clinician decision support. Verify weight, allergies, organ function, opioid exposure, local formulary and monitoring requirements before prescribing.'),
            ),
          );
        }
        final topic = topics[index - 1];
        return Card(child: ListTile(
          leading: CircleAvatar(child: Icon(topic.icon)),
          title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.w800)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _PainDetailScreen(topic: topic))),
        ));
      },
    ),
  );
}

class _PainTopic { final String title; final IconData icon; final List<_PainSection> sections; const _PainTopic(this.title, this.icon, this.sections); }
class _PainSection { final String title; final List<String> bullets; const _PainSection(this.title, this.bullets); }
class _PainDetailScreen extends StatelessWidget {
  final _PainTopic topic; const _PainDetailScreen({required this.topic});
  String get copyText => '${topic.title.toUpperCase()}\n${topic.sections.map((s) => '\n${s.title}\n${s.bullets.map((b) => '- $b').join('\n')}').join()}';
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(topic.title)),
    body: ListView(padding: const EdgeInsets.all(16), children: <Widget>[
      ...topic.sections.map((s) => Card(child: ExpansionTile(initiallyExpanded: true, title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w800)), children: s.bullets.map((b) => ListTile(leading: const Icon(Icons.check_circle_outline), title: Text(b))).toList()))),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: () async { await Clipboard.setData(ClipboardData(text: copyText)); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pain plan copied'))); }, icon: const Icon(Icons.copy), label: const Text('Copy pain plan')),
    ]),
  );
}
