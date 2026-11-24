import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/quiz_question.dart';
import '../theme/app_theme.dart';

enum QuizAction { nextLesson, replay }

class QuizScreen extends StatefulWidget {
  final QuizQuestion question;
  final bool hasNextLesson;
  final bool hasVideo;
  final Future<void> Function(bool isCorrect) onAnswer;

  const QuizScreen({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.hasNextLesson,
    required this.hasVideo,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedIndex;
  bool _isSaving = false;
  bool _saveFailed = false;

  Future<void> _submitAnswer(int index) async {
    if (_isSaving || _selectedIndex != null) return;

    setState(() {
      _isSaving = true;
      _saveFailed = false;
    });

    try {
      await widget.onAnswer(widget.question.isCorrect(index));
      if (mounted) setState(() => _selectedIndex = index);
    } catch (_) {
      if (mounted) setState(() => _saveFailed = true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final question = widget.question;
    final answered = _selectedIndex != null;

    final isCorrect = answered && question.isCorrect(_selectedIndex!);

    final screen = Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.testKnowledge)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    _buildOption(i, answered, enabled: !answered && !_isSaving),

                  if (_isSaving) const LinearProgressIndicator(),
                  if (_saveFailed)
                    Text(l10n.progressSaveFailed, textAlign: TextAlign.center),

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
                          color: isCorrect
                              ? AppColors.success
                              : AppColors.error,
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(question.explanation),
                    const SizedBox(height: 24),
                    if (widget.hasNextLesson)
                      FilledButton.icon(
                        onPressed: () =>
                            Navigator.pop(context, QuizAction.nextLesson),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(l10n.nextLesson),
                      ),
                    if (!isCorrect && widget.hasVideo)
                      OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.pop(context, QuizAction.replay),
                        icon: const Icon(Icons.replay),
                        label: Text(l10n.replayVideo),
                      ),
                  ],
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.backToFeed),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return PopScope(canPop: !_isSaving, child: screen);
  }

  Widget _buildOption(int index, bool answered, {required bool enabled}) {
    final question = widget.question;
    final isSelected = _selectedIndex == index;

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
        enabled: enabled,
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
            onTap: enabled ? () => _submitAnswer(index) : null,
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
