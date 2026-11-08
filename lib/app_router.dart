import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/library/screens/library_screen.dart';
import 'features/camera/screens/camera_screen.dart';
import 'features/editor/screens/editor_screen.dart';
import 'features/document/screens/document_detail_screen.dart';
import 'features/ocr/screens/ocr_text_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/paywall/paywall_screen.dart';
import 'core/widgets/scan_shell.dart';

// ---------------------------------------------------------------------------
// Route paths
// ---------------------------------------------------------------------------
abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String library = '/library';
  static const String camera = '/camera';
  static const String editor = '/editor';
  static const String documentDetail = '/library/:id';
  static const String ocrText = '/library/:id/ocr';
  static const String settings = '/settings';
  static const String paywall = '/paywall';
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.library,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // Main shell: Library + Settings tabs with central FAB
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => ScanShell(navigationShell: shell),
        branches: [
          // Tab 0: Library
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.library,
                builder: (_, __) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => DocumentDetailScreen(
                      documentId:
                          int.parse(state.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'ocr',
                        builder: (_, state) => OcrTextScreen(
                          documentId:
                              int.parse(state.pathParameters['id']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Tab 1: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen routes (outside shell)
      GoRoute(
        path: AppRoutes.camera,
        builder: (_, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'document';
          return CameraScreen(mode: mode);
        },
      ),
      GoRoute(
        path: AppRoutes.editor,
        builder: (_, state) {
          final docId = int.tryParse(
              state.uri.queryParameters['docId'] ?? '');
          return EditorScreen(documentId: docId);
        },
      ),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (_, state) => PaywallScreen(
          reason: state.uri.queryParameters['reason'],
        ),
      ),
    ],
  );
});
