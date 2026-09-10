// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.

import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/pager/pager_mode_data.dart';
import 'package:pediatric_night_companion/features/pager/pager_mode_models.dart';

void main() {
  test('Pager Mode ships a complete initial overnight-call library', () {
    expect(pagerTopics.length, greaterThanOrEqualTo(12));
    expect(
      pagerTopics.map((PagerTopic topic) => topic.id).toSet().length,
      pagerTopics.length,
    );

    for (final PagerTopic topic in pagerTopics) {
      expect(topic.title, isNotEmpty);
      expect(topic.goNowIf, isNotEmpty);
      expect(topic.sections.length, greaterThanOrEqualTo(6));
      expect(topic.sources, isNotEmpty);
      for (final String key in topic.doseKeys) {
        expect(pagerDoses.containsKey(key), isTrue, reason: topic.title);
      }
    }
  });

  test('weight-based emergency dose arithmetic applies maximums', () {
    final PagerDose epinephrine = pagerDoses['epinephrine_im']!;
    final PagerDose lorazepam = pagerDoses['lorazepam_iv']!;
    final PagerDose crystalloid = pagerDoses['crystalloid_10']!;

    expect(epinephrine.calculate(12), closeTo(0.12, 0.0001));
    expect(epinephrine.calculate(80), 0.5);
    expect(epinephrine.isCapped(80), isTrue);
    expect(lorazepam.calculate(20), 2);
    expect(lorazepam.calculate(60), 4);
    expect(crystalloid.calculate(18), 180);
  });

  test('high-risk pager topics are labeled for immediate response', () {
    for (final String id in <String>[
      'desaturation',
      'work_of_breathing',
      'poor_perfusion',
      'altered_mental_status',
      'seizure',
      'hypoglycemia',
      'anaphylaxis',
    ]) {
      expect(pagerTopicById(id)?.urgency, PagerUrgency.immediate, reason: id);
    }
  });
}
