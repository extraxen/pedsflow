// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ecg_tools.dart';

class EcgInterpretationGuideScreen extends StatelessWidget {
  const EcgInterpretationGuideScreen({super.key});

  static const List<_GuideSection> _sections = <_GuideSection>[
    _GuideSection(
      number: '1',
      title: 'Confirm the tracing',
      icon: Icons.verified_outlined,
      items: <String>[
        'Correct child, date/time and clinical indication.',
        'Confirm calibration: usually 25 mm/s and 10 mm/mV.',
        'Check artifact and lead placement; repeat if the tracing conflicts with the child.',
        'At 25 mm/s: small square = 40 ms; large square = 200 ms.',
      ],
    ),
    _GuideSection(
      number: '2',
      title: 'Rate',
      icon: Icons.speed_outlined,
      items: <String>[
        'Regular rhythm: 300 ÷ large squares between consecutive R waves.',
        'Irregular rhythm: count QRS complexes on a timed strip × 60 ÷ strip seconds.',
        'Compare with age-specific normal values; consider clinical drivers of sinus tachycardia or bradycardia.',
      ],
    ),
    _GuideSection(
      number: '3',
      title: 'Rhythm',
      icon: Icons.graphic_eq,
      items: <String>[
        'Regular or irregular? Is there abrupt onset/offset?',
        'Is every QRS preceded by a P wave, and every P followed by a QRS?',
        'Sinus P waves should have a consistent morphology and be upright in II, III and aVF.',
        'Look for ectopy, dropped beats, dissociation, flutter waves or pacing spikes.',
      ],
    ),
    _GuideSection(
      number: '4',
      title: 'Axis',
      icon: Icons.explore_outlined,
      items: <String>[
        'Use QRS polarity in leads I and aVF for the initial quadrant.',
        'Then refine with lead II or the most equiphasic limb lead.',
        'Compare with age: rightward axis is expected in early infancy.',
      ],
    ),
    _GuideSection(
      number: '5',
      title: 'Intervals',
      icon: Icons.linear_scale,
      items: <String>[
        'PR: measure from P-wave onset to QRS onset; interpret by age and heart rate.',
        'QRS: measure onset to end; compare with age. A clearly wide complex is abnormal until explained.',
        'QT: measure QRS onset to T-wave end in II or V5; manually calculate QTc.',
        'Do not rely on the machine measurement when the value matters clinically.',
      ],
    ),
    _GuideSection(
      number: '6',
      title: 'P, QRS and chamber pattern',
      icon: Icons.monitor_heart_outlined,
      items: <String>[
        'P waves: amplitude, width and morphology for atrial enlargement.',
        'Q waves: distribution, depth and width; Q in V1 or absent Q in V5–V6 is abnormal.',
        'Assess R-wave progression, bundle-branch pattern and pre-excitation.',
        'Apply age-specific voltage, R/S-ratio, axis and T-wave criteria together—voltage alone commonly overcalls hypertrophy.',
      ],
    ),
    _GuideSection(
      number: '7',
      title: 'ST segments and T waves',
      icon: Icons.show_chart,
      items: <String>[
        'Review contiguous leads for ST elevation/depression and reciprocal change.',
        'Consider early repolarization, pericarditis, myocarditis, ischemia, strain, Brugada pattern and medication effects in context.',
        'T-wave inversion in V1–V3 is often physiological in childhood; T waves should be upright in V5–V6.',
        'Peaked T waves or progressive P/PR/QRS changes should trigger a hyperkalemia assessment.',
      ],
    ),
    _GuideSection(
      number: '8',
      title: 'Synthesize and act',
      icon: Icons.fact_check_outlined,
      items: <String>[
        'Write one sentence: rate + rhythm + axis + intervals + key morphology/ST-T findings.',
        'Compare with prior ECG and the child’s anatomy, surgery, medications and electrolytes.',
        'Get senior review for an abnormal ECG; a normal ECG does not negate cardiac red flags.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _CardiologyScaffold(
      title: 'ECG Interpretation Guide',
      children: <Widget>[
        const _AlertCard(
          title: 'Before interpreting',
          text:
              'Assess the child first. Altered mental status, shock, hypotension, syncope during exertion, ongoing chest pain, or a dangerous rhythm requires immediate senior/resuscitation support.',
          icon: Icons.warning_amber_rounded,
        ),
        const SizedBox(height: 14),
        ..._sections.map(
          (_GuideSection section) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ExpansionTile(
                initiallyExpanded: section.number == '1',
                leading: CircleAvatar(child: Text(section.number)),
                title: Text(
                  section.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                trailing: Icon(section.icon),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: section.items
                    .map((String item) => _Bullet(text: item))
                    .toList(),
              ),
            ),
          ),
        ),
        const _SourceCard(),
      ],
    );
  }
}

class EcgAxisHelperScreen extends StatefulWidget {
  const EcgAxisHelperScreen({super.key});

  @override
  State<EcgAxisHelperScreen> createState() => _EcgAxisHelperScreenState();
}

class _EcgAxisHelperScreenState extends State<EcgAxisHelperScreen> {
  EcgPolarity _leadI = EcgPolarity.positive;
  EcgPolarity _leadAvf = EcgPolarity.positive;

  @override
  Widget build(BuildContext context) {
    final EcgAxisResult result = classifyAxis(_leadI, _leadAvf);
    return _CardiologyScaffold(
      title: 'QRS Axis Helper',
      children: <Widget>[
        const _IntroCard(
          icon: Icons.explore_outlined,
          title: 'Two-lead quadrant method',
          text:
              'Choose whether the net QRS deflection is positive, negative or approximately equiphasic in leads I and aVF.',
        ),
        const SizedBox(height: 16),
        _PolaritySelector(
          label: 'Lead I',
          value: _leadI,
          onChanged: (EcgPolarity value) => setState(() => _leadI = value),
        ),
        const SizedBox(height: 14),
        _PolaritySelector(
          label: 'Lead aVF',
          value: _leadAvf,
          onChanged: (EcgPolarity value) => setState(() => _leadAvf = value),
        ),
        const SizedBox(height: 18),
        Card(
          color: result.quadrant == EcgAxisQuadrant.extreme
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  result.label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(result.range, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(result.guidance, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const _AlertCard(
          title: 'Pediatric caution',
          text:
              'Quadrant names are not the final interpretation. Neonates normally have a rightward QRS axis. Always compare the estimated degree with the age-specific ECG reference and verify limb-lead placement.',
          icon: Icons.child_care_outlined,
        ),
        const SizedBox(height: 14),
        const _SourceCard(),
      ],
    );
  }
}

class EcgRateCalculatorScreen extends StatefulWidget {
  const EcgRateCalculatorScreen({super.key});

  @override
  State<EcgRateCalculatorScreen> createState() => _EcgRateCalculatorScreenState();
}

class _EcgRateCalculatorScreenState extends State<EcgRateCalculatorScreen> {
  final TextEditingController _largeSquares = TextEditingController();
  final TextEditingController _complexes = TextEditingController();
  final TextEditingController _stripSeconds = TextEditingController(text: '6');
  double _speed = 25;

  @override
  void dispose() {
    _largeSquares.dispose();
    _complexes.dispose();
    _stripSeconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double? largeSquares = _positiveNumber(_largeSquares.text);
    final double? complexes = _nonNegativeNumber(_complexes.text);
    final double? stripSeconds = _positiveNumber(_stripSeconds.text);
    final double? regularRate = largeSquares == null
        ? null
        : heartRateFromLargeSquares(largeSquares, speed: _speed);
    final double? irregularRate = complexes == null || stripSeconds == null
        ? null
        : heartRateFromComplexes(complexes, stripSeconds);

    return _CardiologyScaffold(
      title: 'ECG Rate Calculator',
      children: <Widget>[
        const _IntroCard(
          icon: Icons.speed_outlined,
          title: 'Calculate, then compare by age',
          text:
              'Use R–R spacing for a regular rhythm. For an irregular rhythm, count all QRS complexes across a known strip duration.',
        ),
        const SizedBox(height: 16),
        SegmentedButton<double>(
          segments: const <ButtonSegment<double>>[
            ButtonSegment<double>(value: 25, label: Text('25 mm/s')),
            ButtonSegment<double>(value: 50, label: Text('50 mm/s')),
          ],
          selected: <double>{_speed},
          onSelectionChanged: (Set<double> value) => setState(() => _speed = value.first),
        ),
        const SizedBox(height: 18),
        const _SectionLabel(title: 'Regular rhythm'),
        const SizedBox(height: 8),
        _NumberInput(
          controller: _largeSquares,
          label: 'Large squares between R waves',
          onChanged: () => setState(() {}),
        ),
        if (regularRate != null) ...<Widget>[
          const SizedBox(height: 10),
          _ResultCard(label: 'Estimated heart rate', value: '${regularRate.toStringAsFixed(0)} bpm'),
        ],
        const SizedBox(height: 22),
        const _SectionLabel(title: 'Irregular rhythm'),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _NumberInput(
                controller: _complexes,
                label: 'QRS count',
                onChanged: () => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _NumberInput(
                controller: _stripSeconds,
                label: 'Strip duration',
                suffix: 's',
                onChanged: () => setState(() {}),
              ),
            ),
          ],
        ),
        if (irregularRate != null) ...<Widget>[
          const SizedBox(height: 10),
          _ResultCard(label: 'Estimated heart rate', value: '${irregularRate.toStringAsFixed(0)} bpm'),
        ],
        const SizedBox(height: 14),
        const _AlertCard(
          title: 'Interpretation',
          text:
              'This is a paper-speed calculation, not a rhythm diagnosis. Compare with age-specific norms and assess rhythm regularity, P waves, QRS width and the child’s perfusion.',
          icon: Icons.info_outline,
        ),
      ],
    );
  }
}

class QtcCalculatorScreen extends StatefulWidget {
  const QtcCalculatorScreen({super.key});

  @override
  State<QtcCalculatorScreen> createState() => _QtcCalculatorScreenState();
}

class _QtcCalculatorScreenState extends State<QtcCalculatorScreen> {
  final TextEditingController _qtMs = TextEditingController();
  final TextEditingController _rrMs = TextEditingController();

  @override
  void dispose() {
    _qtMs.dispose();
    _rrMs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double? qt = _positiveNumber(_qtMs.text);
    final double? rrMs = _positiveNumber(_rrMs.text);
    final QtcResult? result = qt == null || rrMs == null
        ? null
        : calculateQtc(qtMs: qt, rrSeconds: rrMs / 1000);

    return _CardiologyScaffold(
      title: 'QT / QTc Calculator',
      children: <Widget>[
        const _IntroCard(
          icon: Icons.timelapse_outlined,
          title: 'Manual QT correction',
          text:
              'Measure QT from QRS onset to T-wave end, usually in lead II or V5. Use the tangent method when the T-wave end is unclear and avoid a post-ectopic beat.',
        ),
        const SizedBox(height: 16),
        _NumberInput(
          controller: _qtMs,
          label: 'Measured QT',
          suffix: 'ms',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 10),
        _NumberInput(
          controller: _rrMs,
          label: 'Preceding R–R interval',
          suffix: 'ms',
          onChanged: () => setState(() {}),
        ),
        if (result != null) ...<Widget>[
          const SizedBox(height: 16),
          _ResultCard(
            label: 'Bazett QTc',
            value: '${result.bazettMs.toStringAsFixed(0)} ms',
            note: 'QT ÷ √RR',
          ),
          const SizedBox(height: 10),
          _ResultCard(
            label: 'Fridericia QTc',
            value: '${result.fridericiaMs.toStringAsFixed(0)} ms',
            note: 'QT ÷ ∛RR',
          ),
        ],
        const SizedBox(height: 14),
        const _AlertCard(
          title: 'Safety check',
          text:
              'RCH uses a manually measured Bazett QTc >340 and ≤450 ms as its general pediatric reference. A borderline or prolonged result must be remeasured and interpreted with age/sex norms, heart rate, QRS duration, symptoms, family history, electrolytes and QT-prolonging drugs. Discuss suspected long-QT syndrome with cardiology.',
          icon: Icons.warning_amber_rounded,
        ),
        const SizedBox(height: 14),
        const _SourceCard(),
      ],
    );
  }
}

class EcgPatternsScreen extends StatelessWidget {
  const EcgPatternsScreen({super.key});

  static const List<_Pattern> _patterns = <_Pattern>[
    _Pattern(
      title: 'SVT vs sinus tachycardia',
      icon: Icons.bolt_outlined,
      urgent: true,
      recognition: <String>[
        'SVT: abrupt rate change, fixed R–R, absent/abnormal P waves; usually ≥220/min in infants or ≥180/min in children.',
        'Sinus: normal P waves, variable R–R; usually <220/min in infants or <180/min in children.',
        'Assess the child—not just the number—for altered mental status, shock or hypotension.',
      ],
      action: <String>[
        'Airway/oxygen/ventilation as needed; monitor, IV/IO, 12-lead ECG if it does not delay care.',
        'Stable probable SVT: vagal manoeuvre, then adenosine 0.1 mg/kg rapid IV/IO push (max 6 mg); repeat 0.2 mg/kg (max 12 mg). Capture a rhythm strip.',
        'Compromise: synchronized cardioversion 0.5–1 J/kg, then 2 J/kg if ineffective. Sedate if feasible; do not delay cardioversion.',
      ],
    ),
    _Pattern(
      title: 'Wide-complex tachycardia',
      icon: Icons.emergency_outlined,
      urgent: true,
      recognition: <String>[
        'Treat broad-complex tachycardia as ventricular tachycardia unless clear evidence proves otherwise.',
        'PALS uses QRS >0.09 s in a tachyarrhythmia as wide; compare with age-specific QRS duration as well.',
        'Look for AV dissociation, capture/fusion beats, concordance, structural disease, surgery, myocarditis, toxins and electrolytes.',
      ],
      action: <String>[
        'Compromise with a pulse: synchronized cardioversion 0.5–1 J/kg, then 2 J/kg; urgent expert help.',
        'Stable, regular, monomorphic rhythm: PALS permits consideration of adenosine while obtaining expert consultation.',
        'Irregular or polymorphic wide-complex rhythm: do not give adenosine; obtain immediate resuscitation/cardiology guidance.',
      ],
    ),
    _Pattern(
      title: 'Bradycardia and AV block',
      icon: Icons.trending_down,
      urgent: true,
      recognition: <String>[
        'Determine P–QRS relationship: prolonged fixed PR, progressive PR then dropped beat, fixed PR with dropped beats, or AV dissociation.',
        'Search for hypoxia, hypothermia, medications/toxins, raised ICP, vagal tone and conduction disease.',
        'Cardiopulmonary compromise = altered mental status, shock or hypotension.',
      ],
      action: <String>[
        'Open airway, give oxygen and positive-pressure ventilation as needed; attach monitor and reassess pulse.',
        'If HR <60/min with persistent compromise despite oxygenation/ventilation: start CPR, obtain IV/IO and follow PALS.',
        'PALS doses: epinephrine 0.01 mg/kg IV/IO (0.1 mg/mL; max 1 mg); atropine 0.02 mg/kg for increased vagal tone or primary AV block (min 0.1 mg, max 0.5 mg; may repeat once). Consider pacing.',
      ],
    ),
    _Pattern(
      title: 'WPW / pre-excitation',
      icon: Icons.call_split_outlined,
      urgent: false,
      recognition: <String>[
        'Short PR for age, delta wave (slurred initial QRS) and widened QRS in sinus rhythm.',
        'The delta wave may be subtle or intermittent; compare prior ECGs.',
        'WPW pattern plus palpitations/syncope, a documented tachyarrhythmia or concerning family history needs cardiology review.',
      ],
      action: <String>[
        'For a regular narrow-complex SVT, follow the pediatric tachyarrhythmia pathway.',
        'An irregular broad-complex tachycardia may be pre-excited atrial fibrillation: obtain urgent expert help and avoid routine AV-nodal-blocking therapy.',
        'If unstable, synchronized cardioversion takes priority.',
      ],
    ),
    _Pattern(
      title: 'Hyperkalemia ECG progression',
      icon: Icons.electric_bolt_outlined,
      urgent: true,
      recognition: <String>[
        'Peaked T waves → PR prolongation → P-wave flattening/loss → QRS widening.',
        'Progression can include bradyarrhythmia, conduction block, sine wave, ventricular arrhythmia, PEA or asystole.',
        'A normal ECG does not eliminate arrhythmia risk in significant hyperkalemia.',
      ],
      action: <String>[
        'Moderate/severe hyperkalemia: continuous monitoring, IV access, repeat non-hemolyzed potassium and treat immediately if critically high and clinically likely.',
        'ECG changes/life-threatening hyperkalemia: give IV calcium per local pathway to stabilize the myocardium; calcium does not lower potassium.',
        'Stop potassium sources, shift potassium intracellularly and arrange removal with senior/PCCU/nephrology/pharmacy guidance.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _CardiologyScaffold(
      title: 'High-risk ECG Patterns',
      children: <Widget>[
        const _AlertCard(
          title: 'Unstable rhythm = act now',
          text:
              'Altered mental status, shock or hypotension are cardiopulmonary compromise in the 2025 AHA pediatric algorithms. Call for resuscitation support and use the current PALS pathway.',
          icon: Icons.emergency_outlined,
        ),
        const SizedBox(height: 14),
        ..._patterns.map(
          (_Pattern pattern) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: pattern.urgent
                      ? Theme.of(context).colorScheme.errorContainer
                      : null,
                  child: Icon(pattern.icon),
                ),
                title: Text(pattern.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(pattern.urgent ? 'Time-sensitive pattern' : 'Recognition and response'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: <Widget>[
                  const _SectionLabel(title: 'Recognize'),
                  ...pattern.recognition.map((String text) => _Bullet(text: text)),
                  const SizedBox(height: 8),
                  const _SectionLabel(title: 'Respond'),
                  ...pattern.action.map((String text) => _Bullet(text: text)),
                ],
              ),
            ),
          ),
        ),
        const _SourceCard(includeAha: true),
      ],
    );
  }
}

class _CardiologyScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CardiologyScaffold({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: children,
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _IntroCard({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                  const SizedBox(height: 5),
                  Text(text, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;

  const _AlertCard({required this.title, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(text, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.circle, size: 7),
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}

class _PolaritySelector extends StatelessWidget {
  final String label;
  final EcgPolarity value;
  final ValueChanged<EcgPolarity> onChanged;

  const _PolaritySelector({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(title: '$label net QRS'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EcgPolarity.values.map((EcgPolarity polarity) {
            final (String, IconData) option = switch (polarity) {
              EcgPolarity.positive => ('Positive', Icons.add),
              EcgPolarity.negative => ('Negative', Icons.remove),
              EcgPolarity.equiphasic => ('Equiphasic', Icons.drag_handle),
            };
            return ChoiceChip(
              selected: value == polarity,
              onSelected: (_) => onChanged(polarity),
              avatar: Icon(option.$2, size: 18),
              label: Text(option.$1),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final VoidCallback onChanged;

  const _NumberInput({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix.isEmpty ? null : suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final String? note;

  const _ResultCard({required this.label, required this.value, this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            SelectableText(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (note != null) ...<Widget>[
              const SizedBox(height: 3),
              Text(note!),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900));
  }
}

class _SourceCard extends StatelessWidget {
  final bool includeAha;
  const _SourceCard({this.includeAha = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Clinical sources', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('Royal Children’s Hospital Melbourne: Basic paediatric ECG interpretation; Supraventricular Tachycardia; Hyperkalaemia.'),
            if (includeAha) ...<Widget>[
              const SizedBox(height: 6),
              const Text('American Heart Association 2025: Pediatric Tachyarrhythmia With a Pulse and Pediatric Bradycardia With a Pulse algorithms.'),
            ],
            const SizedBox(height: 6),
            const Text(
              'Educational bedside support. Confirm current PALS, local policy, doses and rhythm interpretation independently.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideSection {
  final String number;
  final String title;
  final IconData icon;
  final List<String> items;

  const _GuideSection({required this.number, required this.title, required this.icon, required this.items});
}

class _Pattern {
  final String title;
  final IconData icon;
  final bool urgent;
  final List<String> recognition;
  final List<String> action;

  const _Pattern({
    required this.title,
    required this.icon,
    required this.urgent,
    required this.recognition,
    required this.action,
  });
}

double? _positiveNumber(String value) {
  final double? number = double.tryParse(value.trim());
  return number != null && number.isFinite && number > 0 ? number : null;
}

double? _nonNegativeNumber(String value) {
  final double? number = double.tryParse(value.trim());
  return number != null && number.isFinite && number >= 0 ? number : null;
}
