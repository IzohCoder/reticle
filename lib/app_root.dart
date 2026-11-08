import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/design/app_theme.dart';
import 'config/app_config.dart';
import 'services/admob_service.dart';
import 'services/revenue_cat_service.dart';

/// Root widget for Reticle.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.router});

  final RouterConfig<Object> router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: appName,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.dark, // Dark-primary: the Precision Darkroom
    );
  }
}

Future<void> bootstrapApp({required Widget Function() appBuilder}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await RevenueCatService.configure();
  await AdMobService.initialize();
  runApp(
    ProviderScope(
      child: appBuilder(),
    ),
  );
}
