// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'package:flutter/material.dart';

import '../models/admission_plan.dart';
import '../services/app_store.dart';
import '../widgets/plan_tile.dart';

class MedicationReferenceScreen extends StatefulWidget {
  final AppStore store;

  const MedicationReferenceScreen({
    super.key,
    required this.store,
  });

  @override
  State<MedicationReferenceScreen> createState() =>
      _MedicationReferenceScreenState();
}

class _MedicationReferenceScreenState
    extends State<MedicationReferenceScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final List<AdmissionPlan> results =
        widget.store.plans.where((AdmissionPlan plan) {
      final String treatmentText = <String>[
        ...plan.treatments.map(
          (item) => item.text,
        ),
        widget.store.sectionText(plan, 8),
      ].join(' ').toLowerCase();

      if (query.trim().isEmpty) {
        return true;
      }

      final String searchText =
          '${plan.title} ${plan.category} $treatmentText'
              .toLowerCase();

      return searchText.contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medication & Treatment Reference',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Card(
            color: Theme.of(context)
                .colorScheme
                .secondaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'This index searches the medication and treatment '
                'sections of your 100 admission plans. Verify the '
                'patient-specific dose, local formulary, allergies, '
                'renal function, and supervising physician plan.',
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
                  'Search ceftriaxone, dexamethasone, magnesium...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${results.length} matching plans',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          ...results.map(
            (AdmissionPlan plan) {
              final String medicationSection =
                  widget.store.sectionText(plan, 8);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainer,
                child: ExpansionTile(
                  title: Text(
                    plan.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(plan.category),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        medicationSection,
                        style: const TextStyle(height: 1.45),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PlanTile(
                      plan: plan,
                      store: widget.store,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

