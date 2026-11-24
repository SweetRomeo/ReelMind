import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reelmind/widgets/reel_video_player.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:reelmind/main.dart';
import 'package:reelmind/l10n/app_localizations.dart';
import 'package:reelmind/models/video_source.dart';

class FakeVideoPlatform extends VideoPlayerPlatform {
  final calls = <String>[];
  final playingIds = <int>{};
  final volumes = <int, double>{};
  final seeks = <(int, Duration)>[];
  final _streams = <int, StreamController<VideoEvent>>{};
  final firstDisposal = Completer<void>();
  int _nextId = 1;

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = _nextId++;
    final stream = StreamController<VideoEvent>();
    _streams[id] = stream;

    stream.add(
      VideoEvent(
        eventType: VideoEventType.initialized,
        duration: Duration(seconds: 30),
        size: Size(1280, 720),
      ),
    );

    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    return _streams[playerId]!.stream;
  }

  @override
  Future<void> play(int playerId) async {
    calls.add('play');
    playingIds.add(playerId);
  }

  @override
  Future<void> pause(int playerId) async {
    calls.add('pause');
    playingIds.remove(playerId);
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  void completeVideo(int playerId) {
    _streams[playerId]!.add(VideoEvent(eventType: VideoEventType.completed));
  }

  @override
  Future<void> seekTo(int playerId, Duration position) async {
    seeks.add((playerId, position));
  }

  @override
  Future<void> setVolume(int playerId, double volume) async {
    volumes[playerId] = volume;
  }

  void pauseFromSystem(int playerId) {
    playingIds.remove(playerId);
    _streams[playerId]!.add(
      VideoEvent(
        eventType: VideoEventType.isPlayingStateUpdate,
        isPlaying: false,
      ),
    );
  }

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<Duration> getPosition(int playerId) async {
    return Duration.zero;
  }

  @override
  Widget buildView(int playerId) {
    return const SizedBox.expand();
  }

  @override
  Future<void> dispose(int playerId) async {
    calls.add('dispose');
    playingIds.remove(playerId);

    await _streams.remove(playerId)?.close();

    if (!firstDisposal.isCompleted) {
      firstDisposal.complete();
    }
  }
}

void main() {
  late FakeVideoPlatform fake;
  late VideoPlayerPlatform originalPlatform;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    originalPlatform = VideoPlayerPlatform.instance;
    fake = FakeVideoPlatform();
    VideoPlayerPlatform.instance = fake;
  });

  tearDown(() {
    VideoPlayerPlatform.instance = originalPlatform;
  });

  Future<void> showPlayer(WidgetTester tester, bool isActive) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ReelVideoPlayer(
            source: const VideoSource.network('https://example.com/test.mp4'),
            isActive: isActive,
          ),
        ),
      ),
    );

    for (var i = 0; i < 6; i++) {
      await tester.pump();
    }
  }

  testWidgets('Active reel starts and pauses correctly', (tester) async {
    await showPlayer(tester, true);

    expect(fake.calls, contains('play'));

    await showPlayer(tester, false);

    expect(fake.calls, contains('pause'));

    final playCount = fake.calls.where((call) => call == 'play').length;

    await showPlayer(tester, true);

    expect(
      fake.calls.where((call) => call == 'play').length,
      greaterThan(playCount),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Inactive reel does not autoplay', (tester) async {
    await showPlayer(tester, false);

    expect(fake.calls, isNot(contains('play')));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Quiz pauses video and returning resumes playback', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const ReelMindApp());
    await tester.pumpAndSettle();

    // API videosunun olduğu ikinci karta geç.
    await tester.drag(find.byType(PageView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('What is an API?'), findsOneWidget);
    expect(fake.playingIds, hasLength(1));

    await tester.tap(find.text('Test Your Knowledge'));
    await tester.pumpAndSettle();

    expect(fake.playingIds, isEmpty);

    await tester.tap(find.text('Allow applications to exchange data'));
    await tester.pumpAndSettle();

    final backButton = find.text('Back to feed');
    await tester.ensureVisible(backButton);
    await tester.pumpAndSettle();

    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(fake.playingIds, hasLength(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Completed videos wait for replay or quiz and advance by lesson',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const ReelMindApp());
      await tester.pumpAndSettle();

      Future<void> tapLabel(String label) async {
        final button = find.text(label);
        if (button.hitTestable().evaluate().isEmpty) {
          await tester.ensureVisible(button);
          await tester.pumpAndSettle();
        }
        await tester.tap(button);
        await tester.pumpAndSettle();
      }

      final sky = fake.playingIds.single;
      fake.completeVideo(sky);
      await tester.pumpAndSettle();
      expect(fake.playingIds, isEmpty);
      expect(find.text('Take the mini quiz'), findsOneWidget);
      await tapLabel('Replay video');
      expect(fake.seeks.last, (sky, Duration.zero));
      expect(fake.playingIds, {sky});

      fake.completeVideo(sky);
      await tester.pumpAndSettle();
      await tapLabel('Take the mini quiz');
      await tapLabel('Back to feed');
      expect(fake.playingIds, isEmpty);
      await tapLabel('Take the mini quiz');
      await tapLabel('Red');
      expect(find.textContaining('shorter wavelengths'), findsOneWidget);
      await tapLabel('Replay video');
      expect(fake.seeks.last, (sky, Duration.zero));
      expect(fake.playingIds, {sky});

      await tapLabel('Retry Quiz');
      await tapLabel('Blue');
      expect(find.text('Replay video'), findsNothing);
      await tapLabel('Next lesson');
      expect(find.text('What is an API?'), findsOneWidget);
      expect(fake.playingIds.single, isNot(sky));
      await tapLabel('Test Your Knowledge');
      await tapLabel('Allow applications to exchange data');
      await tapLabel('Next lesson');
      expect(fake.playingIds, isEmpty);
      await tapLabel('Test Your Knowledge');
      await tapLabel('Only new deposits');
      expect(find.text('Replay video'), findsNothing);
      expect(find.text('Next lesson'), findsNothing);
      await tapLabel('Back to feed');
      expect(find.text('Answered 3/3 · Correct 2/3'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('Only the active reel video plays while swiping', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const ReelMindApp());
    await tester.pumpAndSettle();

    final skyPlayer = fake.playingIds.single;
    expect(fake.volumes[skyPlayer], 0);
    await tester.tap(find.byTooltip('Unmute'));
    await tester.pumpAndSettle();
    expect(fake.volumes[skyPlayer], 1);
    expect(fake.playingIds, {skyPlayer});

    fake.pauseFromSystem(skyPlayer);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Play'));
    await tester.pumpAndSettle();
    expect(fake.playingIds, {skyPlayer});

    await tester.tap(find.byTooltip('Mute'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Pause'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Unmute'));
    await tester.pumpAndSettle();
    expect(fake.volumes[skyPlayer], 1);
    expect(fake.playingIds, isEmpty);

    await tester.tap(find.byTooltip('Play'));
    await tester.pumpAndSettle();
    expect(fake.playingIds, {skyPlayer});

    // İkinci karttaki API videosu oynar.
    await tester.drag(find.byType(PageView), const Offset(0, -700));
    await tester.pumpAndSettle();

    final activePlayers = tester
        .widgetList<ReelVideoPlayer>(find.byType(ReelVideoPlayer))
        .where((player) => player.isActive)
        .toList();

    expect(activePlayers, hasLength(1));
    expect(
      activePlayers.single.source.location,
      'assets/videos/api_intro_en_001.mp4',
    );
    expect(fake.playingIds, hasLength(1));
    expect(fake.playingIds, isNot(contains(skyPlayer)));

    // Üçüncü karta geçince oynatma durur.
    await tester.drag(find.byType(PageView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(fake.playingIds, isEmpty);

    // API kartına dönünce yeniden oynar.
    await tester.drag(find.byType(PageView), const Offset(0, 700));
    await tester.pumpAndSettle();

    expect(fake.playingIds, hasLength(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('Local asset video plays and is disposed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ReelVideoPlayer(
            source: VideoSource.asset('assets/videos/api_intro_en_001.mp4'),
            isActive: true,
          ),
        ),
      ),
    );

    for (var i = 0; i < 6; i++) {
      await tester.pump();
    }

    expect(fake.playingIds, hasLength(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(
      () => fake.firstDisposal.future.timeout(const Duration(seconds: 3)),
    );

    expect(fake.calls, contains('dispose'));
    expect(fake.playingIds, isEmpty);
  });
}
