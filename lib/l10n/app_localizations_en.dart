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
  String get unmuteVideo => 'Unmute';

  @override
  String get muteVideo => 'Mute';

  @override
  String get playVideo => 'Play';

  @override
  String get pauseVideo => 'Pause';

  @override
  String get startMiniQuiz => 'Take the mini quiz';

  @override
  String get replayVideo => 'Replay video';

  @override
  String get nextLesson => 'Next lesson';

  @override
  String get videoLoadFailed => 'Couldn\'t load the video.';

  @override
  String get videoPlaybackFailed => 'Couldn\'t play the video.';

  @override
  String get videoVolumeFailed => 'Couldn\'t change the volume.';

  @override
  String get languageSaveFailed =>
      'Couldn\'t save your language preference. Please try again.';

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

  @override
  String get lessonOverview => 'Lessons';

  @override
  String progressSummary(int answered, int correct, int total) {
    return 'Answered $answered/$total · Correct $correct/$total';
  }

  @override
  String get quizUnanswered => 'Unanswered';

  @override
  String get quizAnsweredCorrectly => 'Answered correctly';

  @override
  String get quizAnsweredIncorrectly => 'Answered incorrectly';

  @override
  String get retryQuiz => 'Retry Quiz';

  @override
  String get savedDataLoadFailed => 'Couldn\'t load your saved data.';

  @override
  String get progressSaveFailed =>
      'Couldn\'t save your answer. Tap an option to try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get quizSkyQuestion =>
      'Which color is scattered most strongly by air molecules?';

  @override
  String get quizSkyRed => 'Red';

  @override
  String get quizSkyBlue => 'Blue';

  @override
  String get quizSkyGreen => 'Green';

  @override
  String get quizSkyExplanation =>
      'Air molecules scatter shorter wavelengths more strongly, so blue light scatters more than green or red light.';

  @override
  String get quizApiQuestion => 'What is the main purpose of an API?';

  @override
  String get quizApiExchange => 'Allow applications to exchange data';

  @override
  String get quizApiBattery => 'Charge a device battery';

  @override
  String get quizApiBrightness => 'Increase screen brightness';

  @override
  String get quizApiExplanation =>
      'An API defines how one application can request data from another and read the response.';

  @override
  String get quizInterestQuestion => 'What does compound interest include?';

  @override
  String get quizInterestPrincipal => 'Only the original principal';

  @override
  String get quizInterestDeposits => 'Only new deposits';

  @override
  String get quizInterestPrevious => 'Interest earned on previous interest';

  @override
  String get quizInterestExplanation =>
      'Each period’s interest is added to the balance that earns interest in the next period.';

  @override
  String get quizCorrect => 'Correct!';

  @override
  String get quizWrong => 'Not quite. Correct answer:';

  @override
  String get backToFeed => 'Back to feed';
}
