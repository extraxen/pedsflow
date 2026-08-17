import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/growth/lms_engine.dart';

void main() {
  test('CDC published LMS example returns expected z-score', () {
    const LmsPoint point = LmsPoint(l: -0.1600954, m: 9.476500305, s: 0.11218624);
    final double z = LmsEngine.zScore(measurement: 9.7, point: point);
    expect(z, closeTo(0.207, 0.002));
    expect(LmsEngine.percentileFromZ(z), closeTo(58.2, 0.5));
  });
}
