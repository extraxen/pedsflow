from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text(encoding='utf-8-sig')


def write(path: str, text: str) -> None:
    Path(path).write_text(text, encoding='utf-8')


def replace(path: str, old: str, new: str, count: int = -1) -> None:
    text = read(path)
    if old not in text:
        raise SystemExit(f'Expected text not found in {path}: {old[:120]!r}')
    write(path, text.replace(old, new, count))


# Remove automatic updater from app lifecycle and store.
replace('lib/main.dart', '      unawaited(store.checkForUpdate());\n', '')

path = 'lib/services/app_store.dart'
text = read(path)
text = text.replace("import 'package:http/http.dart' as http;\n", '')
text = text.replace("import '../app_metadata.dart';\n", '')
text = text.replace("import 'app_version.dart';\n", '')
text = text.replace('  bool isCheckingForUpdate = false;\n  AvailableAppVersion? availableUpdate;\n', '')
text = text.replace('    await checkForUpdate();\n', '')
start = text.index('  Future<void> checkForUpdate() async {')
end = text.index('  Set<int> _intSet', start)
text = text[:start] + text[end:]
write(path, text)

# Remove Update Available banner while preserving the safety/Awake footer.
path = 'lib/widgets/global_app_status.dart'
text = read(path)
old_build = '''    return Column(
      children: <Widget>[
        if (store.availableUpdate != null)
          _UpdateBanner(store: store),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: store.availableUpdate != null,
            removeBottom: true,
            child: child,
          ),
        ),
        _ClinicalSafetyBar(store: store),
      ],
    );'''
new_build = '''    return Column(
      children: <Widget>[
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: child,
          ),
        ),
        _ClinicalSafetyBar(store: store),
      ],
    );'''
if old_build not in text:
    raise SystemExit('GlobalAppStatus build block not found')
text = text.replace(old_build, new_build, 1)
start = text.index('class _UpdateBanner extends StatelessWidget {')
end = text.index('class _ClinicalSafetyBar extends StatelessWidget {', start)
text = text[:start] + text[end:]
write(path, text)

# Keep Wake Lock bridge; remove only updater bridge.
path = 'lib/services/app_platform_web.dart'
text = read(path)
text = text.replace("\n@JS('pedsFlowInstallUpdate')\nexternal void _installUpdate();\n", '\n')
text = text.replace('\nvoid reloadForAppUpdate() => _installUpdate();\n', '\n')
write(path, text)

path = 'lib/services/app_platform_stub.dart'
text = read(path).replace('\nvoid reloadForAppUpdate() {}\n', '\n')
write(path, text)

path = 'web/index.html'
text = read(path)
marker = '    window.pedsFlowInstallUpdate = async function () {'
if marker in text:
    start = text.index(marker)
    end = text.index('    };', start) + len('    };')
    text = text[:start] + text[end:]
write(path, text)

# Conservative weight-based arithmetic service.
write('lib/services/medication_dose_calculator.dart', r'''// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.

class MedicationDoseCalculation {
  final double minimum;
  final double? maximum;
  final String unit;
  final String scope;
  final String sourceRule;

  const MedicationDoseCalculation({
    required this.minimum,
    required this.maximum,
    required this.unit,
    required this.scope,
    required this.sourceRule,
  });

  String get formattedDose {
    final String minimumText = formatMedicationDoseNumber(minimum);
    final String suffix = '$unit/$scope';
    if (maximum == null) {
      return '$minimumText $suffix';
    }
    return '$minimumText–${formatMedicationDoseNumber(maximum!)} $suffix';
  }
}

final RegExp _weightBasedDosePattern = RegExp(
  r'(\d+(?:\.\d+)?)\s*(?:(?:[-–—]|to)\s*(\d+(?:\.\d+)?))?\s*'
  r'(mg|mcg|µg|ug|g|units?)\s*/\s*kg\s*(?:/|per\s+)\s*(dose|day)\b',
  caseSensitive: false,
);

MedicationDoseCalculation? calculateMedicationDose({
  required String text,
  required double weightKg,
}) {
  if (weightKg <= 0 || weightKg > 300) {
    return null;
  }

  final List<RegExpMatch> matches =
      _weightBasedDosePattern.allMatches(text).toList();

  // Never choose between competing regimens automatically.
  if (matches.length != 1) {
    return null;
  }

  final RegExpMatch match = matches.single;
  final double? minimumPerKg = double.tryParse(match.group(1)!);
  final double? maximumPerKg = match.group(2) == null
      ? null
      : double.tryParse(match.group(2)!);
  if (minimumPerKg == null ||
      (maximumPerKg != null && maximumPerKg < minimumPerKg)) {
    return null;
  }

  String unit = match.group(3)!.toLowerCase();
  if (unit == 'µg' || unit == 'ug') {
    unit = 'mcg';
  } else if (unit == 'unit') {
    unit = 'units';
  }

  final String scope = match.group(4)!.toLowerCase();
  return MedicationDoseCalculation(
    minimum: minimumPerKg * weightKg,
    maximum: maximumPerKg == null ? null : maximumPerKg * weightKg,
    unit: unit,
    scope: scope,
    sourceRule: match.group(0)!.trim(),
  );
}

String formatMedicationDoseNumber(double value) {
  final double rounded = (value * 100).roundToDouble() / 100;
  if (rounded == rounded.roundToDouble()) {
    return rounded.toStringAsFixed(0);
  }
  if (rounded * 10 == (rounded * 10).roundToDouble()) {
    return rounded.toStringAsFixed(1);
  }
  return rounded.toStringAsFixed(2);
}
''')

# Wire patient weight into every medication dose section.
path = 'lib/screens/medications_screen.dart'
text = read(path)
text = text.replace(
    "import '../services/app_store.dart';\n",
    "import '../services/app_store.dart';\nimport '../services/medication_dose_calculator.dart';\n",
    1,
)
text = text.replace(
    '_DoseSectionCard(section: section),',
    '_DoseSectionCard(section: section, store: widget.store),',
    1,
)
start = text.index('class _DoseSectionCard extends StatelessWidget {')
end = text.index('class _TextSection extends StatelessWidget {', start)
dose_card = r'''class _DoseSectionCard extends StatelessWidget {
  final MedicationDoseSection section;
  final AppStore store;

  const _DoseSectionCard({
    required this.section,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? child) {
        final double? weightKg = store.sessionWeightKg;
        final MedicationDoseCalculation? calculation = weightKg == null
            ? null
            : calculateMedicationDose(
                text: section.text,
                weightKg: weightKg,
              );
        final bool historical =
            section.source.toLowerCase().contains('pccu') ||
                section.sourceDate.contains('2003');
        final ColorScheme colors = Theme.of(context).colorScheme;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: historical
              ? colors.errorContainer
              : colors.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Chip(label: Text(section.routeGroup)),
                  ],
                ),
                if (calculation != null && weightKg != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Calculated for ${formatMedicationDoseNumber(weightKg)} kg',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          calculation.formattedDose,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'From ${calculation.sourceRule}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Arithmetic aid only — verify indication, maximum dose, frequency, route, concentration, and local policy before ordering.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 9),
                SelectableText(
                  section.text,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  section.source,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(section.sourceDate),
                if (historical) ...<Widget>[
                  const SizedBox(height: 8),
                  const Text(
                    'Historical local reference — verify against the current local protocol.',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

'''
text = text[:start] + dose_card + text[end:]
write(path, text)

# Clarify what the weight field does.
path = 'lib/widgets/session_weight_bar.dart'
text = read(path)
text = text.replace(
    "? 'Session weight'\n                              : 'Session weight: ${_formatWeight(weight)} kg'",
    "? 'Patient weight for dose calculations'\n                              : 'Dose calculation weight: ${_formatWeight(weight)} kg'",
)
text = text.replace(
    "'Clears on restart • Verify measured weight and every dose'",
    "'Used only this session • Supported weight-based doses calculate automatically'",
)
write(path, text)

# Calculator unit tests.
write('test/medication_dose_calculator_test.dart', r'''// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.

import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/services/medication_dose_calculator.dart';

void main() {
  group('calculateMedicationDose', () {
    test('calculates a single mg/kg/dose rule', () {
      final MedicationDoseCalculation? result = calculateMedicationDose(
        text: 'Give 10 mg/kg/dose IV every 6 hours.',
        weightKg: 18,
      );
      expect(result, isNotNull);
      expect(result!.formattedDose, '180 mg/dose');
      expect(result.sourceRule, '10 mg/kg/dose');
    });

    test('calculates a dose range', () {
      final MedicationDoseCalculation? result = calculateMedicationDose(
        text: 'Use 10–15 mg/kg/dose PO.',
        weightKg: 20,
      );
      expect(result, isNotNull);
      expect(result!.formattedDose, '200–300 mg/dose');
    });

    test('normalizes microgram units', () {
      final MedicationDoseCalculation? result = calculateMedicationDose(
        text: '5 mcg/kg/dose IV.',
        weightKg: 12,
      );
      expect(result, isNotNull);
      expect(result!.formattedDose, '60 mcg/dose');
    });

    test('calculates a daily rule without presenting it as a dose', () {
      final MedicationDoseCalculation? result = calculateMedicationDose(
        text: '30 mg/kg/day divided every 8 hours.',
        weightKg: 10,
      );
      expect(result, isNotNull);
      expect(result!.formattedDose, '300 mg/day');
    });

    test('does not choose between competing regimens', () {
      final MedicationDoseCalculation? result = calculateMedicationDose(
        text: 'Mild: 10 mg/kg/dose. Severe: 20 mg/kg/dose.',
        weightKg: 20,
      );
      expect(result, isNull);
    });

    test('ignores non-weight-based text', () {
      expect(
        calculateMedicationDose(
          text: 'Give 250 mg PO every 8 hours.',
          weightKg: 20,
        ),
        isNull,
      );
    });
  });
}
''')

# Remove updater-only source/tests/version manifest.
for filename in [
    'lib/services/app_version.dart',
    'test/app_version_test.dart',
    'version.json',
]:
    p = Path(filename)
    if p.exists():
        p.unlink()

# Remove updater-only direct HTTP dependency.
replace('pubspec.yaml', '  http: ^1.6.0\n', '')
path = 'pubspec.lock'
text = read(path).replace(
    '  http:\n    dependency: "direct main"\n',
    '  http:\n    dependency: transitive\n',
)
write(path, text)

# Release metadata.
replace('pubspec.yaml', 'version: 20.10.1+2101', 'version: 20.10.2+2102')
path = 'lib/app_metadata.dart'
text = read(path)
text = text.replace("const String pedsFlowVersion = '20.10.1';", "const String pedsFlowVersion = '20.10.2';")
text = text.replace('const int pedsFlowBuildNumber = 2101;', 'const int pedsFlowBuildNumber = 2102;')
text = text.replace("const String pedsFlowVersionLabel = '20.10.1+2101';", "const String pedsFlowVersionLabel = '20.10.2+2102';")
write(path, text)

path = 'README.md'
text = read(path)
text = text.replace('**Version:** 20.10.1+2101', '**Version:** 20.10.2+2102')
text = text.replace('- Automatic version checks with an Update Available action\n', '')
text = text.replace(
    '- Session-only patient weight bar across the medication library and monographs\n',
    '- Session-only patient weight calculator that shows supported weight-based medication doses while preserving the source rule for verification\n',
)
write(path, text)
