import 'package:flutter/material.dart';

import 'video_source.dart';

enum LessonId {
  skyColor('sky-color', 'sky'),
  apiIntro('api-intro', 'api'),
  compoundInterest('compound-interest', 'interest');

  const LessonId(this.storageId, this.narrationKey);

  final String storageId;
  final String narrationKey;
}

class LearningReel {
  final LessonId id;
  final String category;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VideoSource? videoSource;

  const LearningReel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.videoSource,
  });
}
