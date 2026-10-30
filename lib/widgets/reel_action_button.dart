import 'package:flutter/material.dart';

/// Round translucent button with a small label, used in the reel side bar.
class ReelActionButton extends StatelessWidget {
  const ReelActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
    this.progress,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  /// 0..1 download progress (null = indeterminate while [busy]).
  final double? progress;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(95),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(40)),
              ),
              child: busy
                  ? Padding(
                      padding: const EdgeInsets.all(13),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        value: progress,
                        color: Colors.white,
                      ),
                    )
                  : Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
