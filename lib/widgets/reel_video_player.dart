import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const ReelVideoPlayer({super.key, required this.videoUrl});

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late final VideoPlayerController _controller;

  bool _ready = false;
  bool _muted = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();

      if (!mounted) return;

      await _controller.setLooping(true);
      await _controller.setVolume(0);

      if (mounted) {
        setState(() => _ready = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Video yüklenemedi');
      }
    }
  }

  Future<void> _togglePlayback() async {
    try {
      if (_controller.value.isPlaying) {
        await _controller.pause();
      } else {
        await _controller.play();
      }

      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Video oynatılamadı');
      }
    }
  }

  Future<void> _toggleMute() async {
    final nextMuted = !_muted;

    try {
      await _controller.setVolume(nextMuted ? 0 : 1);

      if (mounted) {
        setState(() => _muted = nextMuted);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Ses ayarlanamadı');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
        Positioned(
          top: 112,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                IconButton(
                  tooltip: 'Play or pause',
                  onPressed: _togglePlayback,
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  tooltip: 'Mute or unmute',
                  onPressed: _toggleMute,
                  icon: Icon(
                    _muted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
