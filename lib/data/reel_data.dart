import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/learning_reel.dart';
import '../models/video_source.dart';

List<LearningReel> buildReels(AppLocalizations l10n) {
  return [
    LearningReel(
      id: LessonId.skyColor,
      category: l10n.science,
      title: l10n.skyTitle,
      description: l10n.skyDescription,
      icon: Icons.wb_sunny_outlined,
      color: const Color(0xFF1565C0),
    ),
    LearningReel(
      id: LessonId.apiIntro,
      category: l10n.technology,
      title: l10n.apiTitle,
      description: l10n.apiDescription,
      icon: Icons.code,
      color: const Color(0xFF673AB7),
      videoSource: VideoSource.asset(
        l10n.localeName.startsWith('tr')
            ? 'assets/videos/api_intro_tr_001.mp4'
            : 'assets/videos/api_intro_en_001.mp4',
      ),
    ),
    LearningReel(
      id: LessonId.compoundInterest,
      category: l10n.finance,
      title: l10n.interestTitle,
      description: l10n.interestDescription,
      icon: Icons.trending_up,
      color: const Color(0xFF00796B),
    ),
  ];
}
