// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.

import 'package:flutter/material.dart';

enum PagerUrgency { immediate, urgent, assess }

extension PagerUrgencyPresentation on PagerUrgency {
  String get label => switch (this) {
        PagerUrgency.immediate => 'Go now',
        PagerUrgency.urgent => 'Urgent review',
        PagerUrgency.assess => 'Assess promptly',
      };

  Color color(ColorScheme scheme) => switch (this) {
        PagerUrgency.immediate => scheme.error,
        PagerUrgency.urgent => const Color(0xFFB05B13),
        PagerUrgency.assess => scheme.primary,
      };

  Color containerColor(ColorScheme scheme) => switch (this) {
        PagerUrgency.immediate => scheme.errorContainer,
        PagerUrgency.urgent => const Color(0xFFFFE9D2),
        PagerUrgency.assess => scheme.primaryContainer,
      };
}

class PagerSection {
  final String title;
  final List<String> items;

  const PagerSection(this.title, this.items);
}

class PagerTopic {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final PagerUrgency urgency;
  final List<String> aliases;
  final List<String> goNowIf;
  final List<PagerSection> sections;
  final List<String> doseKeys;
  final List<String> sources;

  const PagerTopic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.urgency,
    required this.aliases,
    required this.goNowIf,
    required this.sections,
    this.doseKeys = const <String>[],
    required this.sources,
  });

  String get searchableText => <String>[
        title,
        subtitle,
        category,
        ...aliases,
        ...goNowIf,
        ...sections.expand((PagerSection section) => <String>[
              section.title,
              ...section.items,
            ]),
      ].join(' ').toLowerCase();
}

class PagerDose {
  final String key;
  final String label;
  final double amountPerKg;
  final String amountUnit;
  final double? maximum;
  final String? route;
  final String? concentration;
  final String note;

  const PagerDose({
    required this.key,
    required this.label,
    required this.amountPerKg,
    required this.amountUnit,
    this.maximum,
    this.route,
    this.concentration,
    required this.note,
  });

  double calculate(double weightKg) {
    final double calculated = amountPerKg * weightKg;
    if (maximum != null && calculated > maximum!) return maximum!;
    return calculated;
  }

  bool isCapped(double weightKg) =>
      maximum != null && amountPerKg * weightKg > maximum!;
}
