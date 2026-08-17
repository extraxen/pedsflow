// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'package:flutter/material.dart';

import '../models/admission_plan.dart';
import '../services/app_store.dart';
import '../widgets/plan_tile.dart';
import 'clinical_sources_screen.dart';

class PlansScreen extends StatefulWidget {
  final AppStore store;

  const PlansScreen({
    super.key,
    required this.store,
  });

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final String normalized = query.trim().toLowerCase();

    final List<AdmissionPlan> filtered =
        widget.store.plans.where((AdmissionPlan plan) {
      // Admission-plan search is intentionally diagnosis-focused.
      // Treatment text is excluded so a diagnosis query does not return
      // unrelated plans merely because they mention the same antibiotic.
      final String haystack = <String>[
        plan.title,
        plan.category,
        ...plan.aliases,
      ].join(' ').toLowerCase();

      return haystack.contains(normalized);
    }).toList();

    final Map<String, List<AdmissionPlan>> grouped =
        <String, List<AdmissionPlan>>{};

    for (final AdmissionPlan plan in filtered) {
      grouped
          .putIfAbsent(
            plan.category,
            () => <AdmissionPlan>[],
          )
          .add(plan);
    }

    final List<MapEntry<String, List<AdmissionPlan>>> entries =
        grouped.entries.toList()
          ..sort(
            (
              MapEntry<String, List<AdmissionPlan>> a,
              MapEntry<String, List<AdmissionPlan>> b,
            ) =>
                a.key.compareTo(b.key),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admission Plans',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clinical sources',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      const ClinicalSourcesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${widget.store.plans.length} '
                              'pediatric admission plans',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.store.plans.map(
                                    (AdmissionPlan p) => p.category,
                                  ).toSet().length} specialties Â· '
                              'search diagnoses, aliases and specialties',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: (String value) {
                  setState(() {
                    query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText:
                      'Search diagnoses or aliases',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 14),
              if (filtered.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'No admission plan matches this search.',
                    ),
                  ),
                ),
              ...entries.map(
                (
                  MapEntry<String, List<AdmissionPlan>> entry,
                ) {
                  entry.value.sort(
                    (AdmissionPlan a, AdmissionPlan b) =>
                        a.title.compareTo(b.title),
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      initiallyExpanded: query.isNotEmpty,
                      title: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle:
                          Text('${entry.value.length} plans'),
                      childrenPadding:
                          const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      children: entry.value
                          .map(
                            (AdmissionPlan plan) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8),
                              child: PlanTile(
                                plan: plan,
                                store: widget.store,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

