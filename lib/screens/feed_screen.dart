import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../providers/feed_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/reels_pager.dart';

/// Home tab: full-screen reels with a search bar floating on top.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.active});

  /// False while another tab is shown (pauses the video).
  final bool active;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final TextEditingController _search = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(String text) {
    _focus.unfocus();
    context.read<FeedProvider>().loadInitial(search: text);
  }

  void _chip(String label) {
    _search.text = label;
    _submit(label);
  }

  void _clear() {
    _search.clear();
    _focus.unfocus();
    context.read<FeedProvider>().loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();

    Widget body;
    if (feed.videos.isEmpty && feed.loading) {
      body = const Center(child: CircularProgressIndicator(color: Brand.pink));
    } else if (feed.videos.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.video_library_outlined,
                  color: Colors.white54, size: 56),
              const SizedBox(height: 14),
              Text(
                feed.error ?? 'No videos found.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: 'Try again',
                icon: Icons.refresh_rounded,
                onPressed: () =>
                    context.read<FeedProvider>().loadInitial(search: feed.query),
              ),
            ],
          ),
        ),
      );
    } else {
      body = ReelsPager(
        key: ValueKey(feed.session),
        videos: feed.videos,
        active: widget.active,
        onNearEnd: feed.loadMore,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand, // reels fill the whole screen
        children: [
          Positioned.fill(child: body),
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SearchBar(
                  controller: _search,
                  focusNode: _focus,
                  onSubmitted: _submit,
                  onClear: _clear,
                ),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: AppConfig.quickChips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final label = AppConfig.quickChips[i];
                      final selected =
                          feed.query?.toLowerCase() == label.toLowerCase();
                      return GestureDetector(
                        onTap: () => _chip(label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: selected ? Brand.gradientSoft : null,
                            color: selected ? null : Colors.black.withAlpha(110),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withAlpha(45)),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(120),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Brand.pink.withAlpha(150), width: 1.2),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          style: const TextStyle(color: Colors.white),
          cursorColor: Brand.pink,
          decoration: InputDecoration(
            hintText: 'Search videos…',
            hintStyle: const TextStyle(color: Colors.white60),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) => value.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: onClear,
                    ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
