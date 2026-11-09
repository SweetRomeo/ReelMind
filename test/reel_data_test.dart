import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reelmind/data/reel_data.dart';
import 'package:reelmind/l10n/app_localizations.dart';
import 'package:reelmind/models/video_source.dart';

void main() {
  test('Builds three reels with correct video sources', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    final reels = buildReels(l10n);

    expect(reels, hasLength(3));

    expect(reels[0].videoSource?.type, VideoSourceType.asset);
    expect(
      reels[0].videoSource?.location,
      'assets/videos/cpp_interview_001.mp4',
    );

    expect(reels[1].videoSource?.type, VideoSourceType.network);
    expect(reels[1].videoSource?.location, endsWith('butterfly.mp4'));

    expect(reels[2].videoSource, isNull);
  });

  test('Reel content follows the selected language', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final tr = await AppLocalizations.delegate.load(const Locale('tr'));

    final englishReels = buildReels(en);
    final turkishReels = buildReels(tr);

    expect(englishReels[0].title, en.skyTitle);
    expect(turkishReels[0].title, tr.skyTitle);

    expect(englishReels[1].description, en.apiDescription);
    expect(turkishReels[1].description, tr.apiDescription);

    expect(turkishReels[0].title, isNot(englishReels[0].title));

    // Changing language must not change video sources.
    expect(turkishReels[0].videoSource, englishReels[0].videoSource);
  });
}
