// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'dart:math' as math;

import 'package:flutter/material.dart';

class HypokalemiaEngineScreen extends StatefulWidget {
  const HypokalemiaEngineScreen({super.key});

  @override
  State<HypokalemiaEngineScreen> createState() =>
      _HypokalemiaEngineScreenState();
}

class _HypokalemiaEngineScreenState extends State<HypokalemiaEngineScreen> {
  final TextEditingController _age = TextEditingController(text: '8');
  final TextEditingController _weight = TextEditingController(text: '20');
  final TextEditingController _currentK = TextEditingController(text: '2.5');
  final TextEditingController _targetK = TextEditingController(text: '3.5');
  final TextEditingController _magnesium = TextEditingController();

  final TextEditingController _baseFluidRate =
      TextEditingController(text: '50');
  final TextEditingController _customIntrinsicK =
      TextEditingController(text: '0');
  final TextEditingController _customAddedK =
      TextEditingController(text: '20');
  final TextEditingController _bagVolume = TextEditingController(text: '1000');
  final TextEditingController _bagTotalAddedK = TextEditingController(text: '20');

  final TextEditingController _oralDosePerKg =
      TextEditingController(text: '1');
  final TextEditingController _oralConcentration =
      TextEditingController(text: '1.33');

  final TextEditingController _ivRatePerKg =
      TextEditingController(text: '0.4');
  final TextEditingController _ivDuration = TextEditingController(text: '1');
  final TextEditingController _ivConcentration =
      TextEditingController(text: '80');

  final TextEditingController _followUpK = TextEditingController();
  final TextEditingController _followUpHours = TextEditingController(text: '2');

  String _fluidType = 'D5 + 0.9% NaCl (D5NS)';
  String _addedKChoice = '20';
  String _oralDoseChoice = '1';
  String _ivPreset = 'critical';
  String _ivConcentrationChoice = '80';
  String _access = 'central';
  int _forecastHours = 4;

  bool _addOral = true;
  bool _addIv = true;
  bool _continueBaseFluidDuringIv = true;
  bool _ecgChanges = false;
  bool _symptomatic = false;
  bool _adequateUrineOutput = true;
  bool _renalImpairment = false;

  static const List<String> _fluidOptions = <String>[
    '0.9% NaCl',
    'D5W',
    'D10W',
    'D5 + 0.9% NaCl (D5NS)',
    'D10 + 0.9% NaCl (D10NS)',
    'D5 + 0.45% NaCl',
    'D10 + 0.45% NaCl',
    'Lactated Ringer\'s',
    'D5 Lactated Ringer\'s',
    'Plasma-Lyte',
    'D5 Plasma-Lyte',
    'Custom fluid',
  ];

  @override
  void dispose() {
    for (final TextEditingController controller in <TextEditingController>[
      _age,
      _weight,
      _currentK,
      _targetK,
      _magnesium,
      _baseFluidRate,
      _customIntrinsicK,
      _customAddedK,
      _bagVolume,
      _bagTotalAddedK,
      _oralDosePerKg,
      _oralConcentration,
      _ivRatePerKg,
      _ivDuration,
      _ivConcentration,
      _followUpK,
      _followUpHours,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _number(TextEditingController controller) {
    final double? value = double.tryParse(controller.text.trim());
    if (value == null || !value.isFinite) return null;
    return value;
  }

  double _intrinsicPotassiumForFluid(String fluid) {
    switch (fluid) {
      case 'Lactated Ringer\'s':
      case 'D5 Lactated Ringer\'s':
        return 4;
      case 'Plasma-Lyte':
      case 'D5 Plasma-Lyte':
        return 5;
      case 'Custom fluid':
        return _number(_customIntrinsicK) ?? 0;
      default:
        return 0;
    }
  }

  double _addedKConcentration() {
    switch (_addedKChoice) {
      case '0':
        return 0;
      case '20':
        return 20;
      case '40':
        return 40;
      case 'custom':
        return math.max(0, _number(_customAddedK) ?? 0).toDouble();
      case 'bag':
        final double? bagVolume = _number(_bagVolume);
        final double? bagTotal = _number(_bagTotalAddedK);
        if (bagVolume == null || bagVolume <= 0 || bagTotal == null) return 0;
        return math.max(0, bagTotal * 1000 / bagVolume).toDouble();
      default:
        return 0;
    }
  }

  double _selectedOralDosePerKg() {
    if (_oralDoseChoice == 'custom') {
      return math.max(0, _number(_oralDosePerKg) ?? 0).toDouble();
    }
    return double.tryParse(_oralDoseChoice) ?? 1;
  }

  double _selectedIvConcentration() {
    if (_ivConcentrationChoice == 'custom') {
      return math.max(0, _number(_ivConcentration) ?? 0).toDouble();
    }
    return double.tryParse(_ivConcentrationChoice) ?? 40;
  }

  void _applyIvPreset(String preset) {
    setState(() {
      _ivPreset = preset;
      if (preset == 'ward') {
        _ivRatePerKg.text = '0.2';
        _ivDuration.text = '3';
        _ivConcentrationChoice = '40';
        _access = 'peripheral';
      } else if (preset == 'critical') {
        _ivRatePerKg.text = '0.4';
        _ivDuration.text = '1';
        _ivConcentrationChoice = '80';
        _access = 'central';
      }
    });
  }

  String _severity(double potassium) {
    if (potassium < 2.0) return 'Critical';
    if (potassium < 2.5) return 'Severe';
    if (potassium < 3.0) return 'Moderate';
    if (potassium < 3.5) return 'Mild';
    return 'Not hypokalemic by this reference range';
  }

  Color _severityColor(BuildContext context, double potassium) {
    if (potassium < 2.5) return Theme.of(context).colorScheme.error;
    if (potassium < 3.0) return const Color(0xFFB25E00);
    if (potassium < 3.5) return const Color(0xFF866400);
    return Theme.of(context).colorScheme.primary;
  }

  double _maintenanceRate(double weight) {
    if (weight <= 10) return 4 * weight;
    if (weight <= 20) return 40 + 2 * (weight - 10);
    return 60 + (weight - 20);
  }

  _IvResponseEstimate? _ivResponseEstimate(double dosePerKg) {
    if (dosePerKg >= 0.32 && dosePerKg <= 0.47) {
      return const _IvResponseEstimate(
        comparatorDose: '0.4 mmol/kg over 1 hour',
        typicalRise: 0.38,
        spread: 'mean +0.38 mmol/L; SD Â±0.36',
        sourceLabel: '2024 pediatric PCCU cohort',
      );
    }
    if (dosePerKg > 0.47 && dosePerKg <= 0.75) {
      return const _IvResponseEstimate(
        comparatorDose: '0.5 mmol/kg IV',
        typicalRise: 0.5,
        spread: 'median +0.5 mmol/L; IQR +0.2 to +0.8',
        sourceLabel: '2023 non-cardiac pediatric cohort',
      );
    }
    if (dosePerKg > 0.75 && dosePerKg <= 1.15) {
      return const _IvResponseEstimate(
        comparatorDose: '1 mmol/kg IV',
        typicalRise: 0.8,
        spread: 'median +0.8 mmol/L; IQR +0.5 to +1.2',
        sourceLabel: '2023 non-cardiac pediatric cohort',
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double? age = _number(_age);
    final double? weight = _number(_weight);
    final double? currentK = _number(_currentK);
    final double? targetK = _number(_targetK);
    final double? baseRate = _number(_baseFluidRate);

    final double intrinsicK = _intrinsicPotassiumForFluid(_fluidType);
    final double addedK = _addedKConcentration();
    final double totalBaseKConcentration = intrinsicK + addedK;

    final double? baseKPerHour = baseRate != null && baseRate >= 0
        ? totalBaseKConcentration * baseRate / 1000
        : null;
    final double? baseKPerKgHour =
        weight != null && weight > 0 && baseKPerHour != null
            ? baseKPerHour / weight
            : null;
    final double? baseKOverForecast = baseKPerHour != null
        ? baseKPerHour * _forecastHours
        : null;
    final double? baseKPerDay = baseKPerHour != null ? baseKPerHour * 24 : null;

    final double oralDosePerKg = _selectedOralDosePerKg();
    final double? oralCalculatedMmol = _addOral && weight != null && weight > 0
        ? weight * oralDosePerKg
        : null;
    final double? oralMmol = oralCalculatedMmol == null
        ? null
        : math.min(oralCalculatedMmol, 20.0).toDouble();
    final double? oralConcentration = _number(_oralConcentration);
    final double? oralVolume = oralMmol != null &&
            oralConcentration != null &&
            oralConcentration > 0
        ? oralMmol / oralConcentration
        : null;

    final double? ivRatePerKg = _addIv ? _number(_ivRatePerKg) : null;
    final double? ivDuration = _addIv ? _number(_ivDuration) : null;
    final double ivConcentration = _selectedIvConcentration();
    final double maxIvMmolPerHour = _ivPreset == 'ward' ? 10 : 20;

    double? ivMmolPerHour;
    double? ivTotalMmol;
    double? ivDosePerKg;
    double? ivCarrierRate;
    if (_addIv &&
        weight != null &&
        weight > 0 &&
        ivRatePerKg != null &&
        ivRatePerKg >= 0 &&
        ivDuration != null &&
        ivDuration > 0) {
      ivMmolPerHour =
          math.min(weight * ivRatePerKg, maxIvMmolPerHour).toDouble();
      ivTotalMmol = ivMmolPerHour * ivDuration;
      ivDosePerKg = ivTotalMmol / weight;
      if (ivConcentration > 0) {
        ivCarrierRate = ivMmolPerHour / ivConcentration * 1000;
      }
    }

    final double backgroundDuringIv =
        _continueBaseFluidDuringIv ? (baseKPerHour ?? 0) : 0;
    final double? totalIvMmolPerHourDuringCorrection = ivMmolPerHour == null
        ? null
        : ivMmolPerHour + backgroundDuringIv;
    final double? totalIvMmolPerKgHourDuringCorrection =
        totalIvMmolPerHourDuringCorrection != null &&
                weight != null &&
                weight > 0
            ? totalIvMmolPerHourDuringCorrection / weight
            : null;

    final double ivMmolWithinForecast = ivMmolPerHour != null &&
            ivDuration != null &&
            ivDuration > 0
        ? ivMmolPerHour * math.min(ivDuration, _forecastHours.toDouble()).toDouble()
        : 0;
    final double combinedForecastMmol =
        (baseKOverForecast ?? 0) + (oralMmol ?? 0) + ivMmolWithinForecast;
    final double? combinedForecastPerKg = weight != null && weight > 0
        ? combinedForecastMmol / weight
        : null;

    final double? maintenanceRate =
        weight != null && weight > 0 ? _maintenanceRate(weight) : null;
    final _IvResponseEstimate? responseEstimate =
        ivDosePerKg == null ? null : _ivResponseEstimate(ivDosePerKg);

    final double? followUpK = _number(_followUpK);
    final double? followUpHours = _number(_followUpHours);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hypokalemia: Build My K Plan',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        children: <Widget>[
          _highAlertBanner(context),
          const SizedBox(height: 14),
          _sectionTitle(context, '1. Patient'),
          _responsiveFields(<Widget>[
            _field(_age, 'Age', 'years'),
            _field(_weight, 'Weight', 'kg'),
            _field(_currentK, 'Current K', 'mmol/L'),
            _field(_targetK, 'Target K', 'mmol/L'),
            _field(_magnesium, 'Magnesium', 'optional'),
          ]),
          if (currentK != null) ...<Widget>[
            const SizedBox(height: 10),
            _severityCard(context, currentK, targetK),
          ],
          const SizedBox(height: 4),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _symptomatic,
            onChanged: (bool value) => setState(() => _symptomatic = value),
            title: const Text('Symptoms attributable to hypokalemia'),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _ecgChanges,
            onChanged: (bool value) => setState(() => _ecgChanges = value),
            title: const Text('ECG changes / arrhythmia concern'),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _adequateUrineOutput,
            onChanged: (bool value) =>
                setState(() => _adequateUrineOutput = value),
            title: const Text('Adequate urine output'),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _renalImpairment,
            onChanged: (bool value) =>
                setState(() => _renalImpairment = value),
            title: const Text('AKI / oliguria / rising creatinine'),
          ),
          if (!_adequateUrineOutput || _renalImpairment)
            _warning(
              context,
              'HIGH RISK: potassium can accumulate when renal excretion is impaired. Do not rely on the routine calculator without senior/PCCU/nephrology/pharmacy review.',
            ),
          if (currentK != null && currentK < 2.0)
            _warning(
              context,
              'K <2.0 mmol/L: treat as a critical monitored replacement scenario with senior/PCCU involvement.',
            ),
          const SizedBox(height: 18),

          _sectionTitle(context, '2. Base IV fluid + potassium additive'),
          DropdownButtonFormField<String>(
            initialValue: _fluidType,
            decoration: const InputDecoration(
              labelText: 'Carrier fluid',
              border: OutlineInputBorder(),
            ),
            items: _fluidOptions
                .map(
                  (String fluid) => DropdownMenuItem<String>(
                    value: fluid,
                    child: Text(fluid),
                  ),
                )
                .toList(),
            onChanged: (String? value) {
              if (value == null) return;
              setState(() => _fluidType = value);
            },
          ),
          const SizedBox(height: 10),
          if (_fluidType == 'Custom fluid')
            _field(
              _customIntrinsicK,
              'Intrinsic K already in custom fluid',
              'mmol/L',
            )
          else if (intrinsicK > 0)
            _infoLine(
              context,
              'This carrier fluid has approximately ${intrinsicK.toStringAsFixed(0)} mmol/L intrinsic potassium before any added KCl. Verify the exact local product formulation.',
            ),
          const SizedBox(height: 10),
          _responsiveFields(<Widget>[
            _field(_baseFluidRate, 'Fluid rate', 'mL/hr'),
            DropdownButtonFormField<String>(
              initialValue: _addedKChoice,
              decoration: const InputDecoration(
                labelText: 'Added KCl',
                border: OutlineInputBorder(),
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem(value: '0', child: Text('None')),
                DropdownMenuItem(value: '20', child: Text('20 mmol/L')),
                DropdownMenuItem(value: '40', child: Text('40 mmol/L')),
                DropdownMenuItem(value: 'custom', child: Text('Custom mmol/L')),
                DropdownMenuItem(value: 'bag', child: Text('Total mmol in bag')),
              ],
              onChanged: (String? value) {
                if (value == null) return;
                setState(() => _addedKChoice = value);
              },
            ),
            if (_addedKChoice == 'custom')
              _field(_customAddedK, 'Custom added KCl', 'mmol/L'),
            if (_addedKChoice == 'bag')
              _field(_bagTotalAddedK, 'KCl added to bag', 'mmol'),
            if (_addedKChoice == 'bag')
              _field(_bagVolume, 'Bag volume', 'mL'),
          ]),
          const SizedBox(height: 10),
          if (_addedKChoice == 'bag')
            _infoLine(
              context,
              'Bag entry is converted to concentration automatically: ${(_number(_bagTotalAddedK) != null && _number(_bagVolume) != null && _number(_bagVolume)! > 0) ? (_number(_bagTotalAddedK)! * 1000 / _number(_bagVolume)!).toStringAsFixed(1) : 'â€”'} mmol/L added KCl.',
            ),
          if (targetK != null && currentK != null)
            _infoLine(
              context,
              'Selected target K ${targetK.toStringAsFixed(1)} is shown for context. PedsFlow does not back-calculate a potassium dose from the ${(targetK - currentK).toStringAsFixed(1)} mmol/L serum gap because serum K is not a direct measure of total-body deficit.',
            ),
          const SizedBox(height: 10),
          _resultCard(
            context,
            'Base-fluid potassium delivery',
            <String>[
              'Carrier: $_fluidType',
              'Intrinsic K: ${intrinsicK.toStringAsFixed(1)} mmol/L',
              'Added KCl: ${addedK.toStringAsFixed(1)} mmol/L',
              'Total K concentration: ${totalBaseKConcentration.toStringAsFixed(1)} mmol/L',
              if (baseKPerHour != null)
                'Exact K delivery: ${baseKPerHour.toStringAsFixed(2)} mmol/hr',
              if (baseKPerKgHour != null)
                '${baseKPerKgHour.toStringAsFixed(3)} mmol/kg/hr',
              if (baseKOverForecast != null)
                '${baseKOverForecast.toStringAsFixed(1)} mmol over $_forecastHours hr',
              if (baseKPerDay != null)
                '${baseKPerDay.toStringAsFixed(1)} mmol over 24 hr',
              if (maintenanceRate != null && baseRate != null)
                'Selected fluid rate ${baseRate.toStringAsFixed(0)} mL/hr; 4-2-1 maintenance â‰ˆ ${maintenanceRate.toStringAsFixed(0)} mL/hr',
            ],
          ),
          const SizedBox(height: 8),
          _infoLine(
            context,
            'Serum-K increase from potassium contained in maintenance fluid cannot be predicted reliably as a fixed mmol/L rise. PedsFlow therefore shows the exact potassium exposure over time instead of inventing a serum response.',
          ),
          const SizedBox(height: 18),

          _sectionTitle(context, '3. Optional oral KCl'),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _addOral,
            onChanged: (bool value) => setState(() => _addOral = value),
            title: const Text('Add oral / enteral KCl'),
          ),
          if (_addOral) ...<Widget>[
            _responsiveFields(<Widget>[
              DropdownButtonFormField<String>(
                initialValue: _oralDoseChoice,
                decoration: const InputDecoration(
                  labelText: 'Dose',
                  border: OutlineInputBorder(),
                ),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: '0.5', child: Text('0.5 mmol/kg')),
                  DropdownMenuItem(value: '1', child: Text('1 mmol/kg')),
                  DropdownMenuItem(value: '2', child: Text('2 mmol/kg')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom')),
                ],
                onChanged: (String? value) {
                  if (value == null) return;
                  setState(() => _oralDoseChoice = value);
                },
              ),
              if (_oralDoseChoice == 'custom')
                _field(_oralDosePerKg, 'Custom oral dose', 'mmol/kg'),
              _field(
                _oralConcentration,
                'Oral KCl concentration',
                'mmol/mL',
              ),
            ]),
            const SizedBox(height: 10),
            if (oralMmol != null)
              _resultCard(
                context,
                'Oral KCl contribution',
                <String>[
                  'Selected dose: ${oralDosePerKg.toStringAsFixed(2)} mmol/kg',
                  if (oralCalculatedMmol != null && oralCalculatedMmol > 20)
                    'Calculated ${oralCalculatedMmol.toStringAsFixed(1)} mmol â†’ capped at 20 mmol by the selected pediatric acute reference',
                  'Administered dose: ${oralMmol.toStringAsFixed(1)} mmol',
                  if (oralVolume != null)
                    'Volume at ${oralConcentration!.toStringAsFixed(2)} mmol/mL: ${oralVolume.toStringAsFixed(1)} mL',
                  'Immediate-release oral potassium has a measurable serum effect over the next few hours; a precise serum-K rise is not reliably predictable.',
                ],
              ),
          ],
          const SizedBox(height: 18),

          _sectionTitle(context, '4. Optional separate IV KCl correction'),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _addIv,
            onChanged: (bool value) => setState(() => _addIv = value),
            title: const Text('Add acute IV KCl correction'),
          ),
          if (_addIv) ...<Widget>[
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'ward',
                  label: Text('Ward reference'),
                ),
                ButtonSegment<String>(
                  value: 'critical',
                  label: Text('Critical care'),
                ),
                ButtonSegment<String>(
                  value: 'custom',
                  label: Text('Custom'),
                ),
              ],
              selected: <String>{_ivPreset},
              onSelectionChanged: (Set<String> value) {
                final String preset = value.first;
                if (preset == 'custom') {
                  setState(() => _ivPreset = preset);
                } else {
                  _applyIvPreset(preset);
                }
              },
            ),
            const SizedBox(height: 10),
            _responsiveFields(<Widget>[
              _field(_ivRatePerKg, 'IV K rate', 'mmol/kg/hr'),
              _field(_ivDuration, 'Duration', 'hours'),
              DropdownButtonFormField<String>(
                initialValue: _access,
                decoration: const InputDecoration(
                  labelText: 'IV access',
                  border: OutlineInputBorder(),
                ),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(
                    value: 'peripheral',
                    child: Text('Peripheral IV'),
                  ),
                  DropdownMenuItem(
                    value: 'central',
                    child: Text('Central IV'),
                  ),
                ],
                onChanged: (String? value) {
                  if (value == null) return;
                  setState(() => _access = value);
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _ivConcentrationChoice,
                decoration: const InputDecoration(
                  labelText: 'Final IV K concentration',
                  border: OutlineInputBorder(),
                ),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: '40', child: Text('40 mmol/L')),
                  DropdownMenuItem(value: '60', child: Text('60 mmol/L')),
                  DropdownMenuItem(value: '80', child: Text('80 mmol/L')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom')),
                ],
                onChanged: (String? value) {
                  if (value == null) return;
                  setState(() => _ivConcentrationChoice = value);
                },
              ),
              if (_ivConcentrationChoice == 'custom')
                _field(
                  _ivConcentration,
                  'Custom final concentration',
                  'mmol/L',
                ),
            ]),
            const SizedBox(height: 6),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _continueBaseFluidDuringIv,
              onChanged: (bool value) =>
                  setState(() => _continueBaseFluidDuringIv = value),
              title: const Text(
                'Continue potassium-containing base fluid during IV correction',
              ),
              subtitle: const Text(
                'Turn this off if you plan to pause the potassium-containing maintenance fluid during acute replacement.',
              ),
            ),
            if (ivMmolPerHour != null && ivTotalMmol != null)
              _resultCard(
                context,
                'Separate IV KCl contribution',
                <String>[
                  'K infusion: ${ivMmolPerHour.toStringAsFixed(2)} mmol/hr',
                  if (weight != null && weight > 0)
                    '${(ivMmolPerHour / weight).toStringAsFixed(3)} mmol/kg/hr',
                  'Duration: ${ivDuration!.toStringAsFixed(1)} hr',
                  'Total IV KCl: ${ivTotalMmol.toStringAsFixed(1)} mmol',
                  if (ivDosePerKg != null)
                    'Total IV dose: ${ivDosePerKg.toStringAsFixed(2)} mmol/kg',
                  'Final concentration: ${ivConcentration.toStringAsFixed(0)} mmol/L',
                  if (ivCarrierRate != null)
                    'Required IV carrier rate: ${ivCarrierRate.toStringAsFixed(1)} mL/hr',
                ],
              ),
            if (_access == 'peripheral' && ivConcentration > 40)
              _warning(
                context,
                'Peripheral concentration above the usual 40 mmol/L reference requires senior/local-protocol review; concentrations >60 mmol/L require central access in the cited RCH guideline.',
              ),
            if (ivConcentration > 60 && _access != 'central')
              _warning(
                context,
                'Selected concentration >60 mmol/L: central access is required by the cited RCH reference.',
              ),
            if (totalIvMmolPerKgHourDuringCorrection != null)
              _combinedIvRateWarning(
                context,
                totalIvMmolPerKgHourDuringCorrection,
              ),
          ],
          const SizedBox(height: 18),

          _sectionTitle(context, '5. Combined potassium plan'),
          _forecastSelector(),
          const SizedBox(height: 10),
          _resultCard(
            context,
            'Exact potassium exposure over $_forecastHours hours',
            <String>[
              if (baseKOverForecast != null)
                'Base fluid: ${baseKOverForecast.toStringAsFixed(1)} mmol',
              if (_addOral && oralMmol != null)
                'Oral KCl: ${oralMmol.toStringAsFixed(1)} mmol',
              if (_addIv && ivMmolWithinForecast > 0)
                'Separate IV KCl: ${ivMmolWithinForecast.toStringAsFixed(1)} mmol',
              'TOTAL potassium exposure: ${combinedForecastMmol.toStringAsFixed(1)} mmol',
              if (combinedForecastPerKg != null)
                '${combinedForecastPerKg.toStringAsFixed(2)} mmol/kg over $_forecastHours hr',
            ],
          ),
          const SizedBox(height: 10),
          if (totalIvMmolPerHourDuringCorrection != null)
            _resultCard(
              context,
              'During the separate IV correction',
              <String>[
                'Separate IV KCl: ${ivMmolPerHour!.toStringAsFixed(2)} mmol/hr',
                if (_continueBaseFluidDuringIv && baseKPerHour != null)
                  'Background IV-fluid K: ${baseKPerHour.toStringAsFixed(2)} mmol/hr',
                if (!_continueBaseFluidDuringIv)
                  'Background potassium-containing fluid: paused',
                'TOTAL IV potassium delivery: ${totalIvMmolPerHourDuringCorrection.toStringAsFixed(2)} mmol/hr',
                if (totalIvMmolPerKgHourDuringCorrection != null)
                  '${totalIvMmolPerKgHourDuringCorrection.toStringAsFixed(3)} mmol/kg/hr',
              ],
            ),
          const SizedBox(height: 18),

          _sectionTitle(context, '6. What might happen to the serum potassium?'),
          if (responseEstimate != null && currentK != null)
            _responseEstimateCard(context, currentK, responseEstimate)
          else if (_addIv)
            _infoLine(
              context,
              'Your selected IV regimen does not closely match one of the pediatric published comparator doses built into PedsFlow, so a numerical serum-K forecast is intentionally not shown.',
            ),
          if (_addOral)
            _infoLine(
              context,
              'Oral KCl: exact absorbed mmol is shown, but PedsFlow does not assign a fixed serum-K rise because pediatric oral dose-to-serum response is too variable to safely model as a universal conversion.',
            ),
          if (baseKPerHour != null && baseKPerHour > 0)
            _infoLine(
              context,
              'Potassium in the base IV fluid: exact mmol exposure is shown, but a separate serum-K rise is not forecast because maintenance delivery interacts with ongoing losses, intracellular shifts, renal handling, insulin/beta-agonists and magnesium.',
            ),
          _warning(
            context,
            'Do not add the published IV estimate to an assumed oral or maintenance-fluid rise. The combined final K must be measured rather than mathematically guaranteed.',
          ),
          const SizedBox(height: 18),

          _sectionTitle(context, '7. Monitoring / recheck'),
          _monitoringCard(context, currentK),
          const SizedBox(height: 18),

          _sectionTitle(context, '8. Actual response tracker'),
          _responsiveFields(<Widget>[
            _field(_followUpK, 'Follow-up K', 'mmol/L'),
            _field(_followUpHours, 'Time after plan', 'hours'),
          ]),
          if (followUpK != null && currentK != null) ...<Widget>[
            const SizedBox(height: 10),
            _resultCard(
              context,
              'Observed patient response',
              <String>[
                'Before: ${currentK.toStringAsFixed(2)} mmol/L',
                'After: ${followUpK.toStringAsFixed(2)} mmol/L',
                'Observed Î”K: ${(followUpK - currentK).toStringAsFixed(2)} mmol/L',
                if (followUpHours != null)
                  'Elapsed time: ${followUpHours.toStringAsFixed(1)} hr',
                if (targetK != null)
                  followUpK >= targetK
                      ? 'Target reached / exceeded'
                      : 'Still ${(targetK - followUpK).toStringAsFixed(2)} mmol/L below selected target',
              ],
            ),
          ],
          const SizedBox(height: 12),
          _referencesCard(context, age),
        ],
      ),
    );
  }

  Widget _highAlertBanner(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.48),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Text(
          'KCl is a high-alert medication. Verify weight, serum K, renal function, urine output, magnesium, ECG risk, final concentration, line type and every concurrent potassium source. Verify with local institutional protocols, formulary, pharmacist, and attending physician before implementation.',
          style: TextStyle(fontWeight: FontWeight.w800, height: 1.35),
        ),
      ),
    );
  }

  Widget _severityCard(
    BuildContext context,
    double currentK,
    double? targetK,
  ) {
    final Color color = _severityColor(context, currentK);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.monitor_heart_outlined, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_severity(currentK)} hypokalemia â€¢ K ${currentK.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.w900, color: color),
            ),
          ),
          if (targetK != null)
            Text(
              'Target ${targetK.toStringAsFixed(1)} â€¢ gap ${(targetK - currentK).toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
        ],
      ),
    );
  }

  Widget _combinedIvRateWarning(BuildContext context, double ratePerKgHour) {
    final double referenceLimit = _ivPreset == 'ward' ? 0.2 : 0.4;
    if (ratePerKgHour <= referenceLimit + 0.0001) {
      return _infoLine(
        context,
        'Combined IV potassium rate = ${ratePerKgHour.toStringAsFixed(3)} mmol/kg/hr.',
      );
    }
    return _warning(
      context,
      'TOTAL IV potassium rate = ${ratePerKgHour.toStringAsFixed(3)} mmol/kg/hr, which exceeds the selected ${referenceLimit.toStringAsFixed(1)} mmol/kg/hr reference when the background potassium-containing fluid is counted. Consider pausing/reducing background K and re-check the whole order.',
    );
  }

  Widget _responseEstimateCard(
    BuildContext context,
    double currentK,
    _IvResponseEstimate estimate,
  ) {
    final double studyScenarioK = currentK + estimate.typicalRise;
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.48),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Research-based IV-only response context',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Closest published comparator: ${estimate.comparatorDose}'),
            Text('Observed response: ${estimate.spread}'),
            const SizedBox(height: 8),
            Text(
              'If the IV component behaved like the typical published response in isolation, K ${currentK.toStringAsFixed(2)} might move toward approximately ${studyScenarioK.toStringAsFixed(2)} mmol/L.',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '${estimate.sourceLabel}. This is not a patient-specific prediction and does not include oral K, background-fluid K, ongoing losses, intracellular shifts, renal handling, magnesium, DKA treatment or beta-agonists.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _monitoringCard(BuildContext context, double? currentK) {
    final bool monitorEcg =
        _addIv || _ecgChanges || _symptomatic || (currentK != null && currentK < 3);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _checkLine('Repeat serum potassium at the route/severity-specific interval'),
            _checkLine('Check magnesium and correct hypomagnesemia when present'),
            _checkLine('Review creatinine / AKI and urine output'),
            _checkLine('Review ongoing GI and renal potassium losses'),
            if (monitorEcg)
              _checkLine('ECG / continuous cardiac monitoring as clinically indicated'),
            if (_addIv)
              _checkLine('Inspect IV site and verify pump / concentration / line labeling'),
            const SizedBox(height: 8),
            Text(
              _addIv && _ivPreset == 'critical'
                  ? 'Critical-care reference: repeat K about 1 hour after IV replacement starts and again 1 hour after completion.'
                  : _addIv
                      ? 'Ward reference: repeat K about 1 hour after IV replacement completes, before another replacement dose.'
                      : 'For enteral/background replacement, recheck timing depends on severity, formulation, ongoing losses and clinical status; immediate-release oral K has a measurable effect over the next few hours.',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _referencesCard(BuildContext context, double? age) {
    return Card(
      child: ExpansionTile(
        title: const Text(
          'Evidence & limitations',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: <Widget>[
          const Text(
            'RCH Hypokalaemia CPG: oral/enteral route preferred when appropriate; acute oral 1â€“2 mmol/kg/dose (max 20 mmol/dose); ward IV reference 0.2 mmol/kg/hr for 3 hr (max 10 mmol/hr); critical care 0.4 mmol/kg/hr for 1â€“2 hr (max 20 mmol/hr). Count every potassium source.',
          ),
          const SizedBox(height: 8),
          const Text(
            'Peripheral IV concentration: usual maximum 40 mmol/L in the cited RCH guideline; >60 mmol/L central-line only there. Local LHSC/PCCU pharmacy and smart-pump policy remains authoritative.',
          ),
          const SizedBox(height: 8),
          const Text(
            'LHSC NICU online monograph: maximum peripheral concentration 40 mmol/L, central 80 mmol/L; supplied oral KCl 1.33 mmol/mL. NICU guidance should not automatically be extrapolated to older children.',
          ),
          const SizedBox(height: 8),
          const Text(
            'Published pediatric IV response studies are observational/retrospective and are used only as context, not as a guaranteed serum-K calculator.',
          ),
          if (age != null && age < 0.1) ...<Widget>[
            const SizedBox(height: 8),
            const Text(
              'Neonatal patient detected: use neonatal/local NICU-specific potassium dosing and monitoring rather than general pediatric defaults.',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ],
      ),
    );
  }

  Widget _forecastSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<int>(
      segments: const <ButtonSegment<int>>[
        ButtonSegment<int>(value: 1, label: Text('1 h')),
        ButtonSegment<int>(value: 2, label: Text('2 h')),
        ButtonSegment<int>(value: 4, label: Text('4 h')),
        ButtonSegment<int>(value: 6, label: Text('6 h')),
        ButtonSegment<int>(value: 12, label: Text('12 h')),
        ButtonSegment<int>(value: 24, label: Text('24 h')),
      ],
      selected: <int>{_forecastHours},
      onSelectionChanged: (Set<int> value) {
        setState(() => _forecastHours = value.first);
      },
      showSelectedIcon: false,
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String suffix,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _responsiveFields(List<Widget> children) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool narrow = constraints.maxWidth < 720;
        if (narrow) {
          return Column(
            children: children
                .map(
                  (Widget child) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: child,
                  ),
                )
                .toList(),
          );
        }
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: children
              .map(
                (Widget child) => SizedBox(
                  width: math.max(210.0, (constraints.maxWidth - 20) / 3).toDouble(),
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }

  Widget _resultCard(
    BuildContext context,
    String title,
    List<String> lines,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...lines.map(
              (String line) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(line),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoLine(BuildContext context, String text) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.info_outline),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

  Widget _warning(BuildContext context, String text) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.50),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.check_circle_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _IvResponseEstimate {
  final String comparatorDose;
  final double typicalRise;
  final String spread;
  final String sourceLabel;

  const _IvResponseEstimate({
    required this.comparatorDose,
    required this.typicalRise,
    required this.spread,
    required this.sourceLabel,
  });
}

