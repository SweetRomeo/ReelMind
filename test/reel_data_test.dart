import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reelmind/data/reel_data.dart';
import 'package:reelmind/l10n/app_localizations.dart';
import 'package:reelmind/models/video_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('All three lessons have bundled videos in each language', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets().toSet();
    for (final locale in AppLocalizations.supportedLocales) {
      final reels = buildReels(await AppLocalizations.delegate.load(locale));
      expect(reels, hasLength(3));
      for (final reel in reels) {
        expect(reel.videoSource?.type, VideoSourceType.asset);
        expect(assets, contains(reel.videoSource!.location));
      }
    }
  });

  test(
    'Reel content and narrated videos follow the selected language',
    () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final tr = await AppLocalizations.delegate.load(const Locale('tr'));

      final englishReels = buildReels(en);
      final turkishReels = buildReels(tr);

      expect(englishReels[0].title, en.skyTitle);
      expect(turkishReels[0].title, tr.skyTitle);
      expect(
        englishReels[0].videoSource?.location,
        'assets/videos/sky_color_en_001.mp4',
      );
      expect(
        turkishReels[0].videoSource?.location,
        'assets/videos/sky_color_tr_001.mp4',
      );

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
      expect(englishReels[2].title, en.interestTitle);
      expect(turkishReels[2].title, tr.interestTitle);
      expect(
        englishReels[2].videoSource?.location,
        'assets/videos/compound_interest_en_001.mp4',
      );
      expect(
        turkishReels[2].videoSource?.location,
        'assets/videos/compound_interest_tr_001.mp4',
      );
    },
  );
}
