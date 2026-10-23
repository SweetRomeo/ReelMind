
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/quiz_question.dart';

class QuizScreen extends StatefulWidget {
  final QuizQuestion question;

  const QuizScreen({
    super.key,
    required this.question,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final answered = selectedIndex != null;
    final correct = answered &&
        widget.question.isCorrect(selectedIndex!);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.testKnowledge),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  widget.question.question,
                  style: Theme.of(context)
                      .textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                for (int i = 0;
                    i < widget.question.options.length;
                    i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OutlinedButton(
                      key: Key('quiz-option-$i'),
                      onPressed: answered
                          ? null
                          : () {
                              setState(() {
                                selectedIndex = i;
                              });
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          widget.question.options[i],
                        ),
                      ),
                    ),
                  ),

                if (answered) ...[
                  const SizedBox(height: 24),
                  Text(
                    correct
                        ? l10n.quizCorrect
                        : '${l10n.quizWrong} '
                          '${widget.question.options[widget.question.correctIndex]}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: correct
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.backToFeed),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
