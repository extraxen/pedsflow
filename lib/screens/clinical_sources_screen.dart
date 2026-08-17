// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'package:flutter/material.dart';

class ClinicalSourcesScreen extends StatelessWidget {
  const ClinicalSourcesScreen({super.key});

  static const List<_SourceItem> _sources = <_SourceItem>[
    _SourceItem(
      name: 'Canadian Paediatric Society',
      type: 'National professional guidance',
      use: 'Canadian position statements and practice points.',
    ),
    _SourceItem(
      name: 'TREKK',
      type: 'Pediatric emergency knowledge translation',
      use: 'Bottom-line recommendations and evidence repositories.',
    ),
    _SourceItem(
      name: 'CHEO ED Outreach',
      type: 'Ontario pediatric clinical resource',
      use: 'Current pediatric and neonatal drug/clinical resources.',
    ),
    _SourceItem(
      name: 'IWK Drug Information Resource',
      type: 'Canadian pediatric drug resource',
      use: 'Dosing, neonatal and parenteral administration references.',
    ),
    _SourceItem(
      name: 'Ontario Poison Centre',
      type: 'Provincial toxicology service',
      use: 'Real-time poisoning, antidote and dialysis guidance.',
    ),
    _SourceItem(
      name: 'LHSC / local institutional pathways',
      type: 'Local source of truth',
      use: 'Order sets, antibiogram, transfer and consultant-specific care.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clinical Sources',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: <Widget>[
              Card(
                color:
                    Theme.of(context).colorScheme.errorContainer,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'PedsFlow organizes educational clinical-support '
                    'content. The current institutional pathway, local '
                    'antibiogram, pharmacist, specialist and supervising '
                    'physician remain authoritative.',
                    style: TextStyle(height: 1.45),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ..._sources.map(
                (_SourceItem source) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      child: Icon(Icons.menu_book_outlined),
                    ),
                    title: Text(
                      source.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${source.type}\n${source.use}',
                      ),
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Content status: the 70 plans added in Version 10 '
                    'are structured original summaries and are labelled '
                    'for local clinical review. They do not replace a '
                    'hospital order set or consultant-specific pathway.',
                    style: TextStyle(height: 1.45),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceItem {
  final String name;
  final String type;
  final String use;

  const _SourceItem({
    required this.name,
    required this.type,
    required this.use,
  });
}

