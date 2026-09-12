// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.

import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/services/app_version.dart';

void main() {
  group('AvailableAppVersion', () {
    test('recognizes a newer build', () {
      final AvailableAppVersion version =
          AvailableAppVersion.fromJson(<String, dynamic>{
        'version': '20.11.0',
        'build_number': '2110',
      });

      expect(version.version, '20.11.0');
      expect(version.buildNumber, 2110);
      expect(version.isNewerThan(2100), isTrue);
      expect(version.isNewerThan(2110), isFalse);
    });

    test('rejects an incomplete response', () {
      expect(
        () => AvailableAppVersion.fromJson(<String, dynamic>{
          'version': '20.11.0',
        }),
        throwsFormatException,
      );
    });
  });
}
