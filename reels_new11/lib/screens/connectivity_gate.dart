import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'no_internet_screen.dart';

/// Shows [child] only while the phone is online (connectivity_plus + a real
/// DNS lookup, so "Wi-Fi without internet" is detected too).
class ConnectivityGate extends StatefulWidget {
  const ConnectivityGate({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends State<ConnectivityGate> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool? _online; // null = first check running
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _check();
    _sub = Connectivity().onConnectivityChanged.listen((_) => _check());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    if (_checking) return;
    if (mounted) setState(() => _checking = true);

    var online = false;
    try {
      final results = await Connectivity().checkConnectivity();
      if (results.any((r) => r != ConnectivityResult.none)) {
        try {
          final lookup = await InternetAddress.lookup('api.pexels.com')
              .timeout(const Duration(seconds: 5));
          online = lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
        } catch (_) {
          online = false;
        }
      }
    } catch (_) {
      online = false;
    }

    if (!mounted) return;
    setState(() {
      _online = online;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_online == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(size: 110),
              SizedBox(height: 28),
              CircularProgressIndicator(color: Brand.pink),
            ],
          ),
        ),
      );
    }
    if (_online == false) {
      return NoInternetScreen(onRetry: _check, checking: _checking);
    }
    return widget.child;
  }
}
