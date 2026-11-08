# Reticle — Build Log

## Phase 1: Research & Spec
| Timestamp | Phase | Done | Decisions & Defaults | Open Issues | Next Step |
|-----------|-------|------|---------------------|-------------|-----------|
| 2026-11-08 15:03 | Phase 1 | SPEC.md written | Name: Reticle (com.isaac.reticle). Accent: Signal Red #E23B3B. Font: Space Grotesk + Inter. Edge detection: cunning_document_scanner. minSdkVersion 24. OCR: ML Kit Latin. Searchable PDF: pdf package with invisible text layer. 5 filters incl. Blueprint custom. Pricing: KES 249/mo, 1999/yr, 3999 lifetime. | Need Space Grotesk font files. | Copy template, apply identity, build M1 skeleton |

## M1: Skeleton & Data ✅
| Timestamp | Phase | Done | Decisions & Defaults | Open Issues | Next Step |
|-----------|-------|------|---------------------|-------------|-----------|
| 2026-11-08 16:50 | M1 | COMPLETE | All screens styled, Drift schema with FTS5 + seed data, zero analyze errors (26 info hints only), debug APK builds. | Phone not connected for install test. google_mobile_ads deferred (AGP 9.x incompatibility) — stubbed. phosphor_flutter→phosphor_icons migration done. | M2: Core features |

### M1 Details
- Git commit: e3ee34b "M1: skeleton and data"
- 72 files, 5,512 insertions
- Build time: ~33 min first build (ML Kit native deps)
- Screens: Library (grid/list + folder chips + search), Camera (crop marks + viewfinder + mode selector), Editor (filter strip + toolbar), Document Detail (pages + OCR badge + actions), OCR Text, Settings, Onboarding, Paywall
- Data: 5 seed documents (M-Pesa, National ID, KCSE Certificate, Fee Receipt, KRA PIN), 3 folders (Receipts, IDs, School)
- Key fixes: phosphor_flutter→phosphor_icons 3.0.1 (IconData final class), withOpacity→withValues, CardTheme→CardThemeData, google_mobile_ads stubbed

## M2: Core ✅
| Timestamp | Phase | Done | Decisions & Defaults | Open Issues | Next Step |
|-----------|-------|------|---------------------|-------------|-----------|
| 2026-11-08 17:20 | M2 | COMPLETE | Real scanning via cunning_document_scanner, all 5 filters, OCR with ML Kit, searchable PDF export, share, print. User confirmed app works on phone. | | M3: Onboarding, Settings, Monetization |

### M2 Details
- Git commit: 12c1eef "M2: core — real scanning, filters, OCR, searchable PDF export, share, print, unit tests"
- 16 files changed, 4,990 insertions
- Services: ImageProcessingService (filters in isolates), ScannerService (cunning_document_scanner + image_picker), OcrService (ML Kit + daily limit), ExportService (PDF with text overlay, JPG, share, print)
- 11 unit tests for document CRUD, page ordering, folder limits, OCR, search, settings
- APK installed on itel A666L — user confirmed "really impressed"

## M3: Onboarding, Settings, Monetization ✅
| Timestamp | Phase | Done | Decisions & Defaults | Open Issues | Next Step |
|-----------|-------|------|---------------------|-------------|-----------|
| 2026-11-08 17:49 | M3 | COMPLETE | Onboarding redirect via GoRouter, settings wiring (filter/quality pickers), folder CRUD with 3-folder limit + paywall, storage screen, banner ad on library, privacy policy. | google_mobile_ads still stubbed (AGP 9.x). RadioListTile deprecated in 3.47 — migrated to Radio+ListTile. | M4: Polish & Release |

### M3 Details
- Git commit: 965b5d8 "M3: onboarding redirect, settings wiring, folder CRUD..."
- 16 files changed, 932 insertions, 60 deletions
- Router: `_onboardingCompleteProvider` + `redirect` checks SharedPreferences; redirects to /onboarding on first launch
- Settings: Default filter picker (5 options), export quality picker (3 options), storage screen with usage breakdown + cleanup
- Folder CRUD: "+" chip in FolderChipBar, create dialog with name + 8 color choices, rename/delete via long-press bottom sheet
- Folder limit: getFolderCount() check before creation, redirects to paywall at >=3 folders
- OCR limit: Already wired in M2 — 5 pages/day, redirects to paywall
- Banner ad: AppBannerAd stub widget at bottom of LibraryScreen (library only, NEVER camera/editor/export)
- Privacy policy: PRIVACY_POLICY.md — on-device processing, no cloud, no account
- url_launcher added for privacy policy / terms / rate links
- Test fix: `import 'package:drift/drift.dart' hide isNull;` to resolve ambiguous import

## M4: Polish & Release ✅
| Timestamp | Phase | Done | Decisions & Defaults | Open Issues | Next Step |
|-----------|-------|------|---------------------|-------------|-----------|
| 2026-11-08 17:49 | M4 | COMPLETE | Adaptive launcher icon (crop marks + lifted corner), dark splash screen, privacy policy, APK on phone. | | Push to GitHub |

### M4 Details
- Adaptive icon: vector drawable foreground (crop marks with Signal Red accent corner + fold triangle + center crosshair), carbon background (#0E0E0E)
- Splash: Dark background (#0E0E0E) via launch_background.xml + colors.xml
- Status bar: Dark during launch via styles.xml
- Privacy policy: PRIVACY_POLICY.md included in repo
- Version: 1.0.0+1 (set in pubspec.yaml)
- APK installed and running on itel A666L
- Zero errors, zero warnings (36 info hints only)

## Known Issues / Risks
1. `google_mobile_ads` v5.3.1 incompatible with AGP 9.x — banner ad is a stub placeholder. Replace when compatible version available.
2. `purchases_flutter` and `share_plus` emit KGP warnings — non-blocking, builds succeed.
3. `Radio.groupValue`/`onChanged` deprecated in Flutter 3.32+ — using them still works, replacement API (`RadioGroup`) not yet widely adopted.
4. `ReorderableListView.onReorder` deprecated — works, replacement is `onReorderItem`.
5. First Gradle build takes ~33 min (ML Kit native deps). Subsequent builds ~2-4 min.
