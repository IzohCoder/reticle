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

## M2: Core (IN PROGRESS)
| Timestamp | Phase | Done | Decisions & Defaults | Open Issues | Next Step |
|-----------|-------|------|---------------------|-------------|-----------|
| 2026-11-08 16:50 | M2 | STARTING | | | Camera capture, edge detection, filters, OCR, export |
