// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'dart:async';

import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'services/app_store.dart';
import 'theme/pedsflow_theme.dart';
import 'widgets/global_app_status.dart';

void main() {
  runApp(const PedsFlowApp());
}

class PedsFlowApp extends StatefulWidget {
  const PedsFlowApp({super.key});

  @override
  State<PedsFlowApp> createState() => _PedsFlowAppState();
}

class _PedsFlowAppState extends State<PedsFlowApp>
    with WidgetsBindingObserver {
  final AppStore store = AppStore();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    store.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && store.ready) {
      unawaited(store.checkForUpdate());
      unawaited(store.restoreWakeLockIfNeeded());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    store.dispose();
    super.dispose();
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
          return GlobalAppStatus(
            store: store,
            child: AppShell(store: store),
          );
        },
      ),
    );
  }
}
