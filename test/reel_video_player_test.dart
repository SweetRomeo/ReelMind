import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reelmind/widgets/reel_video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:reelmind/main.dart';

class FakeVideoPlatform extends VideoPlayerPlatform {
  final calls = <String>[];
  final playingIds = <int>{};
  final _streams = <int, StreamController<VideoEvent>>{};
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

  @override
  Future<void> setVolume(int playerId, double volume) async {}

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
  }
}

void main() {
  late FakeVideoPlatform fake;
  late VideoPlayerPlatform originalPlatform;

  setUp(() {
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
        home: Scaffold(
          body: ReelVideoPlayer(
            videoUrl: 'https://example.com/test.mp4',
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
    await tester.pumpWidget(const ReelMindApp());
    await tester.pumpAndSettle();

    expect(fake.calls, contains('play'));

    final pauseCount = fake.calls.where((call) => call == 'pause').length;

    // Open quiz.
    await tester.tap(find.text('Test Your Knowledge'));
    await tester.pumpAndSettle();

    expect(
      fake.calls.where((call) => call == 'pause').length,
      greaterThan(pauseCount),
    );

    final playCount = fake.calls.where((call) => call == 'play').length;

    // Answer the question and return to the feed.
    await tester.tap(find.text('Blue'));
    await tester.pumpAndSettle();

    final backButton = find.text('Back to feed');

    await tester.scrollUntilVisible(
      backButton,
      200.0,
      scrollable: find.byType(Scrollable).last,
    );

    await tester.pumpAndSettle();

    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(
      fake.calls.where((call) => call == 'play').length,
      greaterThan(playCount),
    );
  });

  testWidgets('Only the active reel video plays while swiping', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const ReelMindApp());
    await tester.pumpAndSettle();

    // First reel: bee video.
    var activePlayers = tester
        .widgetList<ReelVideoPlayer>(find.byType(ReelVideoPlayer))
        .where((player) => player.isActive)
        .toList();

    expect(activePlayers, hasLength(1));
    expect(activePlayers.single.videoUrl, contains('bee.mp4'));
    expect(fake.playingIds, hasLength(1));

    // Swipe to second reel: butterfly video.
    await tester.drag(find.byType(PageView), const Offset(0, -700));
    await tester.pumpAndSettle();

    activePlayers = tester
        .widgetList<ReelVideoPlayer>(find.byType(ReelVideoPlayer))
        .where((player) => player.isActive)
        .toList();

    expect(activePlayers, hasLength(1));
    expect(activePlayers.single.videoUrl, contains('butterfly.mp4'));

    // The previous video must have stopped.
    expect(fake.playingIds, hasLength(1));

    // Third reel has no video.
    await tester.drag(find.byType(PageView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(fake.playingIds, isEmpty);
  });
}
