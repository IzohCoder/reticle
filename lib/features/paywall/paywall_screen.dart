import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import '../../core/design/tokens.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key, this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reticle Pro'),
        leading: const CloseButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (reason != null) ...[
                Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: Radii.cardAll,
                  ),
                  child: Text(reason!,
                      style: theme.textTheme.bodyMedium),
                ),
                const SizedBox(height: Spacing.lg),
              ],
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsFill.crown,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Reticle Pro',
                style: theme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Unlock the full precision toolkit.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),
              _FeatureRow(
                icon: PhosphorIconsRegular.textAa,
                label: 'Unlimited OCR and searchable PDFs',
              ),
              _FeatureRow(
                icon: PhosphorIconsRegular.folders,
                label: 'Unlimited folders',
              ),
              _FeatureRow(
                icon: PhosphorIconsRegular.lockKey,
                label: 'Password-protected PDF export',
              ),
              _FeatureRow(
                icon: PhosphorIconsRegular.fingerprint,
                label: 'App lock with biometric or PIN',
              ),
              _FeatureRow(
                icon: PhosphorIconsRegular.signature,
                label: 'Signature placement on pages',
              ),
              _FeatureRow(
                icon: PhosphorIconsRegular.export,
                label: 'Batch export',
              ),
              _FeatureRow(
                icon: PhosphorIconsRegular.prohibit,
                label: 'No ads, ever',
              ),
              const SizedBox(height: Spacing.xl),
              _PriceOption(
                label: 'Annual',
                price: 'KES 1,999 / year',
                badge: '7-day free trial',
                onTap: () => _purchase(context, 'annual'),
                isPrimary: true,
              ),
              const SizedBox(height: Spacing.sm),
              _PriceOption(
                label: 'Monthly',
                price: 'KES 249 / month',
                onTap: () => _purchase(context, 'monthly'),
              ),
              const SizedBox(height: Spacing.sm),
              _PriceOption(
                label: 'Lifetime',
                price: 'KES 3,999 once',
                onTap: () => _purchase(context, 'lifetime'),
              ),
              const SizedBox(height: Spacing.xl),
              Text(
                'Subscription auto-renews. Cancel anytime in Google Play. '
                'Price shown before purchase.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.sm),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Restore: mock mode')),
                  );
                },
                child: const Text('Restore purchases'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _purchase(BuildContext context, String plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Purchase flow: $plan (mock mode)')),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _PriceOption extends StatelessWidget {
  const _PriceOption({
    required this.label,
    required this.price,
    required this.onTap,
    this.badge,
    this.isPrimary = false,
  });
  final String label;
  final String price;
  final VoidCallback onTap;
  final String? badge;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onTap,
        child: Column(
          children: [
            if (badge != null)
              Text(badge!,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onPrimary)),
            Text('$label · $price'),
          ],
        ),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      child: Text('$label · $price'),
    );
  }
}
