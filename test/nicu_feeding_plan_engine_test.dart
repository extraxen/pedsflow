import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/neonatal/nicu_feeding_plan_engine.dart';

void main() {
  group('NICU starting feeds', () {
    test('<1 kg gives 1 mL q4h', () {
      final result = NicuFeedingPlanEngine.startingFeedForWeightKg(0.82);
      expect(result.mlPerFeed, 1);
      expect(result.intervalHours, 4);
      expect(result.mlPerDay, 6);
    });

    test('1 to 1.5 kg gives 1 mL q2h', () {
      final result = NicuFeedingPlanEngine.startingFeedForWeightKg(1.25);
      expect(result.mlPerFeed, 1);
      expect(result.intervalHours, 2);
      expect(result.mlPerDay, 12);
    });

    test('>2.5 kg gives 10 mL q3h', () {
      final result = NicuFeedingPlanEngine.startingFeedForWeightKg(3.0);
      expect(result.mlPerFeed, 10);
      expect(result.intervalHours, 3);
      expect(result.mlPerDay, 80);
    });
  });

  test('current feeds calculate mL/kg/day correctly', () {
    final value = NicuFeedingPlanEngine.enteralMlKgDay(
      weightKg: 1.14,
      mlPerFeed: 8,
      intervalHours: 3,
    );
    expect(value, closeTo(56.14035, 0.0001));
  });

  test('donor milk criteria trigger for birth weight <=2 kg', () {
    final reasons = NicuFeedingPlanEngine.donorMilkEligibilityReasons(
      birthWeightKg: 1.9,
      gaWeeks: 35,
      gaDays: 0,
    );
    expect(reasons, contains('Birth weight ≤2 kg'));
  });

  group('TPN pathways', () {
    test('25+4 weeks uses 100 mL/kg/day pathway', () {
      final result = NicuFeedingPlanEngine.tpnPathway(
        gaWeeks: 25,
        gaDays: 4,
        birthWeightKg: 0.82,
      );
      expect(result.tfiMlKgDay, 100);
      expect(result.title, '24+0 to 25+6 weeks');
    });

    test('23+0 weeks uses 120 mL/kg/day pathway', () {
      final result = NicuFeedingPlanEngine.tpnPathway(
        gaWeeks: 23,
        gaDays: 0,
        birthWeightKg: 0.6,
      );
      expect(result.tfiMlKgDay, 120);
    });

    test('exact 26+0 under 1.5 kg is flagged for verification', () {
      final result = NicuFeedingPlanEngine.tpnPathway(
        gaWeeks: 26,
        gaDays: 0,
        birthWeightKg: 1.1,
      );
      expect(result.boundaryNeedsVerification, isTrue);
      expect(result.tfiMlKgDay, isNull);
    });
  });

  test('fortification milestone starts at 100 mL/kg/day', () {
    expect(NicuFeedingPlanEngine.fortificationMilestoneReached(99.9), isFalse);
    expect(NicuFeedingPlanEngine.fortificationMilestoneReached(100), isTrue);
  });

  test('TPN milestone recognizes 75 percent enteral contribution', () {
    expect(
      NicuFeedingPlanEngine.tpnDiscontinuationMilestone(
        enteralMlKgDay: 80,
        enteralPercentOfTotalFluids: 75,
      ),
      isTrue,
    );
  });

  test('IV milestone requires >=130 and fortified tolerated', () {
    expect(
      NicuFeedingPlanEngine.ivDiscontinuationMilestone(
        enteralMlKgDay: 130,
        fortifiedFeedsTolerated: false,
      ),
      isFalse,
    );
    expect(
      NicuFeedingPlanEngine.ivDiscontinuationMilestone(
        enteralMlKgDay: 130,
        fortifiedFeedsTolerated: true,
      ),
      isTrue,
    );
  });
}
