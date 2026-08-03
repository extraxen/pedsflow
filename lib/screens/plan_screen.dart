import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/admission_plan.dart';
import '../models/medication_monograph.dart';
import '../services/app_store.dart';
import '../widgets/info_card.dart';
import 'medications_screen.dart';

class PlanScreen extends StatefulWidget {
  final AdmissionPlan plan;
  final AppStore store;

  const PlanScreen({
    super.key,
    required this.plan,
    required this.store,
  });

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  final Set<int> checkedTreatments = <int>{};
  final Set<int> checkedOrders = <int>{};
  String notes = '';

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 5,
      vsync: this,
    );
    loadNotes();
  }

  Future<void> loadNotes() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    if (!mounted) {
      return;
    }

    setState(() {
      notes =
          preferences.getString('notes_${widget.plan.id}') ?? '';
    });
  }

  Future<void> saveNotes(String value) async {
    notes = value;

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      'notes_${widget.plan.id}',
      value,
    );
  }

  Future<String?> editText({
    required String title,
    required String currentValue,
  }) async {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 600,
            child: TextField(
              controller: controller,
              maxLines: 12,
              minLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                controller.text.trim(),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdmissionPlan plan = widget.plan;
    final bool hasEdits = widget.store.planHasEdits(plan);

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title),
        actions: <Widget>[
          if (hasEdits)
            IconButton(
              tooltip: 'Reset your edits',
              onPressed: () async {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Reset plan edits?'),
                      content: const Text(
                        'This restores the original treatment '
                        'and order text for this diagnosis.',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(context).pop(true),
                          child: const Text('Reset'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  await widget.store.resetPlanEdits(plan);
                  if (mounted) {
                    setState(() {});
                  }
                }
              },
              icon: const Icon(Icons.restore),
            ),
        ],
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: const <Tab>[
            Tab(text: 'Summary'),
            Tab(text: 'Treatment'),
            Tab(text: 'Orders'),
            Tab(text: 'Pearls'),
            Tab(text: 'Notes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          buildSummary(plan),
          buildTreatment(plan),
          buildOrders(plan),
          buildPearls(plan),
          buildNotes(),
        ],
      ),
    );
  }

  Widget buildSummary(AdmissionPlan plan) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.verified_user_outlined),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        plan.contentStatus,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Content updated: ${plan.lastUpdated}'),
                if (plan.aliases.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: plan.aliases
                        .map(
                          (String alias) =>
                              Chip(label: Text(alias)),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        InfoCard(
          title: 'Admission / disposition',
          icon: Icons.local_hospital_outlined,
          text: widget.store.sectionText(plan, 0),
        ),
        if (plan.guidance.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          InfoCard(
            title: 'Guidance basis',
            icon: Icons.menu_book_outlined,
            text: plan.guidance,
          ),
        ],
        if (plan.sourceLabels.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      Icon(Icons.source_outlined),
                      SizedBox(width: 9),
                      Text(
                        'Source hierarchy',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  ...plan.sourceLabels.map(
                    (String source) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $source'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget buildTreatment(AdmissionPlan plan) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Medications & treatment',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const Chip(
              label: Text('Editable'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Use the edit button to adapt the reference to your '
          'local practice. Changes are saved only on this device.',
        ),
        const SizedBox(height: 12),
        ...List<Widget>.generate(
          plan.treatments.length,
          (int index) {
            final TreatmentItem item = plan.treatments[index];
            final String text =
                widget.store.treatmentText(plan, index);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: item.group == 'Medications / treatment'
                  ? Theme.of(context)
                      .colorScheme
                      .primaryContainer
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainer,
              child: CheckboxListTile(
                value: checkedTreatments.contains(index),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      checkedTreatments.add(index);
                    } else {
                      checkedTreatments.remove(index);
                    }
                  });
                },
                controlAffinity:
                    ListTileControlAffinity.leading,
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.group,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () async {
                        final String? result = await editText(
                          title: 'Edit ${item.group}',
                          currentValue: text,
                        );

                        if (result != null &&
                            result.isNotEmpty) {
                          await widget.store.updateTreatment(
                            plan,
                            index,
                            result,
                          );
                          if (mounted) {
                            setState(() {});
                          }
                        }
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _LinkedClinicalText(
                    text: text,
                    store: widget.store,
                  ),
                ),
              ),
            );
          },
        ),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              checkedTreatments.clear();
            });
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reset treatment checklist'),
        ),
      ],
    );
  }

  Widget buildOrders(AdmissionPlan plan) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Complete admission plan',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const Chip(
              label: Text('Editable'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List<Widget>.generate(
          plan.sections.length,
          (int index) {
            final PlanSection section = plan.sections[index];
            final String text =
                widget.store.sectionText(plan, index);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: section.number == 9
                  ? Theme.of(context)
                      .colorScheme
                      .primaryContainer
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainer,
              child: CheckboxListTile(
                value: checkedOrders.contains(index),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      checkedOrders.add(index);
                    } else {
                      checkedOrders.remove(index);
                    }
                  });
                },
                controlAffinity:
                    ListTileControlAffinity.leading,
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${section.number}. ${section.label}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit section',
                      onPressed: () async {
                        final String? result = await editText(
                          title: 'Edit ${section.label}',
                          currentValue: text,
                        );

                        if (result != null &&
                            result.isNotEmpty) {
                          await widget.store.updateSection(
                            plan,
                            index,
                            result,
                          );
                          if (mounted) {
                            setState(() {});
                          }
                        }
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _LinkedClinicalText(
                    text: text,
                    store: widget.store,
                  ),
                ),
              ),
            );
          },
        ),
        FilledButton.icon(
          onPressed: () {
            final String copiedText =
                List<String>.generate(
              plan.sections.length,
              (int index) {
                final PlanSection section =
                    plan.sections[index];
                return '${section.number}. '
                    '${section.label}: '
                    '${widget.store.sectionText(plan, index)}';
              },
            ).join('\n\n');

            Clipboard.setData(
              ClipboardData(text: copiedText),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Complete plan copied'),
              ),
            );
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copy complete plan'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              checkedOrders.clear();
            });
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reset checklist'),
        ),
      ],
    );
  }

  Widget buildPearls(AdmissionPlan plan) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        InfoCard(
          title: 'Reassessment / contingency',
          icon: Icons.warning_amber_rounded,
          text: widget.store.sectionText(plan, 11),
          warning: true,
        ),
        const SizedBox(height: 12),
        InfoCard(
          title: 'Consults',
          icon: Icons.groups_outlined,
          text: widget.store.sectionText(plan, 9),
        ),
        const SizedBox(height: 12),
        InfoCard(
          title: 'Nursing / RT instructions',
          icon: Icons.assignment_outlined,
          text: widget.store.sectionText(plan, 10),
        ),
      ],
    );
  }

  Widget buildNotes() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        initialValue: notes,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        onChanged: saveNotes,
        decoration: InputDecoration(
          hintText: 'Add your personal notes...',
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}


class _LinkedClinicalText extends StatelessWidget {
  final String text;
  final AppStore store;

  const _LinkedClinicalText({
    required this.text,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final List<MedicationMonograph> medications =
        store.medicationsMentionedIn(text).take(12).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SelectableText(text),
        if (medications.isNotEmpty) ...<Widget>[
          const SizedBox(height: 11),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: medications.map(
              (MedicationMonograph medication) {
                return ActionChip(
                  avatar:
                      const Icon(Icons.medication_outlined),
                  label: Text(medication.name),
                  onPressed: () async {
                    await store.markMedicationRecent(
                      medication.id,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            MedicationDetailScreen(
                          medication: medication,
                          store: store,
                        ),
                      ),
                    );
                  },
                );
              },
            ).toList(),
          ),
        ],
      ],
    );
  }
}
