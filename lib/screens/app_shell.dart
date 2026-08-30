// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.

import 'package:flutter/material.dart';

import '../services/app_store.dart';
import 'calculators_screen.dart';
import 'ctu_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'medications_screen.dart';
import 'pccu_screen.dart';

class AppShell extends StatefulWidget {
  final AppStore store;

  const AppShell({
    super.key,
    required this.store,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys =
      List<GlobalKey<NavigatorState>>.generate(
    6,
    (_) => GlobalKey<NavigatorState>(),
  );

  void _selectTab(int index) {
    if (index == selectedIndex) {
      // Conventional tab behavior: tapping the active tab returns that
      // section to its root screen.
      _navigatorKeys[index]
          .currentState
          ?.popUntil((Route<dynamic> route) => route.isFirst);
      return;
    }

    setState(() {
      selectedIndex = index;
    });
  }

  Widget _rootForTab(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          store: widget.store,
          openTab: _selectTab,
        );
      case 1:
        return CtuScreen(store: widget.store);
      case 2:
        return MedicationsScreen(store: widget.store);
      case 3:
        return const CalculatorsScreen();
      case 4:
        return const PccuScreen();
      case 5:
        return LibraryScreen(store: widget.store);
      default:
        return HomeScreen(
          store: widget.store,
          openTab: _selectTab,
        );
    }
  }

  Widget _tabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => _rootForTab(index),
        );
      },
    );
  }

  Future<bool> _handleSystemBack() async {
    final NavigatorState? navigator =
        _navigatorKeys[selectedIndex].currentState;

    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return false;
    }

    if (selectedIndex != 0) {
      setState(() {
        selectedIndex = 0;
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        final bool allowRootPop = await _handleSystemBack();
        if (allowRootPop && context.mounted) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: List<Widget>.generate(
            6,
            _tabNavigator,
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: _selectTab,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_hospital_outlined),
              selectedIcon: Icon(Icons.local_hospital),
              label: 'CTU',
            ),
            NavigationDestination(
              icon: Icon(Icons.medication_outlined),
              selectedIcon: Icon(Icons.medication),
              label: 'Medications',
            ),
            NavigationDestination(
              icon: Icon(Icons.calculate_outlined),
              selectedIcon: Icon(Icons.calculate),
              label: 'Calculators',
            ),
            NavigationDestination(
              icon: Icon(Icons.monitor_heart_outlined),
              selectedIcon: Icon(Icons.monitor_heart),
              label: 'PCCU',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: 'Library',
            ),
          ],
        ),
      ),
    );
  }
}
