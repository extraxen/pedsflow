// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'services/app_store.dart';
import 'theme/pedsflow_theme.dart';

void main() {
  runApp(const PedsFlowApp());
}

class PedsFlowApp extends StatefulWidget {
  const PedsFlowApp({super.key});

  @override
  State<PedsFlowApp> createState() => _PedsFlowAppState();
}

class _PedsFlowAppState extends State<PedsFlowApp> {
  final AppStore store = AppStore();

  @override
  void initState() {
    super.initState();
    store.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PedsFlow',
      themeMode: ThemeMode.light,
      theme: PedsFlowTheme.light(),
      home: AnimatedBuilder(
        animation: store,
        builder: (context, child) {
          if (!store.ready) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return AppShell(store: store);
        },
      ),
    );
  }
}

