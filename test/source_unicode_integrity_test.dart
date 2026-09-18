import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dart source contains no known mojibake markers', () {
    const List<String> markers = <String>[
      'â',
      'Ã',
      'Â',
      'Î',
      'Ï',
      '├',
      'Γ',
      '┬',
      '╬',
      '�',
    ];

    final List<String> offenders = <String>[];
    final Directory lib = Directory('lib');

    for (final FileSystemEntity entity in lib.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final String source = entity.readAsStringSync();
      for (final String marker in markers) {
        if (source.contains(marker)) {
          offenders.add('${entity.path}: contains "$marker"');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Known UTF-8/Windows-1252/CP437 mojibake markers must not be '
          'committed to Dart UI source. Use proper Unicode characters.',
    );
  });
}
