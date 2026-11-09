import 'package:flutter/material.dart';

import 'video_source.dart';

class LearningReel {
  final String category;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VideoSource? videoSource;

  const LearningReel({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.videoSource,
  });
}