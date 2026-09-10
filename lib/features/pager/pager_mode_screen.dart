// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pager_mode_data.dart';
import 'pager_mode_models.dart';

class PagerModeScreen extends StatefulWidget {
  const PagerModeScreen({super.key});

  @override
  State<PagerModeScreen> createState() => _PagerModeScreenState();
}

class _PagerModeScreenState extends State<PagerModeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _query = '';
  String _category = 'All';

  List<String> get _categories => <String>[
        'All',
        ...<String>{...pagerTopics.map((PagerTopic topic) => topic.category)},
      ];

  double? get _weightKg {
    final double? value = double.tryParse(_weightController.text.trim());
    return value != null && value > 0 && value <= 250 ? value : null;
  }

  List<PagerTopic> get _visibleTopics {
    final String query = _query.trim().toLowerCase();
    return pagerTopics.where((PagerTopic topic) {
      final bool categoryMatches =
          _category == 'All' || topic.category == _category;
      final bool queryMatches =
          query.isEmpty || topic.searchableText.contains(query);
      return categoryMatches && queryMatches;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _openTopic(PagerTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PagerTopicScreen(
          topic: topic,
          initialWeightKg: _weightKg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<PagerTopic> topics = _visibleTopics;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pager Mode',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: <Widget>[
              const _PagerHero(),
              const SizedBox(height: 14),
              _WeightCard(
                controller: _weightController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (String value) => setState(() => _query = value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'What did the nurse call about?',
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((String category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: _category == category,
                        onSelected: (_) => setState(() => _category = category),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Common overnight calls',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  Text(
                    '${topics.length} topics',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (topics.isEmpty)
                const _EmptySearch()
              else
                ...topics.map(
                  (PagerTopic topic) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PagerTopicCard(
                      topic: topic,
                      onTap: () => _openTopic(topic),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              const _ClinicalScopeCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class PagerTopicScreen extends StatefulWidget {
  final PagerTopic topic;
  final double? initialWeightKg;

  const PagerTopicScreen({
    super.key,
    required this.topic,
    this.initialWeightKg,
  });

  factory PagerTopicScreen.forId(String id, {double? initialWeightKg}) {
    final PagerTopic? topic = pagerTopicById(id);
    assert(topic != null, 'Unknown Pager Mode topic: $id');
    return PagerTopicScreen(
      topic: topic ?? pagerTopics.first,
      initialWeightKg: initialWeightKg,
    );
  }

  @override
  State<PagerTopicScreen> createState() => _PagerTopicScreenState();
}

class _PagerTopicScreenState extends State<PagerTopicScreen> {
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.initialWeightKg == null
          ? ''
          : _formatNumber(widget.initialWeightKg!),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  double? get _weightKg {
    final double? value = double.tryParse(_weightController.text.trim());
    return value != null && value > 0 && value <= 250 ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    final PagerTopic topic = widget.topic;
    final Color urgencyColor = topic.urgency.color(Theme.of(context).colorScheme);
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: topic.urgency
                            .containerColor(Theme.of(context).colorScheme),
                        foregroundColor: urgencyColor,
                        child: Icon(topic.icon),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              topic.category,
                              style: TextStyle(
                                color: urgencyColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              topic.subtitle,
                              style: const TextStyle(height: 1.35),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _UrgencyBadge(urgency: topic.urgency),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _GoNowCard(items: topic.goNowIf),
              if (topic.doseKeys.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                _DoseCalculatorCard(
                  doseKeys: topic.doseKeys,
                  controller: _weightController,
                  weightKg: _weightKg,
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 16),
              ...topic.sections.asMap().entries.map(
                (MapEntry<int, PagerSection> entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ActionSectionCard(
                    number: entry.key + 1,
                    section: entry.value,
                    initiallyExpanded: entry.key < 2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _SourcesCard(sources: topic.sources),
              const SizedBox(height: 12),
              const _ClinicalScopeCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PagerHero extends StatelessWidget {
  const _PagerHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF8C1E2C), Color(0xFFB83B3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF7B1C27).withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(0x33FFFFFF),
            foregroundColor: Colors.white,
            child: Icon(Icons.notifications_active_outlined, size: 31),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'The nurse just called',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Turn a symptom or abnormal vital sign into an ordered bedside response.',
                  style: TextStyle(color: Colors.white, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _WeightCard({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            const CircleAvatar(child: Icon(Icons.monitor_weight_outlined)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Patient weight',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text('Enter once for emergency dose cards.'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 112,
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(?:\.\d{0,2})?')),
                ],
                decoration: const InputDecoration(
                  hintText: 'Weight',
                  suffixText: 'kg',
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PagerTopicCard extends StatelessWidget {
  final PagerTopic topic;
  final VoidCallback onTap;

  const _PagerTopicCard({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color color = topic.urgency.color(Theme.of(context).colorScheme);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        leading: CircleAvatar(
          backgroundColor:
              topic.urgency.containerColor(Theme.of(context).colorScheme),
          foregroundColor: color,
          child: Icon(topic.icon),
        ),
        title: Text(
          topic.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(topic.subtitle),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _UrgencyBadge(urgency: topic.urgency),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right_rounded, size: 19),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _UrgencyBadge extends StatelessWidget {
  final PagerUrgency urgency;

  const _UrgencyBadge({required this.urgency});

  @override
  Widget build(BuildContext context) {
    final Color color = urgency.color(Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: urgency.containerColor(Theme.of(context).colorScheme),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        urgency.label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _GoNowCard extends StatelessWidget {
  final List<String> items;

  const _GoNowCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.directions_run_rounded, color: scheme.error),
                const SizedBox(width: 9),
                Text(
                  'Go to bedside now if',
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            ...items.map((String item) => _Bullet(text: item, color: scheme.error)),
          ],
        ),
      ),
    );
  }
}

class _DoseCalculatorCard extends StatelessWidget {
  final List<String> doseKeys;
  final TextEditingController controller;
  final double? weightKg;
  final ValueChanged<String> onChanged;

  const _DoseCalculatorCard({
    required this.doseKeys,
    required this.controller,
    required this.weightKg,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<PagerDose> doses = doseKeys
        .map((String key) => pagerDoses[key])
        .whereType<PagerDose>()
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.calculate_outlined,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Weight-based emergency doses',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
                SizedBox(
                  width: 108,
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d{0,3}(?:\.\d{0,2})?'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Weight',
                      suffixText: 'kg',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (weightKg == null)
              const Text(
                'Enter a valid weight from 0.01 to 250 kg to calculate doses.',
                style: TextStyle(fontWeight: FontWeight.w700),
              )
            else
              ...doses.map(
                (PagerDose dose) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CalculatedDose(dose: dose, weightKg: weightKg!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalculatedDose extends StatelessWidget {
  final PagerDose dose;
  final double weightKg;

  const _CalculatedDose({required this.dose, required this.weightKg});

  @override
  Widget build(BuildContext context) {
    final double result = dose.calculate(weightKg);
    final bool epi = dose.key == 'epinephrine_im';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(dose.label, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(
            '${_formatNumber(result)} ${dose.amountUnit}'
            '${epi ? ' = ${_formatNumber(result)} mL' : ''}'
            '${dose.route == null ? '' : ' • ${dose.route}'}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (dose.isCapped(weightKg))
            Text('Maximum dose applied (${_formatNumber(dose.maximum!)} ${dose.amountUnit}).'),
          if (dose.concentration != null) ...<Widget>[
            const SizedBox(height: 5),
            Text(dose.concentration!, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
          const SizedBox(height: 5),
          Text(dose.note, style: const TextStyle(height: 1.35)),
        ],
      ),
    );
  }
}

class _ActionSectionCard extends StatelessWidget {
  final int number;
  final PagerSection section;
  final bool initiallyExpanded;

  const _ActionSectionCard({
    required this.number,
    required this.section,
    required this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: CircleAvatar(
          radius: 18,
          child: Text(
            '$number',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: section.items
            .map((String item) => _Bullet(text: item))
            .toList(),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  final Color? color;

  const _Bullet({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 7, color: color ?? Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}

class _SourcesCard extends StatelessWidget {
  final List<String> sources;

  const _SourcesCard({required this.sources});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.menu_book_outlined),
        title: const Text('Source basis', style: TextStyle(fontWeight: FontWeight.w900)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: sources.map((String source) => _Bullet(text: source)).toList(),
      ),
    );
  }
}

class _ClinicalScopeCard extends StatelessWidget {
  const _ClinicalScopeCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Pager Mode supports rapid assessment; it does not replace bedside evaluation, active local policies, pharmacy verification, resuscitation algorithms or escalation to supervising clinicians. Verify doses and concentrations before administration.',
          style: TextStyle(height: 1.4),
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Icon(Icons.search_off_rounded,
                size: 36, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            const Text('No matching pager topic yet.',
                style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Try a symptom, vital sign or bedside phrase.'),
          ],
        ),
      ),
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  if (value.abs() < 1) return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
}
