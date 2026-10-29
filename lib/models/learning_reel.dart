import 'package:flutter/material.dart';

class LearningReel {
  final String category;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? videoUrl;

  const LearningReel({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.videoUrl,
  });
}
