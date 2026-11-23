import 'package:flutter/material.dart';

import 'video_source.dart';

enum LessonId {
  skyColor('sky-color'),
  apiIntro('api-intro'),
  compoundInterest('compound-interest');

  const LessonId(this.storageId);

  final String storageId;
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
