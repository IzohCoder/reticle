import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_config.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/app_typography.dart';
import '../../../data/providers/database_provider.dart';

/// Riverpod provider that reads the default filter from DB settings.
final defaultFilterProvider = FutureProvider<String>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.getSetting('default_filter') ?? 'original';
});

/// Riverpod provider that reads the export quality from DB settings.
final exportQualityProvider = FutureProvider<String>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.getSetting('export_quality') ?? 'balanced';
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final defaultFilter = ref.watch(defaultFilterProvider).valueOrNull ?? 'original';
    final exportQuality = ref.watch(exportQualityProvider).valueOrNull ?? 'balanced';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: AppFonts.display,
          ),
        ),
      ),
      body: ListView(
        children: [
          // Pro upgrade banner
          if (enablePaywall)
            _UpgradeBanner(
              onTap: () => context.push('/paywall?reason=settings'),
            ),

          const SizedBox(height: Spacing.sm),

          // Scanning defaults
          _SectionHeader(title: 'Scanning'),
          _SettingsTile(
            icon: PhosphorIconsRegular.funnel,
            title: 'Default filter',
            subtitle: _filterLabel(defaultFilter),
            onTap: () => _showFilterPicker(context, ref, defaultFilter),
          ),
          _SettingsTile(
            icon: PhosphorIconsRegular.fileArrowDown,
            title: 'Export quality',
            subtitle: _qualityLabel(exportQuality),
            onTap: () => _showQualityPicker(context, ref, exportQuality),
          ),

          const SizedBox(height: Spacing.sm),

          // Storage
          _SectionHeader(title: 'Storage'),
          _SettingsTile(
            icon: PhosphorIconsRegular.hardDrives,
            title: 'Storage usage',
            subtitle: 'Manage scanned documents',
            onTap: () => context.push('/settings/storage'),
          ),

          const SizedBox(height: Spacing.sm),

          // Security (Pro)
          _SectionHeader(title: 'Security'),
          _SettingsTile(
            icon: PhosphorIconsRegular.lockKey,
            title: 'App lock',
            subtitle: 'Require biometric or PIN',
            trailing: _ProBadge(),
            onTap: () {
              if (enablePaywall) {
                context.push('/paywall?reason=App+lock+is+a+Pro+feature');
              }
            },
          ),

          const SizedBox(height: Spacing.sm),

          // About
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: PhosphorIconsRegular.shieldCheck,
            title: 'Privacy policy',
            onTap: () => _openUrl(appPrivacyPolicyUrl),
          ),
          _SettingsTile(
            icon: PhosphorIconsRegular.fileText,
            title: 'Terms of service',
            onTap: () => _openUrl(appTermsUrl),
          ),
          _SettingsTile(
            icon: PhosphorIconsRegular.arrowsClockwise,
            title: 'Restore purchases',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restore: mock mode')),
              );
            },
          ),
          _SettingsTile(
            icon: PhosphorIconsRegular.star,
            title: 'Rate Reticle',
            onTap: () => _openUrl(appPlayStoreUrl),
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Center(
              child: Text(
                '$appName v1.0.0',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Filter picker bottom sheet
  // ---------------------------------------------------------------------------
  String _filterLabel(String key) => switch (key) {
        'enhanced' => 'Enhanced',
        'bw' => 'Black & White',
        'grayscale' => 'Grayscale',
        'blueprint' => 'Blueprint',
        _ => 'Original',
      };

  void _showFilterPicker(BuildContext context, WidgetRef ref, String current) {
    final filters = ['original', 'enhanced', 'bw', 'grayscale', 'blueprint'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: Spacing.lg,
            right: Spacing.lg,
            top: Spacing.md,
            bottom: MediaQuery.of(ctx).padding.bottom + Spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32, height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text('Default Filter', style: theme.textTheme.titleMedium),
              const SizedBox(height: Spacing.sm),
              ...filters.map((f) => ListTile(
                    title: Text(_filterLabel(f)),
                    leading: Radio<String>(
                      value: f,
                      groupValue: current,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (v) async {
                        if (v != null) {
                          final db = ref.read(databaseProvider);
                          await db.setSetting('default_filter', v);
                          ref.invalidate(defaultFilterProvider);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                    onTap: () async {
                      final db = ref.read(databaseProvider);
                      await db.setSetting('default_filter', f);
                      ref.invalidate(defaultFilterProvider);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Quality picker bottom sheet
  // ---------------------------------------------------------------------------
  String _qualityLabel(String key) => switch (key) {
        'small' => 'Small (~150 KB/page)',
        'high' => 'High (~600 KB/page)',
        _ => 'Balanced (~300 KB/page)',
      };

  void _showQualityPicker(BuildContext context, WidgetRef ref, String current) {
    final qualities = ['small', 'balanced', 'high'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: Spacing.lg,
            right: Spacing.lg,
            top: Spacing.md,
            bottom: MediaQuery.of(ctx).padding.bottom + Spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32, height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text('Export Quality', style: theme.textTheme.titleMedium),
              const SizedBox(height: Spacing.sm),
              ...qualities.map((q) => ListTile(
                    title: Text(_qualityLabel(q)),
                    leading: Radio<String>(
                      value: q,
                      groupValue: current,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (v) async {
                        if (v != null) {
                          final db = ref.read(databaseProvider);
                          await db.setSetting('export_quality', v);
                          ref.invalidate(exportQualityProvider);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                    onTap: () async {
                      final db = ref.read(databaseProvider);
                      await db.setSetting('export_quality', q);
                      ref.invalidate(exportQualityProvider);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // URL launcher
  // ---------------------------------------------------------------------------
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ---------------------------------------------------------------------------
// Reusable widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Spacing.md, Spacing.md, Spacing.md, Spacing.xs),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            const SizedBox(width: Spacing.xs),
            Icon(
              PhosphorIconsRegular.caretRight,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  const _UpgradeBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            Spacing.md, Spacing.sm, Spacing.md, 0),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: Radii.cardAll,
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIconsFill.crown,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Pro',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Unlimited OCR, folders, and more',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIconsRegular.caretRight,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: Radii.chipAll,
      ),
      child: Text(
        'PRO',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
