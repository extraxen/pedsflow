import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/endocrine/calcium_hub_math.dart';

void main() {
  group('Health Canada calcium intake age boundaries', () {
    test('infant AI and child RDA use completed months', () {
      const values = <int, int>{
        0: 200, 6: 200, 7: 260, 11: 260, 12: 700,
        47: 700, 48: 1000, 107: 1000,
        108: 1300, 227: 1300,
      };
      values.forEach((age, target) {
        expect(CalciumHubMath.ageCalciumTargetMgPerDay(age), target);
      });
      expect(CalciumHubMath.infantAdequateIntake(11), isTrue);
      expect(CalciumHubMath.infantAdequateIntake(12), isFalse);
      expect(CalciumHubMath.ageCalciumTargetMgPerDay(-1), isNull);
      expect(CalciumHubMath.ageCalciumTargetMgPerDay(228), isNull);
      expect(CalciumHubMath.ageCalciumTargetMgPerDay(null), isNull);
    });
    test('percent and difference are arithmetic, not dosing', () {
      expect(CalciumHubMath.dailyCalciumDifferenceMg(
        ageMonths: 60, reportedDailyIntakeMg: 450), 550);
      expect(CalciumHubMath.percentOfCalciumTarget(
        ageMonths: 60, reportedDailyIntakeMg: 450), closeTo(45, 1e-10));
      expect(CalciumHubMath.dailyCalciumDifferenceMg(
        ageMonths: 60, reportedDailyIntakeMg: 1200), -200);
      expect(CalciumHubMath.percentOfCalciumTarget(
        ageMonths: 60, reportedDailyIntakeMg: 0), 0);
      for (final input in <double?>[null, -1, double.nan,
                                    double.infinity, 10001]) {
        expect(CalciumHubMath.dailyCalciumDifferenceMg(
          ageMonths: 60, reportedDailyIntakeMg: input), isNull);
        expect(CalciumHubMath.percentOfCalciumTarget(
          ageMonths: 60, reportedDailyIntakeMg: input), isNull);
      }
    });
  });

  group('Urine ratio and elemental label arithmetic', () {
    test('same-unit spot urine calcium / creatinine ratio', () {
      expect(CalciumHubMath.urineCalciumCreatinineRatioMmolPerMmol(
        calciumMmolL: 2.5, creatinineMmolL: 5), 0.5);
    });
    test('invalid creatinine and wrong bounds suppressed', () {
      for (final denominator in <double?>[null, 0, -1, double.nan]) {
        expect(CalciumHubMath.urineCalciumCreatinineRatioMmolPerMmol(
          calciumMmolL: 2.5, creatinineMmolL: denominator), isNull);
      }
      expect(CalciumHubMath.urineCalciumCreatinineRatioMmolPerMmol(
        calciumMmolL: double.infinity, creatinineMmolL: 5), isNull);
    });
    test('calcium salt amount times user-labelled elemental percentage', () {
      expect(CalciumHubMath.elementalCalciumFromLabel(
        saltMassMg: 1250, labelledElementalPercent: 40), 500);
      expect(CalciumHubMath.elementalCalciumFromLabel(
        saltMassMg: 400, labelledElementalPercent: 0), 0);
      expect(CalciumHubMath.elementalCalciumFromLabel(
        saltMassMg: 100, labelledElementalPercent: 101), isNull);
      expect(CalciumHubMath.elementalCalciumFromLabel(
        saltMassMg: 100, labelledElementalPercent: null), isNull);
      expect(CalciumHubMath.elementalCalciumFromLabel(
        saltMassMg: -100, labelledElementalPercent: 40), isNull);
    });
  });

  group('Qualitative PTH response interpretation', () {
    test('severe symptoms override lab categories', () {
      final result = CalciumHubMath.interpretation(
        calcium: CalciumStatus.unknown,
        pth: PthStatus.unknown, seriousSymptoms: true);
      expect(result.needsUrgentClinicalAssessment, isTrue);
      expect(result.heading, contains('urgent'));
    });
    test('low calcium with normal PTH is inappropriate', () {
      final result = CalciumHubMath.interpretation(
        calcium: CalciumStatus.low, pth: PthStatus.withinRange);
      expect(result.heading, contains('inappropriately low PTH'));
      expect(result.interpretation, contains('hypoparathyroidism'));
    });
    test('high calcium with normal PTH is non-suppressed', () {
      final result = CalciumHubMath.interpretation(
        calcium: CalciumStatus.high, pth: PthStatus.withinRange);
      expect(result.heading, contains('non-suppressed'));
      expect(result.interpretation, contains('CaSR'));
    });
    test('high calcium and low PTH suggest non-PTH cause', () {
      final result = CalciumHubMath.interpretation(
        calcium: CalciumStatus.high, pth: PthStatus.low);
      expect(result.heading, contains('suppressed PTH'));
      expect(result.interpretation, contains('subcutaneous fat necrosis'));
    });
    test('low calcium high PTH flags vitamin D renal problems', () {
      final result = CalciumHubMath.interpretation(
        calcium: CalciumStatus.low, pth: PthStatus.high);
      expect(result.interpretation, contains('vitamin D'));
    });
    test('normal calcium does not exclude delayed abnormality', () {
      final result = CalciumHubMath.interpretation(
        calcium: CalciumStatus.withinRange,
        pth: PthStatus.unknown);
      expect(result.interpretation, contains('later hypocalcemia'));
    });
  });
}
