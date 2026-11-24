import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'data/quiz_data.dart';
import 'data/quiz_progress_store.dart';
import 'data/reel_data.dart';
import 'l10n/app_localizations.dart';
import 'models/learning_reel.dart';
import 'screens/lesson_overview.dart';
import 'screens/quiz_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/reel_video_player.dart';

void main() {
  runApp(const ReelMindApp());
}

class ReelMindApp extends StatefulWidget {
  const ReelMindApp({super.key});

  @override
  State<ReelMindApp> createState() => _ReelMindAppState();
}

class _ReelMindAppState extends State<ReelMindApp> {
  final _progressStore = QuizProgressStore();
  late Future<Map<LessonId, bool>> _initialResults = _progressStore.load();
  Locale? _selectedLocale;

  void _changeLocale(Locale? locale) {
    setState(() {
      _selectedLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReelMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      locale: _selectedLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      home: FutureBuilder<Map<LessonId, bool>>(
        future: _initialResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.progressLoadFailed),
                    TextButton(
                      onPressed: () {
                        setState(() => _initialResults = _progressStore.load());
                      },
                      child: Text(l10n.tryAgain),
                    ),
                  ],
                ),
              ),
            );
          }

          return VideoFeedScreen(
            onLocaleChanged: _changeLocale,
            initialResults: snapshot.requireData,
            onQuizResult: _progressStore.save,
          );
        },
      ),
    );
  }
}

class VideoFeedScreen extends StatefulWidget {
  final ValueChanged<Locale?> onLocaleChanged;
  final Map<LessonId, bool> initialResults;
  final Future<void> Function(LessonId lessonId, {required bool isCorrect})
  onQuizResult;

  const VideoFeedScreen({
    super.key,
    required this.onLocaleChanged,
    required this.initialResults,
    required this.onQuizResult,
  });

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  late final _results = Map<LessonId, bool>.of(widget.initialResults);
  final _pageController = PageController();
  int _activeIndex = 0;
  bool _isOverlayOpen = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openLessonOverview(List<LearningReel> reels) async {
    if (_isOverlayOpen) return;
    setState(() => _isOverlayOpen = true);

    try {
      final index = await showModalBottomSheet<int>(
        context: context,
        builder: (context) => LessonOverview(
          reels: reels,
          results: _results,
          activeIndex: _activeIndex,
        ),
      );
      if (mounted && index != null && index != _activeIndex) {
        _pageController.jumpToPage(index);
      }
    } finally {
      if (mounted) {
        setState(() => _isOverlayOpen = false);
      }
    }
  }

  Future<void> _openQuiz(LessonId lessonId) async {
    if (_isOverlayOpen) return;

    final l10n = AppLocalizations.of(context)!;
    final question = quizForReel(lessonId, l10n);

    setState(() {
      _isOverlayOpen = true;
    });

    // Allow the video widget to receive isActive = false
    // before opening the quiz screen.
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) return;

    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            question: question,
            onAnswer: (isCorrect) async {
              await widget.onQuizResult(lessonId, isCorrect: isCorrect);
              if (mounted) {
                setState(() => _results[lessonId] = isCorrect);
              }
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOverlayOpen = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reels = buildReels(l10n);
    final lessonIds = reels.map((reel) => reel.id).toSet();
    final outcomes = lessonIds.map((id) => _results[id]).whereType<bool>();
    final progressSummary = l10n.progressSummary(
      outcomes.length,
      outcomes.where((isCorrect) => isCorrect).length,
      lessonIds.length,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            onPageChanged: (index) {
              setState(() {
                _activeIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final reel = reels[index];
              return LearningReelCard(
                reel: reel,
                index: index,
                total: reels.length,
                progressSummary: progressSummary,
                quizResult: _results[reel.id],
                isActive: index == _activeIndex && !_isOverlayOpen,
                onOverviewPressed: () => _openLessonOverview(reels),
                onQuizPressed: () => _openQuiz(reel.id),
                onLocaleChanged: widget.onLocaleChanged,
              );
            },
          ),
        ),
      ),
    );
  }
}

class LearningReelCard extends StatelessWidget {
  final LearningReel reel;
  final int index;
  final int total;
  final String progressSummary;
  final bool? quizResult;
  final bool isActive;
  final ValueChanged<Locale?> onLocaleChanged;
  final VoidCallback onOverviewPressed;
  final VoidCallback onQuizPressed;

  const LearningReelCard({
    super.key,
    required this.reel,
    required this.index,
    required this.total,
    required this.progressSummary,
    required this.quizResult,
    required this.isActive,
    required this.onLocaleChanged,
    required this.onOverviewPressed,
    required this.onQuizPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCompact = MediaQuery.sizeOf(context).height < 650;
    final statusColor = switch (quizResult) {
      null => Colors.white70,
      true => AppColors.success,
      false => AppColors.error,
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-screen video or placeholder.
        if (reel.videoSource != null)
          ReelVideoPlayer(
            key: ValueKey(reel.videoSource),
            source: reel.videoSource!,
            isActive: isActive,
          )
        else
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [reel.color, const Color(0xFF090D1A)],
              ),
            ),
            child: Center(
              child: Icon(reel.icon, size: 110, color: Colors.white54),
            ),
          ),

        // Gradient to keep text readable.
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.38, 1.0],
                colors: [
                  Color(0xB3000000),
                  Colors.transparent,
                  Color(0xE6000000),
                ],
              ),
            ),
          ),
        ),

        // Overlay content.
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 16 : 24,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ReelMind',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isCompact ? 20 : 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${index + 1}/$total'),
                    IconButton(
                      tooltip: l10n.lessonOverview,
                      onPressed: onOverviewPressed,
                      icon: const Icon(Icons.list_alt_outlined),
                    ),
                    PopupMenuButton<String>(
                      key: const Key('language-menu'),
                      tooltip: l10n.language,
                      icon: const Icon(Icons.language),
                      onSelected: (language) {
                        onLocaleChanged(
                          language == 'system' ? null : Locale(language),
                        );
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'system',
                          child: Text(l10n.systemLanguage),
                        ),
                        const PopupMenuItem(value: 'tr', child: Text('Türkçe')),
                        const PopupMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: List.generate(total, (step) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: step == total - 1 ? 0 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: step <= index
                              ? AppColors.accent
                              : Colors.white38,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  progressSummary,
                  style: Theme.of(context).textTheme.labelMedium,
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(reel.category),
                            backgroundColor: reel.color,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            reel.title,
                            style: TextStyle(
                              fontSize: isCompact ? 26 : 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            reel.description,
                            style: TextStyle(
                              fontSize: isCompact ? 14 : 16,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            quizStatusLabel(l10n, quizResult),
                            style: TextStyle(color: statusColor),
                          ),
                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: onQuizPressed,
                              icon: const Icon(Icons.psychology_outlined),
                              label: Text(
                                quizResult == null
                                    ? l10n.testKnowledge
                                    : l10n.retryQuiz,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: Text(
                              l10n.swipeHint,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
