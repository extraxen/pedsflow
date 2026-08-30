// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.

import 'package:flutter/material.dart';

import '../features/growth/growth_suite_screen.dart';
import '../services/app_store.dart';
import 'antibiotic_guide_screen.dart';
import 'pain_management_screen.dart';
import 'plans_screen.dart';

class CtuScreen extends StatelessWidget {
  final AppStore store;

  const CtuScreen({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CTU',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Clinical Teaching Unit',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Ward tools for admission planning, antimicrobial decisions, pain management, and growth.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _CtuToolCard(
                icon: Icons.assignment_outlined,
                title: 'Admission Plans',
                subtitle:
                    '${store.plans.length} diagnosis-specific admission and management plans',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlansScreen(store: store),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _CtuToolCard(
                icon: Icons.biotech_outlined,
                title: 'Antibiotics & organisms',
                subtitle:
                    'Syndrome-based empiric approach and spectrum pearls',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AntibioticGuideScreen(store: store),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _CtuToolCard(
                icon: Icons.healing_outlined,
                title: 'Pediatric Pain Management',
                subtitle:
                    'Mild to severe pain, sickle-cell, SJS/TEN, opioids and naloxone',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PainManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _CtuToolCard(
                icon: Icons.show_chart,
                title: 'Growth Suite',
                subtitle:
                    'Corrected age, longitudinal growth, BMI, velocity, WHO/CDC/Fenton/INTERGROWTH',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const GrowthSuiteScreen(),
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

class _CtuToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CtuToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
