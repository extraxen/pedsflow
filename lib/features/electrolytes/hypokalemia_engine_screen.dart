// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'potassium_rate_engine.dart';

class HypokalemiaEngineScreen extends StatefulWidget {
  const HypokalemiaEngineScreen({super.key});

  @override
  State<HypokalemiaEngineScreen> createState() =>
      _HypokalemiaEngineScreenState();
}

class _HypokalemiaEngineScreenState extends State<HypokalemiaEngineScreen> {
  final TextEditingController _weight = TextEditingController(text: '20');
  final TextEditingController _currentK = TextEditingController(text: '2.6');

  final TextEditingController _mainK = TextEditingController(text: '40');
  final TextEditingController _mainVolume =
      TextEditingController(text: '1000');
  final TextEditingController _mainRate = TextEditingController(text: '50');

  final TextEditingController _otherK = TextEditingController(text: '0');
  final TextEditingController _otherVolume =
      TextEditingController(text: '1000');
  final TextEditingController _otherRate = TextEditingController(text: '0');

  final TextEditingController _oralK = TextEditingController(text: '0');

  final TextEditingController _replacementDose =
      TextEditingController(text: '10');
  final TextEditingController _replacementDuration =
      TextEditingController(text: '4');
  final TextEditingController _replacementVolume =
      TextEditingController(text: '100');

  PotassiumReplacementType _replacementType =
      PotassiumReplacementType.kcl;
  PotassiumPhosphateOrderBasis _phosphateBasis =
      PotassiumPhosphateOrderBasis.potassium;
  IvAccess _access = IvAccess.peripheral;

  bool _mainRunsDuringReplacement = true;
  bool _otherRunsDuringReplacement = true;
  bool _ecgChanges = false;
  bool _renalConcern = false;

  @override
  void dispose() {
    for (final TextEditingController controller in <TextEditingController>[
      _weight,
      _currentK,
      _mainK,
      _mainVolume,
      _mainRate,
      _otherK,
      _otherVolume,
      _otherRate,
      _oralK,
      _replacementDose,
      _replacementDuration,
      _replacementVolume,
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

  String _fmt(double value, {int decimals = 3}) {
    if (value.abs() >= 10) return value.toStringAsFixed(2);
    return value.toStringAsFixed(decimals);
  }

  @override
  Widget build(BuildContext context) {
    final double? weight = _number(_weight);
    final double? currentK = _number(_currentK);

    final bool validWeight = weight != null && weight > 0;
    final double weightKg = validWeight ? weight : 0;
    final PotassiumRateLimits? limits =
        validWeight ? PotassiumRateEngine.limits(weight) : null;

    final PotassiumSourceResult? main = validWeight
        ? PotassiumRateEngine.sourceFromBag(
            weightKg: weight,
            potassiumMmolInBag: _number(_mainK) ?? 0,
            bagVolumeMl: _number(_mainVolume) ?? 0,
            rateMlPerHour: _number(_mainRate) ?? 0,
          )
        : null;

    final PotassiumSourceResult? other = validWeight
        ? PotassiumRateEngine.sourceFromBag(
            weightKg: weight,
            potassiumMmolInBag: _number(_otherK) ?? 0,
            bagVolumeMl: _number(_otherVolume) ?? 0,
            rateMlPerHour: _number(_otherRate) ?? 0,
          )
        : null;

    final double orderedReplacement = _number(_replacementDose) ?? 0;
    final double replacementDuration = _number(_replacementDuration) ?? 0;
    final double replacementVolume = _number(_replacementVolume) ?? 0;

    final double replacementK =
        PotassiumRateEngine.replacementPotassiumMmol(
      type: _replacementType,
      orderedMmol: orderedReplacement,
      phosphateBasis: _phosphateBasis,
    );
    final double replacementPhosphate =
        PotassiumRateEngine.replacementPhosphateMmol(
      type: _replacementType,
      orderedMmol: orderedReplacement,
      phosphateBasis: _phosphateBasis,
    );

    final double replacementMmolPerHour =
        replacementDuration > 0 ? replacementK / replacementDuration : 0;
    final double replacementMmolPerKgHour =
        validWeight ? replacementMmolPerHour / weight : 0;

    final double replacementConcentration =
        PotassiumRateEngine.intermittentConcentrationMmolPerMl(
      potassiumMmol: replacementK,
      finalVolumeMl: replacementVolume,
    );

    final double backgroundAllRunning =
        (main?.mmolPerHour ?? 0) + (other?.mmolPerHour ?? 0);

    final double backgroundDuringReplacement =
        (_mainRunsDuringReplacement ? (main?.mmolPerHour ?? 0) : 0) +
            (_otherRunsDuringReplacement ? (other?.mmolPerHour ?? 0) : 0);

    final double totalDuringReplacement =
        backgroundDuringReplacement + replacementMmolPerHour;
    final double totalIfEverythingRuns =
        backgroundAllRunning + replacementMmolPerHour;
    final double totalIfMainPaused =
        (other?.mmolPerHour ?? 0) + replacementMmolPerHour;

    final double remainingToEcgThreshold = limits == null
        ? 0
        : math.max(
            0,
            limits.ecgThresholdMmolPerHour - totalDuringReplacement,
          ).toDouble();
    final double remainingToAllIvMaximum = limits == null
        ? 0
        : math.max(
            0,
            limits.allIvMaxMmolPerHour - totalDuringReplacement,
          ).toDouble();
    final double replacementProductMaximum = limits == null
        ? 0
        : PotassiumRateEngine.productMaxRateMmolPerHour(
            type: _replacementType,
            limits: limits,
          );
    final double remainingToProductMaximum = limits == null
        ? 0
        : math.max(
            0,
            replacementProductMaximum - replacementMmolPerHour,
          ).toDouble();

    final double oralK = math.max(0, _number(_oralK) ?? 0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Potassium Rate Checker',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reset',
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 940),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
            children: <Widget>[
              _highAlertBanner(context),
              const SizedBox(height: 14),

              _sectionTitle(context, '1. Patient'),
              _responsiveFields(<Widget>[
                _field(_weight, 'Weight', 'kg'),
                _field(_currentK, 'Current potassium', 'mmol/L'),
              ]),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _ecgChanges,
                onChanged: (bool value) =>
                    setState(() => _ecgChanges = value),
                title: const Text('ECG changes / arrhythmia concern'),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _renalConcern,
                onChanged: (bool value) =>
                    setState(() => _renalConcern = value),
                title: const Text(
                  'AKI / oliguria / severe renal impairment concern',
                ),
              ),
              if (!validWeight)
                _warning(context, 'Enter a valid measured weight.'),
              if (_ecgChanges)
                _warning(
                  context,
                  'ECG changes make this a high-risk replacement situation. '
                  'Use continuous cardiac monitoring and senior/PCCU/pharmacy review '
                  'regardless of the arithmetic rate category.',
                ),
              if (_renalConcern)
                _warning(
                  context,
                  'Renal impairment can cause potassium accumulation. '
                  'Do not use the calculated headroom as permission to replace '
                  'without individualized review.',
                ),
              if (currentK != null && currentK < 2.5)
                _warning(
                  context,
                  'Severe hypokalemia: prioritize monitored replacement and '
                  'frequent reassessment according to the active local plan.',
                ),
              const SizedBox(height: 18),

              _sectionTitle(context, '2. What potassium is already running?'),
              _sourceCard(
                context: context,
                title: 'Main IV fluid',
                subtitle:
                    'Example: 40 mmol KCl in a 1000 mL bag running at 50 mL/hr.',
                potassiumController: _mainK,
                volumeController: _mainVolume,
                rateController: _mainRate,
                result: main,
                runsDuringReplacement: _mainRunsDuringReplacement,
                onRunsChanged: (bool value) =>
                    setState(() => _mainRunsDuringReplacement = value),
              ),
              const SizedBox(height: 10),
              _sourceCard(
                context: context,
                title: 'TPN / second potassium-containing IV source',
                subtitle:
                    'Leave at 0 if there is no second IV potassium source.',
                potassiumController: _otherK,
                volumeController: _otherVolume,
                rateController: _otherRate,
                result: other,
                runsDuringReplacement: _otherRunsDuringReplacement,
                onRunsChanged: (bool value) =>
                    setState(() => _otherRunsDuringReplacement = value),
              ),
              const SizedBox(height: 10),
              _resultCard(
                context,
                'Background IV potassium',
                <String>[
                  'Main fluid: ${_fmt(main?.mmolPerHour ?? 0)} mmol/hr'
                      '${validWeight ? ' (${_fmt(main?.mmolPerKgHour ?? 0)} mmol/kg/hr)' : ''}',
                  'Other IV source: ${_fmt(other?.mmolPerHour ?? 0)} mmol/hr'
                      '${validWeight ? ' (${_fmt(other?.mmolPerKgHour ?? 0)} mmol/kg/hr)' : ''}',
                  'ALL background IV K if both are running: '
                      '${_fmt(backgroundAllRunning)} mmol/hr'
                      '${validWeight ? ' (${_fmt(backgroundAllRunning / weight)} mmol/kg/hr)' : ''}',
                ],
              ),
              const SizedBox(height: 10),
              _field(
                _oralK,
                'Oral / enteral potassium already given (optional)',
                'mmol',
              ),
              if (oralK > 0)
                _info(
                  context,
                  '${_fmt(oralK, decimals: 2)} mmol oral/enteral potassium is '
                  'tracked separately and is NOT included in the IV mmol/kg/hr rate ceiling.',
                ),
              const SizedBox(height: 18),

              _sectionTitle(context, '3. What do you want to add IV?'),
              SegmentedButton<PotassiumReplacementType>(
                segments: const <ButtonSegment<PotassiumReplacementType>>[
                  ButtonSegment(
                    value: PotassiumReplacementType.kcl,
                    label: Text('KCl'),
                    icon: Icon(Icons.water_drop_outlined),
                  ),
                  ButtonSegment(
                    value: PotassiumReplacementType.potassiumPhosphate,
                    label: Text('Potassium phosphate'),
                    icon: Icon(Icons.science_outlined),
                  ),
                ],
                selected: <PotassiumReplacementType>{_replacementType},
                onSelectionChanged:
                    (Set<PotassiumReplacementType> selection) {
                  setState(() => _replacementType = selection.first);
                },
              ),
              if (_replacementType ==
                  PotassiumReplacementType.potassiumPhosphate) ...<Widget>[
                const SizedBox(height: 10),
                SegmentedButton<PotassiumPhosphateOrderBasis>(
                  segments:
                      const <ButtonSegment<PotassiumPhosphateOrderBasis>>[
                    ButtonSegment(
                      value: PotassiumPhosphateOrderBasis.potassium,
                      label: Text('Order is POTASSIUM mmol'),
                    ),
                    ButtonSegment(
                      value: PotassiumPhosphateOrderBasis.phosphate,
                      label: Text('Order is PHOSPHATE mmol'),
                    ),
                  ],
                  selected: <PotassiumPhosphateOrderBasis>{
                    _phosphateBasis,
                  },
                  onSelectionChanged:
                      (Set<PotassiumPhosphateOrderBasis> selection) {
                    setState(() => _phosphateBasis = selection.first);
                  },
                ),
                const SizedBox(height: 7),
                _info(
                  context,
                  'LHSC pediatric potassium-phosphate doses are normally ordered '
                  'by POTASSIUM content. The alternate option is included so the '
                  'calculator can safely interpret an order written by phosphate content.',
                ),
              ],
              const SizedBox(height: 10),
              _responsiveFields(<Widget>[
                _field(
                  _replacementDose,
                  _replacementType == PotassiumReplacementType.kcl
                      ? 'KCl dose'
                      : _phosphateBasis ==
                              PotassiumPhosphateOrderBasis.potassium
                          ? 'Potassium dose (as phosphate)'
                          : 'Phosphate dose (as potassium)',
                  'mmol',
                ),
                _field(
                  _replacementDuration,
                  'Infusion duration',
                  'hours',
                ),
                _field(
                  _replacementVolume,
                  'Final infusion volume',
                  'mL',
                ),
              ]),
              DropdownButtonFormField<IvAccess>(
                initialValue: _access,
                decoration: const InputDecoration(
                  labelText: 'IV access',
                  border: OutlineInputBorder(),
                ),
                items: const <DropdownMenuItem<IvAccess>>[
                  DropdownMenuItem(
                    value: IvAccess.peripheral,
                    child: Text('Peripheral IV'),
                  ),
                  DropdownMenuItem(
                    value: IvAccess.central,
                    child: Text('Central IV'),
                  ),
                ],
                onChanged: (IvAccess? value) {
                  if (value == null) return;
                  setState(() => _access = value);
                },
              ),
              const SizedBox(height: 10),
              _resultCard(
                context,
                _replacementType == PotassiumReplacementType.kcl
                    ? 'Intermittent KCl'
                    : 'Intermittent potassium phosphate',
                <String>[
                  if (_replacementType ==
                      PotassiumReplacementType.potassiumPhosphate)
                    'Potassium content: ${_fmt(replacementK, decimals: 2)} mmol',
                  if (_replacementType ==
                      PotassiumReplacementType.potassiumPhosphate)
                    'Phosphate content: ${_fmt(replacementPhosphate, decimals: 2)} mmol',
                  'Potassium delivery: ${_fmt(replacementMmolPerHour)} mmol/hr',
                  if (validWeight)
                    '${_fmt(replacementMmolPerKgHour)} mmol/kg/hr',
                  'Potassium concentration: '
                      '${_fmt(replacementConcentration, decimals: 3)} mmol/mL',
                ],
              ),
              ..._replacementWarnings(
                context: context,
                limits: limits,
                replacementMmolPerHour: replacementMmolPerHour,
                replacementMmolPerKgHour: replacementMmolPerKgHour,
                concentrationMmolPerMl: replacementConcentration,
              ),
              const SizedBox(height: 18),

              _sectionTitle(context, '4. Total IV potassium rate'),
              if (limits == null)
                _warning(
                  context,
                  'Enter a valid weight to calculate the combined IV potassium rate.',
                )
              else ...<Widget>[
                _totalRateCard(
                  context,
                  main: main,
                  other: other,
                  weight: weightKg,
                  replacementMmolPerHour: replacementMmolPerHour,
                  totalMmolPerHour: totalDuringReplacement,
                  limits: limits,
                ),
                if (_ecgChanges)
                  _warning(
                    context,
                    'ECG changes selected: use continuous cardiac monitoring and '
                    'senior/PCCU/pharmacy review regardless of whether the arithmetic '
                    'rate is below the PDAM rate-triggered ECG threshold.',
                  ),
                const SizedBox(height: 12),
                const Text(
                  'Compare the main maintenance-fluid decision',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (
                    BuildContext context,
                    BoxConstraints constraints,
                  ) {
                    final Widget keepCard = _scenarioCard(
                      context,
                      title: 'Keep main K-containing fluid running',
                      totalMmolPerHour: totalIfEverythingRuns,
                      weight: weightKg,
                      limits: limits,
                      replacementMmolPerHour: replacementMmolPerHour,
                    );
                    final Widget pauseCard = _scenarioCard(
                      context,
                      title: 'Pause main K-containing fluid',
                      totalMmolPerHour: totalIfMainPaused,
                      weight: weightKg,
                      limits: limits,
                      replacementMmolPerHour: replacementMmolPerHour,
                    );

                    if (constraints.maxWidth < 700) {
                      return Column(
                        children: <Widget>[
                          keepCard,
                          const SizedBox(height: 8),
                          pauseCard,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(child: keepCard),
                        const SizedBox(width: 10),
                        Expanded(child: pauseCard),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                _policyExpansion(
                  context,
                  limits,
                  totalMmolPerHour: totalDuringReplacement,
                  replacementMmolPerHour: replacementMmolPerHour,
                  remainingToEcgThreshold: remainingToEcgThreshold,
                  remainingToAllIvMaximum: remainingToAllIvMaximum,
                  remainingToProductMaximum: remainingToProductMaximum,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _replacementWarnings({
    required BuildContext context,
    required PotassiumRateLimits? limits,
    required double replacementMmolPerHour,
    required double replacementMmolPerKgHour,
    required double concentrationMmolPerMl,
  }) {
    if (limits == null) return <Widget>[];

    final List<Widget> warnings = <Widget>[];

    if (_replacementType == PotassiumReplacementType.kcl) {
      if (replacementMmolPerHour >
          limits.kclIntermittentMaxMmolPerHour + 0.0001) {
        warnings.add(
          _warning(
            context,
            'KCl intermittent RATE exceeds the LHSC pediatric maximum of '
            '${_fmt(limits.kclIntermittentMaxMmolPerHour)} mmol/hr '
            '(${_fmt(limits.kclIntermittentMaxMmolPerHour / (_number(_weight) ?? 1))} mmol/kg/hr for this weight).',
          ),
        );
      }

      final double concentrationMax =
          _access == IvAccess.peripheral ? 0.1 : 0.4;
      if (concentrationMmolPerMl > concentrationMax + 0.0001) {
        warnings.add(
          _warning(
            context,
            'KCl intermittent concentration exceeds the listed '
            '${_access == IvAccess.peripheral ? 'peripheral' : 'central'} '
            'maximum of ${concentrationMax.toStringAsFixed(1)} mmol/mL.',
          ),
        );
      }
    } else {
      if (replacementMmolPerHour >
          limits.potassiumPhosphateMaxMmolPerHour + 0.0001) {
        warnings.add(
          _warning(
            context,
            'Potassium-phosphate RATE exceeds the LHSC pediatric maximum '
            'of 0.19 mmol potassium/kg/hr. Selected rate is '
            '${_fmt(replacementMmolPerKgHour)} mmol potassium/kg/hr.',
          ),
        );
      }

      final double concentrationMax =
          _access == IvAccess.peripheral ? 0.088 : 0.44;
      if (concentrationMmolPerMl > concentrationMax + 0.0001) {
        warnings.add(
          _warning(
            context,
            'Potassium-phosphate intermittent concentration exceeds the listed '
            '${_access == IvAccess.peripheral ? 'peripheral' : 'central'} '
            'maximum of ${concentrationMax.toStringAsFixed(3)} mmol potassium/mL.',
          ),
        );
      }
    }

    return warnings;
  }

  Widget _totalRateCard(
    BuildContext context, {
    required PotassiumSourceResult? main,
    required PotassiumSourceResult? other,
    required double weight,
    required double replacementMmolPerHour,
    required double totalMmolPerHour,
    required PotassiumRateLimits limits,
  }) {
    final double totalPerKg = totalMmolPerHour / weight;
    final double productMaximum =
        PotassiumRateEngine.productMaxRateMmolPerHour(
      type: _replacementType,
      limits: limits,
    );

    final bool aboveAllIv =
        totalMmolPerHour > limits.allIvMaxMmolPerHour + 0.0001;
    final bool aboveProduct =
        replacementMmolPerHour > productMaximum + 0.0001;
    final bool aboveRateTriggeredEcg =
        totalMmolPerHour > limits.ecgThresholdMmolPerHour + 0.0001;

    final Color color = (aboveAllIv || aboveProduct)
        ? Theme.of(context).colorScheme.error
        : aboveRateTriggeredEcg
            ? const Color(0xFFB25E00)
            : const Color(0xFF237447);

    final String status = (aboveAllIv || aboveProduct)
        ? 'A listed IV potassium rate maximum is exceeded'
        : aboveRateTriggeredEcg
            ? 'Within listed maximums • ECG rate threshold exceeded'
            : 'Within listed IV potassium rate maximums';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'TOTAL IV POTASSIUM DURING REPLACEMENT',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          _rateRow(
            'Main IV fluid',
            _mainRunsDuringReplacement ? (main?.mmolPerHour ?? 0) : 0,
            weight,
            paused: !_mainRunsDuringReplacement,
          ),
          if ((other?.mmolPerHour ?? 0) > 0 || !_otherRunsDuringReplacement)
            _rateRow(
              'TPN / other IV K',
              _otherRunsDuringReplacement ? (other?.mmolPerHour ?? 0) : 0,
              weight,
              paused: !_otherRunsDuringReplacement,
            ),
          _rateRow(
            _replacementType == PotassiumReplacementType.kcl
                ? 'Intermittent KCl'
                : 'Potassium phosphate',
            replacementMmolPerHour,
            weight,
          ),
          const Divider(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text(
                  '${_fmt(totalPerKg)} mmol/kg/hr',
                  style: TextStyle(
                    color: color,
                    fontSize: 31,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${_fmt(totalMmolPerHour)} mmol/hr',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                (aboveAllIv || aboveProduct)
                    ? Icons.error_outline
                    : aboveRateTriggeredEcg
                        ? Icons.monitor_heart_outlined
                        : Icons.check_circle_outline,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (aboveRateTriggeredEcg &&
              !aboveAllIv &&
              !aboveProduct)
            const Padding(
              padding: EdgeInsets.only(top: 7),
              child: Text(
                'The rate-triggered ECG threshold is not the same as the '
                'absolute potassium-rate maximum.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _rateRow(
    String label,
    double mmolPerHour,
    double weight, {
    bool paused = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          if (paused)
            const Text(
              'PAUSED',
              style: TextStyle(fontWeight: FontWeight.w900),
            )
          else
            Text(
              '${_fmt(mmolPerHour)} mmol/hr  •  '
              '${_fmt(mmolPerHour / weight)} mmol/kg/hr',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }

  Widget _sourceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required TextEditingController potassiumController,
    required TextEditingController volumeController,
    required TextEditingController rateController,
    required PotassiumSourceResult? result,
    required bool runsDuringReplacement,
    required ValueChanged<bool> onRunsChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 3),
            Text(subtitle),
            const SizedBox(height: 12),
            _responsiveFields(<Widget>[
              _field(potassiumController, 'K in bag', 'mmol'),
              _field(volumeController, 'Bag volume', 'mL'),
              _field(rateController, 'Current rate', 'mL/hr'),
            ]),
            if (result != null)
              _resultCard(
                context,
                'Exact delivery',
                <String>[
                  'Concentration: '
                      '${_fmt(result.concentrationMmolPerL, decimals: 2)} mmol/L',
                  'Potassium: ${_fmt(result.mmolPerHour)} mmol/hr',
                  '${_fmt(result.mmolPerKgHour)} mmol/kg/hr',
                ],
              ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: runsDuringReplacement,
              onChanged: onRunsChanged,
              title: const Text('Continues during intermittent replacement'),
              subtitle: Text(
                runsDuringReplacement
                    ? 'Included in the combined IV potassium rate.'
                    : 'Excluded from the combined rate while paused.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scenarioCard(
    BuildContext context, {
    required String title,
    required double totalMmolPerHour,
    required double weight,
    required PotassiumRateLimits limits,
    required double replacementMmolPerHour,
  }) {
    final double perKg = totalMmolPerHour / weight;
    final double productMaximum =
        PotassiumRateEngine.productMaxRateMmolPerHour(
      type: _replacementType,
      limits: limits,
    );

    final bool aboveMaximum =
        totalMmolPerHour > limits.allIvMaxMmolPerHour + 0.0001 ||
            replacementMmolPerHour > productMaximum + 0.0001;
    final bool aboveRateTriggeredEcg =
        totalMmolPerHour > limits.ecgThresholdMmolPerHour + 0.0001;

    final IconData icon = aboveMaximum
        ? Icons.cancel_outlined
        : aboveRateTriggeredEcg
            ? Icons.monitor_heart_outlined
            : Icons.check_circle_outline;

    final String status = aboveMaximum
        ? 'Exceeds a listed rate maximum'
        : aboveRateTriggeredEcg
            ? 'Within maximums • ECG rate threshold exceeded'
            : 'Within listed rate maximums';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${_fmt(perKg)} mmol/kg/hr',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text('${_fmt(totalMmolPerHour)} mmol/hr'),
                  const SizedBox(height: 5),
                  Text(
                    status,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _policyExpansion(
    BuildContext context,
    PotassiumRateLimits? limits, {
    required double totalMmolPerHour,
    required double replacementMmolPerHour,
    required double remainingToEcgThreshold,
    required double remainingToAllIvMaximum,
    required double remainingToProductMaximum,
  }) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.tune_outlined),
        title: const Text(
          'Advanced LHSC rate limits & monitoring',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: const Text(
          'Open only if you need the detailed thresholds.',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: <Widget>[
          if (limits != null) ...<Widget>[
            _resultCard(
              context,
              'Current-plan headroom',
              <String>[
                totalMmolPerHour <= limits.ecgThresholdMmolPerHour
                    ? 'Remaining before rate-triggered ECG threshold: '
                        '${_fmt(remainingToEcgThreshold)} mmol/hr'
                    : 'Rate-triggered ECG threshold is already exceeded.',
                totalMmolPerHour <= limits.allIvMaxMmolPerHour
                    ? 'Remaining before ALL-IV potassium maximum: '
                        '${_fmt(remainingToAllIvMaximum)} mmol/hr'
                    : 'ALL-IV potassium maximum is exceeded.',
                replacementMmolPerHour <=
                        PotassiumRateEngine.productMaxRateMmolPerHour(
                          type: _replacementType,
                          limits: limits,
                        )
                    ? 'Remaining before selected replacement-product maximum: '
                        '${_fmt(remainingToProductMaximum)} mmol/hr'
                    : 'Selected replacement-product maximum is exceeded.',
              ],
            ),
            const SizedBox(height: 8),
            _resultCard(
              context,
              'Patient-specific LHSC thresholds',
              <String>[
                'Rate-triggered ECG threshold: >'
                    '${_fmt(limits.ecgThresholdMmolPerHour)} mmol/hr '
                    '(>0.3 mmol/kg/hr or >15 mmol/hr, whichever is less).',
                'Intermittent KCl maximum: '
                    '${_fmt(limits.kclIntermittentMaxMmolPerHour)} mmol/hr '
                    '(0.5 mmol/kg/hr or 20 mmol/hr, whichever is less).',
                'ALL IV potassium maximum: '
                    '${_fmt(limits.allIvMaxMmolPerHour)} mmol/hr '
                    '(1 mmol/kg/hr or 40 mmol/hr, whichever is less).',
                'Potassium-phosphate product maximum: '
                    '${_fmt(limits.potassiumPhosphateMaxMmolPerHour)} mmol K/hr '
                    '(0.19 mmol potassium/kg/hr).',
              ],
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            'Intermittent concentration limits:\n'
            '• KCl peripheral: 0.1 mmol/mL.\n'
            '• KCl central: 0.4 mmol/mL.\n'
            '• Potassium phosphate peripheral: 0.088 mmol potassium/mL.\n'
            '• Potassium phosphate central: 0.44 mmol potassium/mL.\n\n'
            'Monitoring reminders:\n'
            '• Count potassium from every IV source, including potassium phosphate and TPN.\n'
            '• Clinical indications for cardiac monitoring (for example ECG changes) '
            'take precedence over a reassuring arithmetic rate.\n'
            '• After intermittent KCl, potassium is usually repeated within 3–4 hours '
            'after completion according to the LHSC monograph.\n'
            '• After intermittent potassium phosphate, potassium and phosphate are '
            'usually repeated within 3–4 hours after completion.\n'
            '• IV direct potassium administration is prohibited.',
            style: TextStyle(height: 1.45),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sources: LHSC Potassium Chloride Parenteral Drug Administration '
            'Monograph, revised July 21, 2026; LHSC Potassium Phosphate '
            'Parenteral Drug Administration Monograph, revised July 21, 2026.',
            style: TextStyle(fontWeight: FontWeight.w800, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _highAlertBanner(BuildContext context) {
    return Card(
      color: Theme.of(context)
          .colorScheme
          .errorContainer
          .withValues(alpha: 0.52),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Text(
          'HIGH ALERT: This screen answers one question - how much potassium '
          'is entering the patient per hour from ALL IV sources? Verify every '
          'source independently with the active LHSC order set, Pharmacy and PCCU policy.',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _responsiveFields(List<Widget> children) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 700) {
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
                  width: (constraints.maxWidth - 20) / 3,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String suffix,
  ) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            ...lines.map(
              (String line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(line),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _warning(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .errorContainer
            .withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(height: 1.35)),
    );
  }

  void _reset() {
    _weight.text = '20';
    _currentK.text = '2.6';
    _mainK.text = '40';
    _mainVolume.text = '1000';
    _mainRate.text = '50';
    _otherK.text = '0';
    _otherVolume.text = '1000';
    _otherRate.text = '0';
    _oralK.text = '0';
    _replacementDose.text = '10';
    _replacementDuration.text = '4';
    _replacementVolume.text = '100';

    setState(() {
      _replacementType = PotassiumReplacementType.kcl;
      _phosphateBasis = PotassiumPhosphateOrderBasis.potassium;
      _access = IvAccess.peripheral;
      _mainRunsDuringReplacement = true;
      _otherRunsDuringReplacement = true;
      _ecgChanges = false;
      _renalConcern = false;
    });
  }
}
