import 'package:flutter/material.dart';

import '../models/admission_plan.dart';
import '../models/medication_monograph.dart';
import '../services/app_store.dart';
import '../services/search_normalizer.dart';
import '../widgets/plan_tile.dart';
import 'calculators_screen.dart';
import 'pain_management_screen.dart';
import 'pccu_screen.dart';

class UniversalSearchScreen extends StatefulWidget {
  final AppStore store;

  const UniversalSearchScreen({super.key, required this.store});

  @override
  State<UniversalSearchScreen> createState() => _UniversalSearchScreenState();
}

class _UniversalSearchScreenState extends State<UniversalSearchScreen> {
  static const List<String> pccuTopics = <String>[
    'Severe asthma',
    'Status asthmaticus',
    'Bronchiolitis requiring HFNC',
    'Pediatric ARDS',
    'Septic shock',
    'Status epilepticus',
    'Raised intracranial pressure',
    'Cerebral edema in DKA',
    'Pediatric rapid-sequence intubation',
    'High-flow nasal cannula',
    'CPAP and BiPAP basics',
    'Non-invasive ventilation troubleshooting',
    'Vasoactive selection',
    'Continuous sedation',
    'Neuromuscular blockade',
    'Ketamine',
  ];

  static const List<String> calculators = <String>[
    'Pediatric DKA',
    'PCCU & critical care',
    'Maintenance fluids',
    'Hypernatremic dehydration',
    'Medication dose',
    'Corrected sodium',
    'Anion gap',
    'Corrected calcium',
    'Body surface area',
    'QTc',
    'Glucose infusion rate',
    'Free-water deficit',
    'P/F ratio',
  ];

  static const List<String> emergencies = <String>[
    'Status epilepticus',
    'Sepsis',
    'Anaphylaxis',
    'DKA',
    'Hyperkalemia',
    'Raised intracranial pressure',
    'Toxic ingestion',
  ];

  final TextEditingController _controller = TextEditingController();
  late final Map<AdmissionPlan, String> _planSearchText;
  late final Map<MedicationMonograph, String> _medicationSearchText;
  String query = '';

  @override
  void initState() {
    super.initState();
    _planSearchText = <AdmissionPlan, String>{
      for (final AdmissionPlan plan in widget.store.plans)
        plan: <String>[plan.title, plan.category, ...plan.aliases]
            .join(' ')
            .toLowerCase(),
    };
    _medicationSearchText = <MedicationMonograph, String>{
      for (final MedicationMonograph medication in widget.store.medications)
        medication: <String>[
          medication.name,
          medication.category,
          ...medication.aliases,
          medication.summary,
        ].join(' ').toLowerCase(),
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String normalizedQuery = SearchNormalizer.normalize(query);

    final List<AdmissionPlan> plans = normalizedQuery.isEmpty
        ? <AdmissionPlan>[]
        : widget.store.plans
            .where(
              (AdmissionPlan plan) => SearchNormalizer.matches(
                _planSearchText[plan] ?? '',
                normalizedQuery,
              ),
            )
            .toList()
      ..sort(
        (AdmissionPlan a, AdmissionPlan b) => SearchNormalizer.rank(
          a.title,
          normalizedQuery,
        ).compareTo(SearchNormalizer.rank(b.title, normalizedQuery)),
      );

    final List<MedicationMonograph> medications = normalizedQuery.isEmpty
        ? <MedicationMonograph>[]
        : widget.store.medications
            .where(
              (MedicationMonograph medication) => SearchNormalizer.matches(
                _medicationSearchText[medication] ?? '',
                normalizedQuery,
              ),
            )
            .toList()
      ..sort(
        (MedicationMonograph a, MedicationMonograph b) =>
            SearchNormalizer.rank(a.name, normalizedQuery).compareTo(
          SearchNormalizer.rank(b.name, normalizedQuery),
        ),
      );

    final List<String> pccu = normalizedQuery.isEmpty
        ? <String>[]
        : pccuTopics
            .where(
              (String topic) =>
                  SearchNormalizer.matches(topic, normalizedQuery),
            )
            .toList();
    final List<String> calculatorResults = normalizedQuery.isEmpty
        ? <String>[]
        : calculators
            .where(
              (String calculator) =>
                  SearchNormalizer.matches(calculator, normalizedQuery),
            )
            .toList();
    final List<String> emergencyResults = normalizedQuery.isEmpty
        ? <String>[]
        : emergencies
            .where(
              (String emergency) =>
                  SearchNormalizer.matches(emergency, normalizedQuery),
            )
            .toList();

    final bool painMatch = SearchNormalizer.matches(
      'pain analgesia opioid naloxone sickle cell sjs ten neuropathic postoperative',
      normalizedQuery,
    );
    final bool hasResults = plans.isNotEmpty ||
        medications.isNotEmpty ||
        pccu.isNotEmpty ||
        calculatorResults.isNotEmpty ||
        emergencyResults.isNotEmpty ||
        painMatch;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search PedsFlow',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: <Widget>[
            Semantics(
              textField: true,
              label: 'Search PedsFlow clinical content',
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (String value) => setState(() => query = value),
                decoration: InputDecoration(
                  hintText:
                      'Search diagnoses, medications, calculators or PCCU...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _controller.clear();
                            setState(() => query = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                ),
              ),
            ),
            if (normalizedQuery.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(22),
                    child: Text(
                      'Try “vomitting”, “Gravol”, “Zofran”, “hypoK”, “PNA”, '
                      '“ICP”, “CHS”, “DKA” or “status asthma”.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else ...<Widget>[
              if (plans.isNotEmpty) ...<Widget>[
                _heading('Admission plans', plans.length, Icons.assignment_outlined),
                ...plans.take(20).map(
                      (AdmissionPlan plan) => PlanTile(
                        plan: plan,
                        store: widget.store,
                      ),
                    ),
              ],
              if (medications.isNotEmpty) ...<Widget>[
                _heading(
                  'Medications',
                  medications.length,
                  Icons.medication_outlined,
                ),
                ...medications.take(30).map(
                      (MedicationMonograph medication) => Card(
                        child: ExpansionTile(
                          title: Text(
                            medication.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(medication.category),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SelectableText(medication.summary),
                            ),
                            if (medication.doseSections.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: SelectableText(
                                  medication.doseSections
                                      .take(2)
                                      .map(
                                        (dynamic dose) =>
                                            '${dose.title}: ${dose.text}',
                                      )
                                      .join('\n\n'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
              ],
              if (pccu.isNotEmpty) ...<Widget>[
                _heading('PCCU topics', pccu.length, Icons.monitor_heart_outlined),
                ...pccu.map(
                  (String topic) => _navTile(
                    context,
                    topic,
                    Icons.monitor_heart_outlined,
                    () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PccuTopicScreen(title: topic),
                      ),
                    ),
                  ),
                ),
              ],
              if (calculatorResults.isNotEmpty) ...<Widget>[
                _heading(
                  'Calculators',
                  calculatorResults.length,
                  Icons.calculate_outlined,
                ),
                ...calculatorResults.map(
                  (String calculator) => _navTile(
                    context,
                    calculator,
                    Icons.calculate_outlined,
                    () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CalculatorsScreen(),
                      ),
                    ),
                  ),
                ),
              ],
              if (emergencyResults.isNotEmpty) ...<Widget>[
                _heading(
                  'Emergency pathways',
                  emergencyResults.length,
                  Icons.emergency_outlined,
                ),
                ...emergencyResults.map(
                  (String emergency) => _navTile(
                    context,
                    emergency,
                    Icons.emergency_outlined,
                    () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PccuTopicScreen(title: emergency),
                      ),
                    ),
                  ),
                ),
              ],
              if (painMatch)
                _navTile(
                  context,
                  'Pediatric pain management',
                  Icons.healing_outlined,
                  () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PainManagementScreen(),
                    ),
                  ),
                ),
              if (!hasResults)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(22),
                      child: Text(
                        'No matching content found. Try a diagnosis, brand name, '
                        'abbreviation, or common spelling variation.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _heading(String title, int count, IconData icon) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Row(
          children: <Widget>[
            Icon(icon),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Chip(label: Text('$count')),
          ],
        ),
      );

  Widget _navTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) =>
      Semantics(
        button: true,
        label: 'Open $title',
        child: Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap,
          ),
        ),
      );
}
