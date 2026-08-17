import 'dart:async';

import 'package:flutter/material.dart';

import '../features/bilirubin/bilirubin_screen.dart';
import '../features/dka/dka_calculator_screen.dart';
import '../models/admission_plan.dart';
import '../models/medication_monograph.dart';
import '../services/app_store.dart';
import '../services/global_search.dart';
import 'antibiotic_guide_screen.dart';
import 'calculators_screen.dart';
import 'clinical_sources_screen.dart';
import 'escalation_screen.dart';
import 'integrated_clinical_support_screen.dart';
import 'library_screen.dart';
import 'medication_quality_screen.dart';
import 'medication_reference_screen.dart';
import 'medications_screen.dart';
import 'more_screen.dart';
import 'pain_management_screen.dart';
import 'pccu_screen.dart';
import 'pediatric_reference_screen.dart';
import 'plan_screen.dart';

class UniversalSearchScreen extends StatefulWidget {
  final AppStore store;
  const UniversalSearchScreen({super.key, required this.store});
  @override State<UniversalSearchScreen> createState() => _UniversalSearchScreenState();
}

class _UniversalSearchScreenState extends State<UniversalSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  GlobalSearchIndex? _index;
  List<SearchHit> _hits = const [];
  String _filter = 'all';
  Timer? _debounce;
  String _query = '';

  static const List<(String, String)> _filters = <(String, String)>[
    ('all','All'), ('pccu','PCCU'), ('medication','Medications'), ('plan','Plans'),
    ('calculators','Calculators'), ('antibiotic','Antibiotics'), ('pain','Pain'),
  ];

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final GlobalSearchIndex index = await GlobalSearchIndex.build(widget.store);
    if (!mounted) return;
    setState(() { _index = index; _runSearch(); });
  }
  @override void dispose() { _debounce?.cancel(); _controller.dispose(); super.dispose(); }

  void _onChanged(String value) {
    _query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 90), () { if (mounted) setState(_runSearch); });
  }
  void _runSearch() { _hits = _index?.search(_query, kind: _filter) ?? const []; }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search all PedsFlow', style: TextStyle(fontWeight: FontWeight.w900))),
      body: SafeArea(child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          TextField(
            controller: _controller, autofocus: true, textInputAction: TextInputAction.search,
            autocorrect: false, enableSuggestions: false, onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: 'Search any diagnosis, drug, dose, pathway, calculator or phrase…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty ? null : IconButton(onPressed: () { _controller.clear(); setState(() { _query=''; _hits=const []; }); }, icon: const Icon(Icons.clear)),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _filters.map((f) => Padding(
            padding: const EdgeInsets.only(right: 7), child: ChoiceChip(label: Text(f.$2), selected: _filter == f.$1,
              onSelected: (_) => setState(() { _filter=f.$1; _runSearch(); })),)).toList())),
          if (_index == null) const Padding(padding: EdgeInsets.only(top: 28), child: Center(child: CircularProgressIndicator()))
          else if (_query.trim().isEmpty) ...<Widget>[
            const SizedBox(height: 24),
            const Card(child: Padding(padding: EdgeInsets.all(18), child: Column(children: <Widget>[
              Text('Full-app search', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              SizedBox(height: 8),
              Text('Searches admission-plan text, medication doses and warnings, PCCU pathways, calculators, pain content, antibiotics and organisms, emergency guidance, references, saved algorithm notes, and other clinical pages.', textAlign: TextAlign.center),
              SizedBox(height: 12),
              Text('Try: “nimbex infusion”, “lp ketamine”, “campylobacter”, “hyperK ECG”, “CPS bilirubin”, “status asthma magnesium”.', textAlign: TextAlign.center),
            ]))),
          ] else if (_hits.isEmpty) ...<Widget>[
            const SizedBox(height: 24),
            const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('No match found. Try a shorter phrase, abbreviation, brand name, or a spelling variation.', textAlign: TextAlign.center))),
          ] else ...<Widget>[
            Padding(padding: const EdgeInsets.only(top: 18, bottom: 8), child: Text('${_hits.length} best matches', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
            ..._hits.map((SearchHit hit) => _resultTile(context, hit)),
          ],
        ],
      )),
    );
  }

  Widget _resultTile(BuildContext context, SearchHit hit) {
    final SearchDocument d = hit.document;
    return Card(child: ListTile(
      leading: CircleAvatar(child: Icon(_iconFor(d.kind))),
      title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text('${d.category}${hit.matchedOn == 'content' ? '' : '  •  matched ${hit.matchedOn}'}', maxLines: 2),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _open(context, d),
    ));
  }

  IconData _iconFor(String kind) => switch (kind) {
    'medication' => Icons.medication_outlined, 'plan' => Icons.assignment_outlined,
    'pccu' => Icons.monitor_heart_outlined, 'calculators' || 'bilirubin' || 'dka' => Icons.calculate_outlined,
    'antibiotic' => Icons.biotech_outlined, 'pain' => Icons.healing_outlined,
    'algorithm' => Icons.photo_library_outlined, _ => Icons.search_outlined,
  };

  void _open(BuildContext context, SearchDocument d) {
    Widget? screen;
    switch (d.kind) {
      case 'plan':
        final AdmissionPlan? plan = widget.store.planById(d.objectId!);
        if (plan != null) screen = PlanScreen(plan: plan, store: widget.store);
        break;
      case 'medication':
        final MedicationMonograph? med = widget.store.medicationById(d.objectId!);
        if (med != null) screen = MedicationDetailScreen(medication: med, store: widget.store);
        break;
      case 'pccu':
        screen = PccuTopicScreen(title: d.target);
        break;
      case 'calculators':
        screen = const CalculatorsScreen();
        break;
      case 'pain':
        screen = const PainManagementScreen();
        break;
      case 'antibiotic':
        screen = AntibioticGuideScreen(store: widget.store);
        break;
      case 'integrated':
        screen = const IntegratedClinicalSupportScreen();
        break;
      case 'bilirubin':
        screen = const BilirubinScreen();
        break;
      case 'dka':
        screen = const DkaCalculatorScreen();
        break;
      case 'reference':
        screen = const PediatricReferenceScreen();
        break;
      case 'sources':
        screen = const ClinicalSourcesScreen();
        break;
      case 'escalation':
        screen = const EscalationScreen();
        break;
      case 'algorithm':
        screen = LibraryScreen(store: widget.store);
        break;
      case 'med_quality':
        screen = MedicationQualityScreen(store: widget.store);
        break;
      case 'med_reference':
        screen = MedicationReferenceScreen(store: widget.store);
        break;
      case 'more':
        screen = MoreScreen(store: widget.store);
        break;
    }
    if (screen != null) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen!));
    }
  }
}
