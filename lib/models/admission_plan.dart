class PlanSection {
  final int number;
  final String label;
  final String text;

  const PlanSection({
    required this.number,
    required this.label,
    required this.text,
  });

  factory PlanSection.fromJson(Map<String, dynamic> json) {
    return PlanSection(
      number: json['number'] as int,
      label: json['label'] as String,
      text: json['text'] as String,
    );
  }
}

class TreatmentItem {
  final String group;
  final String text;

  const TreatmentItem({
    required this.group,
    required this.text,
  });

  factory TreatmentItem.fromJson(Map<String, dynamic> json) {
    return TreatmentItem(
      group: json['group'] as String,
      text: json['text'] as String,
    );
  }
}

class AdmissionPlan {
  final int id;
  final String title;
  final String category;
  final List<String> aliases;
  final String summary;
  final List<PlanSection> sections;
  final List<TreatmentItem> treatments;
  final String guidance;
  final String contentStatus;
  final String lastUpdated;
  final List<String> sourceLabels;

  const AdmissionPlan({
    required this.id,
    required this.title,
    required this.category,
    required this.aliases,
    required this.summary,
    required this.sections,
    required this.treatments,
    required this.guidance,
    required this.contentStatus,
    required this.lastUpdated,
    required this.sourceLabels,
  });

  factory AdmissionPlan.fromJson(Map<String, dynamic> json) {
    return AdmissionPlan(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      aliases: List<String>.from(
        (json['aliases'] as List<dynamic>?) ?? <dynamic>[],
      ),
      summary: json['summary'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map(
            (dynamic item) => PlanSection.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      treatments: (json['treatments'] as List<dynamic>)
          .map(
            (dynamic item) => TreatmentItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      guidance: (json['guidance'] as String?) ?? '',
      contentStatus: (json['contentStatus'] as String?) ??
          'Verify current local pathway',
      lastUpdated:
          (json['lastUpdated'] as String?) ?? 'Not recorded',
      sourceLabels: List<String>.from(
        (json['sourceLabels'] as List<dynamic>?) ?? <dynamic>[],
      ),
    );
  }
}
