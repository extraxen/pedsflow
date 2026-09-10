// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.

import 'package:flutter/material.dart';

import 'pager_mode_models.dart';

const Map<String, PagerDose> pagerDoses = <String, PagerDose>{
  'epinephrine_im': PagerDose(
    key: 'epinephrine_im',
    label: 'Epinephrine 1 mg/mL for anaphylaxis',
    amountPerKg: 0.01,
    amountUnit: 'mg',
    maximum: 0.5,
    route: 'IM into anterolateral thigh',
    concentration: '1 mg/mL: the calculated mg dose equals the mL volume',
    note: 'Repeat every 5 minutes if anaphylaxis persists while escalating resuscitation. Do not confuse with cardiac-arrest epinephrine concentration or route.',
  ),
  'crystalloid_10': PagerDose(
    key: 'crystalloid_10',
    label: 'Balanced crystalloid reassessment bolus',
    amountPerKg: 10,
    amountUnit: 'mL',
    route: 'IV/IO',
    note: 'Give only when clinically indicated, then reassess perfusion and signs of fluid overload. Smaller/slower aliquots may be required in cardiac or renal disease.',
  ),
  'crystalloid_20': PagerDose(
    key: 'crystalloid_20',
    label: 'Crystalloid bolus upper aliquot',
    amountPerKg: 20,
    amountUnit: 'mL',
    route: 'IV/IO',
    note: 'Use in an appropriate shock pathway with reassessment after every bolus; this is not an automatic fluid order.',
  ),
  'lorazepam_iv': PagerDose(
    key: 'lorazepam_iv',
    label: 'Lorazepam',
    amountPerKg: 0.1,
    amountUnit: 'mg',
    maximum: 4,
    route: 'IV',
    note: 'First-line benzodiazepine option for convulsive status epilepticus. Count any prehospital benzodiazepine doses and support airway/ventilation.',
  ),
  'midazolam_in': PagerDose(
    key: 'midazolam_in',
    label: 'Midazolam',
    amountPerKg: 0.2,
    amountUnit: 'mg',
    maximum: 10,
    route: 'IN/buccal/IM per local protocol',
    note: 'Use when IV access is unavailable or would delay treatment. Confirm the locally stocked concentration before calculating volume.',
  ),
  'dextrose_d10': PagerDose(
    key: 'dextrose_d10',
    label: 'Dextrose 10% initial bolus',
    amountPerKg: 2,
    amountUnit: 'mL',
    route: 'IV/IO over 5-10 minutes',
    note: 'For severe symptomatic hypoglycemia; recheck glucose promptly and begin ongoing glucose delivery as indicated. Neonatal pathways and local protocols may use different thresholds or volumes.',
  ),
};

const List<PagerTopic> pagerTopics = <PagerTopic>[
  PagerTopic(
    id: 'desaturation',
    title: 'New or worsening desaturation',
    subtitle: 'Low SpO2, increasing oxygen need, apnea or cyanosis',
    category: 'Airway & breathing',
    icon: Icons.air,
    urgency: PagerUrgency.immediate,
    aliases: <String>['low sats', 'hypoxemia', 'hypoxia', 'oxygen', 'cyanosis', 'apnea'],
    goNowIf: <String>[
      'Persistent or rapidly falling saturation, central cyanosis, apnea, severe work of breathing, exhaustion, altered consciousness, or escalating oxygen requirement.',
      'Known difficult airway, tracheostomy concern, or the bedside team says the child looks significantly worse.',
    ],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Current SpO2 and waveform quality; baseline saturation and target; room air versus device, flow and FiO2.',
        'Work of breathing, respiratory rate, air entry, colour, mental status, recent apnea/choking/vomiting, and whether this was sudden.',
        'Check probe position/perfusion and obtain a full set of vitals, but do not delay bedside review when the child appears unwell.',
      ]),
      PagerSection('First 5 minutes', <String>[
        'Go to bedside; assess airway, breathing, circulation and responsiveness. Call respiratory therapy and senior/staff early if unstable.',
        'Position airway, apply appropriate oxygen, attach continuous cardiorespiratory monitoring, and bring suction and airway equipment.',
        'Look, listen and feel for obstruction, stridor, wheeze, crackles, asymmetric entry, apnea, secretions or equipment failure.',
      ]),
      PagerSection('Focused assessment', <String>[
        'Review diagnosis, baseline respiratory support, sedating medications, fluid balance, aspiration risk and recent procedures/feeds.',
        'Inspect oxygen tubing and device connections. For tracheostomy patients, immediately assess patency and displacement using the local emergency algorithm.',
        'Consider bronchospasm, mucus plugging, atelectasis, pneumonia, aspiration, pneumothorax, pulmonary edema, hypoventilation, seizure or dyshemoglobinemia.',
      ]),
      PagerSection('Investigations', <String>[
        'Choose tests based on physiology: blood gas, glucose, chest radiograph, ECG, CBC/cultures or point-of-care ultrasound when they will change immediate management.',
        'A normal SpO2 does not exclude inadequate ventilation; obtain a gas/capnography when hypoventilation or hypercapnia is possible.',
      ]),
      PagerSection('Treat and reassess', <String>[
        'Treat the suspected cause while supporting oxygenation/ventilation; use the PCCU respiratory pathway for bronchodilator, HFNC/NIV or airway planning.',
        'Document response after every intervention: SpO2, device/FiO2, respiratory rate, work of breathing, air entry and mental status.',
      ]),
      PagerSection('Escalate now', <String>[
        'Unable to maintain target saturation, rapidly increasing support, severe/recurrent apnea, poor air entry, exhaustion, rising CO2, hemodynamic compromise or need beyond ward capability.',
      ]),
    ],
    sources: <String>['AHA Pediatric Advanced Life Support', 'Local oxygen, airway and rapid-response policies'],
  ),
  PagerTopic(
    id: 'work_of_breathing',
    title: 'Increased work of breathing',
    subtitle: 'Tachypnea, retractions, stridor, wheeze or poor air entry',
    category: 'Airway & breathing',
    icon: Icons.waves_outlined,
    urgency: PagerUrgency.immediate,
    aliases: <String>['respiratory distress', 'retractions', 'stridor', 'wheeze', 'tachypnea'],
    goNowIf: <String>[
      'Stridor at rest, drooling/tripod posture, silent chest, severe retractions, grunting, apnea, exhaustion, altered consciousness or poor perfusion.',
    ],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Onset and trajectory; respiratory rate; SpO2; oxygen device/flow; retractions, stridor, wheeze, grunting, cough and ability to speak/feed.',
        'Recent medication, choking, aspiration, allergen exposure, fever, fluid bolus/transfusion, opioid or sedative administration.',
      ]),
      PagerSection('First 5 minutes', <String>[
        'Bedside ABC assessment; keep the child calm and positioned for comfort. Apply oxygen and monitoring as indicated.',
        'Do not agitate a child with possible critical upper-airway obstruction. Call airway expertise early.',
        'Assess air entry before assuming that audible wheeze means adequate ventilation.',
      ]),
      PagerSection('Focused differential', <String>[
        'Upper airway: croup, bacterial tracheitis/epiglottitis, foreign body, anaphylaxis or tracheostomy obstruction.',
        'Lower airway/lung: asthma, bronchiolitis, pneumonia, aspiration, pneumothorax, effusion or pulmonary edema.',
        'Other: metabolic acidosis, sepsis, cardiac failure, neuromuscular weakness, pain/anxiety or medication effect.',
      ]),
      PagerSection('Investigations', <String>[
        'Investigations follow stabilization and suspected cause; consider gas, glucose, chest radiograph, ECG and infectious testing.',
        'Avoid sending an unstable child away from monitored care for imaging.',
      ]),
      PagerSection('Treat and reassess', <String>[
        'Use the matching PCCU pathway for asthma, croup, bronchiolitis, pneumonia, anaphylaxis, HFNC/NIV or intubation preparation.',
        'Reassess respiratory rate, effort, entry, SpO2/FiO2 and mental status after every treatment.',
      ]),
      PagerSection('Escalate now', <String>[
        'Worsening despite initial treatment, severe obstruction, silent/poor air entry, recurrent apnea, exhaustion, hypercapnia, increasing oxygen or non-invasive support.',
      ]),
    ],
    sources: <String>['AHA Pediatric Advanced Life Support', 'CPS/TREKK condition-specific emergency resources'],
  ),
  PagerTopic(
    id: 'tachycardia',
    title: 'Unexpected tachycardia',
    subtitle: 'Heart rate above expected range or suddenly increased',
    category: 'Circulation',
    icon: Icons.monitor_heart_outlined,
    urgency: PagerUrgency.urgent,
    aliases: <String>['fast heart rate', 'high heart rate', 'palpitations', 'svt'],
    goNowIf: <String>[
      'Poor perfusion, hypotension, altered consciousness, chest pain, severe respiratory distress, abrupt fixed-rate tachycardia or concern for SVT/ventricular arrhythmia.',
    ],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Exact heart rate, age, trend and onset; regular versus variable on the monitor; full vitals and current clinical appearance.',
        'Fever, pain, agitation, dehydration, bleeding, hypoxia, recent salbutamol/epinephrine, stimulant exposure or line/medication change.',
      ]),
      PagerSection('First 5 minutes', <String>[
        'Assess ABCs and perfusion: mental status, pulses, capillary refill, extremity temperature, blood pressure and urine output.',
        'Verify the rate manually, review the monitor tracing, obtain a 12-lead ECG during the event and place on continuous monitoring if significant.',
      ]),
      PagerSection('Focused assessment', <String>[
        'Look for sinus drivers: fever, pain, distress, hypovolemia, anemia, hypoxia, sepsis, medication effect or withdrawal.',
        'Abrupt onset/offset, very fixed rate and absent normal variability increase concern for SVT; use the Cardiology/PCCU arrhythmia pathway.',
      ]),
      PagerSection('Investigations', <String>[
        'ECG first when arrhythmia is possible. Consider glucose, electrolytes including Ca/Mg, CBC, gas/lactate, cultures and cardiac testing according to presentation.',
      ]),
      PagerSection('Treat and reassess', <String>[
        'Treat the cause rather than the number when rhythm is sinus. Avoid reflex fluid boluses without evidence of impaired preload/perfusion.',
        'For suspected unstable tachyarrhythmia, activate the resuscitation pathway and obtain synchronized cardioversion support immediately.',
      ]),
      PagerSection('Escalate now', <String>[
        'Any instability, wide-complex rhythm, suspected SVT not responding to initial pathway, myocarditis/cardiomyopathy concern or persistent unexplained tachycardia.',
      ]),
    ],
    sources: <String>['AHA Pediatric Advanced Life Support', 'PedsFlow Cardiology and ECG reference'],
  ),
  PagerTopic(
    id: 'poor_perfusion',
    title: 'Low blood pressure or poor perfusion',
    subtitle: 'Hypotension, delayed capillary refill, weak pulses or mottling',
    category: 'Circulation',
    icon: Icons.bloodtype_outlined,
    urgency: PagerUrgency.immediate,
    aliases: <String>['hypotension', 'shock', 'mottled', 'delayed cap refill', 'weak pulses'],
    goNowIf: <String>[
      'Hypotension for age, altered mental status, weak central pulses, prolonged capillary refill, cool/mottled extremities, oliguria, rising lactate or active hemorrhage.',
    ],
    doseKeys: <String>['crystalloid_10', 'crystalloid_20'],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Repeat BP manually with correct cuff; heart rate, respiratory status, temperature, mental status, capillary refill and urine output.',
        'Bleeding/fluid loss, fever, allergen/medication exposure, cardiac history, renal disease and fluids already received.',
      ]),
      PagerSection('First 5 minutes', <String>[
        'Go now; call senior/staff and bedside support. Assess ABCs, apply monitoring, give oxygen if needed and obtain IV/IO access.',
        'Check bedside glucose. Send time-critical bloodwork/cultures without delaying resuscitation.',
        'Identify hemorrhagic, distributive/septic, hypovolemic, cardiogenic or obstructive physiology.',
      ]),
      PagerSection('Investigations', <String>[
        'Blood gas/lactate, CBC, electrolytes/renal/liver function, glucose, cultures and coagulation/type and screen as indicated.',
        'Use ECG, chest radiograph and point-of-care ultrasound selectively; do not delay stabilization.',
      ]),
      PagerSection('Treat and reassess', <String>[
        'If fluid responsive physiology is likely, give 10-20 mL/kg crystalloid aliquots with reassessment after each. Stop/reduce for overload or cardiogenic features.',
        'Give syndrome-appropriate antimicrobials urgently for suspected septic shock and epinephrine IM immediately for anaphylaxis.',
        'Track mental status, pulses, refill, BP, urine output, lactate and signs of fluid overload.',
      ]),
      PagerSection('Prepare next steps', <String>[
        'Anticipate vasoactive support, additional access, blood products/source control and PCCU transfer when shock persists.',
      ]),
      PagerSection('Escalate now', <String>[
        'All suspected shock, persistent abnormal perfusion after initial intervention, fluid intolerance, need for vasoactive support or active major hemorrhage.',
      ]),
    ],
    sources: <String>['Surviving Sepsis Campaign pediatric guidelines', 'AHA Pediatric Advanced Life Support'],
  ),
  PagerTopic(
    id: 'fever',
    title: 'New fever or rigors',
    subtitle: 'Temperature spike in an admitted child',
    category: 'General & infectious',
    icon: Icons.thermostat_outlined,
    urgency: PagerUrgency.urgent,
    aliases: <String>['temperature', 'febrile', 'rigors', 'sepsis', 'line infection'],
    goNowIf: <String>[
      'Toxic appearance, abnormal perfusion, hypotension, altered consciousness, respiratory compromise, petechiae/purpura, severe pain, immunocompromise or age under 3 months.',
    ],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Temperature and route, complete vitals, appearance, perfusion, respiratory status, mental status and urine output.',
        'Age, immune status, central line/device, recent procedure, current antimicrobials, cultures already obtained and antipyretics given.',
      ]),
      PagerSection('First assessment', <String>[
        'Assess ABCs and sepsis physiology before focusing on the fever number.',
        'Perform a source-directed exam including line sites, skin, respiratory, abdomen, joints/bones and neurologic findings.',
      ]),
      PagerSection('Investigations', <String>[
        'Testing is risk and source based. Consider blood cultures (including line lumens), urine, respiratory testing, CBC, CRP, electrolytes, gas/lactate and imaging.',
        'Follow neonatal fever, febrile neutropenia, sickle cell, central-line or postoperative protocols when applicable.',
      ]),
      PagerSection('Treat', <String>[
        'Obtain appropriate cultures promptly, but do not delay antibiotics in an unstable child.',
        'Choose empiric antimicrobials from the relevant PedsFlow plan and local antibiogram/order set.',
        'Provide comfort/antipyresis when appropriate while continuing physiologic reassessment.',
      ]),
      PagerSection('Reassess', <String>[
        'Document vitals, perfusion, mental status, intake/output and response. Review cultures and antimicrobial timing/doses.',
      ]),
      PagerSection('Escalate now', <String>[
        'Sepsis/shock physiology, rapidly progressive rash, meningism/encephalopathy, neutropenia/immunocompromise, young infant or deterioration despite therapy.',
      ]),
    ],
    sources: <String>['CPS fever and serious bacterial infection guidance', 'TREKK sepsis resources', 'Local antimicrobial pathways'],
  ),
  PagerTopic(
    id: 'altered_mental_status',
    title: 'Difficult to wake or altered behaviour',
    subtitle: 'New lethargy, confusion, agitation or reduced responsiveness',
    category: 'Neurologic',
    icon: Icons.psychology_alt_outlined,
    urgency: PagerUrgency.immediate,
    aliases: <String>['altered loc', 'lethargy', 'confusion', 'unresponsive', 'decreased gcs', 'agitation'],
    goNowIf: <String>[
      'Reduced or falling GCS, inability to protect airway, hypoventilation, unequal pupils, focal deficit, seizure, severe headache/vomiting or abnormal perfusion.',
    ],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Exact change from baseline and time last normal; responsiveness, pupils, breathing, full vitals and recent seizure/fall.',
        'Recent opioids/sedatives/insulin, access to toxins, diabetes/metabolic disease, fluid balance and sodium risk.',
      ]),
      PagerSection('First 5 minutes', <String>[
        'Go now; assess airway/ventilation, circulation, GCS/AVPU and pupils. Apply monitoring and check point-of-care glucose immediately.',
        'Treat hypoxia, hypoglycemia, seizure and shock without waiting for definitive diagnosis.',
        'Consider naloxone when opioid toxicity is plausible and support ventilation first.',
      ]),
      PagerSection('Focused assessment', <String>[
        'Look for meningism, focal findings, raised-ICP signs, trauma, toxidrome, dehydration/edema and medication errors.',
        'Review MAR, recent PRNs, infusion pumps, renal/hepatic function and laboratory trends.',
      ]),
      PagerSection('Investigations', <String>[
        'Glucose first; then gas, electrolytes including Ca/Mg, CBC, cultures, liver function/ammonia, toxicology tests and imaging/LP as clinically indicated.',
        'Do not delay airway/resuscitation or urgent neuroimaging for broad laboratory panels.',
      ]),
      PagerSection('Treat and reassess', <String>[
        'Treat the identified reversible cause and trend GCS, pupils, ventilation, vitals and glucose.',
        'Use the raised-ICP/status epilepticus/toxicology pathway when suspected.',
      ]),
      PagerSection('Escalate now', <String>[
        'Any falling consciousness, focal deficit, abnormal pupils, recurrent seizure, suspected raised ICP, respiratory depression or unexplained persistent alteration.',
      ]),
    ],
    sources: <String>['AHA Pediatric Advanced Life Support', 'CPS/TREKK neurologic emergency resources'],
  ),
  PagerTopic(
    id: 'seizure',
    title: 'Active seizure or recurrent seizures',
    subtitle: 'Convulsion lasting 5 minutes or repeated without recovery',
    category: 'Neurologic',
    icon: Icons.electric_bolt_outlined,
    urgency: PagerUrgency.immediate,
    aliases: <String>['status epilepticus', 'convulsion', 'fit', 'seizing'],
    goNowIf: <String>[
      'Active seizure approaching or beyond 5 minutes, repeated seizures without recovery, respiratory compromise, trauma, pregnancy or concern for raised ICP.',
    ],
    doseKeys: <String>['lorazepam_iv', 'midazolam_in'],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Start time, current activity, recovery between events, oxygenation/breathing and benzodiazepine doses already given.',
        'Known epilepsy/rescue plan, weight, access, glucose, fever, trauma, possible ingestion and missed medications.',
      ]),
      PagerSection('First 5 minutes', <String>[
        'Activate bedside help; protect from injury, position/suction airway, provide oxygen, monitor and check glucose.',
        'Treat convulsive status at 5 minutes. Give a first-line benzodiazepine by the fastest reliable route; do not wait for IV access.',
        'Count prehospital/home benzodiazepines. Prepare ventilation support and second-line antiseizure medication early.',
      ]),
      PagerSection('Medication sequence', <String>[
        'Use IV lorazepam 0.1 mg/kg (max 4 mg) or non-IV midazolam 0.2 mg/kg (max 10 mg) per local route/concentration protocol.',
        'If still seizing 5 minutes after the first adequate dose, give the second benzodiazepine dose per pathway, then move promptly to second-line therapy.',
        'Avoid repeated benzodiazepine stacking beyond the pathway because respiratory depression increases and second-line treatment is delayed.',
      ]),
      PagerSection('Investigations and causes', <String>[
        'Glucose, electrolytes/Ca/Mg, antiseizure levels when useful, toxicology/infection evaluation and imaging/LP according to context.',
        'Treat hypoglycemia, electrolyte disturbance, meningitis/encephalitis, toxin or raised ICP when suspected.',
      ]),
      PagerSection('Reassess', <String>[
        'Confirm clinical and electrographic recovery when relevant; monitor airway, ventilation, GCS, temperature and recurrent events.',
      ]),
      PagerSection('Escalate now', <String>[
        'Status epilepticus, failure of first-line therapy, respiratory depression, focal/prolonged event, persistent altered consciousness or need for continuous infusion/intubation.',
      ]),
    ],
    sources: <String>['Canadian Paediatric Society: Emergency management of convulsive status epilepticus in children (2021)', 'Local status epilepticus order set'],
  ),
  PagerTopic(
    id: 'oliguria',
    title: 'Reduced urine output',
    subtitle: 'Oliguria, anuria or a new fall in output',
    category: 'Renal & fluids',
    icon: Icons.water_drop_outlined,
    urgency: PagerUrgency.assess,
    aliases: <String>['oliguria', 'anuria', 'no urine', 'low urine output', 'aki'],
    goNowIf: <String>[
      'Anuria, shock/poor perfusion, respiratory distress/pulmonary edema, severe hypertension, gross hematuria, dangerous potassium or rapidly rising creatinine.',
    ],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Measured output in mL and mL/kg/hr, duration, method of collection, last void, fluid intake and balance.',
        'Full vitals, perfusion, weight change, edema, vomiting/diarrhea, nephrotoxins, urinary catheter and renal/cardiac history.',
      ]),
      PagerSection('First assessment', <String>[
        'Confirm measurement and catheter patency/kinks. Assess perfusion and volume status rather than assuming dehydration.',
        'Examine for bladder distension, edema, respiratory crackles, hepatomegaly and hypertension.',
      ]),
      PagerSection('Focused differential', <String>[
        'Pre-renal: inadequate intake/losses, sepsis or low cardiac output.',
        'Intrinsic: nephritis, ATN, HUS, nephrotoxin or tumor lysis.',
        'Post-renal: retention, blocked catheter, stone or structural obstruction.',
      ]),
      PagerSection('Investigations', <String>[
        'Repeat renal function/electrolytes, urinalysis and urine studies when useful; consider bladder scan and renal ultrasound.',
        'Review medication doses and all nephrotoxic exposures. Obtain ECG urgently if hyperkalemia is suspected or confirmed.',
      ]),
      PagerSection('Treat and reassess', <String>[
        'Correct the cause. Give fluid only when hypovolemia is supported; reassess after any aliquot and avoid automatic repeated boluses.',
        'Strict intake/output, daily/current weight and serial electrolytes/creatinine. Adjust medications and fluids for renal function.',
      ]),
      PagerSection('Escalate now', <String>[
        'Anuria, refractory fluid overload, pulmonary edema, severe electrolyte/acidosis abnormality, hypertensive emergency or possible dialysis indication.',
      ]),
    ],
    sources: <String>['KDIGO acute kidney injury principles', 'Local nephrology, fluid and catheter policies'],
  ),
  PagerTopic(
    id: 'vomiting',
    title: 'Repeated or concerning vomiting',
    subtitle: 'Persistent emesis, inability to tolerate fluids or changed vomit',
    category: 'Gastrointestinal',
    icon: Icons.sick_outlined,
    urgency: PagerUrgency.urgent,
    aliases: <String>['emesis', 'bilious', 'coffee ground', 'hematemesis', 'cyclic vomiting'],
    goNowIf: <String>[
      'Bilious, bloody or coffee-ground emesis; severe/distended abdomen; peritonism; altered consciousness; severe headache; shock; or suspected obstruction, DKA or raised ICP.',
    ],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Number, timing, volume and colour/content of vomits; pain/distension; stool/flatus; headache/neurologic change and urine output.',
        'Current feeds/IV fluids, medications and antiemetics already given, surgery history, diabetes/metabolic disease and pregnancy possibility when relevant.',
      ]),
      PagerSection('First assessment', <String>[
        'Assess ABCs, hydration/perfusion, mental status, glucose and abdominal findings.',
        'Inspect the emesis or photograph/document its appearance when possible; do not label dark emesis as benign without assessment.',
      ]),
      PagerSection('Investigations', <String>[
        'Target testing to the differential: glucose/ketones, electrolytes/gas, CBC, lipase/liver tests, urinalysis/pregnancy testing, cultures or imaging.',
        'Urgent surgical imaging/consultation for bilious emesis, obstruction, peritonism or acute abdomen.',
      ]),
      PagerSection('Treat', <String>[
        'Pause unsafe oral/enteral intake when obstruction, aspiration or neurologic compromise is possible. Correct fluid/electrolyte deficits thoughtfully.',
        'Open the Persistent vomiting / cyclic vomiting admission plan for stepwise antiemetic choices, contraindications and QT/EPS/sedation cautions.',
      ]),
      PagerSection('Reassess', <String>[
        'Track emesis, pain, abdominal/neurologic findings, intake/output, glucose and response to each intervention.',
      ]),
      PagerSection('Escalate now', <String>[
        'Concerning emesis colour, acute abdomen, shock, worsening neurologic signs, severe metabolic disturbance or failure of ward-level hydration/symptom control.',
      ]),
    ],
    sources: <String>['PedsFlow Persistent vomiting / cyclic vomiting plan', 'CPS/TREKK condition-specific guidance'],
  ),
  PagerTopic(
    id: 'hypoglycemia',
    title: 'Low bedside glucose',
    subtitle: 'Symptomatic or confirmed hypoglycemia',
    category: 'Metabolic',
    icon: Icons.battery_alert_outlined,
    urgency: PagerUrgency.immediate,
    aliases: <String>['low sugar', 'low glucose', 'hypoglycaemia', 'dextrose', 'glucagon'],
    goNowIf: <String>[
      'Altered consciousness, seizure, inability to take oral carbohydrate, recurrent low glucose, suspected adrenal/metabolic disease or abnormal perfusion.',
    ],
    doseKeys: <String>['dextrose_d10'],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Exact glucose, symptoms, repeat confirmation, age/weight, last intake, IV access and treatment already given.',
        'Diabetes/insulin, adrenal or metabolic disease, fasting/vomiting, sepsis, liver disease and medication exposure.',
      ]),
      PagerSection('First 5 minutes', <String>[
        'Go now for symptoms or severe/recurrent low glucose. Assess ABCs and treat promptly.',
        'If alert and safe to swallow, give rapid oral carbohydrate per local pathway. If unable to take orally, use IV/IO dextrose; use glucagon when access is delayed and appropriate.',
        'Obtain a critical sample before glucose only when this can be done immediately without delaying treatment.',
      ]),
      PagerSection('IV treatment', <String>[
        'A common severe-hypoglycemia option beyond the neonatal period is D10W 2 mL/kg IV/IO over 5-10 minutes; follow the active local age-specific pathway.',
        'Recheck glucose in approximately 10-15 minutes and repeat/escalate treatment if still low.',
      ]),
      PagerSection('Prevent recurrence', <String>[
        'Provide longer-acting carbohydrate when safe, or start a dextrose-containing infusion/feeds appropriate to the cause.',
        'Review insulin and other glucose-lowering medications before the next scheduled dose.',
      ]),
      PagerSection('Investigations', <String>[
        'When unexplained/recurrent, consider critical glucose, insulin/C-peptide, beta-hydroxybutyrate, cortisol, growth hormone, lactate, ammonia, free fatty acids and acylcarnitine studies per endocrine/metabolic guidance.',
      ]),
      PagerSection('Escalate now', <String>[
        'Seizure/altered consciousness, persistent or recurrent hypoglycemia, high glucose-infusion requirement, suspected adrenal crisis, hyperinsulinism, liver failure or metabolic disease.',
      ]),
    ],
    sources: <String>['ISPAD hypoglycemia guidance', 'Pediatric endocrine emergency pathways', 'Local neonatal and pediatric hypoglycemia protocols'],
  ),
  PagerTopic(
    id: 'anaphylaxis',
    title: 'Possible medication reaction or anaphylaxis',
    subtitle: 'New rash, swelling, wheeze, vomiting or hypotension after exposure',
    category: 'Allergy & medication',
    icon: Icons.warning_amber_rounded,
    urgency: PagerUrgency.immediate,
    aliases: <String>['allergic reaction', 'hives', 'urticaria', 'angioedema', 'epinephrine', 'anaphylactic'],
    goNowIf: <String>[
      'Airway swelling/voice change, stridor, wheeze/hypoxemia, repetitive vomiting with systemic symptoms, hypotension, collapse or rapidly progressive multisystem reaction.',
    ],
    doseKeys: <String>['epinephrine_im', 'crystalloid_10', 'crystalloid_20'],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Symptoms and systems involved, timing/progression, suspected exposure, full vitals and whether epinephrine has already been given.',
        'Weight, IV access, asthma history, prior anaphylaxis and relevant medications.',
      ]),
      PagerSection('First 5 minutes', <String>[
        'Stop the suspected exposure/infusion. Call bedside help and assess ABCs.',
        'Give epinephrine 1 mg/mL at 0.01 mg/kg IM into the anterolateral thigh (max 0.5 mg) immediately when anaphylaxis is suspected.',
        'Position appropriately, provide high-flow oxygen, monitoring and IV/IO access. Do not allow sudden standing/walking.',
      ]),
      PagerSection('Ongoing resuscitation', <String>[
        'Repeat IM epinephrine every 5 minutes if symptoms persist. Give 10-20 mL/kg crystalloid aliquots for shock with reassessment.',
        'Bronchodilator may treat persistent bronchospasm but does not replace epinephrine.',
        'Antihistamines and corticosteroids are adjuncts; they do not treat airway obstruction or shock and must not delay epinephrine.',
      ]),
      PagerSection('Refractory reaction', <String>[
        'Escalate urgently for repeated epinephrine, persistent shock/airway symptoms or infusion therapy; prepare advanced airway support with experienced help.',
        'Consider glucagon with specialist/resuscitation support when beta-blockade contributes to refractory shock.',
      ]),
      PagerSection('Observe and document', <String>[
        'Record trigger, timing, systems, epinephrine doses/routes, response and recurrence. Follow the local observation/disposition pathway.',
      ]),
      PagerSection('Escalate now', <String>[
        'All anaphylaxis, airway involvement, hypotension, repeated epinephrine, biphasic deterioration or uncertainty with progressive symptoms.',
      ]),
    ],
    sources: <String>['Public Health Agency of Canada epinephrine dosing guidance (2023)', 'AHA Pediatric Advanced Life Support', 'Local anaphylaxis pathway'],
  ),
  PagerTopic(
    id: 'extravasation',
    title: 'IV infiltrate or extravasation',
    subtitle: 'Swelling, pain, blanching or poor infusion around vascular access',
    category: 'Lines & medication',
    icon: Icons.vaccines_outlined,
    urgency: PagerUrgency.urgent,
    aliases: <String>['infiltration', 'iv swollen', 'extravasated', 'vesicant', 'central line leak'],
    goNowIf: <String>[
      'Vesicant/vasoactive infusion, rapidly progressive swelling, severe pain, blistering, pallor/coolness, delayed capillary refill, weak pulse, sensory/motor change or concern for compartment syndrome.',
    ],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Exact medication/fluid, concentration, infusion rate, estimated volume, time discovered and whether the infusion has stopped.',
        'Site appearance, pain, swelling, colour, temperature, capillary refill, pulse and distal movement/sensation.',
      ]),
      PagerSection('Immediate actions', <String>[
        'Stop the infusion immediately. Disconnect tubing. Leave the cannula in place initially for aspiration or antidote unless the local protocol directs otherwise.',
        'Do not flush. Elevate the limb when appropriate. Mark/photograph/measure the affected area according to policy.',
        'Notify pharmacy promptly to identify vesicant properties, compress type and antidote/extravasation pathway.',
      ]),
      PagerSection('Focused assessment', <String>[
        'Perform and document distal neurovascular examination: pulses, capillary refill, colour, temperature, swelling, pain and motor/sensory function.',
        'Confirm whether peripheral, midline, PICC or central access is involved and assess device position/function.',
      ]),
      PagerSection('Medication-specific care', <String>[
        'Use the institutional extravasation monograph for aspiration, warm versus cold compress, antidote, plastic surgery/wound consultation and monitoring.',
        'Do not improvise an antidote or compress because management differs by infusate.',
      ]),
      PagerSection('Reassess', <String>[
        'Serially document area size, skin changes, pain and neurovascular status. Arrange alternate access before restarting essential therapy.',
      ]),
      PagerSection('Escalate now', <String>[
        'Any neurovascular compromise, compartment concern, tissue injury/blistering, large-volume infiltration, central-line complication or vasoactive/vesicant extravasation.',
      ]),
    ],
    sources: <String>['Local LHSC extravasation and vascular-access policies', 'Drug-specific pharmacy monographs'],
  ),
  PagerTopic(
    id: 'acute_pain',
    title: 'New or uncontrolled pain',
    subtitle: 'Pain despite PRNs, new chest/abdominal/limb pain or sudden change',
    category: 'General & infectious',
    icon: Icons.healing_outlined,
    urgency: PagerUrgency.assess,
    aliases: <String>['breakthrough pain', 'chest pain', 'abdominal pain', 'limb pain', 'pain crisis'],
    goNowIf: <String>[
      'Severe sudden pain, abnormal vitals/perfusion, rigid abdomen, neurologic or neurovascular change, chest pain with exertion/syncope, sickle-cell chest symptoms, postoperative deterioration or pain out of proportion.',
    ],
    sections: <PagerSection>[
      PagerSection('Ask on the phone', <String>[
        'Location, severity using an age-appropriate scale, onset/character, associated symptoms and change from baseline.',
        'Full vitals, recent procedure/injury, analgesics with exact doses/times, response and sedation/respiratory score.',
      ]),
      PagerSection('First assessment', <String>[
        'Assess ABCs and the painful area; look specifically for time-critical causes before escalating analgesia alone.',
        'Review allergies, renal/hepatic function, total acetaminophen/NSAID/opioid exposure and concurrent sedatives.',
      ]),
      PagerSection('Treat', <String>[
        'Use multimodal analgesia and the PedsFlow Pediatric Pain Management pathway. Continue non-pharmacologic comfort measures.',
        'For opioids, prescribe appropriate monitoring and reassessment; avoid unsafe sedative stacking and have naloxone/resuscitation support available when indicated.',
      ]),
      PagerSection('Investigations', <String>[
        'Direct testing to the suspected cause. Consider ECG for concerning chest pain, imaging/surgical review for acute abdomen or limb compromise, and sickle-cell investigations for chest symptoms/fever.',
      ]),
      PagerSection('Reassess', <String>[
        'Reassess pain score, function, vitals, sedation and adverse effects within a route-appropriate interval after medication.',
        'Failure to respond should trigger diagnostic reassessment, not automatic repeated dosing.',
      ]),
      PagerSection('Escalate now', <String>[
        'Pain with physiologic deterioration, acute abdomen, compartment/neurovascular signs, cardiopulmonary symptoms, excessive sedation or uncontrolled pain after an appropriate plan.',
      ]),
    ],
    sources: <String>['PedsFlow Pediatric Pain Management', 'Local acute pain service and opioid monitoring policies'],
  ),
];

PagerTopic? pagerTopicById(String id) {
  for (final PagerTopic topic in pagerTopics) {
    if (topic.id == id) return topic;
  }
  return null;
}
