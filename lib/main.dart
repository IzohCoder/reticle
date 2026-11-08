import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_root.dart';
import 'app_router.dart';
import 'data/providers/database_provider.dart';
import 'data/seed_data.dart';

void main() {
  bootstrapApp(
    appBuilder: () => _AppBootstrap(),
  );
}

class _AppBootstrap extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<_AppBootstrap> {
  @override
  void initState() {
    super.initState();
    _seedOnFirstLaunch();
  }

  Future<void> _seedOnFirstLaunch() async {
    final db = ref.read(databaseProvider);
    await seedDatabase(db);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return AppRoot(router: router);
  }
}
