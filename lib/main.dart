import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'data/quiz_data.dart';
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
      home: VideoFeedScreen(onLocaleChanged: _changeLocale),
    );
  }
}

class LearningReel {
  final String category;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const LearningReel({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class VideoFeedScreen extends StatefulWidget {
  final ValueChanged<Locale?> onLocaleChanged;

  const VideoFeedScreen({super.key, required this.onLocaleChanged});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  int _activeIndex = 0;
  bool _isQuizOpen = false;

  Future<void> _openQuiz(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final question = quizForReel(index, l10n);

    setState(() {
      _isQuizOpen = true;
    });

    // Allow the video widget to receive isActive = false
    // before opening the quiz screen.
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) return;

    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (context) => QuizScreen(question: question)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isQuizOpen = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final reels = [
      LearningReel(
        category: l10n.science,
        title: l10n.skyTitle,
        description: l10n.skyDescription,
        icon: Icons.wb_sunny_outlined,
        color: const Color(0xFF1565C0),
      ),
      LearningReel(
        category: l10n.technology,
        title: l10n.apiTitle,
        description: l10n.apiDescription,
        icon: Icons.code,
        color: const Color(0xFF673AB7),
      ),
      LearningReel(
        category: l10n.finance,
        title: l10n.interestTitle,
        description: l10n.interestDescription,
        icon: Icons.trending_up,
        color: const Color(0xFF00796B),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            onPageChanged: (index) {
              setState(() {
                _activeIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return LearningReelCard(
                reel: reels[index],
                index: index,
                total: reels.length,
                isActive: index == _activeIndex && !_isQuizOpen,
                onQuizPressed: () => _openQuiz(index),
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
  final bool isActive;
  final ValueChanged<Locale?> onLocaleChanged;
  final VoidCallback onQuizPressed;

  const LearningReelCard({
    super.key,
    required this.reel,
    required this.index,
    required this.total,
    required this.isActive,
    required this.onLocaleChanged,
    required this.onQuizPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCompact = MediaQuery.sizeOf(context).height < 650;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-screen video or placeholder.
        if (index == 0)
          ReelVideoPlayer(
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
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

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: onQuizPressed,
                              icon: const Icon(Icons.psychology_outlined),
                              label: Text(l10n.testKnowledge),
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
