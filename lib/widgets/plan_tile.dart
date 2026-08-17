// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'package:flutter/material.dart';

import '../models/admission_plan.dart';
import '../screens/plan_screen.dart';
import '../services/app_store.dart';

class PlanTile extends StatelessWidget {
  final AdmissionPlan plan;
  final AppStore store;

  const PlanTile({
    super.key,
    required this.plan,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final bool favorite = store.favorites.contains(plan.id);

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        title: Text(
          plan.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(plan.category),
        trailing: IconButton(
          onPressed: () => store.toggleFavorite(plan.id),
          icon: Icon(
            favorite ? Icons.star : Icons.star_border,
          ),
        ),
        onTap: () async {
          await store.markRecent(plan.id);

          if (!context.mounted) {
            return;
          }

          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => PlanScreen(
                plan: plan,
                store: store,
              ),
            ),
          );
        },
      ),
    );
  }
}

