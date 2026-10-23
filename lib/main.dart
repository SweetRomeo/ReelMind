
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ReelMindApp());
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

const reels = [
  LearningReel(
    category: 'SCIENCE',
    title: 'Why is the sky blue?',
    description:
        'Sunlight contains many colors. Air molecules scatter '
        'blue light more strongly than red light.',
    icon: Icons.wb_sunny_outlined,
    color: Color(0xFF1565C0),
  ),
  LearningReel(
    category: 'TECHNOLOGY',
    title: 'What is an API?',
    description:
        'An API allows different software applications '
        'to communicate and exchange information.',
    icon: Icons.code,
    color: Color(0xFF673AB7),
  ),
  LearningReel(
    category: 'FINANCE',
    title: 'What is compound interest?',
    description:
        'Compound interest lets you earn returns '
        'on both your original money and previous returns.',
    icon: Icons.trending_up,
    color: Color(0xFF00796B),
  ),
];

class ReelMindApp extends StatelessWidget {
  const ReelMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReelMind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      home: const VideoFeedScreen(),
    );
  }
}

class VideoFeedScreen extends StatelessWidget {
  const VideoFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

  const LearningReelCard({
    super.key,
    required this.reel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
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
                  Text('${index + 1}/${reels.length}'),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quiz coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology_outlined),
                  label: const Text('Test Your Knowledge'),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Swipe up to learn more ↑',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
