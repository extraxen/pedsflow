// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'package:flutter/material.dart';

import '../models/medication_monograph.dart';
import '../services/app_store.dart';
import 'medications_screen.dart';

class MedicationQualityScreen extends StatelessWidget {
  final AppStore store;

  const MedicationQualityScreen({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final List<MedicationMonograph> medications =
        store.medications;

    final List<MedicationMonograph> withDoses =
        medications.where(
      (MedicationMonograph medication) =>
          medication.doseSections.isNotEmpty,
    ).toList();

    final List<MedicationMonograph> missing =
        medications.where(
      (MedicationMonograph medication) =>
          medication.doseSections.isEmpty,
    ).toList();

    final List<MedicationMonograph> intravenous =
        _withRoute(medications, 'intraven');
    final List<MedicationMonograph> oral =
        _withRoute(medications, 'oral');
    final List<MedicationMonograph> inhaled =
        medications.where(
      (MedicationMonograph medication) =>
          medication.doseSections.any(
        (MedicationDoseSection section) {
          final String route =
              section.routeGroup.toLowerCase();
          return route.contains('inhal') ||
              route.contains('intranas');
        },
      ),
    ).toList();

    final List<MedicationMonograph> neonatal =
        medications.where(
      (MedicationMonograph medication) =>
          medication.doseSections.any(
        (MedicationDoseSection section) =>
            '${section.title} ${section.text}'
                .toLowerCase()
                .contains('neonat'),
      ),
    ).toList();

    final List<MedicationMonograph> historicalOnly =
        medications.where(
      (MedicationMonograph medication) {
        if (medication.doseSections.isEmpty) {
          return false;
        }
        return medication.doseSections.every(
          (MedicationDoseSection section) =>
              section.source.toLowerCase().contains('pccu') ||
              section.sourceDate.contains('2003'),
        );
      },
    ).toList();

    final List<MedicationMonograph> missingSourceDate =
        medications.where(
      (MedicationMonograph medication) =>
          medication.doseSections.any(
        (MedicationDoseSection section) =>
            section.source.trim().isEmpty ||
            section.sourceDate.trim().isEmpty,
      ),
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medication Quality',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              28,
            ),
            children: <Widget>[
              Text(
                'Database completeness',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Use this dashboard to identify gaps systematically '
                'instead of updating medications randomly.',
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount:
                    MediaQuery.sizeOf(context).width < 650
                        ? 2
                        : 3,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.35,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: <Widget>[
                  _QualityCard(
                    title: 'Total',
                    count: medications.length,
                    icon: Icons.medication_outlined,
                    onTap: () => _openList(
                      context,
                      'All medications',
                      medications,
                    ),
                  ),
                  _QualityCard(
                    title: 'With doses',
                    count: withDoses.length,
                    icon: Icons.verified_outlined,
                    onTap: () => _openList(
                      context,
                      'Medications with doses',
                      withDoses,
                    ),
                  ),
                  _QualityCard(
                    title: 'Missing doses',
                    count: missing.length,
                    icon: Icons.warning_amber_rounded,
                    warning: true,
                    onTap: () => _openList(
                      context,
                      'Medications missing dose sections',
                      missing,
                    ),
                  ),
                  _QualityCard(
                    title: 'IV',
                    count: intravenous.length,
                    icon: Icons.vaccines_outlined,
                    onTap: () => _openList(
                      context,
                      'Medications with IV dosing',
                      intravenous,
                    ),
                  ),
                  _QualityCard(
                    title: 'Oral',
                    count: oral.length,
                    icon: Icons.medication_liquid_outlined,
                    onTap: () => _openList(
                      context,
                      'Medications with oral dosing',
                      oral,
                    ),
                  ),
                  _QualityCard(
                    title: 'Inhaled',
                    count: inhaled.length,
                    icon: Icons.air_outlined,
                    onTap: () => _openList(
                      context,
                      'Medications with inhaled dosing',
                      inhaled,
                    ),
                  ),
                  _QualityCard(
                    title: 'Neonatal',
                    count: neonatal.length,
                    icon: Icons.child_care_outlined,
                    onTap: () => _openList(
                      context,
                      'Medications with neonatal content',
                      neonatal,
                    ),
                  ),
                  _QualityCard(
                    title: 'Historical only',
                    count: historicalOnly.length,
                    icon: Icons.history_outlined,
                    warning: historicalOnly.isNotEmpty,
                    onTap: () => _openList(
                      context,
                      'Historical-only medication entries',
                      historicalOnly,
                    ),
                  ),
                  _QualityCard(
                    title: 'Source gaps',
                    count: missingSourceDate.length,
                    icon: Icons.source_outlined,
                    warning: missingSourceDate.isNotEmpty,
                    onTap: () => _openList(
                      context,
                      'Dose sections missing source metadata',
                      missingSourceDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Card(
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'A medication is counted as “with doses” when '
                    'at least one structured dose section is present. '
                    'This does not mean its monograph is complete for '
                    'every indication, age group, route, renal status, '
                    'or maximum dose.',
                    style: TextStyle(height: 1.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<MedicationMonograph> _withRoute(
    List<MedicationMonograph> medications,
    String routeTerm,
  ) {
    return medications.where(
      (MedicationMonograph medication) =>
          medication.doseSections.any(
        (MedicationDoseSection section) =>
            section.routeGroup
                .toLowerCase()
                .contains(routeTerm),
      ),
    ).toList();
  }

  void _openList(
    BuildContext context,
    String title,
    List<MedicationMonograph> medications,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            _MedicationQualityListScreen(
          title: title,
          medications: medications,
          store: store,
        ),
      ),
    );
  }
}

class _QualityCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final VoidCallback onTap;
  final bool warning;

  const _QualityCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: warning
          ? Theme.of(context).colorScheme.errorContainer
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon),
              const Spacer(),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicationQualityListScreen extends StatelessWidget {
  final String title;
  final List<MedicationMonograph> medications;
  final AppStore store;

  const _MedicationQualityListScreen({
    required this.title,
    required this.medications,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final List<MedicationMonograph> sorted =
        List<MedicationMonograph>.from(medications)
          ..sort(
            (MedicationMonograph a,
                    MedicationMonograph b) =>
                a.name.compareTo(b.name),
          );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          28,
        ),
        itemCount: sorted.length,
        itemBuilder: (BuildContext context, int index) {
          final MedicationMonograph medication =
              sorted[index];
          return Card(
            child: ListTile(
              title: Text(
                medication.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                '${medication.category} · '
                '${medication.doseSections.length} dose sections',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await store.markMedicationRecent(
                  medication.id,
                );
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        MedicationDetailScreen(
                      medication: medication,
                      store: store,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
