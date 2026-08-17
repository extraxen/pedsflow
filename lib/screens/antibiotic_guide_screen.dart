// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.

import 'package:flutter/material.dart';

import '../models/antibiotic_guide.dart';
import '../models/medication_monograph.dart';
import '../services/app_store.dart';
import 'medications_screen.dart';

class AntibioticGuideScreen extends StatefulWidget {
  final AppStore store;

  const AntibioticGuideScreen({
    super.key,
    required this.store,
  });

  @override
  State<AntibioticGuideScreen> createState() =>
      _AntibioticGuideScreenState();
}

class _AntibioticGuideScreenState extends State<AntibioticGuideScreen>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  String query = '';

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AntibioticGuideData? data = widget.store.antibioticGuide;
    if (data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<AntibioticSyndrome> syndromes = data.syndromes.where(
      (AntibioticSyndrome syndrome) {
        final String searchable = <String>[
          syndrome.title,
          syndrome.category,
          syndrome.approach,
          ...syndrome.organisms,
          ...syndrome.linkedDrugs,
        ].join(' ').toLowerCase();
        return searchable.contains(query.toLowerCase());
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Antibiotics & Organisms',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        bottom: TabBar(
          controller: controller,
          tabs: const <Tab>[
            Tab(text: 'By syndrome'),
            Tab(text: 'Coverage pearls'),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: <Widget>[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(data.warning),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (String value) {
                  setState(() {
                    query = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search syndrome, organism, or antibiotic',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 14),
              ...syndromes.map(
                (AntibioticSyndrome syndrome) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    title: Text(
                      syndrome.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(syndrome.category),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: <Widget>[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Likely organisms',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...syndrome.organisms.map(
                        (String organism) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.bug_report_outlined),
                          title: Text(organism),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          syndrome.approach,
                          style: const TextStyle(height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: syndrome.linkedDrugs.map(
                            (String drugName) {
                              return ActionChip(
                                avatar:
                                    const Icon(Icons.medication_outlined),
                                label: Text(drugName),
                                onPressed: () {
                                  MedicationMonograph? match;
                                  for (final MedicationMonograph item
                                      in widget.store.medications) {
                                    if (item.name.toLowerCase() ==
                                        drugName.toLowerCase()) {
                                      match = item;
                                      break;
                                    }
                                  }
                                  if (match == null) {
                                    return;
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          MedicationDetailScreen(
                                        medication: match!,
                                        store: widget.store,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: <Widget>[
              Text(
                'Spectrum and stewardship pearls',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              ...data.coveragePearls.map(
                (CoveragePearl pearl) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.shield_outlined),
                    ),
                    title: Text(
                      pearl.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(pearl.text),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
