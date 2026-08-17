// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.

class AntibioticGuideData {
  final String lastReviewed;
  final String jurisdiction;
  final String warning;
  final List<AntibioticSyndrome> syndromes;
  final List<CoveragePearl> coveragePearls;

  const AntibioticGuideData({
    required this.lastReviewed,
    required this.jurisdiction,
    required this.warning,
    required this.syndromes,
    required this.coveragePearls,
  });

  factory AntibioticGuideData.fromJson(Map<String, dynamic> json) {
    return AntibioticGuideData(
      lastReviewed: json['lastReviewed'] as String,
      jurisdiction: json['jurisdiction'] as String,
      warning: json['warning'] as String,
      syndromes: (json['syndromes'] as List<dynamic>)
          .map((dynamic item) => AntibioticSyndrome.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
      coveragePearls: (json['coveragePearls'] as List<dynamic>)
          .map((dynamic item) => CoveragePearl.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
    );
  }
}

class AntibioticSyndrome {
  final String title;
  final String category;
  final List<String> organisms;
  final String approach;
  final List<String> linkedDrugs;

  const AntibioticSyndrome({
    required this.title,
    required this.category,
    required this.organisms,
    required this.approach,
    required this.linkedDrugs,
  });

  factory AntibioticSyndrome.fromJson(Map<String, dynamic> json) {
    return AntibioticSyndrome(
      title: json['title'] as String,
      category: json['category'] as String,
      organisms: List<String>.from(json['organisms'] as List<dynamic>),
      approach: json['approach'] as String,
      linkedDrugs: List<String>.from(json['linkedDrugs'] as List<dynamic>),
    );
  }
}

class CoveragePearl {
  final String title;
  final String text;

  const CoveragePearl({
    required this.title,
    required this.text,
  });

  factory CoveragePearl.fromJson(Map<String, dynamic> json) {
    return CoveragePearl(
      title: json['title'] as String,
      text: json['text'] as String,
    );
  }
}

