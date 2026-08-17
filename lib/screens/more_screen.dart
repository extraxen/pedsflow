// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'package:flutter/material.dart';

import '../services/app_store.dart';
import 'medication_reference_screen.dart';

class MoreScreen extends StatelessWidget {
  final AppStore store;

  const MoreScreen({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final int editedPlans = store.plans
        .where(store.planHasEdits)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'More',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.medication_outlined),
              title: const Text(
                'Medication & Treatment Reference',
                style:
                    TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'Search treatment sections across all plans',
              ),
              trailing:
                  const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        MedicationReferenceScreen(
                      store: store,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.edit_note_outlined),
              title: const Text(
                'Customized plans',
                style:
                    TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '$editedPlans plans contain your edits',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.star_outline),
              title: const Text('Favorites'),
              subtitle:
                  Text('${store.favorites.length} saved plans'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.photo_library_outlined),
              title: const Text('Saved algorithms'),
              subtitle:
                  Text('${store.algorithms.length} saved images'),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text(
                'About PedsFlow',
                style:
                    TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Educational reference. Local pathways, '
                'formulary, pharmacist, and supervising '
                'physician supersede.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

