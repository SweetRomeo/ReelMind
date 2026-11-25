# Narrated lessons

The science, API and compound-interest reels each have a Turkish and an English MP4 in `assets/videos`. Each file contains a 25-second portrait animation (1080 × 1920, 24 fps, H.264) and a mono AAC narration track. The app selects the file that matches its language. The player starts muted. Use the speaker button to listen.

| Lesson | Scenes |
| --- | --- |
| Why is the sky blue? | 0–8 s shows the colors in sunlight through a prism. 8–17 s compares scattering of blue and red light by air molecules. 17–25 s follows scattered blue light to the viewer's eye. |
| What is an API? | 0–6 s introduces a weather app. 6–12 s sends a request for Istanbul's temperature. 12–19 s returns and displays an example value of 22 °C. 19–25 s recaps the rules for exchanging data. |
| What is compound interest? | 0–6 s represents a 1,000 TL deposit with 100 squares. 6–14 s adds 100 TL at an illustrative 10% annual rate. 14–25 s shows the second year's 100 TL on the deposit and 10 TL on the first year's interest, bringing the balance to 1,210 TL. |

## Reproduce the videos

The drawings and scripts are original to ReelMind. The bundled narration was synthesized locally with Microsoft Tolga (Turkish) and Microsoft Zira (US English). Both languages have on-screen explanations. Edit the spoken lines and scene start times in `tools/reel_narration.json`.

From the project root, install Pillow and use FFmpeg with libx264. The renderer also accepts the executable bundled with the Python package `imageio-ffmpeg`. On Windows, install the Turkish and US English speech voices and run these commands in PowerShell.

```powershell
python -m pip install Pillow imageio-ffmpeg
./tools/synthesize_reel_voice.ps1
python tools/render_api_reel.py --lesson all
```

Speech synthesis writes one WAV per scene under `build/reel-voice`. The renderer aligns each clip with its scene, checks that it fits, and normalizes the assembled narration before encoding. Use `--voice-dir PATH` for recorded narration with the same filenames, such as `sky_tr_0.wav` for the first Turkish sky scene. Only the final MP4 files are bundled in the app.

Use `--lesson sky`, `--lesson api`, or `--lesson interest` to render a single lesson. The existing `--lesson both` option renders the sky and API pair. Add `--preview-only` to write phone-size storyboard frames under `build/reel-previews`. The default typeface is Arial on Windows and DejaVu Sans on Linux. Use `--font-dir PATH` to select a directory containing `DejaVuSans.ttf` and `DejaVuSans-Bold.ttf`.
