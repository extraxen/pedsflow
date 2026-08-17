import 'dart:math' as math;

import 'package:flutter/material.dart';

class HypokalemiaEngineScreen extends StatefulWidget {
  const HypokalemiaEngineScreen({super.key});

  @override
  State<HypokalemiaEngineScreen> createState() => _HypokalemiaEngineScreenState();
}

class _HypokalemiaEngineScreenState extends State<HypokalemiaEngineScreen> {
  final TextEditingController _weight = TextEditingController(text: '20');
  final TextEditingController _currentK = TextEditingController(text: '2.8');
  final TextEditingController _targetK = TextEditingController(text: '3.5');
  final TextEditingController _fluidK = TextEditingController(text: '20');
  final TextEditingController _fluidRate = TextEditingController(text: '60');
  final TextEditingController _oralDose = TextEditingController(text: '1');
  final TextEditingController _oralConcentration = TextEditingController(text: '1.33');
  final TextEditingController _ivConcentration = TextEditingController(text: '40');
  final TextEditingController _customIvRate = TextEditingController(text: '0.2');
  final TextEditingController _duration = TextEditingController(text: '3');

  String _route = 'oral';
  String _area = 'ward';
  String _access = 'peripheral';
  bool _ecgChanges = false;
  bool _symptomatic = false;
  bool _urineOutput = true;
  bool _renalImpairment = false;
  bool _continueBackgroundFluid = true;

  @override
  void dispose() {
    for (final TextEditingController controller in <TextEditingController>[
      _weight,
      _currentK,
      _targetK,
      _fluidK,
      _fluidRate,
      _oralDose,
      _oralConcentration,
      _ivConcentration,
      _customIvRate,
      _duration,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _n(TextEditingController controller) {
    final double? value = double.tryParse(controller.text.trim());
    return value != null && value.isFinite ? value : null;
  }

  double _maintenanceRate(double weight) {
    if (weight <= 10) return weight * 4;
    if (weight <= 20) return 40 + (weight - 10) * 2;
    return 60 + (weight - 20);
  }

  String _severity(double potassium) {
    if (potassium < 2.0) return 'CRITICAL';
    if (potassium < 2.5) return 'SEVERE';
    if (potassium < 3.0) return 'MODERATE';
    if (potassium < 3.5) return 'MILD';
    return 'NORMAL / ABOVE HYPOKALEMIA RANGE';
  }

  Color _severityColor(BuildContext context, double potassium) {
    if (potassium < 2.5) return Theme.of(context).colorScheme.error;
    if (potassium < 3.0) return const Color(0xFFB25E00);
    if (potassium < 3.5) return const Color(0xFF8A6A00);
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final double? weight = _n(_weight);
    final double? currentK = _n(_currentK);
    final double? targetK = _n(_targetK);
    final double? fluidK = _n(_fluidK);
    final double? fluidRate = _n(_fluidRate);
    final double? oralDosePerKg = _n(_oralDose);
    final double? oralConc = _n(_oralConcentration);
    final double? ivConc = _n(_ivConcentration);
    final double? ivRatePerKg = _n(_customIvRate);
    final double? duration = _n(_duration);

    final double? backgroundMmolPerHour = fluidK != null && fluidRate != null
        ? fluidK * fluidRate / 1000
        : null;
    final double? backgroundMmolPerKgHour = weight != null && weight > 0 && backgroundMmolPerHour != null
        ? backgroundMmolPerHour / weight
        : null;
    final double? backgroundMmolPerKgDay = backgroundMmolPerKgHour != null
        ? backgroundMmolPerKgHour * 24
        : null;

    double? oralMmol;
    double? oralVolume;
    if (weight != null && weight > 0 && oralDosePerKg != null) {
      oralMmol = math.min(weight * oralDosePerKg, 20.0);
      if (oralConc != null && oralConc > 0) oralVolume = oralMmol / oralConc;
    }

    double? ivMmolPerHour;
    double? ivTotalMmol;
    double? requiredFluidRate;
    double? ivMmolPerKgHour;
    if (weight != null && weight > 0 && ivRatePerKg != null) {
      final double maxHourly = _area == 'ward' ? 10.0 : 20.0;
      ivMmolPerHour = math.min(weight * ivRatePerKg, maxHourly);
      ivMmolPerKgHour = ivMmolPerHour / weight;
      if (duration != null && duration > 0) ivTotalMmol = ivMmolPerHour * duration;
      if (ivConc != null && ivConc > 0) requiredFluidRate = ivMmolPerHour / ivConc * 1000;
    }

    final double? totalMmolPerHour = ivMmolPerHour == null
        ? null
        : ivMmolPerHour + ((_continueBackgroundFluid && backgroundMmolPerHour != null) ? backgroundMmolPerHour : 0);
    final double? totalMmolPerKgHour = totalMmolPerHour != null && weight != null && weight > 0
        ? totalMmolPerHour / weight
        : null;
    final double? maintenanceRate = weight != null && weight > 0 ? _maintenanceRate(weight) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hypokalemia Replacement Engine', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        children: <Widget>[
          Card(
            color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.45),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Potassium chloride is a high-alert medication. Confirm the measured weight, repeat/verify unexpected potassium values, ensure urine output, review renal function and magnesium, and independently verify the final order/concentration against local pharmacy/PCCU policy.',
                style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _sectionTitle(context, '1. Patient & severity'),
          Row(children: <Widget>[
            Expanded(child: _field(_weight, 'Weight', 'kg')),
            const SizedBox(width: 10),
            Expanded(child: _field(_currentK, 'Current K', 'mmol/L')),
            const SizedBox(width: 10),
            Expanded(child: _field(_targetK, 'Target K', 'mmol/L')),
          ]),
          if (currentK != null) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _severityColor(context, currentK).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _severityColor(context, currentK).withValues(alpha: 0.35)),
              ),
              child: Row(children: <Widget>[
                Icon(Icons.monitor_heart_outlined, color: _severityColor(context, currentK)),
                const SizedBox(width: 10),
                Expanded(child: Text('Severity: ${_severity(currentK)}', style: TextStyle(fontWeight: FontWeight.w900, color: _severityColor(context, currentK)))),
                if (targetK != null) Text('Δ ${(targetK - currentK).toStringAsFixed(1)} mmol/L', style: const TextStyle(fontWeight: FontWeight.w800)),
              ]),
            ),
          ],
          const SizedBox(height: 8),
          SwitchListTile.adaptive(value: _symptomatic, onChanged: (v) => setState(() => _symptomatic = v), title: const Text('Symptoms attributable to hypokalemia')),
          SwitchListTile.adaptive(value: _ecgChanges, onChanged: (v) => setState(() => _ecgChanges = v), title: const Text('ECG changes / arrhythmia risk')),
          SwitchListTile.adaptive(value: _urineOutput, onChanged: (v) => setState(() => _urineOutput = v), title: const Text('Passing urine / adequate urine output')),
          SwitchListTile.adaptive(value: _renalImpairment, onChanged: (v) => setState(() => _renalImpairment = v), title: const Text('Renal impairment, oliguria, or rising creatinine')),
          if (!_urineOutput || _renalImpairment)
            _warning(context, 'HIGH RISK: potassium replacement may accumulate. Pause routine calculation and obtain senior/PCCU/nephrology/pharmacy guidance before replacement.'),
          if (currentK != null && currentK < 2.0)
            _warning(context, 'CRITICAL K <2.0 mmol/L: specialist/PCCU-level management is recommended; treat this as a monitored high-risk replacement scenario.'),
          const SizedBox(height: 16),
          _sectionTitle(context, '2. Potassium already running in IV fluids'),
          Row(children: <Widget>[
            Expanded(child: _field(_fluidK, 'KCl in current fluid', 'mmol/L')),
            const SizedBox(width: 10),
            Expanded(child: _field(_fluidRate, 'Current IV fluid rate', 'mL/hr')),
          ]),
          const SizedBox(height: 10),
          if (backgroundMmolPerHour != null && weight != null && weight > 0)
            _resultCard(context, 'Background potassium delivery', <String>[
              '${backgroundMmolPerHour.toStringAsFixed(2)} mmol/hr',
              '${backgroundMmolPerKgHour!.toStringAsFixed(3)} mmol/kg/hr',
              '${backgroundMmolPerKgDay!.toStringAsFixed(2)} mmol/kg/day',
              if (maintenanceRate != null) 'Current fluid = ${fluidRate?.toStringAsFixed(0)} mL/hr; 4-2-1 maintenance ≈ ${maintenanceRate.toStringAsFixed(0)} mL/hr',
            ]),
          const SizedBox(height: 16),
          _sectionTitle(context, '3. Replacement route'),
          SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment(value: 'oral', label: Text('Oral / enteral'), icon: Icon(Icons.medication_liquid_outlined)),
              ButtonSegment(value: 'iv', label: Text('IV KCl'), icon: Icon(Icons.water_drop_outlined)),
            ],
            selected: <String>{_route},
            onSelectionChanged: (Set<String> value) => setState(() => _route = value.first),
          ),
          const SizedBox(height: 14),
          if (_route == 'oral') ..._oralSection(context, weight, currentK, oralMmol, oralVolume)
          else ..._ivSection(context, weight, currentK, ivMmolPerHour, ivMmolPerKgHour, ivTotalMmol, requiredFluidRate, totalMmolPerHour, totalMmolPerKgHour, maintenanceRate),
          const SizedBox(height: 18),
          _sectionTitle(context, '4. Expected response & monitoring'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                const Text('Do not convert mmol administered into a guaranteed serum-K rise.', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('The observed change depends on total-body deficit, acid-base status, ongoing GI/renal losses, insulin and beta-agonists, magnesium, renal function, and whether an intracellular shift is resolving.'),
                const SizedBox(height: 10),
                if (_route == 'oral') const Text('Immediate-release oral KCl: measurable serum effect is expected at approximately 2 hours. Controlled-release products are slower (~4 hours). Recheck timing should reflect severity and clinical context.'),
                if (_route == 'iv') Text(_area == 'ward'
                    ? 'General-ward reference: repeat serum potassium 1 hour after replacement completion and check before further replacement.'
                    : 'Critical-care reference: repeat serum potassium 1 hour after replacement commencement and again 1 hour after completion.'),
                const SizedBox(height: 10),
                const Text('Always monitor: clinical/fluid status, urine output, magnesium, renal function; ECG when K <3 mmol/L, symptomatic, arrhythmia risk, or during IV replacement.'),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ExpansionTile(
              title: Text('Why is the potassium low?', style: TextStyle(fontWeight: FontWeight.w800)),
              childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: <Widget>[
                Text('GI losses: vomiting, diarrhea, fistula, laxatives.'),
                SizedBox(height: 5),
                Text('Renal losses: osmotic diuresis, mineralocorticoid excess, renal tubular disorders.'),
                SizedBox(height: 5),
                Text('Transcellular shift: alkalosis, insulin/glucose, DKA treatment, refeeding, beta-agonists/epinephrine.'),
                SizedBox(height: 5),
                Text('Medications: loop/thiazide diuretics, amphotericin, cisplatin, insulin, salbutamol.'),
                SizedBox(height: 5),
                Text('Refractory hypokalemia: check and correct magnesium.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Reference basis: Royal Children’s Hospital Melbourne Hypokalaemia CPG (updated Oct 2024) and Intravenous Fluids CPG; LHSC NICU potassium chloride monograph is shown only for neonatal/local context. Local LHSC/PCCU pharmacy concentrations, smart-pump limits, and order sets remain authoritative.',
                style: TextStyle(fontSize: 12.5, height: 1.35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _oralSection(BuildContext context, double? weight, double? currentK, double? oralMmol, double? oralVolume) {
    return <Widget>[
      Card(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.45),
        child: const Padding(
          padding: EdgeInsets.all(13),
          child: Text('Oral/enteral is preferred when clinically appropriate. Acute reference dose: 1–2 mmol/kg/dose, maximum 20 mmol/dose; recheck before repeating. Maximum total 5 mmol/kg/day (50 mmol/day).', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: <Widget>[
        Expanded(child: _field(_oralDose, 'Chosen acute dose', 'mmol/kg')),
        const SizedBox(width: 10),
        Expanded(child: _field(_oralConcentration, 'Oral KCl concentration', 'mmol/mL')),
      ]),
      const SizedBox(height: 10),
      if (oralMmol != null)
        _resultCard(context, 'Oral KCl order calculation', <String>[
          'Dose = ${oralMmol.toStringAsFixed(1)} mmol${weight != null && _n(_oralDose) != null && weight * _n(_oralDose)! > 20 ? ' (capped at 20 mmol)' : ''}',
          if (oralVolume != null) 'At ${_n(_oralConcentration)?.toStringAsFixed(2)} mmol/mL → ${oralVolume.toStringAsFixed(1)} mL',
          'Expected serum effect: approximately 2 hours for immediate-release oral mixture/effervescent product',
          'Give with or soon after food/feeds to reduce GI irritation',
        ]),
      if (currentK != null && (currentK < 2.5 || _ecgChanges))
        _warning(context, 'Current severity/ECG status is a reason to consider IV replacement rather than relying only on enteral replacement.'),
      const SizedBox(height: 8),
      const Text('Common oral forms: KCl oral mixture 1.33 mmol/mL; effervescent KCl products may contain 14 mmol/tablet; controlled-release products are intended for mild/chronic replacement and have slower absorption.', style: TextStyle(fontSize: 13)),
    ];
  }

  List<Widget> _ivSection(
    BuildContext context,
    double? weight,
    double? currentK,
    double? ivMmolPerHour,
    double? ivMmolPerKgHour,
    double? ivTotalMmol,
    double? requiredFluidRate,
    double? totalMmolPerHour,
    double? totalMmolPerKgHour,
    double? maintenanceRate,
  ) {
    final double selectedDefault = _area == 'ward' ? 0.2 : 0.4;
    final double? ivConc = _n(_ivConcentration);
    final bool concentrationConcern = _access == 'peripheral' && ivConc != null && ivConc > 40;
    final bool centralRequired = ivConc != null && ivConc > 60;
    final bool rateConcern = totalMmolPerKgHour != null && totalMmolPerKgHour > (_area == 'ward' ? 0.2 : 0.4) + 0.0001;
    final bool fluidBurden = requiredFluidRate != null && maintenanceRate != null && requiredFluidRate > maintenanceRate * 1.25;

    return <Widget>[
      DropdownButtonFormField<String>(
        initialValue: _area,
        decoration: const InputDecoration(labelText: 'Treatment area', border: OutlineInputBorder()),
        items: const <DropdownMenuItem<String>>[
          DropdownMenuItem(value: 'ward', child: Text('General ward reference')),
          DropdownMenuItem(value: 'critical', child: Text('Critical care / PCCU reference')),
        ],
        onChanged: (String? value) {
          if (value == null) return;
          setState(() {
            _area = value;
            _customIvRate.text = value == 'ward' ? '0.2' : '0.4';
            _duration.text = value == 'ward' ? '3' : '1';
          });
        },
      ),
      const SizedBox(height: 10),
      Card(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.45),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Text(_area == 'ward'
              ? 'General ward reference: 0.2 mmol/kg/hr for 3 hr (max 10 mmol/hr).'
              : 'Critical care reference: 0.4 mmol/kg/hr for 1–2 hr (max 20 mmol/hr), with continuous ECG monitoring.', style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: <Widget>[
        Expanded(child: _field(_customIvRate, 'Selected K rate', 'mmol/kg/hr')),
        const SizedBox(width: 10),
        Expanded(child: _field(_duration, 'Duration', 'hr')),
      ]),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        initialValue: _access,
        decoration: const InputDecoration(labelText: 'IV access', border: OutlineInputBorder()),
        items: const <DropdownMenuItem<String>>[
          DropdownMenuItem(value: 'peripheral', child: Text('Peripheral IV')),
          DropdownMenuItem(value: 'central', child: Text('Central venous access')),
        ],
        onChanged: (String? value) => setState(() => _access = value ?? 'peripheral'),
      ),
      const SizedBox(height: 10),
      _field(_ivConcentration, 'Final KCl concentration in infusate', 'mmol/L'),
      const SizedBox(height: 6),
      Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
        ActionChip(label: const Text('20 mmol/L'), onPressed: () => setState(() => _ivConcentration.text = '20')),
        ActionChip(label: const Text('40 mmol/L'), onPressed: () => setState(() => _ivConcentration.text = '40')),
        ActionChip(label: const Text('60 mmol/L'), onPressed: () => setState(() => _ivConcentration.text = '60')),
        ActionChip(label: const Text('80 mmol/L'), onPressed: () => setState(() => _ivConcentration.text = '80')),
      ]),
      const SizedBox(height: 10),
      if (ivMmolPerHour != null)
        _resultCard(context, 'IV replacement calculation', <String>[
          '${ivMmolPerHour.toStringAsFixed(2)} mmol/hr (${ivMmolPerKgHour?.toStringAsFixed(3)} mmol/kg/hr)',
          if (ivTotalMmol != null) 'Total over ${_n(_duration)?.toStringAsFixed(1)} hr = ${ivTotalMmol.toStringAsFixed(1)} mmol',
          if (requiredFluidRate != null) 'At ${_n(_ivConcentration)?.toStringAsFixed(0)} mmol/L → infusion fluid rate ${requiredFluidRate.toStringAsFixed(0)} mL/hr',
          if (maintenanceRate != null) '4-2-1 maintenance reference ≈ ${maintenanceRate.toStringAsFixed(0)} mL/hr',
        ]),
      SwitchListTile.adaptive(
        value: _continueBackgroundFluid,
        onChanged: (v) => setState(() => _continueBackgroundFluid = v),
        title: const Text('Continue current potassium-containing background fluid during acute IV replacement'),
        subtitle: const Text('Turn off if it will be paused; the total-delivery calculation changes immediately.'),
      ),
      if (totalMmolPerHour != null && weight != null)
        _resultCard(context, 'TOTAL potassium delivery from all IV sources', <String>[
          '${totalMmolPerHour.toStringAsFixed(2)} mmol/hr',
          '${totalMmolPerKgHour?.toStringAsFixed(3)} mmol/kg/hr',
          'Acute replacement + ${_continueBackgroundFluid ? 'background K-containing fluid' : 'background potassium paused'}',
        ]),
      if (concentrationConcern)
        _warning(context, 'Peripheral concentration >40 mmol/L: 40 mmol/L is the usual peripheral maximum in the RCH reference; 40–60 mmol/L requires senior/local review. Monitor the IV site closely.'),
      if (centralRequired && _access != 'central')
        _warning(context, 'Concentration >60 mmol/L should be treated as CENTRAL-LINE ONLY under the referenced guideline.'),
      if (fluidBurden)
        _warning(context, 'FLUID BURDEN: the calculated infusion fluid rate is >125% of 4-2-1 maintenance. A different concentration/critical-care approach may be required rather than simply increasing fluid volume.'),
      if (rateConcern)
        _warning(context, 'TOTAL K DELIVERY ALERT: background potassium plus replacement exceeds the selected area reference rate. Pause/recalculate potassium-containing maintenance/PN and independently verify the order.'),
      if (_n(_customIvRate) != null && _n(_customIvRate)! > selectedDefault + 0.0001)
        _warning(context, 'The chosen mmol/kg/hr rate is above the default reference for this treatment area. This requires an explicit senior/local protocol decision.'),
      const SizedBox(height: 8),
      const Text('Administration safety: use an infusion pump/smart library where available; use premixed bags where possible; label all potassium-containing bags/lines; never give KCl IV push and never flush a KCl infusion line.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    ];
  }

  Widget _field(TextEditingController controller, String label, String suffix) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: label, suffixText: suffix, border: const OutlineInputBorder()),
      );

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
      );

  Widget _resultCard(BuildContext context, String title, List<String> lines) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            ...lines.map((line) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(line))),
          ]),
        ),
      );

  Widget _warning(BuildContext context, String text) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.35)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.3))),
        ]),
      );
}
