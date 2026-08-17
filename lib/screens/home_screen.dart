// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import '../app_metadata.dart';
import '../features/growth/growth_suite_screen.dart';
import '../features/neonatal/neonatal_hub_screen.dart';
import '../features/endocrine/endocrine_hub_screen.dart';
import '../features/electrolytes/electrolyte_engine_screen.dart';
import '../features/electrolytes/hypokalemia_engine_screen.dart';
import 'package:flutter/material.dart';

import '../models/admission_plan.dart';
import '../services/app_store.dart';
import '../widgets/plan_tile.dart';
import 'escalation_screen.dart';
import 'antibiotic_guide_screen.dart';
import 'backup_screen.dart';
import 'universal_search_screen.dart';
import 'integrated_clinical_support_screen.dart';
import 'pccu_screen.dart';
import 'pain_management_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppStore store;
  final ValueChanged<int> openTab;

  const HomeScreen({
    super.key,
    required this.store,
    required this.openTab,
  });

  @override
  Widget build(BuildContext context) {
    final List<AdmissionPlan> recent = store.recent
        .map(store.planById)
        .whereType<AdmissionPlan>()
        .take(4)
        .toList();

    final List<AdmissionPlan> favorites = store.plans
        .where(
          (AdmissionPlan plan) => store.favorites.contains(plan.id),
        )
        .take(4)
        .toList();

    final int medicationsWithDoses = store.medications
        .where((medication) => medication.doseSections.isNotEmpty)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PedsFlow',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Escalation guide',
            onPressed: () => _openEscalation(context),
            icon: Icon(
              Icons.emergency_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: <Widget>[
              _WelcomePanel(
                plans: store.plans.length,
                medications: store.medications.length,
                medicationsWithDoses: medicationsWithDoses,
              ),
              const SizedBox(height: 16),
              _SearchButton(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          UniversalSearchScreen(store: store),
                    ),
                  );
                },
              ),
              const SizedBox(height: 26),
              const _SectionHeading(
                title: 'Clinical tools',
                subtitle: 'Fast access without oversized dashboard cards',
              ),
              const SizedBox(height: 12),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.assignment_outlined,
                  secondaryIcon: Icons.check_rounded,
                  background: Color(0xFFDDF3F1),
                  accent: Color(0xFF08756F),
                ),
                title: 'Admission plans',
                subtitle: 'Browse ${store.plans.length} diagnosis-specific plans',
                meta: '${store.plans.length} plans',
                onTap: () => openTab(1),
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.medication_outlined,
                  secondaryIcon: Icons.add_rounded,
                  background: Color(0xFFE3ECFA),
                  accent: Color(0xFF315FA8),
                ),
                title: 'Medication library',
                subtitle: 'IV, oral and route-specific dose sections',
                meta: '$medicationsWithDoses with doses',
                onTap: () => openTab(2),
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.calculate_outlined,
                  secondaryIcon: Icons.water_drop_outlined,
                  background: Color(0xFFE1F2E8),
                  accent: Color(0xFF24764E),
                ),
                title: 'Calculators',
                subtitle: 'Fluids, doses, electrolytes, BSA and QTc',
                meta: '23+ tools',
                onTap: () => openTab(3),
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.show_chart,
                  secondaryIcon: Icons.straighten_outlined,
                  background: Color(0xFFE8F4F8),
                  accent: Color(0xFF27677A),
                ),
                title: 'Growth Suite',
                subtitle: 'Corrected age, longitudinal growth, BMI and velocity with WHO/CDC/Fenton/INTERGROWTH framework',
                meta: 'Growth',
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GrowthSuiteScreen())),
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.child_care_outlined,
                  secondaryIcon: Icons.water_drop_outlined,
                  background: Color(0xFFF2ECFA),
                  accent: Color(0xFF6D4C8E),
                ),
                title: 'Neonatal Hub',
                subtitle: 'Bilirubin, glucose, EOS, fluids/GIR, feeds, corrected GA and newborn resuscitation',
                meta: 'Neonatal',
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NeonatalHubScreen())),
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.hub_outlined,
                  secondaryIcon: Icons.water_drop_outlined,
                  background: Color(0xFFE7F3EE),
                  accent: Color(0xFF176B4D),
                ),
                title: 'Endocrine Hub',
                subtitle: 'DKA, adrenal crisis, hypoglycemia, DI/SIADH, calcium, thyroid and insulin tools',
                meta: 'Endocrine',
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const EndocrineHubScreen())),
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.science_outlined,
                  secondaryIcon: Icons.bolt_outlined,
                  background: Color(0xFFFFF0D2),
                  accent: Color(0xFF99610C),
                ),
                title: 'Electrolyte Replacement Engine',
                subtitle: 'Potassium, sodium, magnesium, phosphate and calcium replacement safety',
                meta: 'K • Na • Mg • PO₄ • Ca',
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ElectrolyteEngineScreen())),
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.bolt_outlined,
                  secondaryIcon: Icons.water_drop_outlined,
                  background: Color(0xFFFFF0D2),
                  accent: Color(0xFF99610C),
                ),
                title: 'Hypokalemia replacement engine',
                subtitle: 'Oral/IV KCl, current-fluid potassium, infusion rate, fluid burden and monitoring',
                meta: 'Electrolytes',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const HypokalemiaEngineScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.healing_outlined,
                  secondaryIcon: Icons.favorite_outline,
                  background: Color(0xFFF7E7F0),
                  accent: Color(0xFF9B3F72),
                ),
                title: 'Pediatric pain management',
                subtitle: 'Mild to severe pain, sickle-cell, SJS/TEN, opioids and naloxone',
                meta: '12 pathways',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const PainManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.biotech_outlined,
                  secondaryIcon: Icons.shield_outlined,
                  background: Color(0xFFFFF0D2),
                  accent: Color(0xFF99610C),
                ),
                title: 'Antibiotics & organisms',
                subtitle: 'Syndrome-based empiric approach and spectrum pearls',
                meta: '12 syndromes',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          AntibioticGuideScreen(store: store),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.monitor_heart_outlined,
                  secondaryIcon: Icons.bolt_outlined,
                  background: Color(0xFFFFE8E8),
                  accent: Color(0xFF9E2A2A),
                ),
                title: 'PCCU',
                subtitle: '14 PCCU categories, comprehensive pathways, medication pages and critical-care calculators',
                meta: '',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const PccuScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.health_and_safety_outlined,
                  secondaryIcon: Icons.bolt_outlined,
                  background: Color(0xFFE7F3EE),
                  accent: Color(0xFF176B4D),
                ),
                title: 'ED/PICU decision support',
                subtitle: 'Electrolytes, EMR order sets, antibiotics and emergency algorithms',
                meta: '',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const IntegratedClinicalSupportScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.photo_library_outlined,
                  secondaryIcon: Icons.auto_awesome_outlined,
                  background: Color(0xFFF0E6F6),
                  accent: Color(0xFF795097),
                ),
                title: 'Algorithm library',
                subtitle: 'Save, categorize and zoom clinical images',
                meta: '${store.algorithms.length} saved',
                onTap: () => openTab(5),
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.backup_outlined,
                  secondaryIcon: Icons.restore_outlined,
                  background: Color(0xFFE7ECF8),
                  accent: Color(0xFF4967A9),
                ),
                title: 'Backup & restore',
                subtitle: 'Protect favourites, notes, edits and algorithms',
                meta: 'Local data',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          BackupScreen(store: store),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.emergency_outlined,
                  secondaryIcon: Icons.bolt_rounded,
                  background: Color(0xFFFCE5E7),
                  accent: Color(0xFFB4232F),
                ),
                title: 'Escalation guide',
                subtitle: 'Immediate red flags organized by system',
                meta: 'Emergency',
                warning: true,
                onTap: () => _openEscalation(context),
              ),
              if (recent.isNotEmpty) ...<Widget>[
                const SizedBox(height: 28),
                const _SectionHeading(
                  title: 'Recent',
                  subtitle: 'Continue where you left off',
                ),
                const SizedBox(height: 10),
                ...recent.map(
                  (AdmissionPlan plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PlanTile(plan: plan, store: store),
                  ),
                ),
              ],
              if (favorites.isNotEmpty) ...<Widget>[
                const SizedBox(height: 28),
                const _SectionHeading(
                  title: 'Favorites',
                  subtitle: 'Your most-used admission plans',
                ),
                const SizedBox(height: 10),
                ...favorites.map(
                  (AdmissionPlan plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PlanTile(plan: plan, store: store),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.health_and_safety_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 9),
                          const Text(
                            'Clinical disclaimer',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'PedsFlow is an educational and clinical-support reference '
                        'developed by Dr. Ahmed Saleh. It is intended to assist '
                        'clinicians and trainees and does not replace institutional '
                        'policies, pharmacist consultation, or clinical judgment. '
                        'Medication information should always be verified against '
                        'current Canadian references and local protocols before '
                        'prescribing.',
                        style: TextStyle(height: 1.45),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      'PedsFlow v$pedsFlowVersionLabel',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text('Release: $pedsFlowReleaseDate'),
                    const SizedBox(height: 3),
                    const Text('Copyright (c) 2026 Dr. Ahmed Saleh'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _openEscalation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const EscalationScreen(),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  final int plans;
  final int medications;
  final int medicationsWithDoses;

  const _WelcomePanel({
    required this.plans,
    required this.medications,
    required this.medicationsWithDoses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFFDDF3F1),
            Color(0xFFF3F8FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBBDDD9),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF173B57).withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 620;
          final Widget copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pediatric clinical companion',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                'Developed by Dr. Ahmed Saleh',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Organized for fast overnight use on desktop and iPhone.',
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _MetricChip(text: '$plans plans'),
                  _MetricChip(text: '$medications medications'),
                  _MetricChip(text: '$medicationsWithDoses with doses'),
                  _MetricChip(text: 'v$pedsFlowVersion'),
                ],
              ),
            ],
          );

          final Widget illustration = const _HeroIllustration();

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                copy,
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: illustration,
                ),
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: copy),
              const SizedBox(width: 24),
              illustration,
            ],
          );
        },
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 112,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            right: 8,
            top: 4,
            child: Container(
              width: 98,
              height: 98,
              decoration: BoxDecoration(
                color: const Color(0xFFBFE3DF).withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 22,
            child: Transform.rotate(
              angle: -0.10,
              child: Container(
                width: 82,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFB9CBE5),
                  ),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 34,
                  color: Color(0xFF315FA8),
                ),
              ),
            ),
          ),
          Positioned(
            right: 5,
            bottom: 5,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF0A6F75),
                borderRadius: BorderRadius.circular(20),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF173B57).withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medication_outlined,
                size: 31,
                color: Colors.white,
              ),
            ),
          ),
          const Positioned(
            left: 4,
            bottom: 8,
            child: Icon(
              Icons.auto_awesome,
              size: 20,
              color: Color(0xFF795097),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 0.5,
      shadowColor: const Color(0xFF173B57).withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          child: Row(
            children: <Widget>[
              Icon(Icons.search),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search diagnoses and admission plans',
                ),
              ),
              Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClinicalToolRow extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String subtitle;
  final String meta;
  final VoidCallback onTap;
  final bool warning;

  const _ClinicalToolRow({
    required this.illustration,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.onTap,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = warning
        ? Theme.of(context).colorScheme.errorContainer
        : Theme.of(context).colorScheme.surface;
    final Color border = warning
        ? Theme.of(context).colorScheme.error.withValues(alpha: 0.22)
        : Theme.of(context).colorScheme.outline;

    return Material(
      color: background,
      elevation: warning ? 0 : 0.4,
      shadowColor: const Color(0xFF173B57).withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: <Widget>[
              illustration,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (meta.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      meta,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                )
              else
                const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _IllustratedBadge extends StatelessWidget {
  final IconData icon;
  final IconData secondaryIcon;
  final Color background;
  final Color accent;

  const _IllustratedBadge({
    required this.icon,
    required this.secondaryIcon,
    required this.background,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 62,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 31, color: accent),
            ),
          ),
          Positioned(
            right: -3,
            top: -4,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 3,
                ),
              ),
              child: Icon(
                secondaryIcon,
                size: 14,
                color: background,
              ),
            ),
          ),
          Positioned(
            left: 7,
            bottom: 7,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String text;

  const _MetricChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFC7E1DE)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 3),
        Text(subtitle),
      ],
    );
  }
}
