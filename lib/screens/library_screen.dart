// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/algorithm_item.dart';
import '../services/app_store.dart';

class LibraryScreen extends StatefulWidget {
  final AppStore store;

  const LibraryScreen({
    super.key,
    required this.store,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ImagePicker picker = ImagePicker();

  Future<void> addAlgorithm() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1800,
    );

    if (image == null || !mounted) {
      return;
    }

    final Uint8List bytes = await image.readAsBytes();

    if (!mounted) {
      return;
    }

    final TextEditingController titleController =
        TextEditingController();
    final TextEditingController categoryController =
        TextEditingController();
    final TextEditingController notesController =
        TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save algorithm'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration:
                      const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: categoryController,
                  decoration:
                      const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await widget.store.saveAlgorithm(
      AlgorithmItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: titleController.text.trim(),
        category: categoryController.text.trim().isEmpty
            ? 'Uncategorized'
            : categoryController.text.trim(),
        notes: notesController.text.trim(),
        imageBase64: base64Encode(bytes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<AlgorithmItem> algorithms =
        widget.store.algorithms;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add algorithm',
            onPressed: addAlgorithm,
            icon: const Icon(
              Icons.add_photo_alternate_outlined,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addAlgorithm,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add algorithm'),
      ),
      body: algorithms.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No saved algorithms yet.\n\n'
                  'Tap “Add algorithm” to choose a photo, '
                  'give it a title and category, and add notes.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 430,
                mainAxisExtent: 280,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: algorithms.length,
              itemBuilder: (BuildContext context, int index) {
                final AlgorithmItem item = algorithms[index];
                final Uint8List bytes =
                    base64Decode(item.imageBase64);

                return Card(
                  clipBehavior: Clip.antiAlias,
                  color:
                      Theme.of(context).colorScheme.surfaceContainer,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              _AlgorithmDetailScreen(item: item),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Image.memory(
                            bytes,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            14,
                            10,
                            6,
                            8,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                    Text(item.category),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                onPressed: () {
                                  widget.store.deleteAlgorithm(
                                    item.id,
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _AlgorithmDetailScreen extends StatelessWidget {
  final AlgorithmItem item;

  const _AlgorithmDetailScreen({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final Uint8List bytes = base64Decode(item.imageBase64);

    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: InteractiveViewer(
              maxScale: 5,
              child: Image.memory(bytes),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            item.category,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (item.notes.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            SelectableText(item.notes),
          ],
        ],
      ),
    );
  }
}
