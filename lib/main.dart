import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'data/language_preference_store.dart';
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
  final _languageStore = LanguagePreferenceStore();
  late Future<Map<LessonId, bool>> _initialResults = _loadSavedData();
  Locale? _selectedLocale;
  bool _isSavingLanguage = false;

  Future<Map<LessonId, bool>> _loadSavedData() async {
    final (locale, results) = await (
      _languageStore.load(),
      _progressStore.load(),
    ).wait;
    if (mounted && locale != _selectedLocale) {
      setState(() => _selectedLocale = locale);
    }
    return results;
  }

  Future<void> _changeLocale(BuildContext context, Locale? locale) async {
    if (_isSavingLanguage || locale == _selectedLocale) return;
    setState(() => _isSavingLanguage = true);
    try {
      await _languageStore.save(locale);
      if (mounted) setState(() => _selectedLocale = locale);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.languageSaveFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingLanguage = false);
    }
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
                    Text(l10n.savedDataLoadFailed),
                    TextButton(
                      onPressed: () {
                        setState(() => _initialResults = _loadSavedData());
                      },
                      child: Text(l10n.tryAgain),
                    ),
                  ],
                ),
              ),
            );
          }

          return VideoFeedScreen(
            selectedLocale: _selectedLocale,
            onLocaleChanged: _isSavingLanguage
                ? null
                : (locale) => _changeLocale(context, locale),
            initialResults: snapshot.requireData,
            onQuizResult: _progressStore.save,
          );
        },
      ),
    );
  }
}

class VideoFeedScreen extends StatefulWidget {
  final Locale? selectedLocale;
  final ValueChanged<Locale?>? onLocaleChanged;
  final Map<LessonId, bool> initialResults;
  final Future<void> Function(LessonId lessonId, {required bool isCorrect})
  onQuizResult;

  const VideoFeedScreen({
    super.key,
    this.selectedLocale,
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
  bool _muted = true;

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

  Future<QuizAction?> _openQuiz(List<LearningReel> reels, int index) async {
    if (_isOverlayOpen) return null;

    final reel = reels[index];
    final lessonId = reel.id;
    final l10n = AppLocalizations.of(context)!;
    final question = quizForReel(lessonId, l10n);

    setState(() {
      _isOverlayOpen = true;
    });

    // Allow the video widget to receive isActive = false
    // before opening the quiz screen.
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) return null;

    try {
      final action = await Navigator.of(context).push<QuizAction>(
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            question: question,
            hasNextLesson: index + 1 < reels.length,
            hasVideo: reel.videoSource != null,
            onAnswer: (isCorrect) async {
              await widget.onQuizResult(lessonId, isCorrect: isCorrect);
              if (mounted) {
                setState(() => _results[lessonId] = isCorrect);
              }
            },
          ),
        ),
      );
      if (mounted && action == QuizAction.nextLesson) {
        _pageController.jumpToPage(index + 1);
      }
      return action;
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
                key: ValueKey((reel.id, reel.videoSource)),
                reel: reel,
                index: index,
                total: reels.length,
                progressSummary: progressSummary,
                quizResult: _results[reel.id],
                isActive: index == _activeIndex && !_isOverlayOpen,
                muted: _muted,
                onMuteChanged: (muted) => setState(() => _muted = muted),
                onOverviewPressed: () => _openLessonOverview(reels),
                onQuizPressed: () => _openQuiz(reels, index),
                selectedLocale: widget.selectedLocale,
                onLocaleChanged: widget.onLocaleChanged,
              );
            },
          ),
        ),
      ),
    );
  }
}

class LearningReelCard extends StatefulWidget {
  final LearningReel reel;
  final int index;
  final int total;
  final String progressSummary;
  final bool? quizResult;
  final bool isActive;
  final bool? muted;
  final ValueChanged<bool>? onMuteChanged;
  final Locale? selectedLocale;
  final ValueChanged<Locale?>? onLocaleChanged;
  final VoidCallback onOverviewPressed;
  final Future<QuizAction?> Function() onQuizPressed;

  const LearningReelCard({
    super.key,
    required this.reel,
    required this.index,
    required this.total,
    required this.progressSummary,
    required this.quizResult,
    required this.isActive,
    this.muted,
    this.onMuteChanged,
    this.selectedLocale,
    required this.onLocaleChanged,
    required this.onOverviewPressed,
    required this.onQuizPressed,
  });

  @override
  State<LearningReelCard> createState() => _LearningReelCardState();
}

class _LearningReelCardState extends State<LearningReelCard> {
  bool _videoCompleted = false;
  int _replayRequest = 0;

  void _replay() => setState(() => _replayRequest++);

  Future<void> _openQuiz() async {
    final action = await widget.onQuizPressed();
    if (mounted && action == QuizAction.replay) _replay();
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;
    final l10n = AppLocalizations.of(context)!;
    final isCompact = MediaQuery.sizeOf(context).height < 650;
    final statusColor = switch (widget.quizResult) {
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
            isActive: widget.isActive,
            muted: widget.muted,
            onMuteChanged: widget.onMuteChanged,
            replayRequest: _replayRequest,
            onCompletionChanged: (completed) {
              setState(() => _videoCompleted = completed);
            },
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
                    Text('${widget.index + 1}/${widget.total}'),
                    IconButton(
                      tooltip: l10n.lessonOverview,
                      onPressed: widget.onOverviewPressed,
                      icon: const Icon(Icons.list_alt_outlined),
                    ),
                    PopupMenuButton<String>(
                      key: const Key('language-menu'),
                      tooltip: l10n.language,
                      icon: const Icon(Icons.language),
                      enabled: widget.onLocaleChanged != null,
                      onSelected: (language) {
                        widget.onLocaleChanged?.call(
                          language == 'system' ? null : Locale(language),
                        );
                      },
                      itemBuilder: (context) => [
                        CheckedPopupMenuItem(
                          value: 'system',
                          checked: widget.selectedLocale == null,
                          child: Text(l10n.systemLanguage),
                        ),
                        CheckedPopupMenuItem(
                          value: 'tr',
                          checked: widget.selectedLocale?.languageCode == 'tr',
                          child: const Text('Türkçe'),
                        ),
                        CheckedPopupMenuItem(
                          value: 'en',
                          checked: widget.selectedLocale?.languageCode == 'en',
                          child: const Text('English'),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: List.generate(widget.total, (step) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: step == widget.total - 1 ? 0 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: step <= widget.index
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
                  widget.progressSummary,
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
                            quizStatusLabel(l10n, widget.quizResult),
                            style: TextStyle(color: statusColor),
                          ),
                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _openQuiz,
                              icon: const Icon(Icons.psychology_outlined),
                              label: Text(
                                _videoCompleted
                                    ? l10n.startMiniQuiz
                                    : widget.quizResult == null
                                    ? l10n.testKnowledge
                                    : l10n.retryQuiz,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: _videoCompleted
                                ? TextButton.icon(
                                    onPressed: _replay,
                                    icon: const Icon(Icons.replay),
                                    label: Text(l10n.replayVideo),
                                  )
                                : Text(
                                    l10n.swipeHint,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
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
