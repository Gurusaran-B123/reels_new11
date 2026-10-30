import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/gradient_button.dart';

/// Shown whenever the device has no internet.
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key, required this.onRetry, this.checking = false});

  final VoidCallback onRetry;
  final bool checking;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 84),
                const SizedBox(height: 36),
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Brand.purple.withAlpha(isDark ? 50 : 28),
                  ),
                  child: ShaderMask(
                    shaderCallback: (r) => Brand.gradient.createShader(r),
                    child: const Icon(Icons.wifi_off_rounded,
                        size: 60, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Please turn on your internet',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  'Reels new11 needs a connection to load videos.\n'
                  'Turn on Wi-Fi or mobile data and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                checking
                    ? const CircularProgressIndicator(color: Brand.pink)
                    : GradientButton(
                        label: 'Try again',
                        icon: Icons.refresh_rounded,
                        onPressed: onRetry,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
