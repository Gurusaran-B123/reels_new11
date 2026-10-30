import 'package:flutter/material.dart';

import '../models/reel_video.dart';
import 'reel_item.dart';

/// Instagram-style vertical, full-screen swipe pager.
class ReelsPager extends StatefulWidget {
  const ReelsPager({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    this.active = true,
    this.onNearEnd,
  });

  final List<ReelVideo> videos;
  final int initialIndex;

  /// False when the tab/screen hosting the pager is hidden (pauses playback).
  final bool active;

  /// Called when the user gets close to the last loaded reel.
  final VoidCallback? onNearEnd;

  @override
  State<ReelsPager> createState() => _ReelsPagerState();
}

class _ReelsPagerState extends State<ReelsPager> {
  late final PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.videos.length,
      onPageChanged: (i) {
        setState(() => _current = i);
        if (i >= widget.videos.length - 3) widget.onNearEnd?.call();
      },
      itemBuilder: (context, i) {
        final video = widget.videos[i];
        return ReelItem(
          key: ValueKey(video.id),
          video: video,
          isActive: widget.active && i == _current,
        );
      },
    );
  }
}
