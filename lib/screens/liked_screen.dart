import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reel_video.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/reels_pager.dart';

/// Grid of liked videos (stored locally in Hive).
class LikedScreen extends StatelessWidget {
  const LikedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videos = context.watch<LikesProvider>().videos;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Liked videos')),
      body: videos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (r) => Brand.gradient.createShader(r),
                      child: const Icon(Icons.favorite_rounded,
                          size: 84, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No liked videos yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the heart (or double-tap a reel) to save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 9 / 14,
              ),
              itemCount: videos.length,
              itemBuilder: (context, i) => _LikedTile(
                video: videos[i],
                onTap: () {
                  // Snapshot so un-liking inside the player doesn't shift pages.
                  final snapshot = List<ReelVideo>.of(videos);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          _LikedPlayerScreen(videos: snapshot, initialIndex: i),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _LikedTile extends StatelessWidget {
  const _LikedTile({required this.video, required this.onTap});

  final ReelVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(gradient: Brand.gradientSoft),
            ),
            if (video.thumb.isNotEmpty)
              Image.network(
                video.thumb,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Color(0xCC000000), Color(0x00000000)],
                ),
              ),
            ),
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.favorite, color: Brand.pink, size: 22),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                '@${video.author}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const Center(
              child: Icon(Icons.play_circle_fill_rounded,
                  color: Colors.white70, size: 40),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikedPlayerScreen extends StatelessWidget {
  const _LikedPlayerScreen({required this.videos, required this.initialIndex});

  final List<ReelVideo> videos;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: ReelsPager(videos: videos, initialIndex: initialIndex),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withAlpha(110),
                ),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
