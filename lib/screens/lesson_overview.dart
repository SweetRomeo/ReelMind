import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/learning_reel.dart';

String quizStatusLabel(AppLocalizations l10n, bool? result) => switch (result) {
  null => l10n.quizUnanswered,
  true => l10n.quizAnsweredCorrectly,
  false => l10n.quizAnsweredIncorrectly,
};

class LessonOverview extends StatelessWidget {
  const LessonOverview({
    super.key,
    required this.reels,
    required this.results,
    required this.activeIndex,
  });

  final List<LearningReel> reels;
  final Map<LessonId, bool> results;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Semantics(
              header: true,
              child: Text(
                l10n.lessonOverview,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          for (final (index, reel) in reels.indexed)
            ListTile(
              leading: Icon(reel.icon),
              title: Text(reel.title),
              subtitle: Text(quizStatusLabel(l10n, results[reel.id])),
              selected: index == activeIndex,
              onTap: () => Navigator.pop(context, index),
            ),
        ],
      ),
    );
  }
}
