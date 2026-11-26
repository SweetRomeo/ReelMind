import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../l10n/app_localizations.dart';
import '../models/video_source.dart';

enum _VideoError { load, playback, volume }

class ReelVideoPlayer extends StatefulWidget {
  final VideoSource source;
  final bool isActive;
  final bool? muted;
  final ValueChanged<bool>? onMuteChanged;
  final int replayRequest;
  final ValueChanged<bool>? onCompletionChanged;

  const ReelVideoPlayer({
    super.key,
    required this.source,
    required this.isActive,
    this.muted,
    this.onMuteChanged,
    this.replayRequest = 0,
    this.onCompletionChanged,
  }) : assert((muted == null) == (onMuteChanged == null));

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late final VideoPlayerController _controller;

  bool _ready = false;
  bool _localMuted = true;
  bool get _muted => widget.muted ?? _localMuted;
  bool _completed = false;
  _VideoError? _error;

  @override
  void initState() {
    super.initState();

    final source = widget.source;
    _controller = switch (source.type) {
      VideoSourceType.asset => VideoPlayerController.asset(source.location),
      VideoSourceType.network => VideoPlayerController.networkUrl(
        Uri.parse(source.location),
      ),
    };

    _controller.addListener(_onVideoChanged);
    _initializeVideo();
  }

  void _onVideoChanged() {
    final completed = _controller.value.isCompleted;
    if (completed == _completed) return;
    _completed = completed;
    widget.onCompletionChanged?.call(completed);
  }

  @override
  void didUpdateWidget(covariant ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.replayRequest != widget.replayRequest) {
      _replay();
    } else if (oldWidget.isActive != widget.isActive) {
      _syncPlayback();
    } else if (_ready && widget.isActive && oldWidget.muted != widget.muted) {
      _applyVolume();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();

      if (!mounted) return;

      await _controller.setVolume(0);

      if (!mounted) return;

      setState(() {
        _ready = true;
      });

      await _syncPlayback();
    } catch (e) {
      debugPrint('Video initialization error: $e');

      if (mounted) {
        setState(() => _error = _VideoError.load);
      }
    }
  }

  Future<void> _syncPlayback() async {
    if (!_ready || !mounted) return;

    try {
      if (widget.isActive) {
        await _applyVolume();
        if (!mounted || !widget.isActive || _completed || _error != null) {
          return;
        }
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

  Future<void> _replay() async {
    if (!_ready || !widget.isActive) return;
    try {
      await _controller.seekTo(Duration.zero);
      if (!mounted || !widget.isActive) return;
      await _applyVolume();
      if (mounted && widget.isActive && _error == null) {
        await _controller.play();
      }
    } catch (_) {
      if (mounted) setState(() => _error = _VideoError.playback);
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
        setState(() => _error = _VideoError.playback);
      }
    }
  }

  void _toggleMute() {
    if (!widget.isActive) return;
    if (widget.onMuteChanged case final onChanged?) {
      onChanged(!_muted);
    } else {
      setState(() => _localMuted = !_localMuted);
      _applyVolume();
    }
  }

  Future<void> _applyVolume() async {
    final volume = _muted ? 0.0 : 1.0;
    if (_controller.value.volume == volume) return;
    try {
      await _controller.setVolume(volume);
    } catch (_) {
      if (mounted) {
        setState(() => _error = _VideoError.volume);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_error case final error?) {
      return Center(
        child: Text(switch (error) {
          _VideoError.load => l10n.videoLoadFailed,
          _VideoError.playback => l10n.videoPlaybackFailed,
          _VideoError.volume => l10n.videoVolumeFailed,
        }),
      );
    }

    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.contain,
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
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => IconButton(
                    tooltip: value.isPlaying ? l10n.pauseVideo : l10n.playVideo,
                    onPressed: _togglePlayback,
                    icon: Icon(
                      value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: _muted ? l10n.unmuteVideo : l10n.muteVideo,
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
