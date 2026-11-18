# ReelMind API pilot / Issue 17

## Included videos

- assets/videos/api_intro_tr_001.mp4 — Turkish on-screen explanations
- assets/videos/api_intro_en_001.mp4 — English on-screen explanations
- 1080 × 1920, 9:16, 25 seconds, 24 fps, H.264 yuv420p + AAC mono
- No voice narration. Original synthesized transition chimes at scene changes.
  The full lesson is understandable with audio muted.
- 22 °C is illustrative example data, not a live weather reading.

## Scenes

0–6 s: where a weather app gets its data.
6–12 s: the app sends a request to the weather service's API.
12–19 s: the service returns data; the app displays the temperature.
19–25 s: API as an interface with defined communication rules; data exchange recap.

The existing API title, description and API quiz match this lesson in TR and EN.
Keep the science and finance cards without unrelated video samples.

## Origin and reuse

The diagrams, animation and audio were created programmatically for this pilot;
no stock footage, third-party video clips, logos or music were included.
The included source reproduces both language variants. Text is rendered with
DejaVu Sans, an open font; no font binary is bundled. Check the font's license
if redistributing the font itself.

## Reproduce

Requires Python 3, Pillow, ffmpeg with libx264 and the DejaVu Sans font files.
From this package's root:

    python -m pip install Pillow
    python tools/render_api_reel.py --font-dir PATH_TO_DEJAVU_FONTS

Use --preview-only to generate PNG storyboard previews. Copy final MP4 files to
the app's assets/videos directory and register both exact paths in pubspec.yaml.
Select the Turkish or English video from buildReels using l10n.localeName.
Restore the video_source.dart import when adding VideoSource.asset.

## Framing and verification

Essential content is between y=275 and y=1130 on the 1080×1920 canvas; the lower
area is intentionally left quiet for the ReelMind category, title, description,
quiz and swipe hint. Retain BoxFit.contain for the first device check.
This positioning was designed against the current Flutter layout source.
It has not been validated in the running app and cannot guarantee every viewport.
Check a small phone, the Android emulator/physical phone and Chrome.

Verify autoplay only on the active reel, swipe pause, quiz pause/resume,
mute/unmute (short chimes), replay, no clipped captions, and TR/EN video selection
when switching language while the API reel is visible. The player currently uses
a source-based key, which should recreate it when the language-specific source changes.

Update the existing reel-data tests: science has no video, API uses the local
asset matching the selected language, and finance has no video. The existing
expectations for the C++ and butterfly samples should be replaced.
Run flutter analyze and flutter test. This asset package has not run those checks.

Media verification performed: ffprobe dimensions, 25-second duration, H.264/AAC
streams, and full ffmpeg decoding. This is not Android/Chrome playback validation.
