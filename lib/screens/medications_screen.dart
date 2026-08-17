// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'package:flutter/material.dart';

import '../models/admission_plan.dart';
import '../models/medication_monograph.dart';
import '../services/app_store.dart';
import 'medication_quality_screen.dart';
import 'plan_screen.dart';

class MedicationsScreen extends StatefulWidget {
  final AppStore store;

  const MedicationsScreen({
    super.key,
    required this.store,
  });

  @override
  State<MedicationsScreen> createState() =>
      _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  String query = '';
  String category = 'All';
  String completeness = 'All';

  @override
  Widget build(BuildContext context) {
    final List<String> categories = <String>[
      'All',
      ...widget.store.medications
          .map(
            (MedicationMonograph medication) =>
                medication.category,
          )
          .toSet()
          .toList()
        ..sort(),
    ];

    final List<MedicationMonograph> filtered =
        widget.store.medications.where(
      (MedicationMonograph medication) {
        final bool categoryMatch = category == 'All' ||
            medication.category == category;

        final bool completenessMatch =
            completeness == 'All' ||
                (completeness == 'With doses' &&
                    medication.doseSections.isNotEmpty) ||
                (completeness == 'Missing doses' &&
                    medication.doseSections.isEmpty);

        final String searchable = <String>[
          medication.name,
          medication.category,
          medication.summary,
          medication.currentCanadianMonograph,
          ...medication.aliases,
          ...medication.doseSections.map(
            (MedicationDoseSection section) =>
                '${section.title} ${section.routeGroup} '
                '${section.text} ${section.source}',
          ),
        ].join(' ').toLowerCase();

        return categoryMatch &&
            completenessMatch &&
            searchable.contains(query.toLowerCase());
      },
    ).toList()
      ..sort(
        (MedicationMonograph a, MedicationMonograph b) =>
            a.name.compareTo(b.name),
      );

    final List<MedicationMonograph> favourites =
        widget.store.medications
            .where(
              (MedicationMonograph medication) =>
                  widget.store.medicationFavorites
                      .contains(medication.id),
            )
            .toList()
          ..sort(
            (MedicationMonograph a,
                    MedicationMonograph b) =>
                a.name.compareTo(b.name),
          );

    final List<MedicationMonograph> recent = widget
        .store.recentMedications
        .map(widget.store.medicationById)
        .whereType<MedicationMonograph>()
        .take(8)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medication Library',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Medication quality',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      MedicationQualityScreen(
                    store: widget.store,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.fact_check_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              28,
            ),
            children: <Widget>[
              _MedicationSummary(
                total: widget.store.medications.length,
                withDoses: widget.store.medications
                    .where(
                      (MedicationMonograph item) =>
                          item.doseSections.isNotEmpty,
                    )
                    .length,
                favourites: favourites.length,
                onQualityTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          MedicationQualityScreen(
                        store: widget.store,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: (String value) {
                  setState(() {
                    query = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText:
                      'Search drug, alias, route, indication, or dose',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (
                  BuildContext context,
                  BoxConstraints constraints,
                ) {
                  final bool compact =
                      constraints.maxWidth < 620;
                  final Widget categoryField =
                      DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration:
                        const InputDecoration(labelText: 'Category'),
                    items: categories
                        .map(
                          (String value) =>
                              DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        category = value;
                      });
                    },
                  );

                  final Widget statusField =
                      DropdownButtonFormField<String>(
                    initialValue: completeness,
                    decoration:
                        const InputDecoration(labelText: 'Status'),
                    items: const <String>[
                      'All',
                      'With doses',
                      'Missing doses',
                    ]
                        .map(
                          (String value) =>
                              DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        completeness = value;
                      });
                    },
                  );

                  if (compact) {
                    return Column(
                      children: <Widget>[
                        categoryField,
                        const SizedBox(height: 10),
                        statusField,
                      ],
                    );
                  }

                  return Row(
                    children: <Widget>[
                      Expanded(child: categoryField),
                      const SizedBox(width: 10),
                      Expanded(child: statusField),
                    ],
                  );
                },
              ),
              if (query.isEmpty &&
                  category == 'All' &&
                  completeness == 'All') ...<Widget>[
                if (favourites.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 24),
                  const _Heading(
                    title: 'Favourite medications',
                    icon: Icons.star,
                  ),
                  const SizedBox(height: 9),
                  _HorizontalMedicationList(
                    medications: favourites,
                    store: widget.store,
                  ),
                ],
                if (recent.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 24),
                  const _Heading(
                    title: 'Recently viewed',
                    icon: Icons.history,
                  ),
                  const SizedBox(height: 9),
                  _HorizontalMedicationList(
                    medications: recent,
                    store: widget.store,
                  ),
                ],
              ],
              const SizedBox(height: 24),
              _Heading(
                title: 'All medications',
                icon: Icons.medication_outlined,
                trailing: '${filtered.length} results',
              ),
              const SizedBox(height: 10),
              ...filtered.map(
                (MedicationMonograph medication) =>
                    _MedicationListTile(
                  medication: medication,
                  store: widget.store,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicationSummary extends StatelessWidget {
  final int total;
  final int withDoses;
  final int favourites;
  final VoidCallback onQualityTap;

  const _MedicationSummary({
    required this.total,
    required this.withDoses,
    required this.favourites,
    required this.onQualityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Icons.medication_outlined,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Pediatric medication reference',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$total medications · $withDoses with dose '
                    'sections · $favourites favourites',
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Open medication quality dashboard',
              onPressed: onQualityTap,
              icon: const Icon(Icons.fact_check_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? trailing;

  const _Heading({
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        if (trailing != null) Text(trailing!),
      ],
    );
  }
}

class _HorizontalMedicationList extends StatelessWidget {
  final List<MedicationMonograph> medications;
  final AppStore store;

  const _HorizontalMedicationList({
    required this.medications,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: medications.length,
        separatorBuilder: (
          BuildContext context,
          int index,
        ) =>
            const SizedBox(width: 9),
        itemBuilder: (BuildContext context, int index) {
          final MedicationMonograph medication =
              medications[index];
          return SizedBox(
            width: 230,
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _openMedication(
                  context,
                  medication,
                  store,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              medication.name,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (store.medicationFavorites
                              .contains(medication.id))
                            const Icon(
                              Icons.star,
                              size: 18,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        medication.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        '${medication.doseSections.length} dose sections',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MedicationListTile extends StatelessWidget {
  final MedicationMonograph medication;
  final AppStore store;

  const _MedicationListTile({
    required this.medication,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final bool favourite =
        store.medicationFavorites.contains(medication.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        leading: CircleAvatar(
          child: Text(
            medication.name.characters.first.toUpperCase(),
          ),
        ),
        title: Text(
          medication.name,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          '${medication.category} · '
          '${medication.doseSections.length} dose sections',
        ),
        trailing: IconButton(
          tooltip: favourite
              ? 'Remove favourite'
              : 'Add favourite',
          onPressed: () =>
              store.toggleMedicationFavorite(medication.id),
          icon: Icon(
            favourite ? Icons.star : Icons.star_border,
          ),
        ),
        onTap: () => _openMedication(
          context,
          medication,
          store,
        ),
      ),
    );
  }
}

Future<void> _openMedication(
  BuildContext context,
  MedicationMonograph medication,
  AppStore store,
) async {
  await store.markMedicationRecent(medication.id);
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
}

class MedicationDetailScreen extends StatefulWidget {
  final MedicationMonograph medication;
  final AppStore store;

  const MedicationDetailScreen({
    super.key,
    required this.medication,
    required this.store,
  });

  @override
  State<MedicationDetailScreen> createState() =>
      _MedicationDetailScreenState();
}

class _MedicationDetailScreenState
    extends State<MedicationDetailScreen> {
  String route = 'All';

  @override
  void initState() {
    super.initState();
    widget.store.markMedicationRecent(
      widget.medication.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final MedicationMonograph medication =
        widget.medication;

    final List<String> routes = <String>[
      'All',
      ...medication.doseSections
          .map(
            (MedicationDoseSection section) =>
                section.routeGroup,
          )
          .toSet(),
    ];

    final List<MedicationDoseSection> visible =
        medication.doseSections.where(
      (MedicationDoseSection section) =>
          route == 'All' || section.routeGroup == route,
    ).toList();

    final bool favourite = widget.store.medicationFavorites
        .contains(medication.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(medication.name),
        actions: <Widget>[
          IconButton(
            tooltip: favourite
                ? 'Remove favourite'
                : 'Add favourite',
            onPressed: () async {
              await widget.store.toggleMedicationFavorite(
                medication.id,
              );
              if (mounted) {
                setState(() {});
              }
            },
            icon: Icon(
              favourite ? Icons.star : Icons.star_border,
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              28,
            ),
            children: <Widget>[
              _MedicationHeader(medication: medication),
              if (routes.length > 1) ...<Widget>[
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<String>(
                    segments: routes
                        .map(
                          (String value) =>
                              ButtonSegment<String>(
                            value: value,
                            label: Text(value),
                          ),
                        )
                        .toList(),
                    selected: <String>{route},
                    onSelectionChanged: (
                      Set<String> selection,
                    ) {
                      setState(() {
                        route = selection.first;
                      });
                    },
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Text(
                'Dose sections',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              if (visible.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No structured dose section is currently '
                      'available for this medication.',
                    ),
                  ),
                ),
              ...visible.map(
                (MedicationDoseSection section) =>
                    _DoseSectionCard(section: section),
              ),
              if (medication.administration.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                _TextSection(
                  title: 'Administration',
                  icon: Icons.vaccines_outlined,
                  text: medication.administration,
                ),
              ],
              if (medication.monitoring.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                _TextSection(
                  title: 'Monitoring',
                  icon: Icons.monitor_heart_outlined,
                  text: medication.monitoring,
                ),
              ],
              if (medication.warnings.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                _TextSection(
                  title: 'Warnings',
                  icon: Icons.warning_amber_rounded,
                  text: medication.warnings,
                  warning: true,
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Linked admission plans',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              if (medication.linkedPlans.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No linked admission plan is currently '
                      'available.',
                    ),
                  ),
                ),
              ...medication.linkedPlans.map(
                (MedicationLinkedPlan linked) {
                  final AdmissionPlan? plan =
                      widget.store.planById(linked.planId);
                  return Card(
                    child: ListTile(
                      title: Text(
                        linked.planTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(linked.category),
                      trailing:
                          const Icon(Icons.chevron_right),
                      onTap: plan == null
                          ? null
                          : () async {
                              await widget.store
                                  .markRecent(plan.id);
                              if (!context.mounted) {
                                return;
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder:
                                      (BuildContext context) =>
                                          PlanScreen(
                                    plan: plan,
                                    store: widget.store,
                                  ),
                                ),
                              );
                            },
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              _TextSection(
                title: 'Verification status',
                icon: Icons.verified_user_outlined,
                text: medication.verificationStatus,
                warning: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicationHeader extends StatelessWidget {
  final MedicationMonograph medication;

  const _MedicationHeader({
    required this.medication,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              medication.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 5),
            Text(medication.category),
            if (medication.aliases.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: medication.aliases
                    .map(
                      (String alias) =>
                          Chip(label: Text(alias)),
                    )
                    .toList(),
              ),
            ],
            if (medication.summary.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                medication.summary,
                style: const TextStyle(height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DoseSectionCard extends StatelessWidget {
  final MedicationDoseSection section;

  const _DoseSectionCard({
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final bool historical =
        section.source.toLowerCase().contains('pccu') ||
            section.sourceDate.contains('2003');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: historical
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Chip(label: Text(section.routeGroup)),
              ],
            ),
            const SizedBox(height: 9),
            SelectableText(
              section.text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              section.source,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(section.sourceDate),
            if (historical) ...<Widget>[
              const SizedBox(height: 8),
              const Text(
                'Historical local reference — verify against '
                'the current local protocol.',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String text;
  final bool warning;

  const _TextSection({
    required this.title,
    required this.icon,
    required this.text,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: warning
          ? Theme.of(context).colorScheme.errorContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon),
                const SizedBox(width: 9),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            SelectableText(
              text,
              style: const TextStyle(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
