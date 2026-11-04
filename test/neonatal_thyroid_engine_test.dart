import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/endocrine/neonatal_thyroid_engine.dart';

ThyroidTriageResult evaluate(int day, double tsh, double ft4, {
  bool serum = true,
  bool preterm = false,
  bool pituitary = false,
  bool treated = false,
  ThyroidScreenStatus screen = ThyroidScreenStatus.unknown,
}) => NeonatalThyroidEngine.assess(ThyroidTriageInput(
  ageDays: day,
  tshMiuL: tsh,
  freeT4PmolL: ft4,
  serumConfirmed: serum,
  pretermOrNicu: preterm,
  pituitaryConcern: pituitary,
  onLevothyroxine: treated,
  newbornScreen: screen,
));

void main() {
  group('Source slide — exact neonatal intervals', () {
    test('TSH 0–4 days, absent day 5, 6–31 days', () {
      expect(NeonatalThyroidEngine.tshReference(0)?.low, 3.2);
      expect(NeonatalThyroidEngine.tshReference(4)?.high, 19);
      expect(NeonatalThyroidEngine.tshReference(5), isNull);
      expect(NeonatalThyroidEngine.tshReference(6)?.low, 1.7);
      expect(NeonatalThyroidEngine.tshReference(31)?.high, 9.1);
      expect(NeonatalThyroidEngine.tshReference(32)?.high, 6.3);
    });
    test('FT4 absent 0–2 days, then exact early age bands', () {
      expect(NeonatalThyroidEngine.freeT4Reference(0), isNull);
      expect(NeonatalThyroidEngine.freeT4Reference(2), isNull);
      expect(NeonatalThyroidEngine.freeT4Reference(3)?.low, 13.0);
      expect(NeonatalThyroidEngine.freeT4Reference(14)?.high, 52.2);
      expect(NeonatalThyroidEngine.freeT4Reference(15)?.low, 10.5);
      expect(NeonatalThyroidEngine.freeT4Reference(29)?.high, 30);
      expect(NeonatalThyroidEngine.freeT4Reference(30)?.high, 22.7);
    });
    test('later bands retain supplied values with approximate month cutoffs', () {
      expect(NeonatalThyroidEngine.tshReference(89)?.high, 6.3);
      expect(NeonatalThyroidEngine.tshReference(90)?.high, 4.77);
      expect(NeonatalThyroidEngine.tshReference(180)?.low, 0.61);
      expect(NeonatalThyroidEngine.freeT4Reference(119)?.high, 22.7);
      expect(NeonatalThyroidEngine.freeT4Reference(120)?.high, 22);
      expect(NeonatalThyroidEngine.freeT4Reference(365)?.high, 17.6);
      expect(NeonatalThyroidEngine.tshReference(365)?.high, 4.09);
      expect(NeonatalThyroidEngine.tshReference(5110)?.low, 0.47);
      expect(NeonatalThyroidEngine.tshReference(6935), isNull);
    });
    test('reference boundaries inclusive; no fabricated missing interval', () {
      final ref = NeonatalThyroidEngine.freeT4Reference(10);
      expect(NeonatalThyroidEngine.flag(13, ref), ThyroidValueFlag.within);
      expect(NeonatalThyroidEngine.flag(52.2, ref), ThyroidValueFlag.within);
      expect(NeonatalThyroidEngine.flag(12.9, ref), ThyroidValueFlag.below);
      expect(NeonatalThyroidEngine.flag(52.3, ref), ThyroidValueFlag.above);
      expect(NeonatalThyroidEngine.flag(5, null),
          ThyroidValueFlag.unavailable);
    });
  });

  group('Evidence-based neonatal next-step triage', () {
    test('TSH over 20 with normal FT4 in second week urgent', () {
      final r = evaluate(12, 25, 20);
      expect(r.priority, ThyroidPriority.urgent);
      expect(r.heading, contains('>20'));
      expect(r.steps.join(' '), contains('levothyroxine'));
    });
    test('low FT4 with elevated TSH urgently raises primary CH', () {
      final r = evaluate(12, 15, 11);
      expect(r.priority, ThyroidPriority.urgent);
      expect(r.heading, contains('primary CH'));
    });
    test('low FT4 with normal TSH considers central CH and adrenal', () {
      final r = evaluate(15, 3, 7, pituitary: true);
      expect(r.priority, ThyroidPriority.urgent);
      expect(r.steps.join(' ').toLowerCase(), contains('adrenal'));
    });
    test('normal FT4 and TSH 6–20 beyond 21 days require review', () {
      final r = evaluate(26, 7, 15);
      expect(r.tshFlag, ThyroidValueFlag.within);
      expect(r.priority, ThyroidPriority.followUp);
      expect(r.steps.join(' '), contains('1–2 weeks'));
      expect(evaluate(21, 7, 15).priority, ThyroidPriority.chartOnly);
      expect(evaluate(22, 6, 15).priority, ThyroidPriority.followUp);
    });
    test('abnormal NBS overrides serum values within source range', () {
      final r = evaluate(15, 4, 20,
        screen: ThyroidScreenStatus.reportedAbnormal);
      expect(r.priority, ThyroidPriority.urgent);
      expect(r.heading, contains('Abnormal newborn screen'));
    });
    test('DBS values cannot be interpreted as serum', () {
      final r = evaluate(15, 4, 20, serum: false);
      expect(r.priority, ThyroidPriority.incomplete);
      expect(r.heading, contains('serum'));
    });
    test('premature NICU despite normal values requires follow-up', () {
      final r = evaluate(18, 3, 19, preterm: true);
      expect(r.priority, ThyroidPriority.followUp);
      expect(r.steps.join(' '), contains('2–4 weeks'));
    });
    test('pituitary risk despite normal tests needs specialist review', () {
      final r = evaluate(18, 3, 19, pituitary: true);
      expect(r.priority, ThyroidPriority.followUp);
    });
    test('known LT4 therapy switches to treated-patient monitoring', () {
      final r = evaluate(18, 3, 19, treated: true);
      expect(r.priority, ThyroidPriority.followUp);
      expect(r.heading, contains('levothyroxine'));
    });
    test('first 2 days and missing day 5 TSH never reassure', () {
      expect(evaluate(1, 10, 19).priority, ThyroidPriority.followUp);
      expect(evaluate(5, 10, 20).priority, ThyroidPriority.followUp);
    });
    test('suppressed TSH and high FT4 prompts thyrotoxicosis review', () {
      final r = evaluate(10, 0.1, 60);
      expect(r.priority, ThyroidPriority.urgent);
      expect(r.heading, contains('thyrotoxicosis'));
    });
    test('missing FT4 requires both paired serum measurements', () {
      final r = NeonatalThyroidEngine.assess(
        const ThyroidTriageInput(ageDays: 14, tshMiuL: 7,
          serumConfirmed: true));
      expect(r.priority, ThyroidPriority.incomplete);
    });
    test('invalid ages, NaN and negative laboratory values fail closed', () {
      expect(evaluate(-1, 10, 15).priority, ThyroidPriority.incomplete);
      expect(evaluate(15, double.nan, 15).priority,
          ThyroidPriority.incomplete);
      expect(evaluate(15, -1, 15).priority, ThyroidPriority.incomplete);
      expect(evaluate(15, 5, double.infinity).priority,
          ThyroidPriority.incomplete);
    });
  });
}
