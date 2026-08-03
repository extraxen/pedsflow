import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/bilirubin/bilirubin_engine.dart';

void main() {
  group('BilirubinEngine', () {
    test('matches 40 week 24 hour reference thresholds', () {
      final double photo = BilirubinEngine.phototherapyThreshold(
        gestationalWeeks: 40,
        ageHours: 24,
        additionalNeurotoxicityRisk: false,
      );
      final double exchange = BilirubinEngine.exchangeThreshold(
        gestationalWeeks: 40,
        ageHours: 24,
        additionalNeurotoxicityRisk: false,
      );
      expect(photo / 17.1, closeTo(13.3, 0.01));
      expect(exchange / 17.1, closeTo(21.4, 0.01));
    });

    test('interpolates between table anchors', () {
      final double at24 = BilirubinEngine.phototherapyThreshold(
        gestationalWeeks: 38,
        ageHours: 24,
        additionalNeurotoxicityRisk: false,
      );
      final double at36 = BilirubinEngine.phototherapyThreshold(
        gestationalWeeks: 38,
        ageHours: 36,
        additionalNeurotoxicityRisk: false,
      );
      final double at30 = BilirubinEngine.phototherapyThreshold(
        gestationalWeeks: 38,
        ageHours: 30,
        additionalNeurotoxicityRisk: false,
      );
      expect(at30, closeTo((at24 + at36) / 2, 0.01));
    });

    test('flags CPS pre-exchange zone', () {
      final double exchange = BilirubinEngine.exchangeThreshold(
        gestationalWeeks: 38,
        ageHours: 48,
        additionalNeurotoxicityRisk: false,
      );
      final BilirubinAssessment result = BilirubinEngine.assess(
        gestationalWeeks: 38,
        ageHours: 48,
        bilirubin: exchange - 20,
        unit: BilirubinUnit.micromolPerL,
        measurementType: BilirubinMeasurementType.tsb,
        additionalNeurotoxicityRisk: false,
        acuteEncephalopathySigns: false,
      );
      expect(result.zone, BilirubinZone.preExchange);
    });

    test('TcB close to treatment threshold requires TSB', () {
      final double photo = BilirubinEngine.phototherapyThreshold(
        gestationalWeeks: 38,
        ageHours: 48,
        additionalNeurotoxicityRisk: false,
      );
      final BilirubinAssessment result = BilirubinEngine.assess(
        gestationalWeeks: 38,
        ageHours: 48,
        bilirubin: photo - 40,
        unit: BilirubinUnit.micromolPerL,
        measurementType: BilirubinMeasurementType.tcb,
        additionalNeurotoxicityRisk: false,
        acuteEncephalopathySigns: false,
      );
      expect(result.requiresSerumConfirmation, isTrue);
    });
  });
}
