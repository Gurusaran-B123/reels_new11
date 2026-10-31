import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../config/app_config.dart';
import '../models/reel_video.dart';
import '../providers/app_providers.dart';
import '../services/download_service.dart';
import '../theme/app_theme.dart';
import 'reel_action_button.dart';

/// One full-screen reel: video, side buttons (like, mute, play/pause, share,
/// download), author info and a progress bar.
class ReelItem extends StatefulWidget {
  const ReelItem({super.key, required this.video, required this.isActive});

  final ReelVideo video;

  /// True only for the reel currently on screen (and when its tab is visible).
  final bool isActive;

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;
  bool _userPaused = false;
  bool _showHeart = false;
  bool _downloading = false;
  double? _progress;
  Timer? _heartTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final muted = context.read<MuteProvider>().muted;
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.url),
    );
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted) return;
      await controller.setLooping(true);
      await controller.setVolume(muted ? 0 : 1);
      if (widget.isActive) await controller.play();
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void didUpdateWidget(covariant ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive == widget.isActive) return;
    final c = _controller;
    if (c == null || !_ready) return;
    if (widget.isActive) {
      setState(() => _userPaused = false);
      c.setVolume(context.read<MuteProvider>().muted ? 0.0 : 1.0);
      c.play();
    } else {
      c.pause();
    }
  }

  @override
  void dispose() {
    _heartTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _retry() {
    _controller?.dispose();
    setState(() {
      _controller = null;
      _ready = false;
      _failed = false;
    });
    _init();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !_ready) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
        _userPaused = true;
      } else {
        c.play();
        _userPaused = false;
      }
    });
  }

  void _doubleTapLike() {
    final likes = context.read<LikesProvider>();
    if (!likes.isLiked(widget.video.id)) likes.toggle(widget.video);
    _heartTimer?.cancel();
    setState(() => _showHeart = true);
    _heartTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  Future<void> _share() async {
    final v = widget.video;
    await Share.share(
      'Watch this reel by ${v.author} 🎬\n${v.pageUrl}\n\n'
      'Shared via ${AppConfig.appName} (${AppConfig.brand})',
      subject: AppConfig.appName,
    );
  }

  Future<void> _download() async {
    if (_downloading) return;
    setState(() {
      _downloading = true;
      _progress = null;
    });
    _toast('Downloading…');

    final ok = await DownloadService.saveToGallery(
      widget.video,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
    );

    if (!mounted) return;
    setState(() {
      _downloading = false;
      _progress = null;
    });
    _toast(ok
        ? 'Saved to gallery ✓'
        : 'Download failed. Check storage permission & internet.');
  }

  void _toast(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
      );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final muted = context.watch<MuteProvider>().muted;
    final liked = context.watch<LikesProvider>().isLiked(widget.video.id);
    final c = _controller;
    if (c != null && _ready) c.setVolume(muted ? 0.0 : 1.0);
    final landscape = c != null &&
        _ready &&
        c.value.size.width > 0 &&
        c.value.size.width >= c.value.size.height;

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail shown until the video is ready.
          if (!_ready && widget.video.thumb.isNotEmpty)
            Image.network(
              widget.video.thumb,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),

          // Landscape clips: blurred copy of the thumbnail fills the screen,
          // the video itself is shown in full on top (no heavy zoom/crop).
          if (_ready && c != null && landscape && widget.video.thumb.isNotEmpty)
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: Image.network(
                  widget.video.thumb,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          if (_ready && c != null && landscape)
            Positioned.fill(
              child: ColoredBox(color: Colors.black.withAlpha(110)),
            ),

          // Video: portrait fills the screen, landscape is shown in full.
          if (_ready && c != null)
            ClipRect(
              child: FittedBox(
                fit: landscape ? BoxFit.contain : BoxFit.cover,
                child: SizedBox(
                  width: c.value.size.width,
                  height: c.value.size.height,
                  child: VideoPlayer(c),
                ),
              ),
            ),

          // Loading / error overlay.
          if (!_ready && !_failed)
            const Center(
              child: CircularProgressIndicator(color: Brand.pink),
            ),
          if (_failed)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white70, size: 44),
                  const SizedBox(height: 8),
                  const Text(
                    'Could not play this video',
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(onPressed: _retry, child: const Text('Retry')),
                ],
              ),
            ),

          // Readability gradients.
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 260,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xCC000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),

          // Tap = play/pause, double-tap = like.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _togglePlay,
              onDoubleTap: _doubleTapLike,
            ),
          ),

          // Big paused icon.
          if (_userPaused)
            const Center(
              child: IgnorePointer(
                child: Icon(Icons.play_arrow_rounded,
                    color: Colors.white70, size: 96),
              ),
            ),

          // Double-tap heart burst.
          Center(
            child: IgnorePointer(
              child: AnimatedScale(
                scale: _showHeart ? 1 : 0.3,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: _showHeart ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: ShaderMask(
                    shaderCallback: (r) => Brand.gradient.createShader(r),
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 120),
                  ),
                ),
              ),
            ),
          ),

          // Side buttons.
          Positioned(
            right: 10,
            bottom: 44,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReelActionButton(
                  icon: liked ? Icons.favorite : Icons.favorite_border,
                  label: liked ? 'Liked' : 'Like',
                  color: liked ? Brand.pink : Colors.white,
                  onTap: () => context.read<LikesProvider>().toggle(widget.video),
                ),
                ReelActionButton(
                  icon: muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  label: muted ? 'Unmute' : 'Mute',
                  onTap: () => context.read<MuteProvider>().toggle(),
                ),
                ReelActionButton(
                  icon: _userPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  label: _userPaused ? 'Play' : 'Pause',
                  onTap: _togglePlay,
                ),
                ReelActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: _share,
                ),
                ReelActionButton(
                  icon: Icons.download_rounded,
                  label: 'Save',
                  busy: _downloading,
                  progress: _progress,
                  onTap: _download,
                ),
              ],
            ),
          ),

          // Author + duration.
          Positioned(
            left: 16,
            right: 84,
            bottom: 26,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    gradient: Brand.gradient,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '@${widget.video.author}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                    ),
                  ),
                ),
                if (widget.video.duration > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(110),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _formatDuration(widget.video.duration),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),

          // Progress bar.
          if (_ready && c != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                c,
                allowScrubbing: true,
                padding: EdgeInsets.zero,
                colors: const VideoProgressColors(
                  playedColor: Brand.pink,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
