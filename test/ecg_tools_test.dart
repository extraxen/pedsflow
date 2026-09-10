import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/cardiology/ecg_tools.dart';

void main() {
  group('ECG rate tools', () {
    test('calculates rate from RR interval', () {
      expect(heartRateFromRrSeconds(0.5), closeTo(120, 0.001));
    });

    test('calculates regular rate from large squares', () {
      expect(heartRateFromLargeSquares(2), closeTo(150, 0.001));
      expect(
        heartRateFromLargeSquares(4, speed: 50),
        closeTo(150, 0.001),
      );
    });

    test('calculates irregular rate from strip count', () {
      expect(heartRateFromComplexes(12, 6), closeTo(120, 0.001));
    });
  });

  test('calculates Bazett and Fridericia QTc', () {
    final QtcResult result = calculateQtc(qtMs: 400, rrSeconds: 1);
    expect(result.bazettMs, closeTo(400, 0.001));
    expect(result.fridericiaMs, closeTo(400, 0.001));
  });

  group('axis helper', () {
    test('identifies positive quadrant', () {
      expect(
        classifyAxis(EcgPolarity.positive, EcgPolarity.positive).quadrant,
        EcgAxisQuadrant.normalOrRightward,
      );
    });

    test('identifies extreme quadrant', () {
      expect(
        classifyAxis(EcgPolarity.negative, EcgPolarity.negative).quadrant,
        EcgAxisQuadrant.extreme,
      );
    });
  });
}
