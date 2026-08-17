// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/admission_plan.dart';
import '../models/algorithm_item.dart';
import '../models/antibiotic_guide.dart';
import '../models/medication_monograph.dart';

class AppStore extends ChangeNotifier {
  List<AdmissionPlan> plans = <AdmissionPlan>[];
  Set<int> favorites = <int>{};
  List<int> recent = <int>[];

  List<MedicationMonograph> medications = <MedicationMonograph>[];
  Set<int> medicationFavorites = <int>{};
  List<int> recentMedications = <int>[];

  List<AlgorithmItem> algorithms = <AlgorithmItem>[];
  AntibioticGuideData? antibioticGuide;

  Map<String, String> sectionOverrides = <String, String>{};
  Map<String, String> treatmentOverrides = <String, String>{};

  bool ready = false;

  Future<void> initialize() async {
    final String raw =
        await rootBundle.loadString('assets/admission_plans.json');
    final String medicationsRaw =
        await rootBundle.loadString('assets/medications_300.json');
    final String antibioticRaw =
        await rootBundle.loadString('assets/antibiotic_guide.json');

    plans = (jsonDecode(raw) as List<dynamic>)
        .map(
          (dynamic item) => AdmissionPlan.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    medications = (jsonDecode(medicationsRaw) as List<dynamic>)
        .map(
          (dynamic item) => MedicationMonograph.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    antibioticGuide = AntibioticGuideData.fromJson(
      jsonDecode(antibioticRaw) as Map<String, dynamic>,
    );

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    favorites = _intSet(
      preferences.getStringList('favorites'),
    );
    recent = _intList(
      preferences.getStringList('recent'),
    );

    medicationFavorites = _intSet(
      preferences.getStringList('medication_favorites_v1'),
    );
    recentMedications = _intList(
      preferences.getStringList('recent_medications_v1'),
    );

    final String? algorithmsJson =
        preferences.getString('algorithms_v1');
    if (algorithmsJson != null && algorithmsJson.isNotEmpty) {
      algorithms = (jsonDecode(algorithmsJson) as List<dynamic>)
          .map(
            (dynamic item) => AlgorithmItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    sectionOverrides = _stringMapFromJson(
      preferences.getString('section_overrides_v1'),
    );
    treatmentOverrides = _stringMapFromJson(
      preferences.getString('treatment_overrides_v1'),
    );

    ready = true;
    notifyListeners();
  }

  Set<int> _intSet(List<String>? values) {
    return (values ?? <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  List<int> _intList(List<String>? values) {
    return (values ?? <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .toList();
  }

  Map<String, String> _stringMapFromJson(String? value) {
    if (value == null || value.isEmpty) {
      return <String, String>{};
    }
    return Map<String, String>.from(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }

  AdmissionPlan? planById(int id) {
    for (final AdmissionPlan plan in plans) {
      if (plan.id == id) {
        return plan;
      }
    }
    return null;
  }

  MedicationMonograph? medicationById(int id) {
    for (final MedicationMonograph medication in medications) {
      if (medication.id == id) {
        return medication;
      }
    }
    return null;
  }

  MedicationMonograph? medicationByName(String name) {
    final String normalized = name.trim().toLowerCase();
    for (final MedicationMonograph medication in medications) {
      if (medication.name.toLowerCase() == normalized ||
          medication.aliases.any(
            (String alias) => alias.toLowerCase() == normalized,
          )) {
        return medication;
      }
    }
    return null;
  }

  List<MedicationMonograph> medicationsMentionedIn(String text) {
    final String normalized = text.toLowerCase();
    final List<MedicationMonograph> matches =
        <MedicationMonograph>[];

    for (final MedicationMonograph medication in medications) {
      final List<String> terms = <String>[
        medication.name,
        ...medication.aliases,
      ];

      final bool found = terms.any((String term) {
        final String value = term.trim().toLowerCase();
        if (value.length < 4) {
          return false;
        }
        return normalized.contains(value);
      });

      if (found) {
        matches.add(medication);
      }
    }

    matches.sort(
      (MedicationMonograph a, MedicationMonograph b) =>
          a.name.compareTo(b.name),
    );
    return matches;
  }

  Future<void> toggleFavorite(int id) async {
    favorites.contains(id)
        ? favorites.remove(id)
        : favorites.add(id);

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    await preferences.setStringList(
      'favorites',
      favorites.map((int id) => '$id').toList(),
    );
    notifyListeners();
  }

  Future<void> markRecent(int id) async {
    recent.remove(id);
    recent.insert(0, id);
    if (recent.length > 8) {
      recent = recent.take(8).toList();
    }

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    await preferences.setStringList(
      'recent',
      recent.map((int id) => '$id').toList(),
    );
    notifyListeners();
  }

  Future<void> toggleMedicationFavorite(int id) async {
    medicationFavorites.contains(id)
        ? medicationFavorites.remove(id)
        : medicationFavorites.add(id);

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    await preferences.setStringList(
      'medication_favorites_v1',
      medicationFavorites.map((int id) => '$id').toList(),
    );
    notifyListeners();
  }

  Future<void> markMedicationRecent(int id) async {
    recentMedications.remove(id);
    recentMedications.insert(0, id);
    if (recentMedications.length > 12) {
      recentMedications =
          recentMedications.take(12).toList();
    }

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    await preferences.setStringList(
      'recent_medications_v1',
      recentMedications.map((int id) => '$id').toList(),
    );
    notifyListeners();
  }

  String sectionText(
    AdmissionPlan plan,
    int sectionIndex,
  ) {
    final String key = '${plan.id}:$sectionIndex';
    return sectionOverrides[key] ??
        plan.sections[sectionIndex].text;
  }

  String treatmentText(
    AdmissionPlan plan,
    int treatmentIndex,
  ) {
    final String key = '${plan.id}:$treatmentIndex';
    return treatmentOverrides[key] ??
        plan.treatments[treatmentIndex].text;
  }

  Future<void> updateSection(
    AdmissionPlan plan,
    int sectionIndex,
    String value,
  ) async {
    final String key = '${plan.id}:$sectionIndex';
    final String original = plan.sections[sectionIndex].text;

    if (value.trim() == original.trim()) {
      sectionOverrides.remove(key);
    } else {
      sectionOverrides[key] = value.trim();
    }

    await _persistOverrides();
    notifyListeners();
  }

  Future<void> updateTreatment(
    AdmissionPlan plan,
    int treatmentIndex,
    String value,
  ) async {
    final String key = '${plan.id}:$treatmentIndex';
    final String original = plan.treatments[treatmentIndex].text;

    if (value.trim() == original.trim()) {
      treatmentOverrides.remove(key);
    } else {
      treatmentOverrides[key] = value.trim();
    }

    await _persistOverrides();
    notifyListeners();
  }

  Future<void> resetPlanEdits(AdmissionPlan plan) async {
    sectionOverrides.removeWhere(
      (String key, String value) =>
          key.startsWith('${plan.id}:'),
    );
    treatmentOverrides.removeWhere(
      (String key, String value) =>
          key.startsWith('${plan.id}:'),
    );

    await _persistOverrides();
    notifyListeners();
  }

  bool planHasEdits(AdmissionPlan plan) {
    return sectionOverrides.keys.any(
          (String key) => key.startsWith('${plan.id}:'),
        ) ||
        treatmentOverrides.keys.any(
          (String key) => key.startsWith('${plan.id}:'),
        );
  }

  Future<void> saveAlgorithm(AlgorithmItem item) async {
    algorithms.insert(0, item);
    await _persistAlgorithms();
    notifyListeners();
  }

  Future<void> deleteAlgorithm(String id) async {
    algorithms.removeWhere(
      (AlgorithmItem item) => item.id == id,
    );
    await _persistAlgorithms();
    notifyListeners();
  }

  Future<String> exportBackupJson() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final Map<String, String> notes = <String, String>{};
    for (final String key in preferences.getKeys()) {
      if (key.startsWith('notes_')) {
        final String? value = preferences.getString(key);
        if (value != null) {
          notes[key] = value;
        }
      }
    }

    final Map<String, dynamic> backup = <String, dynamic>{
      'schema': 'pedsflow-backup-v1',
      'appVersion': '16.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'planFavorites': favorites.toList(),
      'recentPlans': recent,
      'medicationFavorites': medicationFavorites.toList(),
      'recentMedications': recentMedications,
      'sectionOverrides': sectionOverrides,
      'treatmentOverrides': treatmentOverrides,
      'notes': notes,
      'algorithms': algorithms
          .map((AlgorithmItem item) => item.toJson())
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  Future<void> importBackupJson(String raw) async {
    final dynamic decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Backup must contain a JSON object.',
      );
    }

    if (decoded['schema'] != 'pedsflow-backup-v1') {
      throw const FormatException(
        'This is not a supported PedsFlow backup.',
      );
    }

    favorites = _dynamicIntSet(decoded['planFavorites']);
    recent = _dynamicIntList(decoded['recentPlans']);
    medicationFavorites =
        _dynamicIntSet(decoded['medicationFavorites']);
    recentMedications =
        _dynamicIntList(decoded['recentMedications']);

    sectionOverrides = Map<String, String>.from(
      (decoded['sectionOverrides']
              as Map<String, dynamic>?) ??
          <String, dynamic>{},
    );
    treatmentOverrides = Map<String, String>.from(
      (decoded['treatmentOverrides']
              as Map<String, dynamic>?) ??
          <String, dynamic>{},
    );

    algorithms =
        ((decoded['algorithms'] as List<dynamic>?) ??
                <dynamic>[])
            .map(
              (dynamic item) => AlgorithmItem.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await preferences.setStringList(
      'favorites',
      favorites.map((int id) => '$id').toList(),
    );
    await preferences.setStringList(
      'recent',
      recent.map((int id) => '$id').toList(),
    );
    await preferences.setStringList(
      'medication_favorites_v1',
      medicationFavorites.map((int id) => '$id').toList(),
    );
    await preferences.setStringList(
      'recent_medications_v1',
      recentMedications.map((int id) => '$id').toList(),
    );

    await _persistOverrides();
    await _persistAlgorithms();

    for (final String key in preferences.getKeys()) {
      if (key.startsWith('notes_')) {
        await preferences.remove(key);
      }
    }

    final Map<String, dynamic> notes =
        (decoded['notes'] as Map<String, dynamic>?) ??
            <String, dynamic>{};
    for (final MapEntry<String, dynamic> entry
        in notes.entries) {
      if (entry.key.startsWith('notes_') &&
          entry.value is String) {
        await preferences.setString(
          entry.key,
          entry.value as String,
        );
      }
    }

    notifyListeners();
  }

  Set<int> _dynamicIntSet(dynamic value) {
    return _dynamicIntList(value).toSet();
  }

  List<int> _dynamicIntList(dynamic value) {
    if (value is! List<dynamic>) {
      return <int>[];
    }
    return value
        .map((dynamic item) {
          if (item is int) {
            return item;
          }
          return int.tryParse('$item');
        })
        .whereType<int>()
        .toList();
  }

  Future<void> _persistAlgorithms() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      'algorithms_v1',
      jsonEncode(
        algorithms
            .map(
              (AlgorithmItem item) => item.toJson(),
            )
            .toList(),
      ),
    );
  }

  Future<void> _persistOverrides() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      'section_overrides_v1',
      jsonEncode(sectionOverrides),
    );
    await preferences.setString(
      'treatment_overrides_v1',
      jsonEncode(treatmentOverrides),
    );
  }
}
