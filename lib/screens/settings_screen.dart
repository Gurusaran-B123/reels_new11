import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).colorScheme.surface;
    final subtle = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Brand header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26),
            decoration: BoxDecoration(
              gradient: Brand.gradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Brand.purple.withAlpha(90),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Column(
              children: [
                AppLogo(size: 76),
                SizedBox(height: 12),
                Text(
                  AppConfig.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AppConfig.brand,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          _SectionLabel('APPEARANCE', color: subtle),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_rounded),
              title: const Text('Dark mode',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Saved on this device', style: TextStyle(color: subtle)),
              value: theme.isDark,
              onChanged: (v) => context.read<ThemeProvider>().setDark(v),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
          ),
          const SizedBox(height: 22),

          _SectionLabel('ABOUT', color: subtle),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const _InfoTile(
                  icon: Icons.rocket_launch_rounded,
                  title: AppConfig.brand,
                ),
                const Divider(height: 1, indent: 56),
                const _InfoTile(
                  icon: Icons.code_rounded,
                  title: AppConfig.developer,
                ),
                const Divider(height: 1, indent: 56),
                _InfoTile(
                  icon: Icons.info_outline_rounded,
                  title: 'App version',
                  trailing: AppConfig.version,
                  subtleColor: subtle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              'Videos provided by Pixabay',
              style: TextStyle(color: subtle, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 6, bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.subtleColor,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final Color? subtleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ShaderMask(
        shaderCallback: (r) => Brand.gradient.createShader(r),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: trailing == null
          ? null
          : Text(trailing!,
              style: TextStyle(color: subtleColor, fontWeight: FontWeight.w600)),
    );
  }
}
