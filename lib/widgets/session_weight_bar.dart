// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_store.dart';

class SessionWeightBar extends StatefulWidget {
  final AppStore store;

  const SessionWeightBar({
    super.key,
    required this.store,
  });

  @override
  State<SessionWeightBar> createState() => _SessionWeightBarState();
}

class _SessionWeightBarState extends State<SessionWeightBar> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncController() {
    final double? weight = widget.store.sessionWeightKg;
    _controller.text = weight == null ? '' : _formatWeight(weight);
  }

  String _formatWeight(double value) =>
      value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);

  void _save() {
    final double? weight = double.tryParse(_controller.text.trim());
    if (weight == null || weight <= 0 || weight > 300) {
      setState(() {
        _error = 'Enter >0–300 kg';
      });
      return;
    }
    widget.store.setSessionWeight(weight);
    setState(() {
      _error = null;
      _controller.text = _formatWeight(weight);
    });
    FocusScope.of(context).unfocus();
  }

  void _clear() {
    widget.store.setSessionWeight(null);
    setState(() {
      _controller.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (BuildContext context, Widget? child) {
        final double? weight = widget.store.sessionWeightKg;
        final ColorScheme colors = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.monitor_weight_outlined, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          weight == null
                              ? 'Session weight'
                              : 'Session weight: ${_formatWeight(weight)} kg',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const Text(
                          'Clears on restart • Verify measured weight and every dose',
                          maxLines: 2,
                          style: TextStyle(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 86,
                    child: TextField(
                      controller: _controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}(\.\d?)?$'),
                        ),
                      ],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _save(),
                      decoration: InputDecoration(
                        labelText: 'kg',
                        errorText: _error,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    tooltip: 'Set session weight',
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                  ),
                  if (weight != null)
                    IconButton(
                      tooltip: 'Clear session weight',
                      onPressed: _clear,
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
