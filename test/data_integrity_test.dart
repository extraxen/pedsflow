
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('admission plan asset contains exactly 200 plans', () async {
    final String raw =
        await rootBundle.loadString('assets/admission_plans.json');
    final List<dynamic> plans = jsonDecode(raw) as List<dynamic>;
    expect(plans.length, equals(200));
    for (final dynamic item in plans) {
      final Map<String, dynamic> plan = item as Map<String, dynamic>;
      expect(plan['title'], isNotEmpty);
      expect((plan['sections'] as List<dynamic>).length, 12);
    }
  });

  test('medication catalogue contains 300 entries', () async {
    final String raw =
        await rootBundle.loadString('assets/medications_300.json');
    final List<dynamic> medications = jsonDecode(raw) as List<dynamic>;
    expect(medications.length, 300);
  });

  test('medication dose coverage remains measurable', () async {
    final String raw =
        await rootBundle.loadString('assets/medications_300.json');
    final List<dynamic> medications =
        jsonDecode(raw) as List<dynamic>;
    final int withDoses = medications.where(
      (dynamic item) =>
          ((item as Map<String, dynamic>)['doseSections']
                  as List<dynamic>)
              .isNotEmpty,
    ).length;
    expect(withDoses, greaterThanOrEqualTo(200));
  });

  test('antibiotic guide contains syndrome and coverage data', () async {
    final String raw =
        await rootBundle.loadString('assets/antibiotic_guide.json');
    final Map<String, dynamic> guide =
        jsonDecode(raw) as Map<String, dynamic>;
    expect((guide['syndromes'] as List<dynamic>).length,
        greaterThanOrEqualTo(10));
    expect((guide['coveragePearls'] as List<dynamic>).isNotEmpty, isTrue);
  });
}
