// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'System default';

  @override
  String get science => 'SCIENCE';

  @override
  String get technology => 'TECHNOLOGY';

  @override
  String get finance => 'FINANCE';

  @override
  String get skyTitle => 'Why is the sky blue?';

  @override
  String get skyDescription =>
      'Sunlight contains many colors. Air molecules scatter blue light more strongly than red light.';

  @override
  String get apiTitle => 'What is an API?';

  @override
  String get apiDescription =>
      'An API allows different software applications to communicate and exchange information.';

  @override
  String get interestTitle => 'What is compound interest?';

  @override
  String get interestDescription =>
      'Compound interest lets you earn returns on both your original money and previous returns.';

  @override
  String get testKnowledge => 'Test Your Knowledge';

  @override
  String get quizComingSoon => 'Quiz coming soon!';

  @override
  String get swipeHint => 'Swipe up to learn more ↑';
}
