// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.

import 'dart:convert';

const Map<int, int> _windows1252Reverse = <int, int>{
  0x20AC: 0x80,
  0x201A: 0x82,
  0x0192: 0x83,
  0x201E: 0x84,
  0x2026: 0x85,
  0x2020: 0x86,
  0x2021: 0x87,
  0x02C6: 0x88,
  0x2030: 0x89,
  0x0160: 0x8A,
  0x2039: 0x8B,
  0x0152: 0x8C,
  0x017D: 0x8E,
  0x2018: 0x91,
  0x2019: 0x92,
  0x201C: 0x93,
  0x201D: 0x94,
  0x2022: 0x95,
  0x2013: 0x96,
  0x2014: 0x97,
  0x02DC: 0x98,
  0x2122: 0x99,
  0x0161: 0x9A,
  0x203A: 0x9B,
  0x0153: 0x9C,
  0x017E: 0x9E,
  0x0178: 0x9F,
};

const Map<String, String> _literalRepairs = <String, String>{
  '\u00e2\u20ac\u00a2': '\u2022',
  '\u00e2\u20ac\u201c': '\u2013',
  '\u00e2\u20ac\u201d': '\u2014',
  '\u00e2\u20ac\u2122': '\u2019',
  '\u00e2\u20ac\u02dc': '\u2018',
  '\u00e2\u20ac\u0153': '\u201c',
  '\u00e2\u20ac\u009d': '\u201d',
  '\u00e2\u20ac\u00a6': '\u2026',
  '\u00e2\u2020\u2019': '\u2192',
  '\u00e2\u2020\u0090': '\u2190',
  '\u00e2\u2030\u00a4': '\u2264',
  '\u00e2\u2030\u00a5': '\u2265',
  '\u00e2\u2030\u00a0': '\u2260',
  '\u00e2\u02c6\u2019': '\u2212',
  '\u00c2\u00b1': '\u00b1',
  '\u00c2\u00b0': '\u00b0',
  '\u00c2\u00b7': '\u00b7',
  '\u00c2\u00b5': '\u00b5',
  '\u00c2\u00a0': ' ',
  '\u00ce\u00bc': '\u03bc',
  '\u00ce\u00b1': '\u03b1',
  '\u00ce\u00b2': '\u03b2',
  '\u00ce\u00b3': '\u03b3',
  '\u00ce\u201d': '\u0394',
  '\u00ce\u00bb': '\u03bb',
  '\u00cf\u20ac': '\u03c0',
  '\u00c3\u2014': '\u00d7',
  '\u00c3\u00b7': '\u00f7',
};

String repairMojibake(String input) {
  String current = input;

  for (final MapEntry<String, String> entry in _literalRepairs.entries) {
    current = current.replaceAll(entry.key, entry.value);
  }

  for (int pass = 0; pass < 3; pass++) {
    if (!_looksSuspicious(current)) {
      break;
    }
    final String? decoded = _decodeWindows1252BytesAsUtf8(current);
    if (decoded == null || decoded == current) {
      break;
    }
    current = decoded;
    for (final MapEntry<String, String> entry in _literalRepairs.entries) {
      current = current.replaceAll(entry.key, entry.value);
    }
  }

  return current;
}

dynamic repairMojibakeJson(dynamic value) {
  if (value is String) {
    return repairMojibake(value);
  }
  if (value is List<dynamic>) {
    return value.map<dynamic>(repairMojibakeJson).toList();
  }
  if (value is Map<String, dynamic>) {
    return value.map<String, dynamic>(
      (String key, dynamic item) => MapEntry<String, dynamic>(
        repairMojibake(key),
        repairMojibakeJson(item),
      ),
    );
  }
  return value;
}

bool _looksSuspicious(String value) {
  const List<int> markers = <int>[
    0x00C2,
    0x00C3,
    0x00CE,
    0x00CF,
    0x00E2,
    0x00F0,
    0xFFFD,
  ];
  return value.runes.any(markers.contains);
}

String? _decodeWindows1252BytesAsUtf8(String input) {
  final List<int> bytes = <int>[];
  for (final int rune in input.runes) {
    if (rune <= 0xFF) {
      bytes.add(rune);
      continue;
    }
    final int? mapped = _windows1252Reverse[rune];
    if (mapped == null) {
      return null;
    }
    bytes.add(mapped);
  }

  try {
    return utf8.decode(bytes, allowMalformed: false);
  } on FormatException {
    return null;
  }
}
