// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/bilirubin/bilirubin_screen.dart';
import '../features/dka/dka_calculator_screen.dart';
import '../features/electrolytes/electrolyte_engine_screen.dart';
import '../features/electrolytes/hypokalemia_engine_screen.dart';
import '../features/endocrine/endocrine_hub_screen.dart';
import '../features/growth/growth_suite_screen.dart';
import '../features/neonatal/neonatal_hub_screen.dart';
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

IconData searchIconForKind(String kind) => switch (kind) {
      'medication' => Icons.medication_outlined,
      'plan' => Icons.assignment_outlined,
      'pccu' => Icons.monitor_heart_outlined,
      'calculators' || 'bilirubin' || 'dka' => Icons.calculate_outlined,
      'antibiotic' => Icons.biotech_outlined,
      'pain' => Icons.healing_outlined,
      'algorithm' => Icons.photo_library_outlined,
      'growth' => Icons.show_chart,
      'neonatal' => Icons.child_care_outlined,
      'endocrine' => Icons.hub_outlined,
      'electrolytes' || 'hypokalemia_engine' => Icons.science_outlined,
      _ => Icons.search_outlined,
    };

void openSearchDocument(
  BuildContext context,
  AppStore store,
  SearchDocument document,
) {
  Widget? screen;
  switch (document.kind) {
    case 'plan':
      final AdmissionPlan? plan = store.planById(document.objectId!);
      if (plan != null) screen = PlanScreen(plan: plan, store: store);
      break;
    case 'medication':
      final MedicationMonograph? medication = store.medicationById(
        document.objectId!,
      );
      if (medication != null) {
        screen = MedicationDetailScreen(
          medication: medication,
          store: store,
        );
      }
      break;
    case 'pccu':
      screen = PccuTopicScreen(title: document.target);
      break;
    case 'calculators':
      screen = const CalculatorsScreen();
      break;
    case 'hypokalemia_engine':
      screen = const HypokalemiaEngineScreen();
      break;
    case 'electrolytes':
      screen = const ElectrolyteEngineScreen();
      break;
    case 'neonatal':
      screen = const NeonatalHubScreen();
      break;
    case 'endocrine':
      screen = const EndocrineHubScreen();
      break;
    case 'growth':
      screen = const GrowthSuiteScreen();
      break;
    case 'pain':
      screen = const PainManagementScreen();
      break;
    case 'antibiotic':
      screen = AntibioticGuideScreen(store: store);
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
      screen = LibraryScreen(store: store);
      break;
    case 'med_quality':
      screen = MedicationQualityScreen(store: store);
      break;
    case 'med_reference':
      screen = MedicationReferenceScreen(store: store);
      break;
    case 'more':
      screen = MoreScreen(store: store);
      break;
  }

  if (screen != null) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen!),
    );
  }
}

class UniversalSearchScreen extends StatefulWidget {
  final AppStore store;
  final String initialQuery;

  const UniversalSearchScreen({
    super.key,
    required this.store,
    this.initialQuery = '',
  });

  @override
  State<UniversalSearchScreen> createState() => _UniversalSearchScreenState();
}

class _UniversalSearchScreenState extends State<UniversalSearchScreen> {
  static const String _recentKey = 'pedsflow_search_recent_v2';
  static const String _favoriteKey = 'pedsflow_search_favorites_v2';

  final TextEditingController _controller = TextEditingController();
  GlobalSearchIndex? _index;
  List<SearchHit> _hits = const <SearchHit>[];
  String _filter = 'all';
  Timer? _debounce;
  String _query = '';
  List<String> _recent = <String>[];
  Set<String> _favoriteIds = <String>{};

  static const List<(String, String)> _filters = <(String, String)>[
    ('all', 'All'),
    ('pccu', 'PCCU'),
    ('medication', 'Medications'),
    ('plan', 'Plans'),
    ('calculators', 'Calculators'),
    ('electrolytes', 'Electrolytes'),
    ('neonatal', 'Neonatal'),
    ('endocrine', 'Endocrine'),
    ('growth', 'Growth'),
    ('antibiotic', 'Antibiotics'),
    ('pain', 'Pain'),
  ];

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim();
    _controller.text = _query;
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    _load();
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final GlobalSearchIndex index = await GlobalSearchIndex.build(widget.store);
    if (!mounted) return;
    setState(() {
      _recent = prefs.getStringList(_recentKey) ?? <String>[];
      _favoriteIds = (prefs.getStringList(_favoriteKey) ?? <String>[]).toSet();
      _index = index;
      _runSearch();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 90), () {
      if (mounted) setState(_runSearch);
    });
  }

  void _runSearch() {
    final String? engineKind = switch (_filter) {
      'electrolytes' => 'electrolytes',
      'neonatal' => 'neonatal',
      'endocrine' => 'endocrine',
      'growth' => 'growth',
      _ => _filter,
    };
    _hits = _index?.search(_query, kind: engineKind) ?? const <SearchHit>[];
  }

  Future<void> _remember(String query) async {
    final String clean = query.trim();
    if (clean.length < 2) return;
    _recent.removeWhere(
      (String value) => value.toLowerCase() == clean.toLowerCase(),
    );
    _recent.insert(0, clean);
    if (_recent.length > 10) _recent = _recent.take(10).toList();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, _recent);
    if (mounted) setState(() {});
  }

  Future<void> _toggleFavorite(SearchDocument document) async {
    if (_favoriteIds.contains(document.id)) {
      _favoriteIds.remove(document.id);
    } else {
      _favoriteIds.add(document.id);
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteKey, _favoriteIds.toList());
    if (mounted) setState(() {});
  }

  void _applyQuery(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    setState(() {
      _query = query;
      _runSearch();
    });
  }

  double? get _commandWeight {
    final RegExpMatch? match = RegExp(
      r'(\d+(?:\.\d+)?)\s*kg\b',
      caseSensitive: false,
    ).firstMatch(_query);
    return match == null ? null : double.tryParse(match.group(1)!);
  }

  String get _semanticQuery => _query
      .replaceAll(
        RegExp(r'\d+(?:\.\d+)?\s*kg\b', caseSensitive: false),
        '',
      )
      .trim();

  @override
  Widget build(BuildContext context) {
    final double? weight = _commandWeight;
    final List<SearchHit> favoriteHits = _index == null
        ? const <SearchHit>[]
        : _index!.documents
            .where((SearchDocument d) => _favoriteIds.contains(d.id))
            .map((SearchDocument d) => SearchHit(d, 0, 'favorite'))
            .toList();

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
            TextField(
              controller: _controller,
              autofocus: widget.initialQuery.isEmpty,
              textInputAction: TextInputAction.search,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: _onChanged,
              onSubmitted: _remember,
              decoration: InputDecoration(
                hintText:
                    'Search diagnoses, medications, doses, calculators or pathways…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _query = '';
                            _hits = const <SearchHit>[];
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
            if (weight != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.scale_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Command parser detected '
                            '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg • '
                            'clinical query: “$_semanticQuery”. Dose results still '
                            'require opening the verified medication/pathway; '
                            'PedsFlow will not infer a dose from free text.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters
                    .map(
                      ((String, String) filter) => Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: ChoiceChip(
                          label: Text(filter.$2),
                          selected: _filter == filter.$1,
                          onSelected: (_) {
                            setState(() {
                              _filter = filter.$1;
                              _runSearch();
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            if (_index == null)
              const Padding(
                padding: EdgeInsets.only(top: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_query.trim().isEmpty) ...<Widget>[
              const SizedBox(height: 18),
              const Text(
                'Quick clinical commands',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: <String>[
                  'ketamine dose 25 kg',
                  'ceftriaxone meningitis',
                  'epinephrine',
                  'hydromorphone',
                  'LP sedation',
                  'hyperK',
                  'nimbex infusion',
                  'CPS bilirubin',
                  'DKA cerebral edema',
                  'hypophos IV',
                ]
                    .map(
                      (String query) => ActionChip(
                        label: Text(query),
                        onPressed: () => _applyQuery(query),
                      ),
                    )
                    .toList(),
              ),
              if (_recent.isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Recent searches',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        _recent.clear();
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.remove(_recentKey);
                        if (mounted) setState(() {});
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: _recent
                      .map(
                        (String query) => ActionChip(
                          avatar: const Icon(Icons.history, size: 18),
                          label: Text(query),
                          onPressed: () => _applyQuery(query),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (favoriteHits.isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                const Text(
                  'Favorite results',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                ...favoriteHits.take(12).map(
                      (SearchHit hit) => _resultTile(context, hit),
                    ),
              ],
              const SizedBox(height: 18),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Search indexes full admission-plan text, medication dose '
                    'sections/warnings, PCCU pathways, neonatal/endocrine/'
                    'electrolyte modules, calculators, pain, antibiotics/organisms, '
                    'references and saved algorithm notes. Medication results now '
                    'surface the dose or indication section most relevant to your '
                    'query before you open the full monograph.',
                  ),
                ),
              ),
            ] else if (_hits.isEmpty) ...<Widget>[
              const SizedBox(height: 24),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No match found. Try a shorter clinical term, abbreviation, '
                    'brand name, indication, or spelling variation.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ] else ...<Widget>[
              const SizedBox(height: 16),
              Text(
                'Best match',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              _bestMatch(context, _hits.first),
              if (_hits.length > 1) ...<Widget>[
                const SizedBox(height: 14),
                Text(
                  '${_hits.length - 1} more results',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                ..._hits.skip(1).map(
                      (SearchHit hit) => _resultTile(context, hit),
                    ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _bestMatch(BuildContext context, SearchHit hit) {
    final SearchDocument document = hit.document;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          child: Icon(searchIconForKind(document.kind)),
        ),
        title: Text(
          document.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        subtitle: _SearchResultSubtitle(
          category: document.category,
          matchedOn: hit.matchedOn,
          snippet: hit.snippet,
        ),
        isThreeLine: hit.snippet.isNotEmpty,
        trailing: IconButton(
          tooltip: 'Favorite',
          icon: Icon(
            _favoriteIds.contains(document.id) ? Icons.star : Icons.star_border,
          ),
          onPressed: () => _toggleFavorite(document),
        ),
        onTap: () {
          _remember(_query);
          openSearchDocument(context, widget.store, document);
        },
      ),
    );
  }

  Widget _resultTile(BuildContext context, SearchHit hit) {
    final SearchDocument document = hit.document;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(searchIconForKind(document.kind)),
        ),
        title: Text(
          document.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: _SearchResultSubtitle(
          category: document.category,
          matchedOn: hit.matchedOn,
          snippet: hit.snippet,
        ),
        isThreeLine: hit.snippet.isNotEmpty,
        trailing: IconButton(
          tooltip: 'Favorite',
          icon: Icon(
            _favoriteIds.contains(document.id) ? Icons.star : Icons.star_border,
          ),
          onPressed: () => _toggleFavorite(document),
        ),
        onTap: () {
          _remember(_query);
          openSearchDocument(context, widget.store, document);
        },
      ),
    );
  }
}

class _SearchResultSubtitle extends StatelessWidget {
  final String category;
  final String matchedOn;
  final String snippet;

  const _SearchResultSubtitle({
    required this.category,
    required this.matchedOn,
    required this.snippet,
  });

  @override
  Widget build(BuildContext context) {
    final String matchText = matchedOn == 'content' || matchedOn == 'favorite'
        ? category
        : '$category • matched $matchedOn';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(matchText, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (snippet.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            snippet,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              height: 1.25,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
