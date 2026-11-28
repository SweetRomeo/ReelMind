import 'dart:convert';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/learning_reel.dart';

typedef _Scene = ({int start, String tr, String en});

class LessonTranscript extends StatefulWidget {
  const LessonTranscript({super.key, required this.lessonId});

  final LessonId lessonId;

  @override
  State<LessonTranscript> createState() => _LessonTranscriptState();
}

class _LessonTranscriptState extends State<LessonTranscript> {
  late Future<List<_Scene>> _scenes = _loadScenes();

  Future<List<_Scene>> _loadScenes() async {
    final key = widget.lessonId.narrationKey;
    final script = await DefaultAssetBundle.of(context)
        .loadStructuredData<Map<String, dynamic>>(
          'tools/reel_narration.json',
          (source) async => jsonDecode(source) as Map<String, dynamic>,
        );
    return [
      for (final scene in script[key] as List)
        (
          start: scene['start'] as int,
          tr: scene['tr'] as String,
          en: scene['en'] as String,
        ),
    ];
  }

  String _timestamp(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(24, 12, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  container: true,
                  headingLevel: 2,
                  child: Text(
                    l10n.transcript,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              const CloseButton(),
            ],
          ),
          FutureBuilder(
            future: _scenes,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Column(
                  children: [
                    Text(l10n.transcriptLoadFailed),
                    TextButton(
                      onPressed: () => setState(() => _scenes = _loadScenes()),
                      child: Text(l10n.tryAgain),
                    ),
                  ],
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  for (final scene in snapshot.requireData)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, right: 8),
                      child: Semantics(
                        container: true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _timestamp(scene.start),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                language == 'tr' ? scene.tr : scene.en,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
