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
  final age = TextEditingController(text: '3');
  final customVolume = TextEditingController(text: '150');
  final customKcal = TextEditingController(text: '100');
  String ageUnit = 'days';
  double kcalOz = 20;
  int hoursBetweenFeeds = 3;
  bool continuous = false;
  bool customTarget = false;

  double? n(TextEditingController c) => double.tryParse(c.text.trim());
  int? i(TextEditingController c) => int.tryParse(c.text.trim());

  int? get ageDays {
    final value = i(age);
    if (value == null) return null;
    if (ageUnit == 'weeks') return value * 7;
    if (ageUnit == 'months') return (value * 30.4375).round();
    return value;
  }

  int get feedsPerDay => continuous ? 24 : 24 ~/ hoursBetweenFeeds;

  @override
  void dispose() {
    weight.dispose(); age.dispose(); customVolume.dispose(); customKcal.dispose();
    super.dispose();
  }

  Widget field(TextEditingController c, String label, String suffix) => TextField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(labelText: label, suffixText: suffix, border: const OutlineInputBorder()),
  );

  Widget result(String label, String value, {bool primary = false}) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontWeight: primary ? FontWeight.w900 : FontWeight.w700))),
        Text(value, style: TextStyle(fontSize: primary ? 22 : 16, fontWeight: FontWeight.w900)),
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final w = n(weight);
    final days = ageDays;
    final early = days != null && days <= 5;
    final dolTarget = days == null ? null : InfantFeedingEngine.termTargetForDol(days);
    final suggestedMlKg = early && dolTarget != null ? dolTarget.midpoint : 150.0;
    final mlKg = customTarget ? n(customVolume) : suggestedMlKg;
    final daily = w != null && mlKg != null ? InfantFeedingEngine.dailyVolume(weightKg: w, mlKgDay: mlKg) : null;
    final energy = mlKg != null ? InfantFeedingEngine.kcalKgDay(mlKgDay: mlKg, kcalPerOz: kcalOz) : null;
    final perFeed = !continuous && daily != null ? daily / feedsPerDay : null;
    final hourly = continuous && daily != null ? daily / 24 : null;
    final desiredKcal = n(customKcal);
    final volumeForCalories = desiredKcal != null ? InfantFeedingEngine.mlKgDayFromCalories(targetKcalKgDay: desiredKcal, kcalPerOz: kcalOz) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Feeding Calculator', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('PATIENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 10, children: [
          SizedBox(width: 190, child: field(weight, 'Weight', 'kg')),
          SizedBox(width: 120, child: field(age, 'Age', '')),
          SizedBox(width: 150, child: DropdownButtonFormField<String>(
            initialValue: ageUnit,
            decoration: const InputDecoration(labelText: 'Age unit', border: OutlineInputBorder()),
            items: const ['days','weeks','months'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (v) => setState(() => ageUnit = v ?? ageUnit),
          )),
        ]),
        const SizedBox(height: 18),
        const Text('FEED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 10, children: [
          SizedBox(width: 190, child: DropdownButtonFormField<double>(
            initialValue: kcalOz,
            decoration: const InputDecoration(labelText: 'Feed density', border: OutlineInputBorder()),
            items: const [20.0,22.0,24.0,27.0,30.0].map((x) => DropdownMenuItem(value: x, child: Text('${x.toInt()} kcal/oz'))).toList(),
            onChanged: (v) => setState(() => kcalOz = v ?? kcalOz),
          )),
          SizedBox(width: 190, child: DropdownButtonFormField<String>(
            initialValue: 'q3h',
            decoration: const InputDecoration(labelText: 'Frequency', border: OutlineInputBorder()),
            items: const ['q2h','q3h','q4h','continuous'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (v) => setState(() {
              continuous = v == 'continuous';
              if (v == 'q2h') hoursBetweenFeeds = 2;
              if (v == 'q3h') hoursBetweenFeeds = 3;
              if (v == 'q4h') hoursBetweenFeeds = 4;
            }),
          )),
        ]),
        const SizedBox(height: 18),
        if (early && dolTarget != null) Card(child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text('DOL reference: ${dolTarget.minMlKgDay.toStringAsFixed(0)}–${dolTarget.maxMlKgDay.toStringAsFixed(0)} mL/kg/day. Calculations use the midpoint unless you override it.',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        )) else const Card(child: Padding(
          padding: EdgeInsets.all(14),
          child: Text('Default bedside volume reference: 150 mL/kg/day. Adjust for age, growth, illness, fluid restriction and the clinical feeding plan.',
            style: TextStyle(fontWeight: FontWeight.w800)),
        )),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Override volume target'),
          value: customTarget,
          onChanged: (v) => setState(() => customTarget = v),
        ),
        if (customTarget) field(customVolume, 'Volume target', 'mL/kg/day'),
        const SizedBox(height: 8),
        if (perFeed != null) result('Give per feed', '${perFeed.toStringAsFixed(0)} mL', primary: true),
        if (hourly != null) result('Continuous rate', '${hourly.toStringAsFixed(1)} mL/hr', primary: true),
        if (daily != null) result('Total daily volume', '${daily.toStringAsFixed(0)} mL/day'),
        if (mlKg != null) result('Volume target', '${mlKg.toStringAsFixed(0)} mL/kg/day'),
        if (energy != null) result('Calories delivered', '${energy.toStringAsFixed(0)} kcal/kg/day'),
        const Divider(height: 30),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('Advanced / Energy target', style: TextStyle(fontWeight: FontWeight.w900)),
          subtitle: const Text('Optional calorie → volume calculation'),
          children: [
            field(customKcal, 'Desired energy', 'kcal/kg/day'),
            const SizedBox(height: 8),
            if (volumeForCalories != null) result('Volume needed', '${volumeForCalories.toStringAsFixed(0)} mL/kg/day'),
            if (volumeForCalories != null && w != null)
              result('Total volume needed', '${(volumeForCalories * w).toStringAsFixed(0)} mL/day'),
            if (volumeForCalories != null && w != null && !continuous)
              result('Equivalent per feed', '${(volumeForCalories * w / feedsPerDay).toStringAsFixed(0)} mL/feed'),
            if (volumeForCalories != null && w != null && continuous)
              result('Equivalent continuous rate', '${(volumeForCalories * w / 24).toStringAsFixed(1)} mL/hr'),
          ],
        ),
        const Divider(height: 24),
        const Text('Clinical decision support only. Early newborn targets represent total-fluid references, not mandatory enteral intake. Direct breastfeeding, prematurity, growth, hydration, electrolytes, illness and local NICU/dietitian plans require individualized assessment.',
          style: TextStyle(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
