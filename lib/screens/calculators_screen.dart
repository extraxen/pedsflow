// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import '../features/neonatal/neonatal_hub_screen.dart';
import '../features/endocrine/endocrine_hub_screen.dart';
import '../features/electrolytes/electrolyte_engine_screen.dart';
import '../features/electrolytes/hypokalemia_engine_screen.dart';
import '../features/dka/dka_calculator_screen.dart';
import '../features/bilirubin/bilirubin_screen.dart';
import 'pediatric_reference_screen.dart';
import 'pccu_screen.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_CalculatorItem> calculators = <_CalculatorItem>[
      _CalculatorItem(
        title: 'Neonatal Hub',
        subtitle: 'Bilirubin, glucose, EOS, fluids/GIR, feeds, corrected GA and resuscitation',
        icon: Icons.child_care_outlined,
        screen: const NeonatalHubScreen(),
      ),
      _CalculatorItem(
        title: 'Endocrine Hub',
        subtitle: 'DKA, adrenal crisis, glucose, DI/SIADH, calcium, thyroid and insulin tools',
        icon: Icons.hub_outlined,
        screen: const EndocrineHubScreen(),
      ),
      _CalculatorItem(
        title: 'Electrolyte Replacement Engine',
        subtitle: 'K, Na, Mg, phosphate and calcium safety workflows',
        icon: Icons.science_outlined,
        screen: const ElectrolyteEngineScreen(),
      ),
      _CalculatorItem(
        title: 'Hypokalemia replacement engine',
        subtitle: 'Oral vs IV KCl, background-fluid potassium, concentration, fluid burden and monitoring',
        icon: Icons.bolt_outlined,
        screen: const HypokalemiaEngineScreen(),
      ),
      _CalculatorItem(
        title: 'PCCU & critical care',
        subtitle: 'Ventilation, vasoactives, oxygenation, cardiac and monitoring tools',
        icon: Icons.monitor_heart_outlined,
        screen: const PccuCalculatorsScreen(),
      ),
      _CalculatorItem(
        title: 'CPS neonatal bilirubin',
        subtitle: 'Advanced phototherapy, exchange, ╬öTSB, TcB and rebound support',
        icon: Icons.wb_sunny_outlined,
        screen: const BilirubinScreen(),
      ),
      _CalculatorItem(
        title: 'Pediatric reference & growth',
        subtitle: 'Vital signs, BP/MAP thresholds and WHO growth percentiles',
        icon: Icons.show_chart,
        screen: const PediatricReferenceScreen(),
      ),
      _CalculatorItem(
        title: 'Pediatric DKA',
        subtitle: 'Native CPS/TREKK assessment, fluids, insulin and monitoring',
        icon: Icons.water_drop_outlined,
        screen: const DkaCalculatorScreen(),
      ),
      _CalculatorItem(
        title: 'Maintenance fluids',
        subtitle: '4-2-1 and 100-50-20',
        icon: Icons.water_drop_outlined,
        screen: const MaintenanceCalculator(),
      ),
      _CalculatorItem(
        title: 'Hypernatremic dehydration',
        subtitle: 'Deficit, sodium target, fluid comparison and monitoring',
        icon: Icons.water_drop_outlined,
        screen: const HypernatremicDehydrationCalculator(),
      ),
      _CalculatorItem(
        title: 'Bolus volume',
        subtitle: 'mL/kg ├ù weight',
        icon: Icons.bloodtype_outlined,
        screen: const BolusCalculator(),
      ),
      _CalculatorItem(
        title: 'Medication dose',
        subtitle: 'mg/kg, maximum dose, and mL',
        icon: Icons.medication_outlined,
        screen: const MedicationDoseCalculator(),
      ),
      _CalculatorItem(
        title: 'Corrected sodium',
        subtitle: 'Hyperglycemia correction',
        icon: Icons.science_outlined,
        screen: const CorrectedSodiumCalculator(),
      ),
      _CalculatorItem(
        title: 'Anion gap',
        subtitle: 'Na ΓêÆ (Cl + HCOΓéâ)',
        icon: Icons.calculate_outlined,
        screen: const AnionGapCalculator(),
      ),
      _CalculatorItem(
        title: 'Corrected calcium',
        subtitle: 'Albumin-adjusted calcium',
        icon: Icons.biotech_outlined,
        screen: const CorrectedCalciumCalculator(),
      ),
      _CalculatorItem(
        title: 'Body surface area',
        subtitle: 'Mosteller formula',
        icon: Icons.accessibility_new_outlined,
        screen: const BsaCalculator(),
      ),
      _CalculatorItem(
        title: 'QTc',
        subtitle: 'Bazett correction',
        icon: Icons.monitor_heart_outlined,
        screen: const QtcCalculator(),
      ),
      _CalculatorItem(
        title: 'Glucose infusion rate',
        subtitle: 'GIR from dextrose concentration and rate',
        icon: Icons.water_drop_outlined,
        screen: const GirCalculator(),
      ),
      _CalculatorItem(
        title: 'Calculated osmolality',
        subtitle: '2Na + glucose + urea',
        icon: Icons.science_outlined,
        screen: const OsmolalityCalculator(),
      ),
      _CalculatorItem(
        title: 'Fractional excretion of sodium',
        subtitle: 'FENa percentage',
        icon: Icons.filter_alt_outlined,
        screen: const FenaCalculator(),
      ),
      _CalculatorItem(
        title: 'Bedside Schwartz eGFR',
        subtitle: '0.413 ├ù height / creatinine',
        icon: Icons.biotech_outlined,
        screen: const EgfrCalculator(),
      ),
      _CalculatorItem(
        title: 'Ideal body weight',
        subtitle: 'Pediatric BMI-at-50th-percentile approximation',
        icon: Icons.accessibility_new_outlined,
        screen: const IdealBodyWeightCalculator(),
      ),
      _CalculatorItem(
        title: 'Fluid deficit',
        subtitle: 'Weight ├ù dehydration percentage',
        icon: Icons.opacity_outlined,
        screen: const FluidDeficitCalculator(),
      ),
      _CalculatorItem(
        title: 'Sodium deficit',
        subtitle: '(Target Na ΓêÆ measured Na) ├ù TBW',
        icon: Icons.science_outlined,
        screen: const SodiumDeficitCalculator(),
      ),
      _CalculatorItem(
        title: 'Free-water deficit',
        subtitle: 'TBW ├ù (Na/target ΓêÆ 1)',
        icon: Icons.water_outlined,
        screen: const FreeWaterDeficitCalculator(),
      ),
      _CalculatorItem(
        title: 'Mean arterial pressure',
        subtitle: '(SBP + 2├ùDBP) / 3',
        icon: Icons.monitor_heart_outlined,
        screen: const MapCalculator(),
      ),
      _CalculatorItem(
        title: 'P/F ratio',
        subtitle: 'PaOΓéé / FiOΓéé',
        icon: Icons.air_outlined,
        screen: const PfRatioCalculator(),
      ),
      _CalculatorItem(
        title: 'Corrected gestational age',
        subtitle: 'Gestational age at birth + chronological age',
        icon: Icons.child_care_outlined,
        screen: const CorrectedGestationalAgeCalculator(),
      ),
      _CalculatorItem(
        title: 'BMI',
        subtitle: 'kg / height┬▓',
        icon: Icons.straighten_outlined,
        screen: const BmiCalculator(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculators',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: calculators.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final _CalculatorItem item = calculators[index];

          return Card(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(item.icon),
              ),
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final Widget? screen = item.screen;
                if (screen == null || !context.mounted) {
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => screen,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CalculatorItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? screen;

  const _CalculatorItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.screen,
  });
}

double? _number(TextEditingController controller) {
  final double? value = double.tryParse(controller.text.trim());
  if (value == null || !value.isFinite) {
    return null;
  }
  return value;
}

class _CalculatorScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CalculatorScaffold({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: children,
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final VoidCallback onChanged;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: suffix.isEmpty ? label : '$label in $suffix',
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        onChanged: (value) => onChanged(),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final String note;

  const _ResultCard({
    required this.title,
    required this.value,
    this.note = '',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SelectableText(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (note.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(note),
            ],
          ],
        ),
      ),
    );
  }
}

class MaintenanceCalculator extends StatefulWidget {
  const MaintenanceCalculator({super.key});

  @override
  State<MaintenanceCalculator> createState() =>
      _MaintenanceCalculatorState();
}

class _MaintenanceCalculatorState
    extends State<MaintenanceCalculator> {
  final TextEditingController weightController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? weight = _number(weightController);
    double hourly = 0;
    double daily = 0;

    if (weight != null && weight > 0) {
      if (weight <= 10) {
        hourly = 4 * weight;
        daily = 100 * weight;
      } else if (weight <= 20) {
        hourly = 40 + 2 * (weight - 10);
        daily = 1000 + 50 * (weight - 10);
      } else {
        hourly = 60 + (weight - 20);
        daily = 1500 + 20 * (weight - 20);
      }
    }

    return _CalculatorScaffold(
      title: 'Maintenance fluids',
      children: <Widget>[
        _NumberField(
          controller: weightController,
          label: 'Weight',
          suffix: 'kg',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Hourly rate',
          value: weight == null
              ? 'ΓÇö'
              : '${hourly.toStringAsFixed(1)} mL/h',
          note: '4-2-1 rule',
        ),
        const SizedBox(height: 12),
        _ResultCard(
          title: 'Daily maintenance',
          value: weight == null
              ? 'ΓÇö'
              : '${daily.toStringAsFixed(0)} mL/day',
          note: '100-50-20 rule',
        ),
      ],
    );
  }
}

class BolusCalculator extends StatefulWidget {
  const BolusCalculator({super.key});

  @override
  State<BolusCalculator> createState() => _BolusCalculatorState();
}

class _BolusCalculatorState extends State<BolusCalculator> {
  final TextEditingController weightController =
      TextEditingController();
  final TextEditingController doseController =
      TextEditingController(text: '10');

  @override
  Widget build(BuildContext context) {
    final double? weight = _number(weightController);
    final double? dose = _number(doseController);

    final double? volume =
        weight != null && dose != null ? weight * dose : null;

    return _CalculatorScaffold(
      title: 'Bolus volume',
      children: <Widget>[
        _NumberField(
          controller: weightController,
          label: 'Weight',
          suffix: 'kg',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: doseController,
          label: 'Bolus',
          suffix: 'mL/kg',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Calculated volume',
          value: volume == null
              ? 'ΓÇö'
              : '${volume.toStringAsFixed(0)} mL',
        ),
      ],
    );
  }
}

class MedicationDoseCalculator extends StatefulWidget {
  const MedicationDoseCalculator({super.key});

  @override
  State<MedicationDoseCalculator> createState() =>
      _MedicationDoseCalculatorState();
}

class _MedicationDoseCalculatorState
    extends State<MedicationDoseCalculator> {
  final TextEditingController weightController =
      TextEditingController();
  final TextEditingController doseController =
      TextEditingController();
  final TextEditingController maximumController =
      TextEditingController();
  final TextEditingController concentrationController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? weight = _number(weightController);
    final double? dosePerKg = _number(doseController);
    final double? maximum = _number(maximumController);
    final double? concentration =
        _number(concentrationController);

    double? dose;

    if (weight != null && dosePerKg != null) {
      dose = weight * dosePerKg;

      if (maximum != null && maximum > 0) {
        dose = math.min(dose, maximum);
      }
    }

    final double? volume =
        dose != null && concentration != null && concentration > 0
            ? dose / concentration
            : null;

    return _CalculatorScaffold(
      title: 'Medication dose',
      children: <Widget>[
        _NumberField(
          controller: weightController,
          label: 'Weight',
          suffix: 'kg',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: doseController,
          label: 'Dose',
          suffix: 'mg/kg',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: maximumController,
          label: 'Maximum dose (optional)',
          suffix: 'mg',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: concentrationController,
          label: 'Concentration (optional)',
          suffix: 'mg/mL',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Dose',
          value: dose == null
              ? 'ΓÇö'
              : '${dose.toStringAsFixed(2)} mg',
        ),
        const SizedBox(height: 12),
        _ResultCard(
          title: 'Volume',
          value: volume == null
              ? 'ΓÇö'
              : '${volume.toStringAsFixed(2)} mL',
        ),
      ],
    );
  }
}

class CorrectedSodiumCalculator extends StatefulWidget {
  const CorrectedSodiumCalculator({super.key});

  @override
  State<CorrectedSodiumCalculator> createState() =>
      _CorrectedSodiumCalculatorState();
}

class _CorrectedSodiumCalculatorState
    extends State<CorrectedSodiumCalculator> {
  final TextEditingController sodiumController =
      TextEditingController();
  final TextEditingController glucoseController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? sodium = _number(sodiumController);
    final double? glucose = _number(glucoseController);

    final double? corrected =
        sodium != null && glucose != null
            ? sodium + 1.6 * ((glucose - 5.6) / 5.6)
            : null;

    return _CalculatorScaffold(
      title: 'Corrected sodium',
      children: <Widget>[
        _NumberField(
          controller: sodiumController,
          label: 'Measured sodium',
          suffix: 'mmol/L',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: glucoseController,
          label: 'Glucose',
          suffix: 'mmol/L',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Corrected sodium',
          value: corrected == null
              ? 'ΓÇö'
              : '${corrected.toStringAsFixed(1)} mmol/L',
        ),
      ],
    );
  }
}

class AnionGapCalculator extends StatefulWidget {
  const AnionGapCalculator({super.key});

  @override
  State<AnionGapCalculator> createState() =>
      _AnionGapCalculatorState();
}

class _AnionGapCalculatorState
    extends State<AnionGapCalculator> {
  final TextEditingController sodiumController =
      TextEditingController();
  final TextEditingController chlorideController =
      TextEditingController();
  final TextEditingController bicarbonateController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? sodium = _number(sodiumController);
    final double? chloride = _number(chlorideController);
    final double? bicarbonate =
        _number(bicarbonateController);

    final double? gap = sodium != null &&
            chloride != null &&
            bicarbonate != null
        ? sodium - chloride - bicarbonate
        : null;

    return _CalculatorScaffold(
      title: 'Anion gap',
      children: <Widget>[
        _NumberField(
          controller: sodiumController,
          label: 'Sodium',
          suffix: 'mmol/L',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: chlorideController,
          label: 'Chloride',
          suffix: 'mmol/L',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: bicarbonateController,
          label: 'Bicarbonate',
          suffix: 'mmol/L',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Anion gap',
          value:
              gap == null ? 'ΓÇö' : '${gap.toStringAsFixed(1)} mmol/L',
        ),
      ],
    );
  }
}

class CorrectedCalciumCalculator extends StatefulWidget {
  const CorrectedCalciumCalculator({super.key});

  @override
  State<CorrectedCalciumCalculator> createState() =>
      _CorrectedCalciumCalculatorState();
}

class _CorrectedCalciumCalculatorState
    extends State<CorrectedCalciumCalculator> {
  final TextEditingController calciumController =
      TextEditingController();
  final TextEditingController albuminController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? calcium = _number(calciumController);
    final double? albumin = _number(albuminController);

    final double? corrected =
        calcium != null && albumin != null
            ? calcium + 0.02 * (40 - albumin)
            : null;

    return _CalculatorScaffold(
      title: 'Corrected calcium',
      children: <Widget>[
        _NumberField(
          controller: calciumController,
          label: 'Measured calcium',
          suffix: 'mmol/L',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: albuminController,
          label: 'Albumin',
          suffix: 'g/L',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Corrected calcium',
          value: corrected == null
              ? 'ΓÇö'
              : '${corrected.toStringAsFixed(2)} mmol/L',
        ),
      ],
    );
  }
}

class BsaCalculator extends StatefulWidget {
  const BsaCalculator({super.key});

  @override
  State<BsaCalculator> createState() => _BsaCalculatorState();
}

class _BsaCalculatorState extends State<BsaCalculator> {
  final TextEditingController heightController =
      TextEditingController();
  final TextEditingController weightController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? height = _number(heightController);
    final double? weight = _number(weightController);

    final double? bsa = height != null && weight != null
        ? math.sqrt((height * weight) / 3600)
        : null;

    return _CalculatorScaffold(
      title: 'Body surface area',
      children: <Widget>[
        _NumberField(
          controller: heightController,
          label: 'Height',
          suffix: 'cm',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: weightController,
          label: 'Weight',
          suffix: 'kg',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'BSA',
          value:
              bsa == null ? 'ΓÇö' : '${bsa.toStringAsFixed(3)} m┬▓',
          note: 'Mosteller formula',
        ),
      ],
    );
  }
}

class QtcCalculator extends StatefulWidget {
  const QtcCalculator({super.key});

  @override
  State<QtcCalculator> createState() => _QtcCalculatorState();
}

class _QtcCalculatorState extends State<QtcCalculator> {
  final TextEditingController qtController =
      TextEditingController();
  final TextEditingController rrController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? qt = _number(qtController);
    final double? rr = _number(rrController);

    final double? qtc = qt != null && rr != null && rr > 0
        ? qt / math.sqrt(rr / 1000)
        : null;

    return _CalculatorScaffold(
      title: 'QTc',
      children: <Widget>[
        _NumberField(
          controller: qtController,
          label: 'QT interval',
          suffix: 'ms',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: rrController,
          label: 'RR interval',
          suffix: 'ms',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'QTc (Bazett)',
          value: qtc == null
              ? 'ΓÇö'
              : '${qtc.toStringAsFixed(0)} ms',
        ),
      ],
    );
  }
}


class GirCalculator extends StatefulWidget {
  const GirCalculator({super.key});
  @override
  State<GirCalculator> createState() => _GirCalculatorState();
}

class _GirCalculatorState extends State<GirCalculator> {
  final TextEditingController dextrose = TextEditingController();
  final TextEditingController rate = TextEditingController();
  final TextEditingController weight = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? d = _number(dextrose);
    final double? r = _number(rate);
    final double? w = _number(weight);
    final double? result =
        d != null && r != null && w != null && w > 0
            ? d * 10 * r / (w * 60)
            : null;
    return _CalculatorScaffold(
      title: 'Glucose infusion rate',
      children: <Widget>[
        _NumberField(controller: dextrose, label: 'Dextrose concentration', suffix: '%', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: rate, label: 'Infusion rate', suffix: 'mL/h', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: weight, label: 'Weight', suffix: 'kg', onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'GIR',
          value: result == null ? 'ΓÇö' : '${result.toStringAsFixed(2)} mg/kg/min',
          note: 'Arithmetic result only. Confirm glucose targets and escalation thresholds using the current neonatal/endocrine pathway.',
        ),
      ],
    );
  }
}

class OsmolalityCalculator extends StatefulWidget {
  const OsmolalityCalculator({super.key});
  @override
  State<OsmolalityCalculator> createState() => _OsmolalityCalculatorState();
}

class _OsmolalityCalculatorState extends State<OsmolalityCalculator> {
  final TextEditingController sodium = TextEditingController();
  final TextEditingController glucose = TextEditingController();
  final TextEditingController urea = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? na = _number(sodium);
    final double? glc = _number(glucose);
    final double? ur = _number(urea);
    final double? result =
        na != null && glc != null && ur != null ? 2 * na + glc + ur : null;
    return _CalculatorScaffold(
      title: 'Calculated serum osmolality',
      children: <Widget>[
        _NumberField(controller: sodium, label: 'Sodium', suffix: 'mmol/L', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: glucose, label: 'Glucose', suffix: 'mmol/L', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: urea, label: 'Urea', suffix: 'mmol/L', onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        _ResultCard(title: 'Calculated osmolality', value: result == null ? 'ΓÇö' : '${result.toStringAsFixed(1)} mOsm/kg'),
      ],
    );
  }
}

class FenaCalculator extends StatefulWidget {
  const FenaCalculator({super.key});
  @override
  State<FenaCalculator> createState() => _FenaCalculatorState();
}

class _FenaCalculatorState extends State<FenaCalculator> {
  final TextEditingController urineNa = TextEditingController();
  final TextEditingController plasmaCr = TextEditingController();
  final TextEditingController plasmaNa = TextEditingController();
  final TextEditingController urineCr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? un = _number(urineNa);
    final double? pc = _number(plasmaCr);
    final double? pn = _number(plasmaNa);
    final double? uc = _number(urineCr);
    final double? result = un != null && pc != null && pn != null && uc != null && pn > 0 && uc > 0
        ? (un * pc) / (pn * uc) * 100
        : null;
    return _CalculatorScaffold(
      title: 'Fractional excretion of sodium',
      children: <Widget>[
        _NumberField(controller: urineNa, label: 'Urine sodium', suffix: 'mmol/L', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: plasmaNa, label: 'Plasma sodium', suffix: 'mmol/L', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: urineCr, label: 'Urine creatinine', suffix: 'same units', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: plasmaCr, label: 'Plasma creatinine', suffix: 'same units', onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'FENa',
          value: result == null ? 'ΓÇö' : '${result.toStringAsFixed(2)}%',
          note: 'Interpret cautiously in neonates, CKD, glomerular disease and after diuretics.',
        ),
      ],
    );
  }
}

class EgfrCalculator extends StatefulWidget {
  const EgfrCalculator({super.key});
  @override
  State<EgfrCalculator> createState() => _EgfrCalculatorState();
}

class _EgfrCalculatorState extends State<EgfrCalculator> {
  final TextEditingController height = TextEditingController();
  final TextEditingController creatinine = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? h = _number(height);
    final double? cr = _number(creatinine);
    final double? result = h != null && cr != null && cr > 0 ? 0.413 * h / cr : null;
    return _CalculatorScaffold(
      title: 'Bedside Schwartz eGFR',
      children: <Widget>[
        _NumberField(controller: height, label: 'Height', suffix: 'cm', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: creatinine, label: 'Serum creatinine', suffix: 'mg/dL', onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Estimated GFR',
          value: result == null ? 'ΓÇö' : '${result.toStringAsFixed(1)} mL/min/1.73m┬▓',
          note: 'Creatinine must be entered in mg/dL. Use the laboratory/local nephrology method when available.',
        ),
      ],
    );
  }
}

class IdealBodyWeightCalculator extends StatefulWidget {
  const IdealBodyWeightCalculator({super.key});
  @override
  State<IdealBodyWeightCalculator> createState() => _IdealBodyWeightCalculatorState();
}

class _IdealBodyWeightCalculatorState extends State<IdealBodyWeightCalculator> {
  final TextEditingController height = TextEditingController();
  final TextEditingController medianBmi = TextEditingController(text: '17');

  @override
  Widget build(BuildContext context) {
    final double? h = _number(height);
    final double? bmi = _number(medianBmi);
    final double? result = h != null && bmi != null ? bmi * math.pow(h / 100, 2) : null;
    return _CalculatorScaffold(
      title: 'Ideal body weight approximation',
      children: <Widget>[
        _NumberField(controller: height, label: 'Height', suffix: 'cm', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: medianBmi, label: 'Selected median BMI for age/sex', suffix: 'kg/m┬▓', onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Approximate IBW',
          value: result == null ? 'ΓÇö' : '${result.toStringAsFixed(1)} kg',
          note: 'Use a validated age/sex growth reference rather than the default placeholder BMI before clinical dosing.',
        ),
      ],
    );
  }
}

class FluidDeficitCalculator extends StatefulWidget {
  const FluidDeficitCalculator({super.key});
  @override
  State<FluidDeficitCalculator> createState() => _FluidDeficitCalculatorState();
}

class _FluidDeficitCalculatorState extends State<FluidDeficitCalculator> {
  final TextEditingController weight = TextEditingController();
  final TextEditingController dehydration = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? w = _number(weight);
    final double? p = _number(dehydration);
    final double? result = w != null && p != null ? w * p * 10 : null;
    return _CalculatorScaffold(
      title: 'Fluid deficit',
      children: <Widget>[
        _NumberField(controller: weight, label: 'Weight', suffix: 'kg', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: dehydration, label: 'Estimated dehydration', suffix: '%', onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Estimated deficit',
          value: result == null ? 'ΓÇö' : '${result.toStringAsFixed(0)} mL',
          note: 'Clinical dehydration estimates are imprecise. Replace according to syndrome, ongoing losses and reassessment.',
        ),
      ],
    );
  }
}

class SodiumDeficitCalculator extends StatefulWidget {
  const SodiumDeficitCalculator({super.key});
  @override
  State<SodiumDeficitCalculator> createState() => _SodiumDeficitCalculatorState();
}

class _SodiumDeficitCalculatorState extends State<SodiumDeficitCalculator> {
  final TextEditingController measured = TextEditingController();
  final TextEditingController target = TextEditingController();
  final TextEditingController weight = TextEditingController();
  final TextEditingController tbw = TextEditingController(text: '0.6');

  @override
  Widget build(BuildContext context) {
    final double? m = _number(measured);
    final double? t = _number(target);
    final double? w = _number(weight);
    final double? f = _number(tbw);
    final double? result = m != null && t != null && w != null && f != null ? (t - m) * f * w : null;
    return _CalculatorScaffold(
      title: 'Sodium deficit',
      children: <Widget>[
        _NumberField(controller: measured, label: 'Measured sodium', suffix: 'mmol/L', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: target, label: 'Target sodium', suffix: 'mmol/L', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: weight, label: 'Weight', suffix: 'kg', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: tbw, label: 'TBW fraction', suffix: '', onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Calculated sodium deficit',
          value: result == null ? 'ΓÇö' : '${result.toStringAsFixed(1)} mmol',
          note: 'Do not use this arithmetic result without a controlled correction-rate plan and serial sodium monitoring.',
        ),
      ],
    );
  }
}

class FreeWaterDeficitCalculator extends StatefulWidget {
  const FreeWaterDeficitCalculator({super.key});
  @override
  State<FreeWaterDeficitCalculator> createState() => _FreeWaterDeficitCalculatorState();
}

class _FreeWaterDeficitCalculatorState extends State<FreeWaterDeficitCalculator> {
  final TextEditingController sodium = TextEditingController();
  final TextEditingController target = TextEditingController(text: '140');
  final TextEditingController weight = TextEditingController();
  final TextEditingController tbw = TextEditingController(text: '0.6');

  @override
  Widget build(BuildContext context) {
    final double? na = _number(sodium);
    final double? tar = _number(target);
    final double? w = _number(weight);
    final double? f = _number(tbw);
    final double? result = na != null && tar != null && w != null && f != null && tar > 0
        ? f * w * (na / tar - 1)
        : null;
    return _CalculatorScaffold(
      title: 'Free-water deficit',
      children: <Widget>[
        _NumberField(controller: sodium, label: 'Measured sodium', suffix: 'mmol/L', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: target, label: 'Target sodium', suffix: 'mmol/L', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: weight, label: 'Weight', suffix: 'kg', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: tbw, label: 'TBW fraction', suffix: '', onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Free-water deficit',
          value: result == null ? 'ΓÇö' : '${result.toStringAsFixed(2)} L',
          note: 'Plan correction over an appropriate timeframe with ongoing losses and serial sodium checks.',
        ),
      ],
    );
  }
}

class MapCalculator extends StatefulWidget {
  const MapCalculator({super.key});
  @override
  State<MapCalculator> createState() => _MapCalculatorState();
}

class _MapCalculatorState extends State<MapCalculator> {
  final TextEditingController sbp = TextEditingController();
  final TextEditingController dbp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? s = _number(sbp);
    final double? d = _number(dbp);
    final double? result = s != null && d != null ? (s + 2 * d) / 3 : null;
    return _CalculatorScaffold(
      title: 'Mean arterial pressure',
      children: <Widget>[
        _NumberField(controller: sbp, label: 'Systolic BP', suffix: 'mmHg', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: dbp, label: 'Diastolic BP', suffix: 'mmHg', onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        _ResultCard(title: 'MAP', value: result == null ? 'ΓÇö' : '${result.toStringAsFixed(1)} mmHg'),
      ],
    );
  }
}

class PfRatioCalculator extends StatefulWidget {
  const PfRatioCalculator({super.key});
  @override
  State<PfRatioCalculator> createState() => _PfRatioCalculatorState();
}

class _PfRatioCalculatorState extends State<PfRatioCalculator> {
  final TextEditingController pao2 = TextEditingController();
  final TextEditingController fio2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? p = _number(pao2);
    final double? f = _number(fio2);
    final double? fraction = f != null && f > 1 ? f / 100 : f;
    final double? result = p != null && fraction != null && fraction > 0 ? p / fraction : null;
    return _CalculatorScaffold(
      title: 'P/F ratio',
      children: <Widget>[
        _NumberField(controller: pao2, label: 'PaOΓéé', suffix: 'mmHg', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: fio2, label: 'FiOΓéé', suffix: 'fraction or %', onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        _ResultCard(title: 'P/F ratio', value: result == null ? 'ΓÇö' : result.toStringAsFixed(0)),
      ],
    );
  }
}

class CorrectedGestationalAgeCalculator extends StatefulWidget {
  const CorrectedGestationalAgeCalculator({super.key});
  @override
  State<CorrectedGestationalAgeCalculator> createState() => _CorrectedGestationalAgeCalculatorState();
}

class _CorrectedGestationalAgeCalculatorState extends State<CorrectedGestationalAgeCalculator> {
  final TextEditingController birthWeeks = TextEditingController();
  final TextEditingController birthDays = TextEditingController(text: '0');
  final TextEditingController ageDays = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? bw = _number(birthWeeks);
    final double? bd = _number(birthDays);
    final double? age = _number(ageDays);
    final double? total = bw != null && bd != null && age != null ? bw * 7 + bd + age : null;
    final int? totalDays = total?.floor();
    final int? weeks =
        totalDays == null ? null : totalDays ~/ 7;
    final int? days =
        totalDays == null ? null : totalDays % 7;
    return _CalculatorScaffold(
      title: 'Corrected gestational age',
      children: <Widget>[
        _NumberField(controller: birthWeeks, label: 'Gestational age at birth', suffix: 'weeks', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: birthDays, label: 'Additional days at birth', suffix: 'days', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: ageDays, label: 'Chronological age', suffix: 'days', onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        _ResultCard(title: 'Current postmenstrual age', value: weeks == null ? 'ΓÇö' : '$weeks weeks + $days days'),
      ],
    );
  }
}

class BmiCalculator extends StatefulWidget {
  const BmiCalculator({super.key});
  @override
  State<BmiCalculator> createState() => _BmiCalculatorState();
}

class _BmiCalculatorState extends State<BmiCalculator> {
  final TextEditingController weight = TextEditingController();
  final TextEditingController height = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double? w = _number(weight);
    final double? h = _number(height);
    final double? result = w != null && h != null && h > 0 ? w / math.pow(h / 100, 2) : null;
    return _CalculatorScaffold(
      title: 'Body mass index',
      children: <Widget>[
        _NumberField(controller: weight, label: 'Weight', suffix: 'kg', onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        _NumberField(controller: height, label: 'Height', suffix: 'cm', onChanged: () => setState(() {})),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'BMI',
          value: result == null ? 'ΓÇö' : '${result.toStringAsFixed(1)} kg/m┬▓',
          note: 'Pediatric BMI requires age- and sex-specific percentile interpretation.',
        ),
      ],
    );
  }
}


class HypernatremicDehydrationCalculator extends StatefulWidget {
  const HypernatremicDehydrationCalculator({super.key});

  @override
  State<HypernatremicDehydrationCalculator> createState() =>
      _HypernatremicDehydrationCalculatorState();
}

class _HypernatremicDehydrationCalculatorState
    extends State<HypernatremicDehydrationCalculator> {
  final TextEditingController currentWeight =
      TextEditingController();
  final TextEditingController premorbidWeight =
      TextEditingController();
  final TextEditingController clinicianPercent =
      TextEditingController(text: '8');
  final TextEditingController bolusVolume =
      TextEditingController(text: '0');
  final TextEditingController otherDeficitFluid =
      TextEditingController(text: '0');
  final TextEditingController replacementHours =
      TextEditingController(text: '48');
  final TextEditingController maintenanceWeight =
      TextEditingController();
  final TextEditingController currentSodium =
      TextEditingController();
  final TextEditingController targetSodium =
      TextEditingController();
  final TextEditingController selectedRate =
      TextEditingController();
  final TextEditingController tbwFactor =
      TextEditingController(text: '0.6');
  final TextEditingController previousSodium =
      TextEditingController();
  final TextEditingController sodiumInterval =
      TextEditingController();
  final TextEditingController sodiumValue =
      TextEditingController(text: '130');
  final TextEditingController potassiumValue =
      TextEditingController(text: '4');

  String deficitMethod = 'premorbid';
  String maintenanceBasis = 'premorbid';
  String selectedFluid = 'D5RL';

  int mentalStatus = 0;
  int perfusion = 0;
  int mucosaEyes = 0;
  int urine = 0;
  int breathing = 0;

  static const Map<String, List<double>> fluidComposition =
      <String, List<double>>{
    'D5RL': <double>[130, 4],
    'D5NS': <double>[154, 0],
    'D5 0.45% NS': <double>[77, 0],
    'D5 0.2% NS': <double>[34, 0],
    'Custom': <double>[0, 0],
  };

  double? get _weight => _number(currentWeight);

  int get _clinicalScore =>
      mentalStatus + perfusion + mucosaEyes + urine + breathing;

  String get _clinicalCategory {
    if (_clinicalScore <= 2) return 'Mild / limited signs';
    if (_clinicalScore <= 6) return 'Moderate dehydration pattern';
    return 'Severe dehydration or shock pattern';
  }

  String get _clinicalRange {
    if (_clinicalScore <= 2) return '<5%';
    if (_clinicalScore <= 6) return '5ΓÇô9%';
    return 'ΓëÑ10%';
  }

  double? get _selectedDehydrationPercent {
    if (deficitMethod == 'premorbid') {
      final double? current = _weight;
      final double? previous = _number(premorbidWeight);
      if (current == null || previous == null || previous <= current) {
        return null;
      }
      return (previous - current) / previous * 100;
    }
    return _number(clinicianPercent);
  }

  double? get _initialDeficit {
    final double? current = _weight;
    if (current == null) return null;
    if (deficitMethod == 'premorbid') {
      final double? previous = _number(premorbidWeight);
      if (previous == null || previous <= current) return null;
      return (previous - current) * 1000;
    }
    final double? percent = _number(clinicianPercent);
    if (percent == null || percent < 0) return null;
    return current * percent * 10;
  }

  double? get _derivedPremorbidWeight {
    final double? current = _weight;
    final double? percent = _selectedDehydrationPercent;
    if (current == null || percent == null || percent >= 100) return null;
    return current / (1 - percent / 100);
  }

  double? get _remainingDeficit {
    final double? initial = _initialDeficit;
    if (initial == null) return null;
    return math.max(
      0,
      initial -
          (_number(bolusVolume) ?? 0) -
          (_number(otherDeficitFluid) ?? 0),
    );
  }

  double? get _maintenanceWeight {
    if (maintenanceBasis == 'current') return _weight;
    if (maintenanceBasis == 'manual') {
      return _number(maintenanceWeight);
    }
    if (deficitMethod == 'premorbid') {
      return _number(premorbidWeight);
    }
    return _derivedPremorbidWeight;
  }

  double? _maintenanceDaily(double? weight) {
    if (weight == null || weight <= 0) return null;
    if (weight <= 10) return weight * 100;
    if (weight <= 20) return 1000 + (weight - 10) * 50;
    return 1500 + (weight - 20) * 20;
  }

  List<double> get _fluid {
    if (selectedFluid == 'Custom') {
      return <double>[
        _number(sodiumValue) ?? 0,
        _number(potassiumValue) ?? 0,
      ];
    }
    return fluidComposition[selectedFluid]!;
  }

  void _setFluid(String value) {
    setState(() {
      selectedFluid = value;
      final List<double> values = fluidComposition[value]!;
      if (value != 'Custom') {
        sodiumValue.text = values[0].toStringAsFixed(0);
        potassiumValue.text = values[1].toStringAsFixed(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double? weight = _weight;
    final double? dehydrationPercent = _selectedDehydrationPercent;
    final double? initialDeficit = _initialDeficit;
    final double? remainingDeficit = _remainingDeficit;
    final double? maintenanceKg = _maintenanceWeight;
    final double? maintenanceDay = _maintenanceDaily(maintenanceKg);
    final double? maintenanceHour =
        maintenanceDay == null ? null : maintenanceDay / 24;
    final double? hours = _number(replacementHours);
    final double? deficitHour = remainingDeficit != null &&
            hours != null &&
            hours > 0
        ? remainingDeficit / hours
        : null;
    final double? totalRate = maintenanceHour != null &&
            deficitHour != null
        ? maintenanceHour + deficitHour
        : null;

    final double? actualRate = _number(selectedRate);
    final double? dailyAtRate =
        actualRate == null ? null : actualRate * 24;
    final double? towardDeficit = dailyAtRate != null &&
            maintenanceDay != null
        ? math.max(0, dailyAtRate - maintenanceDay)
        : null;
    final double? durationAtRate = remainingDeficit != null &&
            towardDeficit != null &&
            towardDeficit > 0
        ? remainingDeficit / towardDeficit * 24
        : null;

    final double? sodium = _number(currentSodium);
    final double? target = _number(targetSodium);
    final double? tbw = weight != null && _number(tbwFactor) != null
        ? weight * _number(tbwFactor)!
        : null;
    final double? freeWaterDeficit = sodium != null &&
            target != null &&
            target > 0 &&
            tbw != null
        ? tbw * (sodium / target - 1) * 1000
        : null;

    final List<double> fluid = _fluid;
    final double fluidNaK = fluid[0] + fluid[1];
    final double? freeWaterFraction = sodium != null && sodium > 0
        ? 1 - fluidNaK / sodium
        : null;
    final double? freeWaterPerDay = actualRate != null &&
            freeWaterFraction != null
        ? actualRate * 24 * freeWaterFraction
        : null;
    final double? adroguePerL = sodium != null && tbw != null
        ? (fluidNaK - sodium) / (tbw + 1)
        : null;
    final double? adroguePerDay = adroguePerL != null &&
            actualRate != null
        ? adroguePerL * actualRate * 24 / 1000
        : null;

    final double? previousNa = _number(previousSodium);
    final double? elapsed = _number(sodiumInterval);
    final double? observedRate = previousNa != null &&
            sodium != null &&
            elapsed != null &&
            elapsed > 0
        ? (sodium - previousNa) / elapsed
        : null;

    final bool severeCalculated =
        dehydrationPercent != null && dehydrationPercent >= 10;
    final bool highRiskFluid = selectedFluid == 'D5 0.2% NS';
    final bool rapidChange =
        observedRate != null && observedRate.abs() > 0.5;
    final bool severeHypernatremia = sodium != null && sodium >= 170;

    return _CalculatorScaffold(
      title: 'Hypernatremic dehydration',
      children: <Widget>[
        _ClinicalWarningCard(
          title: 'Clinical decision support',
          text:
              'Verify with local institutional protocols, formulary, pharmacist, '
              'and attending physician before implementation. Calculations are '
              'estimates and must be adjusted to measured sodium trajectory, '
              'clinical examination, renal function, oral intake, medication '
              'carrier volumes and ongoing losses.',
          danger: false,
        ),
        const SizedBox(height: 14),
        const _CalculatorSectionTitle('1. Deficit estimation'),
        DropdownButtonFormField<String>(
          initialValue: deficitMethod,
          decoration: const InputDecoration(
            labelText: 'Deficit-estimation method',
            filled: true,
          ),
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem(
              value: 'premorbid',
              child: Text('Reliable premorbid weight'),
            ),
            DropdownMenuItem(
              value: 'signs',
              child: Text('Estimate from clinical signs'),
            ),
            DropdownMenuItem(
              value: 'percent',
              child: Text('Clinician-entered dehydration %'),
            ),
          ],
          onChanged: (String? value) {
            if (value != null) {
              setState(() => deficitMethod = value);
            }
          },
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: currentWeight,
          label: 'Current/presentation weight',
          suffix: 'kg',
          onChanged: () => setState(() {}),
        ),
        if (deficitMethod == 'premorbid') ...<Widget>[
          const SizedBox(height: 12),
          _NumberField(
            controller: premorbidWeight,
            label: 'Reliable premorbid weight',
            suffix: 'kg',
            onChanged: () => setState(() {}),
          ),
        ],
        if (deficitMethod == 'signs') ...<Widget>[
          const SizedBox(height: 14),
          _ClinicalSignsPanel(
            mentalStatus: mentalStatus,
            perfusion: perfusion,
            mucosaEyes: mucosaEyes,
            urine: urine,
            breathing: breathing,
            onMentalStatus: (int value) =>
                setState(() => mentalStatus = value),
            onPerfusion: (int value) =>
                setState(() => perfusion = value),
            onMucosaEyes: (int value) =>
                setState(() => mucosaEyes = value),
            onUrine: (int value) =>
                setState(() => urine = value),
            onBreathing: (int value) =>
                setState(() => breathing = value),
          ),
          const SizedBox(height: 12),
          _ResultCard(
            title: 'Clinical pattern',
            value: '$_clinicalCategory ($_clinicalRange)',
            note:
                'The signs suggest a range, not an exact percentage. Select the '
                'final working estimate below after clinician assessment.',
          ),
          const SizedBox(height: 12),
          _NumberField(
            controller: clinicianPercent,
            label: 'Clinician-selected dehydration estimate',
            suffix: '%',
            onChanged: () => setState(() {}),
          ),
        ],
        if (deficitMethod == 'percent') ...<Widget>[
          const SizedBox(height: 12),
          _NumberField(
            controller: clinicianPercent,
            label: 'Clinician-entered dehydration',
            suffix: '%',
            onChanged: () => setState(() {}),
          ),
        ],
        const SizedBox(height: 12),
        _NumberField(
          controller: bolusVolume,
          label: 'Documented bolus volume already given',
          suffix: 'mL',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: otherDeficitFluid,
          label: 'Other deficit-directed fluid already given',
          suffix: 'mL',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _ResultCard(
          title: 'Initial estimated deficit',
          value: initialDeficit == null
              ? 'ΓÇö'
              : '${initialDeficit.toStringAsFixed(0)} mL',
          note: dehydrationPercent == null
              ? ''
              : 'Estimated dehydration: '
                  '${dehydrationPercent.toStringAsFixed(1)}%. '
                  'Derived premorbid weight: '
                  '${_derivedPremorbidWeight?.toStringAsFixed(2) ?? 'ΓÇö'} kg.',
        ),
        const SizedBox(height: 10),
        _ResultCard(
          title: 'Remaining estimated deficit',
          value: remainingDeficit == null
              ? 'ΓÇö'
              : '${remainingDeficit.toStringAsFixed(0)} mL',
          note:
              'Excludes undocumented fluid and subsequent measurable losses.',
        ),
        if (severeCalculated) ...<Widget>[
          const SizedBox(height: 10),
          const _ClinicalWarningCard(
            title: 'Severe calculated dehydration',
            text:
                'Confirm weights, timing, scale accuracy, fluid already received '
                'and edema status. Stabilization and senior/PICU review take '
                'priority over routine deficit calculations.',
            danger: true,
          ),
        ],
        const SizedBox(height: 20),
        const _CalculatorSectionTitle('2. Maintenance + deficit'),
        DropdownButtonFormField<String>(
          initialValue: maintenanceBasis,
          decoration: const InputDecoration(
            labelText: 'Maintenance-weight basis',
            filled: true,
          ),
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem(
              value: 'premorbid',
              child: Text('Premorbid / derived premorbid weight'),
            ),
            DropdownMenuItem(
              value: 'current',
              child: Text('Current weight'),
            ),
            DropdownMenuItem(
              value: 'manual',
              child: Text('Clinician-entered weight'),
            ),
          ],
          onChanged: (String? value) {
            if (value != null) {
              setState(() => maintenanceBasis = value);
            }
          },
        ),
        if (maintenanceBasis == 'manual') ...<Widget>[
          const SizedBox(height: 12),
          _NumberField(
            controller: maintenanceWeight,
            label: 'Maintenance weight',
            suffix: 'kg',
            onChanged: () => setState(() {}),
          ),
        ],
        const SizedBox(height: 12),
        _NumberField(
          controller: replacementHours,
          label: 'Deficit-replacement duration',
          suffix: 'hours',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _ResultCard(
          title: 'Maintenance',
          value: maintenanceHour == null
              ? 'ΓÇö'
              : '${maintenanceHour.toStringAsFixed(1)} mL/hour',
          note: maintenanceDay == null
              ? ''
              : '${maintenanceDay.toStringAsFixed(0)} mL/day using the '
                  '100-50-20 method.',
        ),
        const SizedBox(height: 10),
        _ResultCard(
          title: 'Deficit component',
          value: deficitHour == null
              ? 'ΓÇö'
              : '${deficitHour.toStringAsFixed(1)} mL/hour',
        ),
        const SizedBox(height: 10),
        _ResultCard(
          title: 'Calculated scheduled total',
          value: totalRate == null
              ? 'ΓÇö'
              : '${totalRate.toStringAsFixed(1)} mL/hour',
          note:
              'Subtract oral/NG intake and medication-carrier volumes from the '
              'IV component. Replace measurable ongoing losses separately.',
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: selectedRate,
          label: 'Actual/considered total fluid rate',
          suffix: 'mL/hour',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 10),
        _ResultCard(
          title: 'What does this rate provide?',
          value: durationAtRate == null
              ? 'ΓÇö'
              : 'Γëê ${durationAtRate.toStringAsFixed(0)} hours',
          note: dailyAtRate == null
              ? ''
              : '${dailyAtRate.toStringAsFixed(0)} mL/day total; '
                  '${towardDeficit?.toStringAsFixed(0) ?? 'ΓÇö'} mL/day remains '
                  'for deficit after calculated maintenance.',
        ),
        const SizedBox(height: 20),
        const _CalculatorSectionTitle('3. Sodium target and trend'),
        _NumberField(
          controller: currentSodium,
          label: 'Current sodium',
          suffix: 'mmol/L',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: targetSodium,
          label: 'Selected target sodium',
          suffix: 'mmol/L',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: previousSodium,
          label: 'Previous sodium (optional)',
          suffix: 'mmol/L',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: sodiumInterval,
          label: 'Time between sodium values',
          suffix: 'hours',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 10),
        _ResultCard(
          title: 'Observed sodium change',
          value: observedRate == null
              ? 'ΓÇö'
              : '${observedRate.toStringAsFixed(2)} mmol/L/hour',
          note:
              'A negative result means sodium is falling. Review immediately if '
              'the trajectory exceeds the locally selected safety limit.',
        ),
        if (rapidChange || severeHypernatremia) ...<Widget>[
          const SizedBox(height: 10),
          _ClinicalWarningCard(
            title: 'Urgent sodium review',
            text: severeHypernatremia
                ? 'Sodium is in the severe range. Do not generate a routine '
                    'fluid recommendation; obtain urgent senior/PICU, nephrology '
                    'and pharmacy review.'
                : 'Observed sodium change exceeds 0.5 mmol/L/hour in magnitude. '
                    'Reassess fluid delivery and obtain urgent senior review.',
            danger: true,
          ),
        ],
        const SizedBox(height: 20),
        const _CalculatorSectionTitle('4. Free water and fluid comparison'),
        _NumberField(
          controller: tbwFactor,
          label: 'Total body water factor',
          suffix: '',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: selectedFluid,
          decoration: const InputDecoration(
            labelText: 'IV fluid',
            filled: true,
          ),
          items: fluidComposition.keys
              .map(
                (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ),
              )
              .toList(),
          onChanged: (String? value) {
            if (value != null) _setFluid(value);
          },
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: sodiumValue,
          label: 'Fluid sodium',
          suffix: 'mmol/L',
          onChanged: () {
            setState(() => selectedFluid = 'Custom');
          },
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: potassiumValue,
          label: 'Fluid potassium',
          suffix: 'mmol/L',
          onChanged: () {
            setState(() => selectedFluid = 'Custom');
          },
        ),
        const SizedBox(height: 10),
        _ResultCard(
          title: 'Electrolyte-free-water deficit',
          value: freeWaterDeficit == null
              ? 'ΓÇö'
              : '${freeWaterDeficit.toStringAsFixed(0)} mL',
          note:
              'TBW ├ù [(current Na ├╖ target Na) ΓêÆ 1]. This is not the total '
              'volume deficit and must not be administered as a rapid D5W bolus.',
        ),
        const SizedBox(height: 10),
        _ResultCard(
          title: 'Estimated electrolyte-free-water delivery',
          value: freeWaterPerDay == null
              ? 'ΓÇö'
              : '${freeWaterPerDay.toStringAsFixed(0)} mL/day',
          note: freeWaterFraction == null
              ? ''
              : 'Estimated fraction: '
                  '${(freeWaterFraction * 100).toStringAsFixed(1)}%. '
                  'Educational estimate only.',
        ),
        const SizedBox(height: 10),
        _ResultCard(
          title: 'Adrogu├⌐ΓÇôMadias estimate',
          value: adroguePerDay == null
              ? 'ΓÇö'
              : '${adroguePerDay.toStringAsFixed(1)} mmol/L/day',
          note: adroguePerL == null
              ? ''
              : '${adroguePerL.toStringAsFixed(2)} mmol/L per litre. '
                  'Theoretical estimate only; measured sodium trajectory is '
                  'more reliable.',
        ),
        if (highRiskFluid) ...<Widget>[
          const SizedBox(height: 10),
          const _ClinicalWarningCard(
            title: 'D5 0.2% NaCl selected',
            text:
                'This fluid is markedly hypotonic after dextrose metabolism and '
                'may deliver substantially more electrolyte-free water. Confirm '
                'the exact bag composition, indication, correction target, urine '
                'output and sodium monitoring schedule with local protocol, '
                'pharmacy and senior/PICU or nephrology support.',
            danger: true,
          ),
        ],
        const SizedBox(height: 20),
        const _CalculatorSectionTitle('5. Monitoring and documentation'),
        const _ClinicalWarningCard(
          title: 'Monitoring checklist',
          text:
              'ΓÇó Strict intake/output with urine, stool, emesis, oral/NG intake '
              'and medication carriers recorded separately.\n'
              'ΓÇó Serial neurologic and perfusion assessments.\n'
              'ΓÇó Repeat sodium according to severity and local protocol; consider '
              'earlier testing after a major rate change or unexpected trend.\n'
              'ΓÇó Recalculate after every new sodium and material change in net '
              'fluid balance.\n'
              'ΓÇó Escalate for seizure, altered mental status, shock, oliguria/'
              'anuria, sodium ΓëÑ170 mmol/L, rising sodium or overly rapid decline.',
          danger: false,
        ),
        const SizedBox(height: 12),
        SelectableText(
          'EMR SUMMARY\n'
          'Current weight: ${weight?.toStringAsFixed(2) ?? '<WEIGHT>'} kg\n'
          'Deficit method: $deficitMethod\n'
          'Estimated dehydration: '
          '${dehydrationPercent?.toStringAsFixed(1) ?? '<PERCENT>'}%\n'
          'Initial deficit: '
          '${initialDeficit?.toStringAsFixed(0) ?? '<INITIAL_DEFICIT>'} mL\n'
          'Remaining deficit: '
          '${remainingDeficit?.toStringAsFixed(0) ?? '<REMAINING_DEFICIT>'} mL\n'
          'Maintenance: '
          '${maintenanceHour?.toStringAsFixed(1) ?? '<MAINTENANCE>'} mL/hour\n'
          'Deficit component: '
          '${deficitHour?.toStringAsFixed(1) ?? '<DEFICIT_RATE>'} mL/hour\n'
          'Calculated scheduled total: '
          '${totalRate?.toStringAsFixed(1) ?? '<TOTAL_RATE>'} mL/hour\n'
          'Current sodium: ${sodium?.toStringAsFixed(0) ?? '<NA>'} mmol/L\n'
          'Target sodium: ${target?.toStringAsFixed(0) ?? '<TARGET_NA>'} mmol/L\n'
          'Selected fluid: $selectedFluid '
          '(Na ${fluid[0].toStringAsFixed(0)}, '
          'K ${fluid[1].toStringAsFixed(0)} mmol/L)\n'
          'Repeat sodium/reassessment: <TIME PER LOCAL PROTOCOL>\n\n'
          'Calculations are estimates. Verify with local institutional '
          'protocols, formulary, pharmacist, and attending physician before '
          'implementation.',
          style: const TextStyle(height: 1.45),
        ),
      ],
    );
  }
}

class _CalculatorSectionTitle extends StatelessWidget {
  final String text;

  const _CalculatorSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _ClinicalWarningCard extends StatelessWidget {
  final String title;
  final String text;
  final bool danger;

  const _ClinicalWarningCard({
    required this.title,
    required this.text,
    required this.danger,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = danger
        ? Theme.of(context).colorScheme.errorContainer
        : Theme.of(context).colorScheme.primaryContainer;
    final Color foreground = danger
        ? Theme.of(context).colorScheme.onErrorContainer
        : Theme.of(context).colorScheme.onPrimaryContainer;
    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: TextStyle(color: foreground, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClinicalSignsPanel extends StatelessWidget {
  final int mentalStatus;
  final int perfusion;
  final int mucosaEyes;
  final int urine;
  final int breathing;
  final ValueChanged<int> onMentalStatus;
  final ValueChanged<int> onPerfusion;
  final ValueChanged<int> onMucosaEyes;
  final ValueChanged<int> onUrine;
  final ValueChanged<int> onBreathing;

  const _ClinicalSignsPanel({
    required this.mentalStatus,
    required this.perfusion,
    required this.mucosaEyes,
    required this.urine,
    required this.breathing,
    required this.onMentalStatus,
    required this.onPerfusion,
    required this.onMucosaEyes,
    required this.onUrine,
    required this.onBreathing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: <Widget>[
            _SignDropdown(
              label: 'Mental status',
              value: mentalStatus,
              options: const <String>[
                'Alert',
                'Irritable',
                'Lethargic/reduced consciousness',
              ],
              onChanged: onMentalStatus,
            ),
            const SizedBox(height: 10),
            _SignDropdown(
              label: 'Perfusion',
              value: perfusion,
              options: const <String>[
                'Warm, normal refill/pulses',
                'Mildly prolonged refill/cool',
                'Weak pulses, cold/mottled or hypotensive',
              ],
              onChanged: onPerfusion,
            ),
            const SizedBox(height: 10),
            _SignDropdown(
              label: 'Mucosa/eyes/skin',
              value: mucosaEyes,
              options: const <String>[
                'Moist/normal',
                'Dry or mildly sunken',
                'Very dry/deeply sunken/markedly reduced recoil',
              ],
              onChanged: onMucosaEyes,
            ),
            const SizedBox(height: 10),
            _SignDropdown(
              label: 'Urine output',
              value: urine,
              options: const <String>[
                'Normal',
                'Reduced',
                'Oliguria/anuria',
              ],
              onChanged: onUrine,
            ),
            const SizedBox(height: 10),
            _SignDropdown(
              label: 'Breathing',
              value: breathing,
              options: const <String>[
                'Normal',
                'Tachypnea',
                'Deep acidotic/abnormal breathing',
              ],
              onChanged: onBreathing,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignDropdown extends StatelessWidget {
  final String label;
  final int value;
  final List<String> options;
  final ValueChanged<int> onChanged;

  const _SignDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
      ),
      items: List<DropdownMenuItem<int>>.generate(
        options.length,
        (int index) => DropdownMenuItem<int>(
          value: index,
          child: Text(options[index]),
        ),
      ),
      onChanged: (int? next) {
        if (next != null) onChanged(next);
      },
    );
  }
}

