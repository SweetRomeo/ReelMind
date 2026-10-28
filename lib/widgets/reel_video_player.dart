import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isActive;

  const ReelVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.isActive,
  });

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

  @override
  void didUpdateWidget(covariant ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      _syncPlayback();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();

      if (!mounted) return;

      await _controller.setLooping(true);
      await _controller.setVolume(0);

      if (!mounted) return;

      setState(() {
        _ready = true;
      });

      await _syncPlayback();
    } catch (e) {
      debugPrint('Video initialization error: $e');

      if (mounted) {
        setState(() => _error = 'Video yüklenemedi');
      }
    }
  }

  Future<void> _syncPlayback() async {
    if (!_ready || !mounted) return;

    try {
      if (widget.isActive) {
        await _controller.setVolume(_muted ? 0 : 1);
        await _controller.play();
      } else {
        await _controller.pause();
      }

      debugPrint(
        'VIDEO: active=${widget.isActive}, '
        'playing=${_controller.value.isPlaying}',
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      debugPrint('VIDEO AUTOPLAY ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
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
