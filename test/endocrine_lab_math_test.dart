import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/endocrine/endocrine_lab_math.dart';

void main() {
  group('Glucocorticoid anti-inflammatory equivalences', () {
    test('classical oral/IV reference: prednisone 5 to hydrocortisone 20', () {
      expect(EndocrineLabMath.steroidEquivalent(
        sourceDoseMg: 5, from: SteroidAgent.prednisone,
        to: SteroidAgent.hydrocortisone), closeTo(20, 1e-9));
      expect(EndocrineLabMath.steroidEquivalent(
        sourceDoseMg: 20, from: SteroidAgent.hydrocortisone,
        to: SteroidAgent.methylprednisolone), closeTo(4, 1e-9));
    });
    test('classic dexamethasone 0.75 and betamethasone 0.6 table', () {
      expect(EndocrineLabMath.steroidEquivalent(
        sourceDoseMg: 20, from: SteroidAgent.hydrocortisone,
        to: SteroidAgent.dexamethasone), 0.75);
      expect(EndocrineLabMath.steroidEquivalent(
        sourceDoseMg: 0.6, from: SteroidAgent.betamethasone,
        to: SteroidAgent.prednisolone), 5);
    });
    test('daily equivalent requires actual administration count', () {
      expect(EndocrineLabMath.steroidDailyEquivalent(
        sourceDoseMg: 30, administrationsPerDay: 4,
        from: SteroidAgent.hydrocortisone,
        to: SteroidAgent.prednisolone), 30);
      expect(EndocrineLabMath.steroidDailyEquivalent(
        sourceDoseMg: 30, administrationsPerDay: null,
        from: SteroidAgent.hydrocortisone,
        to: SteroidAgent.prednisolone), isNull);
    });
    test('empty, zero, negative, infinite, extreme rejected', () {
      for (final d in <double?>[null, 0, -2, 1001,
          double.infinity, double.nan]) {
        expect(EndocrineLabMath.steroidEquivalent(
          sourceDoseMg: d, from: SteroidAgent.prednisone,
          to: SteroidAgent.hydrocortisone), isNull);
      }
      expect(EndocrineLabMath.steroidDailyEquivalent(
        sourceDoseMg: 5, administrationsPerDay: 0,
        from: SteroidAgent.prednisone, to: SteroidAgent.hydrocortisone),
        isNull);
    });
  });

  group('Corrected sodium', () {
    test('reference Katz/Hillier example, glucose 300 mg/dL', () {
      expect(EndocrineLabMath.correctedSodium(
        measuredNaMmolL: 130, glucoseMgDl: 300,
        correctionPer100MgDl: 1.6), closeTo(133.2, 1e-9));
      expect(EndocrineLabMath.correctedSodium(
        measuredNaMmolL: 130, glucoseMgDl: 300,
        correctionPer100MgDl: 2.4), closeTo(134.8, 1e-9));
    });
    test('100 mg/dL has zero correction', () {
      expect(EndocrineLabMath.correctedSodium(
        measuredNaMmolL: 135, glucoseMgDl: 100,
        correctionPer100MgDl: 1.6), 135);
    });
    test('CPS formula independent of historic correction rules', () {
      expect(EndocrineLabMath.cpsDkaCorrectedSodium(
        measuredNaMmolL: 130, glucoseMmolL: 20), closeTo(134.5, 1e-9));
    });
    test('glucose conversions and invalid inputs', () {
      expect(EndocrineLabMath.glucoseMgDl(10), closeTo(180.182, 1e-6));
      expect(EndocrineLabMath.correctedSodium(
        measuredNaMmolL: 130, glucoseMgDl: 80,
        correctionPer100MgDl: 2.4), isNull);
      expect(EndocrineLabMath.correctedSodium(
        measuredNaMmolL: 130, glucoseMgDl: 300,
        correctionPer100MgDl: 1.0), isNull);
      expect(EndocrineLabMath.correctedSodium(
        measuredNaMmolL: 130, glucoseMgDl: double.nan,
        correctionPer100MgDl: 1.6), isNull);
      expect(EndocrineLabMath.cpsDkaCorrectedSodium(
        measuredNaMmolL: -2, glucoseMmolL: 20), isNull);
    });
  });

  group('Serum anion gap', () {
    test('Na - (Cl + bicarbonate)', () {
      expect(EndocrineLabMath.serumAnionGap(
        sodiumMmolL: 140, chlorideMmolL: 100,
        bicarbonateMmolL: 12), 28);
    });
    test('albumin 20 g/L increases AG by 5', () {
      expect(EndocrineLabMath.albuminAdjustedAnionGap(
        anionGapMmolL: 13, albuminGL: 20), 18);
    });
    test('missing and invalid quantities fail closed', () {
      expect(EndocrineLabMath.serumAnionGap(
        sodiumMmolL: null, chlorideMmolL: 100,
        bicarbonateMmolL: 12), isNull);
      expect(EndocrineLabMath.serumAnionGap(
        sodiumMmolL: 140, chlorideMmolL: -2,
        bicarbonateMmolL: 12), isNull);
      expect(EndocrineLabMath.serumAnionGap(
        sodiumMmolL: 140, chlorideMmolL: 100,
        bicarbonateMmolL: double.infinity), isNull);
      expect(EndocrineLabMath.albuminAdjustedAnionGap(
        anionGapMmolL: 13, albuminGL: 45), isNull);
    });
  });

  group('Serum osmolarity', () {
    test('effective = 2Na + glucose; total adds urea mmol/L', () {
      expect(EndocrineLabMath.effectiveOsmolarity(
        sodiumMmolL: 140, glucoseMmolL: 10), 290);
      expect(EndocrineLabMath.calculatedTotalOsmolarity(
        sodiumMmolL: 140, glucoseMmolL: 10, ureaMmolL: 5), 295);
      expect(EndocrineLabMath.osmolalGap(
        measuredOsmolalityMOsmKg: 306,
        calculatedTotalOsmolarity: 295), 11);
    });
    test('urea absent still permits effective but not total', () {
      expect(EndocrineLabMath.effectiveOsmolarity(
        sodiumMmolL: 140, glucoseMmolL: 10), 290);
      expect(EndocrineLabMath.calculatedTotalOsmolarity(
        sodiumMmolL: 140, glucoseMmolL: 10, ureaMmolL: null), isNull);
    });
    test('zero, negative, extreme and NaN input handling', () {
      expect(EndocrineLabMath.effectiveOsmolarity(
        sodiumMmolL: 0, glucoseMmolL: 10), isNull);
      expect(EndocrineLabMath.calculatedTotalOsmolarity(
        sodiumMmolL: 140, glucoseMmolL: 10, ureaMmolL: -1), isNull);
      expect(EndocrineLabMath.calculatedTotalOsmolarity(
        sodiumMmolL: 140, glucoseMmolL: double.nan, ureaMmolL: 10),
        isNull);
      expect(EndocrineLabMath.osmolalGap(
        measuredOsmolalityMOsmKg: 306,
        calculatedTotalOsmolarity: null), isNull);
    });
  });
}
