
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'data/quiz_data.dart';
import 'screens/quiz_screen.dart';

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
      theme: ThemeData.dark(),
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
      home: VideoFeedScreen(
        onLocaleChanged: _changeLocale,
      ),
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

  const VideoFeedScreen({
    super.key,
    required this.onLocaleChanged,
  });

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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            reel.color,
            const Color(0xFF101018),
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'ReelMind',
                    style: TextStyle(
                      fontSize: 26,
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
                        language == 'system'
                            ? null
                            : Locale(language),
                      );
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'system',
                        child: Text(l10n.systemLanguage),
                      ),
                      const PopupMenuItem(
                        value: 'tr',
                        child: Text('Türkçe'),
                      ),
                      const PopupMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Icon(
                    reel.icon,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                reel.category,
                style: const TextStyle(
                  color: Colors.white70,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                reel.title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                reel.description,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(

                onPressed: () {
                  final question = quizForReel(index, l10n);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        question: question,
                      ),
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
                  style: const TextStyle(
                    color: Colors.white70,
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
