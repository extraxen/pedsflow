// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.

import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/services/text_encoding_repair.dart';

void main() {
  group('repairMojibake', () {
    test('repairs common punctuation corruption', () {
      expect(repairMojibake('Item \u00e2\u20ac\u00a2 next'), 'Item \u2022 next');
      expect(repairMojibake('10\u00e2\u20ac\u201c15'), '10\u201315');
      expect(repairMojibake('word\u00e2\u20ac\u2122s'), 'word\u2019s');
    });

    test('repairs common medical symbols', () {
      expect(repairMojibake('\u00c2\u00b0C'), '\u00b0C');
      expect(repairMojibake('\u00ce\u00bcg/kg'), '\u03bcg/kg');
      expect(repairMojibake('\u00e2\u2030\u00a4 5'), '\u2264 5');
      expect(repairMojibake('\u00e2\u2020\u2019 PICU'), '\u2192 PICU');
    });

    test('repairs double-encoded text when possible', () {
      expect(repairMojibake('\u00c3\u00a2\u00e2\u201a\u00ac\u00c2\u00a2'), '\u2022');
    });

    test('leaves valid UTF-8 text unchanged', () {
      const String text = 'Dose \u2022 10\u201315 mg/kg \u2264 500 mg \u2192 reassess \u00b0C \u03bcg';
      expect(repairMojibake(text), text);
    });

    test('repairs strings recursively in decoded JSON', () {
      final dynamic repaired = repairMojibakeJson(<String, dynamic>{
        'title': 'A \u00e2\u20ac\u00a2 B',
        'items': <dynamic>['\u00c2\u00b1', 4],
      });
      expect(repaired['title'], 'A \u2022 B');
      expect(repaired['items'][0], '\u00b1');
      expect(repaired['items'][1], 4);
    });
  });
}
