// PedsFlow - Proprietary Software
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
