// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_store.dart';

class BackupScreen extends StatefulWidget {
  final AppStore store;

  const BackupScreen({
    super.key,
    required this.store,
  });

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final TextEditingController importController =
      TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Backup & Restore',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              28,
            ),
            children: <Widget>[
              Card(
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'The backup includes favourites, recent items, '
                    'personal notes, edited admission-plan text and '
                    'saved algorithm data. Do not include patient names, '
                    'identifiers, photographs, or protected health '
                    'information.',
                    style: TextStyle(height: 1.45),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    child: Icon(Icons.copy_all_outlined),
                  ),
                  title: const Text(
                    'Copy backup JSON',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: const Text(
                    'Copy your backup to the clipboard, then save it '
                    'in a secure personal text file.',
                  ),
                  trailing: busy
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.chevron_right),
                  onTap: busy ? null : _copyBackup,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Restore from backup',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Paste a previously exported PedsFlow backup below. '
                'Restoring replaces the saved preferences currently '
                'stored in this browser.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: importController,
                minLines: 8,
                maxLines: 18,
                decoration: const InputDecoration(
                  hintText:
                      'Paste PedsFlow backup JSON here...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: busy ? null : _restore,
                icon: const Icon(Icons.restore_outlined),
                label: const Text('Validate and restore'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyBackup() async {
    setState(() {
      busy = true;
    });

    try {
      final String raw =
          await widget.store.exportBackupJson();
      await Clipboard.setData(ClipboardData(text: raw));

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Backup copied to the clipboard.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> _restore() async {
    final String raw = importController.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paste a backup first.'),
        ),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Restore backup?'),
        content: const Text(
          'This replaces the personal settings and saved content '
          'currently stored in this browser.',
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
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      busy = true;
    });

    try {
      await widget.store.importBackupJson(raw);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Backup restored successfully.',
          ),
        ),
      );
      importController.clear();
    } on FormatException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not restore backup: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }
}
