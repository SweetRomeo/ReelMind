
import '../models/quiz_question.dart';
import '../l10n/app_localizations.dart';

QuizQuestion quizForReel(int index, AppLocalizations l10n) {
  switch (index) {
    case 0:
      return QuizQuestion(
        question: l10n.quizSkyQuestion,
        options: [
          l10n.quizSkyRed,
          l10n.quizSkyBlue,
          l10n.quizSkyGreen,
        ],
        correctIndex: 1,
      );

    case 1:
      return QuizQuestion(
        question: l10n.quizApiQuestion,
        options: [
          l10n.quizApiExchange,
          l10n.quizApiBattery,
          l10n.quizApiBrightness,
        ],
        correctIndex: 0,
      );

    case 2:
      return QuizQuestion(
        question: l10n.quizInterestQuestion,
        options: [
          l10n.quizInterestPrincipal,
          l10n.quizInterestDeposits,
          l10n.quizInterestPrevious,
        ],
        correctIndex: 2,
      );

    default:
      throw ArgumentError('Invalid reel index: $index');
  }
}
