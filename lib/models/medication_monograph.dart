// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
class MedicationMonograph {
  final int id;
  final String name;
  final String category;
  final List<String> aliases;
  final List<MedicationLinkedPlan> linkedPlans;
  final String summary;
  final String doseStatus;
  final String administration;
  final String monitoring;
  final String warnings;
  final List<String> sourceLabels;
  final String verificationStatus;
  final String sourceSummary;
  final String currentCanadianMonograph;
  final List<MedicationDoseSection> doseSections;

  const MedicationMonograph({
    required this.id,
    required this.name,
    required this.category,
    required this.aliases,
    required this.linkedPlans,
    required this.summary,
    required this.doseStatus,
    required this.administration,
    required this.monitoring,
    required this.warnings,
    required this.sourceLabels,
    required this.verificationStatus,
    required this.sourceSummary,
    required this.currentCanadianMonograph,
    required this.doseSections,
  });

  factory MedicationMonograph.fromJson(Map<String, dynamic> json) {
    return MedicationMonograph(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      aliases: List<String>.from(json['aliases'] as List<dynamic>),
      linkedPlans: (json['linkedPlans'] as List<dynamic>)
          .map((dynamic item) => MedicationLinkedPlan.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
      summary: (json['summary'] as String?) ?? '',
      doseStatus: (json['doseStatus'] as String?) ?? '',
      administration: (json['administration'] as String?) ?? '',
      monitoring: (json['monitoring'] as String?) ?? '',
      warnings: (json['warnings'] as String?) ?? '',
      sourceLabels: List<String>.from(
        (json['sourceLabels'] as List<dynamic>?) ?? <dynamic>[],
      ),
      verificationStatus: (json['verificationStatus'] as String?) ?? '',
      sourceSummary: (json['sourceSummary'] as String?) ?? '',
      currentCanadianMonograph:
          (json['currentCanadianMonograph'] as String?) ?? '',
      doseSections: ((json['doseSections'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic item) => MedicationDoseSection.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
    );
  }
}

class MedicationDoseSection {
  final String title;
  final String routeGroup;
  final String text;
  final String source;
  final String sourceDate;
  final bool requiresVerification;

  const MedicationDoseSection({
    required this.title,
    required this.routeGroup,
    required this.text,
    required this.source,
    required this.sourceDate,
    required this.requiresVerification,
  });

  factory MedicationDoseSection.fromJson(Map<String, dynamic> json) {
    return MedicationDoseSection(
      title: json['title'] as String,
      routeGroup: json['routeGroup'] as String,
      text: json['text'] as String,
      source: json['source'] as String,
      sourceDate: json['sourceDate'] as String,
      requiresVerification: json['requiresVerification'] as bool? ?? true,
    );
  }
}

class MedicationLinkedPlan {
  final int planId;
  final String planTitle;
  final String category;
  final String excerpt;

  const MedicationLinkedPlan({
    required this.planId,
    required this.planTitle,
    required this.category,
    required this.excerpt,
  });

  factory MedicationLinkedPlan.fromJson(Map<String, dynamic> json) {
    return MedicationLinkedPlan(
      planId: json['planId'] as int,
      planTitle: json['planTitle'] as String,
      category: json['category'] as String,
      excerpt: json['excerpt'] as String,
    );
  }
}

