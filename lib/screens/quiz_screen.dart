import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/quiz_question.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final QuizQuestion question;

  const QuizScreen({super.key, required this.question});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final question = widget.question;
    final answered = selectedIndex != null;

    final isCorrect = answered && question.isCorrect(selectedIndex!);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.testKnowledge)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(
                  Icons.psychology_outlined,
                  color: AppColors.accent,
                  size: 54,
                ),

                const SizedBox(height: 24),

                Text(
                  question.question,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 32),

                for (int i = 0; i < question.options.length; i++)
                  _buildOption(i, answered),

                if (answered) ...[
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCorrect ? AppColors.success : AppColors.error,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.info_outline,
                          color: isCorrect
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isCorrect
                                ? l10n.quizCorrect
                                : '${l10n.quizWrong} '
                                      '${question.options[question.correctIndex]}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.backToFeed),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(int index, bool answered) {
    final question = widget.question;
    final isSelected = selectedIndex == index;

    final showCorrect = answered && index == question.correctIndex;

    final showWrong = answered && isSelected && !question.isCorrect(index);

    final borderColor = showCorrect
        ? AppColors.success
        : showWrong
        ? AppColors.error
        : AppColors.border;

    final backgroundColor = showCorrect
        ? AppColors.success.withValues(alpha: 0.12)
        : showWrong
        ? AppColors.error.withValues(alpha: 0.12)
        : AppColors.surface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        selected: isSelected,
        enabled: !answered,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: showCorrect || showWrong ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: answered
                ? null
                : () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      question.options[index],
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  if (showCorrect)
                    const Icon(Icons.check_circle, color: AppColors.success)
                  else if (showWrong)
                    const Icon(Icons.cancel, color: AppColors.error),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
