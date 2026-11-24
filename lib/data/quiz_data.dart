import '../l10n/app_localizations.dart';
import '../models/learning_reel.dart';
import '../models/quiz_question.dart';

QuizQuestion quizForReel(LessonId id, AppLocalizations l10n) {
  switch (id) {
    case LessonId.skyColor:
      return QuizQuestion(
        question: l10n.quizSkyQuestion,
        options: [l10n.quizSkyRed, l10n.quizSkyBlue, l10n.quizSkyGreen],
        correctIndex: 1,
        explanation: l10n.quizSkyExplanation,
      );

    case LessonId.apiIntro:
      return QuizQuestion(
        question: l10n.quizApiQuestion,
        options: [
          l10n.quizApiExchange,
          l10n.quizApiBattery,
          l10n.quizApiBrightness,
        ],
        correctIndex: 0,
        explanation: l10n.quizApiExplanation,
      );

    case LessonId.compoundInterest:
      return QuizQuestion(
        question: l10n.quizInterestQuestion,
        options: [
          l10n.quizInterestPrincipal,
          l10n.quizInterestDeposits,
          l10n.quizInterestPrevious,
        ],
        correctIndex: 2,
        explanation: l10n.quizInterestExplanation,
      );
  }
}
