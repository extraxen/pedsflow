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
    final double totalDuringReplacementPerKg =
        validWeight ? totalDuringReplacement / weight : 0;

    final double totalIfEverythingRuns =
        backgroundAllRunning + replacementMmolPerHour;
    final double totalIfMainPaused =
        (other?.mmolPerHour ?? 0) + replacementMmolPerHour;

    final double ecgHeadroom = limits == null
        ? 0
        : math.max(
            0,
            limits.ecgThresholdMmolPerHour -
                backgroundDuringReplacement,
          ).toDouble();
    final double allIvHeadroom = limits == null
        ? 0
        : math.max(
            0,
            limits.allIvMaxMmolPerHour - backgroundDuringReplacement,
          ).toDouble();

    final double maxReplacementWithBackground = limits == null
        ? 0
        : PotassiumRateEngine.maxReplacementRateWithBackground(
            type: _replacementType,
            limits: limits,
            backgroundMmolPerHour: backgroundDuringReplacement,
          );

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

              _sectionTitle(context, '4. Can these run together?'),
              if (limits == null)
                _warning(
                  context,
                  'Enter a valid weight to calculate the combined IV rate limits.',
                )
              else ...<Widget>[
                _bigRateCard(
                  context,
                  totalMmolPerHour: totalDuringReplacement,
                  totalMmolPerKgHour: totalDuringReplacementPerKg,
                  limits: limits,
                  replacementMmolPerHour: replacementMmolPerHour,
                ),
                const SizedBox(height: 10),
                _resultCard(
                  context,
                  'What is contributing during the replacement?',
                  <String>[
                    _mainRunsDuringReplacement
                        ? 'Main IV fluid: ${_fmt(main?.mmolPerHour ?? 0)} mmol/hr'
                        : 'Main IV fluid: PAUSED',
                    _otherRunsDuringReplacement
                        ? 'TPN / other IV K: ${_fmt(other?.mmolPerHour ?? 0)} mmol/hr'
                        : 'TPN / other IV K: PAUSED',
                    'Intermittent replacement: '
                        '${_fmt(replacementMmolPerHour)} mmol/hr',
                    'TOTAL IV POTASSIUM: '
                        '${_fmt(totalDuringReplacement)} mmol/hr = '
                        '${_fmt(totalDuringReplacementPerKg)} mmol/kg/hr',
                  ],
                ),
                const SizedBox(height: 10),
                _resultCard(
                  context,
                  'Rate headroom with the selected background status',
                  <String>[
                    'Room before LHSC ECG-rate threshold: '
                        '${_fmt(ecgHeadroom)} mmol/hr'
                        ' (${_fmt(ecgHeadroom / weight!)} mmol/kg/hr)',
                    'Room before ALL-IV potassium maximum: '
                        '${_fmt(allIvHeadroom)} mmol/hr'
                        ' (${_fmt(allIvHeadroom / weight)} mmol/kg/hr)',
                    'Maximum intermittent replacement rate allowed by the '
                        'listed product-specific + all-IV ceilings: '
                        '${_fmt(maxReplacementWithBackground)} mmol/hr'
                        ' (${_fmt(maxReplacementWithBackground / weight)} mmol/kg/hr)',
                    'This is a mathematical ceiling from these PDAM limits, '
                        'not a suggested replacement rate.',
                  ],
                ),
                const SizedBox(height: 10),
                _scenarioCard(
                  context,
                  title: 'If EVERYTHING continues',
                  totalMmolPerHour: totalIfEverythingRuns,
                  weight: weight,
                  limits: limits,
                ),
                const SizedBox(height: 8),
                _scenarioCard(
                  context,
                  title: 'If the MAIN potassium-containing fluid is paused',
                  totalMmolPerHour: totalIfMainPaused,
                  weight: weight,
                  limits: limits,
                ),
              ],
              const SizedBox(height: 18),

              _policyExpansion(context, limits),
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

  Widget _bigRateCard(
    BuildContext context, {
    required double totalMmolPerHour,
    required double totalMmolPerKgHour,
    required PotassiumRateLimits limits,
    required double replacementMmolPerHour,
  }) {
    final bool aboveAllIv =
        totalMmolPerHour > limits.allIvMaxMmolPerHour + 0.0001;
    final bool aboveProduct =
        replacementMmolPerHour >
            PotassiumRateEngine.productMaxRateMmolPerHour(
              type: _replacementType,
              limits: limits,
            ) +
                0.0001;
    final bool aboveEcg =
        totalMmolPerHour > limits.ecgThresholdMmolPerHour + 0.0001;

    final Color color = (aboveAllIv || aboveProduct)
        ? Theme.of(context).colorScheme.error
        : aboveEcg
            ? const Color(0xFFB25E00)
            : const Color(0xFF237447);

    final String status = (aboveAllIv || aboveProduct)
        ? 'EXCEEDS A LISTED RATE MAXIMUM'
        : aboveEcg
            ? 'WITHIN MAXIMUMS, BUT ECG RATE THRESHOLD EXCEEDED'
            : 'BELOW THE LISTED ECG RATE THRESHOLD';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_fmt(totalMmolPerKgHour)} mmol/kg/hr',
            style: TextStyle(
              color: color,
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_fmt(totalMmolPerHour)} mmol/hr TOTAL IV potassium',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'ECG-rate threshold for this weight: '
            '${_fmt(limits.ecgThresholdMmolPerHour)} mmol/hr '
            '(${_fmt(limits.ecgThresholdMmolPerHour / (_number(_weight) ?? 1))} mmol/kg/hr).',
          ),
          Text(
            'All-IV potassium maximum for this weight: '
            '${_fmt(limits.allIvMaxMmolPerHour)} mmol/hr '
            '(${_fmt(limits.allIvMaxMmolPerHour / (_number(_weight) ?? 1))} mmol/kg/hr).',
          ),
          if (aboveEcg && !aboveAllIv && !aboveProduct)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'This does NOT mean the rate is prohibited by the PDAM; it means '
                'the ECG monitoring threshold has been crossed. Local unit rules '
                'may be more restrictive.',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                ),
              ),
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
  }) {
    final double perKg = totalMmolPerHour / weight;
    final bool aboveMax =
        totalMmolPerHour > limits.allIvMaxMmolPerHour + 0.0001;
    final bool aboveEcg =
        totalMmolPerHour > limits.ecgThresholdMmolPerHour + 0.0001;

    return Card(
      child: ListTile(
        leading: Icon(
          aboveMax
              ? Icons.cancel_outlined
              : aboveEcg
                  ? Icons.monitor_heart_outlined
                  : Icons.check_circle_outline,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${_fmt(totalMmolPerHour)} mmol/hr = '
          '${_fmt(perKg)} mmol/kg/hr\n'
          '${aboveMax ? 'Above all-IV maximum' : aboveEcg ? 'Above ECG-rate threshold, but below all-IV maximum' : 'Below ECG-rate threshold'}',
        ),
      ),
    );
  }

  Widget _policyExpansion(
    BuildContext context,
    PotassiumRateLimits? limits,
  ) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.policy_outlined),
        title: const Text(
          '2026 LHSC potassium rules used',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: const Text(
          'Open only when you need the limits and monitoring details.',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: <Widget>[
          if (limits != null)
            _resultCard(
              context,
              'Patient-specific rate thresholds',
              <String>[
                'KCl / total-K ECG threshold: >'
                    '${_fmt(limits.ecgThresholdMmolPerHour)} mmol/hr '
                    '(>0.3 mmol/kg/hr or >15 mmol/hr, whichever is less).',
                'KCl intermittent maximum: '
                    '${_fmt(limits.kclIntermittentMaxMmolPerHour)} mmol/hr '
                    '(0.5 mmol/kg/hr or 20 mmol/hr, whichever is less).',
                'ALL IV potassium maximum: '
                    '${_fmt(limits.allIvMaxMmolPerHour)} mmol/hr '
                    '(1 mmol/kg/hr or 40 mmol/hr, whichever is less).',
                'Potassium-phosphate maximum: '
                    '${_fmt(limits.potassiumPhosphateMaxMmolPerHour)} mmol K/hr '
                    '(0.19 mmol potassium/kg/hr).',
              ],
            ),
          const SizedBox(height: 8),
          const Text(
            'Concentrations - intermittent infusions:\n'
            '• KCl peripheral: 0.1 mmol/mL maximum.\n'
            '• KCl central: 0.4 mmol/mL maximum.\n'
            '• Potassium phosphate peripheral: 0.088 mmol potassium/mL maximum.\n'
            '• Potassium phosphate central: 0.44 mmol potassium/mL maximum.\n\n'
            'Continuous KCl background fluid:\n'
            '• Peripheral: 40 mmol/1000 mL; PCCU and ED-to-PCCU may use up to '
            '60 mmol/L according to the monograph.\n'
            '• Central: 80 mmol/1000 mL (pharmacy prepared).\n\n'
            'Monitoring:\n'
            '• Count potassium from all IV sources, including potassium phosphate and TPN.\n'
            '• KCl intermittent rates above the patient-specific ECG threshold require '
            'continuous ECG monitoring.\n'
            '• Potassium-phosphate rates at or below 0.19 mmol K/kg/hr may be given '
            'without ECG monitoring based on rate alone; clinical indications for '
            'monitoring still take precedence.\n'
            '• After intermittent KCl, repeat potassium is usually ordered within '
            '3-4 hours after completion.\n'
            '• After intermittent potassium phosphate, repeat potassium and phosphate '
            'are usually ordered within 3-4 hours after completion.\n'
            '• IV direct potassium administration is prohibited.',
            style: TextStyle(height: 1.45),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sources: LHSC Potassium Chloride Parenteral Drug Administration '
            'Monograph, revised July 21, 2026; LHSC Potassium Phosphate '
            'Parenteral Drug Administration Monograph, revised July 21, 2026.',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
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
