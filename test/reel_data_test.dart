import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reelmind/data/reel_data.dart';
import 'package:reelmind/l10n/app_localizations.dart';
import 'package:reelmind/models/video_source.dart';

void main() {
  test('Builds three reels with a local API video', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    final reels = buildReels(l10n);

    expect(reels, hasLength(3));
    expect(reels[0].videoSource, isNull);
    expect(reels[2].videoSource, isNull);

    expect(reels[1].videoSource?.type, VideoSourceType.asset);
    expect(
      reels[1].videoSource?.location,
      'assets/videos/api_intro_en_001.mp4',
    );
  });

  test('Reel content and API video follow the selected language', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final tr = await AppLocalizations.delegate.load(const Locale('tr'));

    final englishReels = buildReels(en);
    final turkishReels = buildReels(tr);

    expect(englishReels[0].title, en.skyTitle);
    expect(turkishReels[0].title, tr.skyTitle);

    expect(englishReels[1].title, en.apiTitle);
    expect(turkishReels[1].title, tr.apiTitle);
    expect(englishReels[1].description, en.apiDescription);
    expect(turkishReels[1].description, tr.apiDescription);

    expect(
      englishReels[1].videoSource?.location,
      'assets/videos/api_intro_en_001.mp4',
    );
    expect(
      turkishReels[1].videoSource?.location,
      'assets/videos/api_intro_tr_001.mp4',
    );
  });
}
