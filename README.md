# Starting a New App from _template

## Quick Start

```powershell
# 1. Copy the template (replace "my-app" with your app slug)
Copy-Item -Recurse C:\AppDevelopment\_template C:\AppDevelopment\apps\my-app
cd C:\AppDevelopment\apps\my-app

# 2. Rename the package in all files
# Replace com.isaac.pencraft_template with com.isaac.myapp
Get-ChildItem -Recurse -File | Where-Object { $_.Extension -in '.dart','.yaml','.gradle','.kt','.xml' } |
  ForEach-Object { (Get-Content $_.FullName) -replace 'com\.isaac\.pencraft_template', 'com.isaac.myapp' |
  Set-Content $_.FullName }

# 3. Apply the app's identity in ONE place:
#    - lib/config/app_config.dart  (name, flags, keys)
#    - lib/core/design/app_colors.dart  (palette)
#    - lib/core/design/app_typography.dart  (fonts if different)
#    - Replace assets/fonts/ with app-specific fonts if needed

# 4. Initialize git
git init
git add .
git commit -m "init: scaffold from _template"

# 5. Get packages and generate Drift code
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 6. Run on phone
flutter run
```

## Template Structure

```
_template/
  lib/
    app_root.dart           # ProviderScope + MaterialApp.router bootstrap
    config/
      app_config.dart       # Feature flags, keys, identity (EDIT THIS)
      secrets.local.dart.example
    core/
      design/
        tokens.dart         # Spacing, radii, motion, shadows
        app_colors.dart     # Named colour roles (light + dark)
        app_typography.dart # Font families + TextTheme builder
        app_theme.dart      # ThemeData for light and dark
      widgets/
        app_button.dart     # Primary/secondary/ghost/destructive
        app_card.dart       # Paper-like card with optional depth shadow
        app_text_field.dart # Underline-style themed text field
        section_header.dart # Uppercase section label with optional action
        empty_state.dart    # Icon + title + subtitle + action CTA
        error_state.dart    # Error message + retry
        skeleton_loader.dart # Animated skeleton + list tile skeleton
        bottom_sheet_helper.dart # showAppBottomSheet() + drag handle
        scaffold_shell.dart # StatefulNavigationShell wrapper
    data/
      database.dart         # Drift schema: all 7 tables
      providers/
        database_provider.dart
    services/
      revenue_cat_service.dart  # Mock-safe IAP wrapper
      admob_service.dart        # TEST-id-safe banner ads + AppBannerAd widget
      settings_service.dart     # SharedPreferences notifier (theme, onboarding, Pro mock)
    features/
      paywall/
        paywall_screen.dart     # Configurable paywall with 3 pricing options
  assets/
    fonts/                  # DMSerifDisplay, Inter, NotoSans (add before first run)
  pubspec.yaml              # All packages pinned
```

## Standard Package Versions

| Package | Version |
|---------|---------|
| flutter_riverpod | ^2.6.1 |
| go_router | ^14.6.2 |
| drift | ^2.21.0 |
| drift_flutter | ^0.2.2 |
| sqlite3_flutter_libs | ^0.5.24 |
| purchases_flutter | ^8.2.2 |
| google_mobile_ads | ^5.2.0 |
| shared_preferences | ^2.3.3 |
| intl | ^0.19.0 |
| share_plus | ^10.1.2 |
| path_provider | ^2.1.5 |
| pdf | ^3.11.1 |
| printing | ^5.14.1 |
| image_picker | ^1.1.2 |
| image_cropper | ^7.1.0 |
| signature | ^5.4.0 |
| file_picker | ^8.1.4 |
| open_filex | ^4.5.1 |
| phosphor_flutter | ^2.1.0 |

## Design Principles (binding for all 20 apps)

1. Re-skin identity in `app_colors.dart` + `app_config.dart` only — never scatter hex values
2. 8pt spacing grid via `Spacing.*` constants
3. Money stored as integer minor units — never double
4. Tabular figures on all monetary displays: `style.tabular`
5. No shadows on cards — use `colorOutline` borders
6. `flutter analyze` must be clean before every commit
7. Each milestone ends with a git commit + BUILD_LOG.md entry
