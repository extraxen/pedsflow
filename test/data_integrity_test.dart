import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('admission plan asset contains at least 200 complete plans', () async {
    final String raw =
        await rootBundle.loadString('assets/admission_plans.json');
    final List<dynamic> plans = jsonDecode(raw) as List<dynamic>;

    expect(plans.length, greaterThanOrEqualTo(200));

    for (final dynamic item in plans) {
      final Map<String, dynamic> plan = item as Map<String, dynamic>;
      expect(plan['title'], isNotEmpty);
      expect((plan['sections'] as List<dynamic>).length, 12);
    }
  });

  test('persistent vomiting plan includes stepwise medication safety', () async {
    final String raw =
        await rootBundle.loadString('assets/admission_plans.json');
    final List<dynamic> plans = jsonDecode(raw) as List<dynamic>;
    final Map<String, dynamic> plan = plans.cast<Map<String, dynamic>>()
        .singleWhere((Map<String, dynamic> item) => item['id'] == 219);

    expect(plan['title'], 'Persistent vomiting / cyclic vomiting syndrome');
    expect((plan['sections'] as List<dynamic>).length, 12);

    final String treatmentText = (plan['treatments'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => item['text'] as String)
        .join(' ')
        .toLowerCase();

    for (final String medication in <String>[
      'ondansetron',
      'dimenhydrinate',
      'metoclopramide',
      'prochlorperazine',
      'chlorpromazine',
      'promethazine',
      'domperidone',
      'granisetron',
      'palonosetron',
      'aprepitant',
      'fosaprepitant',
      'lorazepam',
      'scopolamine',
      'olanzapine',
      'cyproheptadine',
      'amitriptyline',
      'propranolol',
      'topiramate',
      'pizotifen',
    ]) {
      expect(treatmentText, contains(medication));
    }

    expect(treatmentText, contains('bilious'));
    expect(treatmentText, contains('qt'));
    expect(treatmentText, contains('not a primary antiemetic'));
  });

  test('peritonsillar abscess plan includes verified IV and oral antibiotics',
      () async {
    final String raw =
        await rootBundle.loadString('assets/admission_plans.json');
    final List<dynamic> plans = jsonDecode(raw) as List<dynamic>;
    final Map<String, dynamic> plan = plans.cast<Map<String, dynamic>>()
        .singleWhere((Map<String, dynamic> item) => item['id'] == 141);
    final String treatmentText = (plan['treatments'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => item['text'] as String)
        .join(' ')
        .toLowerCase();

    expect(treatmentText, contains('ampicillin-sulbactam'));
    expect(treatmentText, contains('amoxicillin-clavulanate'));
    expect(treatmentText, contains('clindamycin'));
    expect(treatmentText, contains('metronidazole 10 mg/kg/dose'));
    expect(treatmentText, contains('maximum 500 mg/dose'));
    expect(treatmentText, isNot(contains('15 mg/kg/dose')));
  });

  test('medication catalogue contains at least 300 entries', () async {
    final String raw =
        await rootBundle.loadString('assets/medications_300.json');
    final List<dynamic> medications = jsonDecode(raw) as List<dynamic>;

    expect(medications.length, greaterThanOrEqualTo(300));
  });

  test('persistent vomiting specialist medications are available', () async {
    final String raw =
        await rootBundle.loadString('assets/medications_300.json');
    final List<dynamic> medications = jsonDecode(raw) as List<dynamic>;
    final Set<String> names = medications
        .cast<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) =>
            (item['name'] as String).toLowerCase())
        .toSet();

    for (final String medication in <String>[
      'granisetron',
      'palonosetron',
      'chlorpromazine',
      'fosaprepitant',
      'scopolamine',
      'sumatriptan',
      'cyproheptadine',
      'pizotifen',
    ]) {
      expect(names, contains(medication));
    }
  });

  test('medication dose coverage remains measurable', () async {
    final String raw =
        await rootBundle.loadString('assets/medications_300.json');
    final List<dynamic> medications = jsonDecode(raw) as List<dynamic>;

    final int withDoses = medications.where(
      (dynamic item) =>
          ((item as Map<String, dynamic>)['doseSections'] as List<dynamic>)
              .isNotEmpty,
    ).length;

    expect(withDoses, greaterThanOrEqualTo(200));
  });

  test('antibiotic guide contains syndrome and coverage data', () async {
    final String raw =
        await rootBundle.loadString('assets/antibiotic_guide.json');
    final Map<String, dynamic> guide =
        jsonDecode(raw) as Map<String, dynamic>;

    expect(
      (guide['syndromes'] as List<dynamic>).length,
      greaterThanOrEqualTo(10),
    );
    expect((guide['coveragePearls'] as List<dynamic>).isNotEmpty, isTrue);
  });
}
