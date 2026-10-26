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

class VideoFeedScreen extends StatelessWidget {
  final ValueChanged<Locale?> onLocaleChanged;

  const VideoFeedScreen({super.key, required this.onLocaleChanged});

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
            itemBuilder: (context, index) {
              return LearningReelCard(
                reel: reels[index],
                index: index,
                total: reels.length,
                onLocaleChanged: onLocaleChanged,
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
  final ValueChanged<Locale?> onLocaleChanged;

  const LearningReelCard({
    super.key,
    required this.reel,
    required this.index,
    required this.total,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 650;

    final horizontalPadding = isCompact ? 16.0 : 24.0;
    final logoFontSize = isCompact ? 22.0 : 26.0;
    final heroCardWidth = isCompact ? 150.0 : 190.0;
    final heroCardHeight = isCompact ? 110.0 : 190.0;
    final heroIconSize = isCompact ? 70.0 : 90.0;

    final titleFontSize = isCompact ? 28.0 : 30.0;
    final descriptionFontSize = isCompact ? 14.0 : 17.0;
    final buttonHeight = isCompact ? 50.0 : 58.0;

    final gapSmall = isCompact ? 8.0 : 12.0;
    final gapMedium = isCompact ? 12.0 : 16.0;
    final gapLarge = isCompact ? 20.0 : 28.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF171F3D), Color(0xFF101528), Color(0xFF090D1A)],
        ),
      ),

      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'ReelMind',
                    style: TextStyle(
                      fontSize: logoFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
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
                      const PopupMenuItem(value: 'en', child: Text('English')),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: List.generate(total, (step) {
                  final isCompleted = step <= index;

                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: step == total - 1 ? 0 : 6),
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.accent : Colors.white24,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Center(
                  child: Container(
                    width: heroCardWidth,
                    height: heroCardHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [reel.color, const Color(0xFF242044)],
                      ),
                      border: Border.all(color: Colors.white24, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: reel.color.withValues(alpha: 0.3),
                          blurRadius: 55,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: index == 0
                        ? const ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            child: ReelVideoPlayer(
                              videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                            ),
                          )
                        : Center(
                            child: Icon(
                              reel.icon,
                              size: heroIconSize,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: reel.color.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: reel.color.withValues(alpha: 0.65)),
                ),
                child: Text(
                  reel.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              SizedBox(height: gapMedium),
              Text(
                reel.title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: gapSmall),
              Text(
                reel.description,
                style: TextStyle(fontSize: descriptionFontSize, height: 1.5),
              ),
              SizedBox(height: gapLarge),
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final question = quizForReel(index, l10n);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(question: question),
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology_outlined),
                  label: Text(l10n.testKnowledge),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  l10n.swipeHint,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isCompact ? 13 : 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
