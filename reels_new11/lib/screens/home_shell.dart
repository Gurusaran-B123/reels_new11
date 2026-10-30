import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/feed_provider.dart';
import 'feed_screen.dart';
import 'liked_screen.dart';
import 'settings_screen.dart';

/// Bottom navigation: Reels · Liked · Settings.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // FeedProvider is created here (not in main) so it only starts loading
    // once the connectivity gate has confirmed the phone is online.
    return ChangeNotifierProvider(
      create: (_) => FeedProvider(),
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            FeedScreen(active: _index == 0),
            const LikedScreen(),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.play_circle_outline_rounded),
              selectedIcon: Icon(Icons.play_circle_rounded),
              label: 'Reels',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Liked',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
