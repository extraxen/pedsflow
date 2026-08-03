import 'package:flutter/material.dart';

import '../models/admission_plan.dart';
import '../services/app_store.dart';
import '../widgets/plan_tile.dart';

class UniversalSearchScreen extends StatefulWidget {
  final AppStore store;

  const UniversalSearchScreen({
    super.key,
    required this.store,
  });

  @override
  State<UniversalSearchScreen> createState() =>
      _UniversalSearchScreenState();
}

class _UniversalSearchScreenState
    extends State<UniversalSearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final String normalized = query.trim().toLowerCase();

    final List<AdmissionPlan> plans = normalized.isEmpty
        ? <AdmissionPlan>[]
        : widget.store.plans.where(
            (AdmissionPlan plan) {
              final String searchable = <String>[
                plan.title,
                plan.category,
                ...plan.aliases,
              ].join(' ').toLowerCase();

              return searchable.contains(normalized);
            },
          ).take(30).toList()
      ..sort(
        (AdmissionPlan a, AdmissionPlan b) {
          final bool aStarts =
              a.title.toLowerCase().startsWith(normalized);
          final bool bStarts =
              b.title.toLowerCase().startsWith(normalized);
          if (aStarts != bStarts) {
            return aStarts ? -1 : 1;
          }
          return a.title.compareTo(b.title);
        },
      );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search PedsFlow',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          TextField(
            autofocus: true,
            onChanged: (String value) {
              setState(() {
                query = value;
              });
            },
            decoration: const InputDecoration(
              hintText:
                  'Search diagnoses and admission plans...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          if (normalized.isEmpty) ...<Widget>[
            const SizedBox(height: 24),
            const _EmptySearchCard(),
          ] else ...<Widget>[
            const SizedBox(height: 22),
            _ResultHeading(
              title: 'Admission plans',
              count: plans.length,
              icon: Icons.assignment_outlined,
            ),
            const SizedBox(height: 10),
            if (plans.isEmpty)
              const _NoResultCard(
                text: 'No admission-plan matches',
              ),
            ...plans.map(
              (AdmissionPlan plan) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PlanTile(
                  plan: plan,
                  store: widget.store,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultHeading extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const _ResultHeading({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const Spacer(),
        Chip(label: Text('$count')),
      ],
    );
  }
}

class _EmptySearchCard extends StatelessWidget {
  const _EmptySearchCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.manage_search,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Search admission plans quickly',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try “Tylenol overdose”, “HSV”, “low phosphate”, '
              '“hypokalemia”, or “refeeding”.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultCard extends StatelessWidget {
  final String text;

  const _NoResultCard({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text),
      ),
    );
  }
}
