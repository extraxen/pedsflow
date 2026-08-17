// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/admission_plan.dart';
import '../models/algorithm_item.dart';
import '../models/antibiotic_guide.dart';
import '../models/medication_monograph.dart';
import 'app_store.dart';

class SearchDocument {
  final String id;
  final String title;
  final String category;
  final String kind;
  final String target;
  final List<String> aliases;
  final String body;
  final List<String> fragments;
  final int? objectId;

  const SearchDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.kind,
    required this.target,
    required this.aliases,
    required this.body,
    this.fragments = const <String>[],
    this.objectId,
  });

  factory SearchDocument.fromJson(Map<String, dynamic> json) => SearchDocument(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        kind: json['kind'] as String,
        target: (json['target'] as String?) ?? '',
        aliases: List<String>.from(
          (json['aliases'] as List<dynamic>?) ?? const <dynamic>[],
        ),
        body: (json['body'] as String?) ?? '',
        fragments: List<String>.from(
          (json['fragments'] as List<dynamic>?) ?? const <dynamic>[],
        ),
      );
}

class SearchHit {
  final SearchDocument document;
  final int score;
  final String matchedOn;
  final String snippet;

  const SearchHit(
    this.document,
    this.score,
    this.matchedOn, [
    this.snippet = '',
  ]);
}

class GlobalSearchIndex {
  final List<SearchDocument> documents;

  const GlobalSearchIndex(this.documents);

  static const Map<String, String> _aliases = <String, String>{
    'vomitting': 'vomiting',
    'emesis': 'vomiting',
    'gravol': 'dimenhydrinate',
    'zofran': 'ondansetron',
    'hypok': 'hypokalemia',
    'hyperk': 'hyperkalemia',
    'hypophos': 'hypophosphatemia',
    'bronch': 'bronchiolitis',
    'pna': 'pneumonia',
    'icp': 'raised intracranial pressure',
    'chs': 'cannabis hyperemesis syndrome',
    'tylenol': 'acetaminophen',
    'paracetamol': 'acetaminophen',
    'motrin': 'ibuprofen',
    'advil': 'ibuprofen',
    'dilaudid': 'hydromorphone',
    'epi': 'epinephrine',
    'norad': 'norepinephrine',
    'noradrenaline': 'norepinephrine',
    'status asthma': 'status asthmaticus',
    'rsi': 'rapid sequence intubation',
    'ett': 'intubation',
    'lp': 'lumbar puncture',
    'tbi': 'traumatic brain injury',
    'roc': 'rocuronium',
    'roconium': 'rocuronium',
    'nimbex': 'cisatracurium',
    'precedex': 'dexmedetomidine',
    'dex': 'dexmedetomidine',
    'versed': 'midazolam',
    'fent': 'fentanyl',
    'prop': 'propofol',
    'sux': 'succinylcholine',
    'clavulin': 'amoxicillin clavulanate',
    'zosyn': 'piperacillin tazobactam',
    'pip tazo': 'piperacillin tazobactam',
    'keppra': 'levetiracetam',
    'lasix': 'furosemide',
    'solumedrol': 'methylprednisolone',
    'solu medrol': 'methylprednisolone',
    'bactrim': 'trimethoprim sulfamethoxazole',
    'septra': 'trimethoprim sulfamethoxazole',
    'rocephin': 'ceftriaxone',
    'ancef': 'cefazolin',
    'flagyl': 'metronidazole',
    'diflucan': 'fluconazole',
    'ampho b': 'amphotericin b',
    'suxamethonium': 'succinylcholine',
    'dka cerebral edema': 'cerebral edema in dka',
    'sickle crisis': 'vaso occlusive pain',
    'voc': 'vaso occlusive pain',
    'sickle cell crisis': 'vaso occlusive pain',
    'aki': 'acute kidney injury',
    'ards': 'acute respiratory distress syndrome',
    'hf': 'heart failure',
    'svt': 'supraventricular tachycardia',
    'se': 'status epilepticus',
    'po4': 'phosphate',
    'mag': 'magnesium',
    'hypomag': 'hypomagnesemia',
    'low sodium': 'hyponatremia',
    'low calcium': 'hypocalcemia',
    'nrp': 'newborn resuscitation',
    'eos': 'early onset sepsis',
    'cga': 'corrected gestational age',
    'adrenal crisis': 'adrenal crisis',
    'siadh': 'siadh',
    'di': 'diabetes insipidus',
  };

  static Future<GlobalSearchIndex> build(AppStore store) async {
    final List<SearchDocument> docs = <SearchDocument>[];
    final String raw = await rootBundle.loadString(
      'assets/static_search_index.json',
    );
    docs.addAll(
      (jsonDecode(raw) as List<dynamic>).map(
        (dynamic item) => SearchDocument.fromJson(
          item as Map<String, dynamic>,
        ),
      ),
    );

    for (final AdmissionPlan plan in store.plans) {
      final List<String> fragments = <String>[
        plan.summary,
        plan.guidance,
        ...plan.sections.asMap().entries.map(
              (entry) =>
                  '${entry.value.label}: ${store.sectionText(plan, entry.key)}',
            ),
        ...plan.treatments.asMap().entries.map(
              (entry) =>
                  '${entry.value.group}: ${store.treatmentText(plan, entry.key)}',
            ),
      ].where((String value) => value.trim().isNotEmpty).toList();

      docs.add(
        SearchDocument(
          id: 'plan:${plan.id}',
          title: plan.title,
          category: 'Admission plan • ${plan.category}',
          kind: 'plan',
          target: '',
          aliases: plan.aliases,
          objectId: plan.id,
          fragments: fragments,
          body: <String>[
            plan.summary,
            plan.guidance,
            plan.contentStatus,
            plan.lastUpdated,
            ...plan.sourceLabels,
            ...fragments,
          ].join(' '),
        ),
      );
    }

    for (final MedicationMonograph med in store.medications) {
      final List<String> doseFragments = med.doseSections
          .map(
            (d) => <String>[
              d.title,
              if (d.routeGroup.trim().isNotEmpty) d.routeGroup,
              d.text,
            ].where((String value) => value.trim().isNotEmpty).join(' • '),
          )
          .where((String value) => value.trim().isNotEmpty)
          .toList();

      final List<String> fragments = <String>[
        ...doseFragments,
        if (med.summary.trim().isNotEmpty) med.summary,
        if (med.administration.trim().isNotEmpty)
          'Administration: ${med.administration}',
        if (med.monitoring.trim().isNotEmpty) 'Monitoring: ${med.monitoring}',
        if (med.warnings.trim().isNotEmpty) 'Warnings: ${med.warnings}',
      ];

      docs.add(
        SearchDocument(
          id: 'med:${med.id}',
          title: med.name,
          category: 'Medication • ${med.category}',
          kind: 'medication',
          target: '',
          aliases: med.aliases,
          objectId: med.id,
          fragments: fragments,
          body: <String>[
            med.summary,
            med.doseStatus,
            med.administration,
            med.monitoring,
            med.warnings,
            med.verificationStatus,
            med.sourceSummary,
            med.currentCanadianMonograph,
            ...med.sourceLabels,
            ...med.linkedPlans.expand(
              (p) => <String>[p.planTitle, p.category, p.excerpt],
            ),
            ...med.doseSections.expand(
              (d) => <String>[
                d.title,
                d.routeGroup,
                d.text,
                d.source,
                d.sourceDate,
              ],
            ),
          ].join(' '),
        ),
      );
    }

    final AntibioticGuideData? guide = store.antibioticGuide;
    if (guide != null) {
      for (final AntibioticSyndrome s in guide.syndromes) {
        final List<String> fragments = <String>[
          s.approach,
          if (s.organisms.isNotEmpty) 'Organisms: ${s.organisms.join(', ')}',
          if (s.linkedDrugs.isNotEmpty) 'Drugs: ${s.linkedDrugs.join(', ')}',
        ].where((String value) => value.trim().isNotEmpty).toList();
        docs.add(
          SearchDocument(
            id: 'abx:${s.title}',
            title: s.title,
            category: 'Antibiotics • ${s.category}',
            kind: 'antibiotic',
            target: s.title,
            aliases: const <String>[],
            fragments: fragments,
            body: <String>[
              ...s.organisms,
              s.approach,
              ...s.linkedDrugs,
            ].join(' '),
          ),
        );
      }
      for (final CoveragePearl p in guide.coveragePearls) {
        docs.add(
          SearchDocument(
            id: 'abxpearl:${p.title}',
            title: p.title,
            category: 'Antibiotic coverage pearl',
            kind: 'antibiotic',
            target: p.title,
            aliases: const <String>[],
            fragments: <String>[p.text],
            body: p.text,
          ),
        );
      }
    }

    for (final AlgorithmItem algorithm in store.algorithms) {
      docs.add(
        SearchDocument(
          id: 'algorithm:${algorithm.id}',
          title: algorithm.title,
          category: 'Algorithm • ${algorithm.category}',
          kind: 'algorithm',
          target: algorithm.id,
          aliases: const <String>[],
          fragments: <String>[algorithm.notes],
          body: algorithm.notes,
        ),
      );
    }

    return GlobalSearchIndex(docs);
  }

  List<SearchHit> search(
    String rawQuery, {
    String? kind,
    int limit = 80,
  }) {
    final String normalized = _normalize(rawQuery);
    if (normalized.isEmpty) return const <SearchHit>[];

    final List<String> tokens = normalized
        .split(' ')
        .where((String token) => token.isNotEmpty)
        .toList();
    final List<SearchHit> hits = <SearchHit>[];

    for (final SearchDocument doc in documents) {
      if (kind != null && kind != 'all') {
        final bool groupMatch = kind == 'electrolytes' &&
            (doc.kind == 'electrolytes' ||
                doc.kind == 'hypokalemia_engine');
        if (!groupMatch && doc.kind != kind) continue;
      }

      final String title = _normalize(doc.title);
      final String category = _normalize(doc.category);
      final String aliases = _normalize(doc.aliases.join(' '));
      final String body = _normalize(doc.body);
      final String combined = '$title $aliases $category $body';
      if (!_allTokensMatch(tokens, combined)) continue;

      int score = 0;
      String matchedOn = 'content';
      if (title == normalized) {
        score += 1500;
        matchedOn = 'title';
      } else if (title.startsWith(normalized)) {
        score += 1100;
        matchedOn = 'title';
      } else if (title.contains(normalized)) {
        score += 850;
        matchedOn = 'title';
      }
      if (aliases.contains(normalized)) {
        score += 950;
        matchedOn = 'alias';
      }
      if (category.contains(normalized)) score += 250;
      if (body.contains(normalized)) score += 150;

      for (final String token in tokens) {
        if (title.split(' ').contains(token)) {
          score += 220;
        } else if (title.split(' ').any((String word) => word.startsWith(token))) {
          score += 160;
        }
        if (aliases.split(' ').contains(token)) score += 180;
        if (category.split(' ').contains(token)) score += 60;
        if (body.contains(token)) score += 25;
      }

      if (doc.kind == 'pccu' ||
          doc.kind == 'medication' ||
          doc.kind == 'plan') {
        score += 20;
      }

      hits.add(
        SearchHit(
          doc,
          score,
          matchedOn,
          _bestSnippet(doc, tokens, normalized),
        ),
      );
    }

    hits.sort((SearchHit a, SearchHit b) {
      final int byScore = b.score.compareTo(a.score);
      return byScore != 0
          ? byScore
          : a.document.title.compareTo(b.document.title);
    });
    return hits.take(limit).toList();
  }

  static String _bestSnippet(
    SearchDocument doc,
    List<String> tokens,
    String normalizedQuery,
  ) {
    final List<String> candidates = doc.fragments
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList();
    if (candidates.isEmpty) return '';

    String best = candidates.first;
    int bestScore = -1;

    for (final String candidate in candidates) {
      final String normalizedCandidate = _normalize(candidate);
      int score = 0;
      if (normalizedCandidate.contains(normalizedQuery)) score += 120;
      for (final String token in tokens) {
        if (normalizedCandidate.split(' ').contains(token)) {
          score += 35;
        } else if (normalizedCandidate.contains(token)) {
          score += 20;
        }
      }
      if (doc.kind == 'medication' &&
          RegExp(
            r'\b(?:mg|mcg|g|mmol|units?)(?:/kg)?(?:/dose|/hr|/min)?\b',
            caseSensitive: false,
          ).hasMatch(candidate)) {
        score += 5;
      }
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }

    return _trimSnippet(best, 230);
  }

  static String _trimSnippet(String value, int maxLength) {
    final String clean = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= maxLength) return clean;
    final String shortened = clean.substring(0, maxLength - 1);
    final int lastSpace = shortened.lastIndexOf(' ');
    return '${lastSpace > 150 ? shortened.substring(0, lastSpace) : shortened}…';
  }

  static String _normalize(String value) {
    String normalized = value
        .toLowerCase()
        .replaceAll(
          RegExp(r'\b\d+(?:\.\d+)?\s*kg\b'),
          ' ',
        )
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9+./-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
    if (_aliases.containsKey(normalized)) {
      normalized = _aliases[normalized]!;
    }
    return normalized
        .split(' ')
        .map((String token) => _aliases[token] ?? token)
        .join(' ')
        .trim();
  }

  static bool _allTokensMatch(List<String> tokens, String haystack) {
    final List<String> words = haystack.split(' ');
    for (final String token in tokens) {
      if (haystack.contains(token)) continue;
      final bool fuzzy = words.any(
        (String word) => _fuzzyToken(token, word),
      );
      if (!fuzzy) return false;
    }
    return true;
  }

  static bool _fuzzyToken(String a, String b) {
    if (a.length < 4 || b.length < 4) return false;
    if (b.startsWith(a) || a.startsWith(b)) return true;
    final int maxDistance = a.length >= 8 ? 2 : 1;
    if ((a.length - b.length).abs() > maxDistance) return false;
    return _levenshtein(a, b, maxDistance) <= maxDistance;
  }

  static int _levenshtein(String a, String b, int stopAt) {
    List<int> previous = List<int>.generate(
      b.length + 1,
      (int index) => index,
    );
    for (int i = 1; i <= a.length; i++) {
      final List<int> current = List<int>.filled(b.length + 1, 0)..[0] = i;
      int rowMin = current[0];
      for (int j = 1; j <= b.length; j++) {
        final int cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        current[j] = _min3(
          current[j - 1] + 1,
          previous[j] + 1,
          previous[j - 1] + cost,
        );
        if (current[j] < rowMin) rowMin = current[j];
      }
      if (rowMin > stopAt) return stopAt + 1;
      previous = current;
    }
    return previous[b.length];
  }

  static int _min3(int a, int b, int c) =>
      a < b ? (a < c ? a : c) : (b < c ? b : c);
}
