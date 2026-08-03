import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/main.dart';

void main() {
  testWidgets(
    'PedsFlow app widget can be created',
    (WidgetTester tester) async {
      await tester.pumpWidget(const PedsFlowApp());
      expect(find.byType(PedsFlowApp), findsOneWidget);
    },
  );
}
