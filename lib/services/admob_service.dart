import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// AdMob service — stubbed for M1. Real ads wired in M3.
class AdMobService {
  static Future<void> initialize() async {
    // Stub: no-op in M1
  }
}

/// Stub banner ad widget. Real implementation in M3.
class AppBannerAd extends StatelessWidget {
  const AppBannerAd({super.key, this.isPro = false});

  final bool isPro;

  @override
  Widget build(BuildContext context) {
    if (!enableAds || isPro) return const SizedBox.shrink();
    // Placeholder: thin banner slot
    return Container(
      height: 50,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Text(
          'Ad space (test)',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
