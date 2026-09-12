// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.

import 'package:flutter/material.dart';

import '../services/app_store.dart';

class GlobalAppStatus extends StatelessWidget {
  final AppStore store;
  final Widget child;

  const GlobalAppStatus({
    super.key,
    required this.store,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: child,
          ),
        ),
        _ClinicalSafetyBar(store: store),
      ],
    );
  }
}

class _ClinicalSafetyBar extends StatelessWidget {
  final AppStore store;

  const _ClinicalSafetyBar({required this.store});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colors.outlineVariant),
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () => _showClinicalDisclaimer(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.health_and_safety_outlined, size: 17),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Clinical reference • Verify doses and local policy',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(Icons.info_outline, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 26,
                color: colors.outlineVariant,
              ),
              TextButton.icon(
                onPressed: () async {
                  final bool enabled = !store.keepScreenAwake;
                  final bool applied =
                      await store.setKeepScreenAwake(enabled);
                  if (context.mounted && enabled && !applied) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Keep Screen Awake is not available in this browser.',
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(
                  store.keepScreenAwake
                      ? Icons.lightbulb
                      : Icons.lightbulb_outline,
                  color: store.keepScreenAwake ? colors.primary : null,
                ),
                label: Text(
                  store.keepScreenAwake ? 'Awake on' : 'Awake',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showClinicalDisclaimer(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Clinical safety disclaimer',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              const Text(
                'PedsFlow is an educational clinical decision-support reference '
                'for healthcare professionals. It does not replace bedside '
                'assessment, clinical judgment, supervision, pharmacist review, '
                'or current institutional policies and emergency pathways.',
                style: TextStyle(height: 1.45),
              ),
              const SizedBox(height: 12),
              const Text(
                'Before patient care, independently verify the indication, current '
                'measured weight, age, dose, concentration, maximum dose, route, '
                'frequency, allergies, interactions, renal and hepatic function, '
                'contraindications, monitoring, and local formulary. Source '
                'recommendations can change after publication.',
                style: TextStyle(height: 1.45),
              ),
              const SizedBox(height: 12),
              const Text(
                'For an unstable patient, prioritize immediate stabilization and '
                'activate local emergency, senior, and critical-care support. Do '
                'not enter patient-identifiable information. PedsFlow is not '
                'intended for public self-diagnosis or self-treatment.',
                style: TextStyle(height: 1.45),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('I understand'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
