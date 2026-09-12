// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/services/app_store.dart';
import 'package:pediatric_night_companion/widgets/global_app_status.dart';

void main() {
  testWidgets('Awake unsupported state does not replace the app surface',
      (WidgetTester tester) async {
    final AppStore store = AppStore();

    await tester.pumpWidget(
      MaterialApp(
        home: GlobalAppStatus(
          store: store,
          child: const Scaffold(body: Text('Clinical content')),
        ),
      ),
    );

    await tester.tap(find.text('Awake'));
    await tester.pumpAndSettle();

    expect(find.text('Clinical content'), findsOneWidget);
    expect(
      find.text('Keep Screen Awake is not available in this browser.'),
      findsOneWidget,
    );
  });

  testWidgets('clinical disclaimer opens within the app navigator',
      (WidgetTester tester) async {
    final AppStore store = AppStore();

    await tester.pumpWidget(
      MaterialApp(
        home: GlobalAppStatus(
          store: store,
          child: const Scaffold(body: Text('Clinical content')),
        ),
      ),
    );

    await tester.tap(find.textContaining('Clinical reference'));
    await tester.pumpAndSettle();

    expect(find.text('Clinical safety disclaimer'), findsOneWidget);
    expect(find.text('I understand'), findsOneWidget);
  });
}
