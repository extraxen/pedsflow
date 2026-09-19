// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.

import 'package:flutter/material.dart';
import 'infant_feeding_engine.dart';

class InfantFeedingScreen extends StatefulWidget {
  const InfantFeedingScreen({super.key});
  @override
  State<InfantFeedingScreen> createState() => _InfantFeedingScreenState();
}

class _InfantFeedingScreenState extends State<InfantFeedingScreen> {
  final weight = TextEditingController(text: '3.2');
  final birthWeight = TextEditingController(text: '3.3');
  final ageDays = TextEditingController(text: '3');
  final volumeGoal = TextEditingController(text: '130');
  final kcalOz = TextEditingController(text: '20');
  final calorieGoal = TextEditingController(text: '100');
  int feeds = 8;
  bool useDolTarget = true;

  double? n(TextEditingController c) => double.tryParse(c.text.trim());
  int? intValue(TextEditingController c) => int.tryParse(c.text.trim());

  @override
  void dispose() {
    weight.dispose(); birthWeight.dispose(); ageDays.dispose(); volumeGoal.dispose();
    kcalOz.dispose(); calorieGoal.dispose(); super.dispose();
  }

  Widget field(TextEditingController c, String label, String suffix) => TextField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(labelText: label, suffixText: suffix, border: const OutlineInputBorder()),
  );

  Widget result(String label, String value) => Card(
    child: ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final w = n(weight);
    final bw = n(birthWeight);
    final days = intValue(ageDays);
    final density = n(kcalOz);
    final early = days != null && days <= 5;
    final target = days == null ? null : InfantFeedingEngine.termTargetForDol(days);
    final selectedMlKg = useDolTarget && early && target != null ? target.midpoint : n(volumeGoal);
    final daily = w != null && selectedMlKg != null ? InfantFeedingEngine.dailyVolume(weightKg: w, mlKgDay: selectedMlKg) : null;
    final perFeed = w != null && selectedMlKg != null ? InfantFeedingEngine.volumePerFeed(weightKg: w, mlKgDay: selectedMlKg, feedsPerDay: feeds) : null;
    final energy = selectedMlKg != null && density != null ? InfantFeedingEngine.kcalKgDay(mlKgDay: selectedMlKg, kcalPerOz: density) : null;
    final desired = n(calorieGoal);
    final reverse = desired != null && density != null && density > 0 ? InfantFeedingEngine.mlKgDayFromCalories(targetKcalKgDay: desired, kcalPerOz: density) : null;
    final change = w != null && bw != null && bw > 0 ? InfantFeedingEngine.percentWeightChange(birthWeightKg: bw, currentWeightKg: w) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Neonatal & Infant Feeding', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(
          early
            ? 'Early term-newborn mode: day-of-life values are reference TOTAL-FLUID targets, not mandatory enteral intake. Breastfeeding effectiveness, weight trajectory, urine/stool output, glucose, sodium and clinical status must guide the actual plan.'
            : 'Infant nutrition mode: calculate volume and calories together. Individualize for growth, illness, fluid restriction and feeding tolerance.',
          style: const TextStyle(fontWeight: FontWeight.w700)))),
        Wrap(spacing: 10, runSpacing: 10, children: [
          SizedBox(width: 210, child: field(weight, 'Current weight', 'kg')),
          SizedBox(width: 210, child: field(birthWeight, 'Birth weight', 'kg')),
          SizedBox(width: 210, child: field(ageDays, 'Age', 'days')),
          SizedBox(width: 210, child: field(kcalOz, 'Feed density', 'kcal/oz')),
        ]),
        const SizedBox(height: 12),
        if (target != null && early) ...[
          result('DOL reference', target.minMlKgDay == target.maxMlKgDay
            ? target.minMlKgDay.toStringAsFixed(0) + ' mL/kg/day'
            : target.minMlKgDay.toStringAsFixed(0) + '–' + target.maxMlKgDay.toStringAsFixed(0) + ' mL/kg/day'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Use DOL reference midpoint for calculations'),
            subtitle: Text('Currently ' + target.midpoint.toStringAsFixed(0) + ' mL/kg/day'),
            value: useDolTarget, onChanged: (v) => setState(() => useDolTarget = v)),
        ],
        if (!useDolTarget || !early) field(volumeGoal, 'Volume target', 'mL/kg/day'),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          initialValue: feeds,
          decoration: const InputDecoration(labelText: 'Feeding frequency', border: OutlineInputBorder()),
          items: const [6, 8, 10, 12].map((x) => DropdownMenuItem(value: x, child: Text(x.toString() + ' feeds/day'))).toList(),
          onChanged: (v) => setState(() => feeds = v ?? feeds)),
        const SizedBox(height: 10),
        if (selectedMlKg != null) result('Selected volume', selectedMlKg.toStringAsFixed(0) + ' mL/kg/day'),
        if (daily != null) result('Total daily volume', daily.toStringAsFixed(0) + ' mL/day'),
        if (perFeed != null) result('Volume per feed', perFeed.toStringAsFixed(1) + ' mL/feed'),
        if (energy != null) result('Energy delivered', energy.toStringAsFixed(0) + ' kcal/kg/day'),
        if (change != null) result('Change from birth weight', (change >= 0 ? '+' : '') + change.toStringAsFixed(1) + '%'),
        const Divider(height: 30),
        const Text('CALORIE → VOLUME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 8),
        field(calorieGoal, 'Desired energy', 'kcal/kg/day'),
        if (reverse != null) ...[
          result('Required volume', reverse.toStringAsFixed(0) + ' mL/kg/day'),
          if (w != null) result('Total volume needed', (reverse * w).toStringAsFixed(0) + ' mL/day'),
          if (w != null) result('Volume per feed', (reverse * w / feeds).toStringAsFixed(1) + ' mL/feed'),
        ],
        const Divider(height: 30),
        const Text('Reference framework', style: TextStyle(fontWeight: FontWeight.w900)),
        const Text('• Term newborn reference progression: 60–80, 80–100, 100–120, 120–140, 140–150, then ~150 mL/kg/day.\n'
          '• Standard 20 kcal/oz milk is ~0.676 kcal/mL; therefore 150 mL/kg/day provides ~101 kcal/kg/day.\n'
          '• Preterm infants should use the separate Specific Patient Feeding Plan / local NICU pathway; do not apply this term progression blindly.\n'
          '• Healthy direct breastfeeding should be assessed clinically rather than prescribed a fixed mL/feed solely from this calculator.'),
        const SizedBox(height: 10),
        const Text('Clinical decision support only. Verify against the active local neonatal/infant feeding guideline and dietitian/NICU plan when applicable.',
          style: TextStyle(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
