// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'package:flutter/material.dart';

class EscalationScreen extends StatelessWidget {
  const EscalationScreen({super.key});

  static const Map<String, String> items = <String, String>{
    'Airway':
        'Stridor with fatigue, drooling/tripod posture, rapidly '
        'progressive swelling, recurrent apnea, inability to protect '
        'the airway, tracheostomy obstruction/dislodgement, or '
        'anticipated difficult airway.',
    'Breathing':
        'Severe work of breathing, silent/poor air entry, persistent '
        'hypoxemia, rapidly rising oxygen/HFNC/NIV, hypercapnia, '
        'recurrent apnea, or exhaustion.',
    'Circulation':
        'Shock, hypotension, weak pulses, abnormal perfusion, '
        'arrhythmia with poor perfusion, hypertensive emergency, '
        'major hemorrhage, or rapidly accumulating fluid overload.',
    'Neurologic':
        'Declining GCS, unequal pupils, focal deficit, status '
        'epilepticus, suspected cerebral injury/raised ICP, or acute '
        'bilirubin encephalopathy.',
    'Metabolic / renal':
        'Recurrent hypoglycemia, dangerous sodium/potassium/calcium, '
        'severe acidosis, anuria, pulmonary edema, or likely dialysis '
        'indication.',
    'Hematology / oncology':
        'Hyperleukocytosis symptoms, tumor lysis, DIC, acute chest '
        'syndrome deterioration, splenic sequestration, or severe '
        'transfusion reaction.',
    'Surgery / trauma':
        'Peritonitis, bilious vomiting with deterioration, ischemic '
        'limb/compartment signs, significant head/abdominal injury, '
        'or immediate safeguarding risk.',
    'Unit capability':
        'The child needs monitoring, oxygen, ventilation, vasoactive '
        'support, staffing, procedures, or reassessment frequency '
        'beyond the receiving unit.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escalate immediately')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Call the senior/staff and required bedside team at the '
            'same time when delay could harm the child.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...items.entries.map(
            (MapEntry<String, String> entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                color:
                    Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(entry.value),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

