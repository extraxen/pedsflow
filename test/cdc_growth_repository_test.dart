import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/features/growth/cdc_growth_repository.dart';
import 'package:pediatric_night_companion/features/growth/growth_reference_engine.dart';

void main() {
  test('parses official CDC-style LMS CSV rows', () {
    const csv =
        'Sex,Agemos,L,M,S,P3\n'
        '1,24,-0.20615,12.67076,0.108126,10.1\n'
        '1,25.5,-0.23979,12.88102,0.108275,10.2\n'
        '2,24,-0.73534,12.05504,0.107399,9.5\n';

    final rows = CdcGrowthRepository.parseCsv(csv);
    expect(rows.length, 3);
    expect(rows.first.sex, GrowthSex.male);
    expect(rows.first.ageMonths, 24);
    expect(rows.first.m, closeTo(12.67076, 1e-8));
  });
}
