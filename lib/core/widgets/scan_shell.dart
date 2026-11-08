import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Main scaffold with 2 tabs (Library, Settings) and a centered scan FAB.
class ScanShell extends StatelessWidget {
  const ScanShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.folderOpen),
              selectedIcon: Icon(PhosphorIconsFill.folderOpen),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.gearSix),
              selectedIcon: Icon(PhosphorIconsFill.gearSix),
              label: 'Settings',
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () => context.push('/camera'),
          elevation: 6,
          backgroundColor: accent,
          shape: const CircleBorder(),
          child: const Icon(
            PhosphorIconsBold.scan,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
