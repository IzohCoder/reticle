# Reticle — Product Specification

## Design Concept

**The Precision Darkroom.** Reticle is a surgical optical instrument for paper. The camera screen is a full-bleed darkroom where the document is the only luminous object, framed by hairline crop marks that snap into place with mechanical precision. The library is a calm light table — graphite, bone-white, and ash surfaces. One sharp accent — Signal Red — behaves like a laser alignment line: thin, precise, never decorative. It marks the active edge detection boundary, the capture flash, and the OCR highlight wave. Dark theme is the primary personality, not an afterthought. Typography is technical and tabular. Every interaction feels like operating a well-calibrated instrument.

## Name Rationale

Five candidates evaluated:

| # | Name | Meaning | Verdict |
|---|------|---------|---------|
| 1 | **Reticle** | Crosshair/viewfinder in optical instruments; evokes precision targeting | ✅ CHOSEN — no scanner conflicts on Play Store |
| 2 | Aperture | Camera lens opening | ❌ Apple's discontinued photo app; potential confusion |
| 3 | Foldmark | Where paper folds meet crop marks | ❌ "Foldmark Labs" developer exists on Play Store |
| 4 | Crisp | Sharp, clean edges | ❌ Multiple scanner apps already named Crisp |
| 5 | Traceline | Tracing document edges | ⚠️ Puzzle game "TraceLine" exists |

**Reticle** is short (7 chars), easy to spell, ownable, and directly tied to the optical-instrument concept. No Play Store conflicts in the scanner/productivity space.

**Package ID:** `com.isaac.reticle`

## MVP Features

### Core Capture
- Camera with live edge detection (via cunning_document_scanner native ML Kit), auto-capture with manual shutter fallback
- Flash toggle, steady-hand guidance, gallery import
- Multi-page batch scanning with retake/delete of last page

### Editor
- Drag corners to adjust perspective, perspective correction
- Rotate (90° increments)
- Five filters: Original, Enhanced, Black & White, Grayscale, Blueprint (custom — a high-contrast cyan-tinted technical drawing look)
- Brightness/contrast sliders
- Reorder pages (drag), per-page delete

### ID-Card Mode
- Guided capture: front then back
- Both auto-placed onto one A4 page (front top, back bottom)

### Library
- Grid and list views with thumbnails
- Rename documents, sort (date, name, size)
- Search by title and by recognized OCR text (FTS5)
- Folders (3 free, unlimited Pro)
- Multi-select actions (delete, move, export)
- Recent documents section

### OCR
- On-device Latin script (ML Kit) — covers English and Swahili
- View and copy extracted text, share as text
- Searchable PDF with invisible text layer under page image
- 5 OCR pages/day free, unlimited Pro

### Export
- PDF or JPG
- Share to any app (WhatsApp, email, etc.) via system share sheet
- Save to Files
- Print via printing package
- Quality control: Small (~150 KB/page), Balanced (~300 KB/page), High (~600 KB/page)

### Reliability
- Drafts survive crashes and process death (auto-save to DB + filesystem)

## Post-MVP (Deferred)

- Cloud sync and backup
- E-signature workflows
- Translation of recognized text
- QR and barcode scanning
- Auto-categorization by document type
- Collaboration and sharing
- Fax
- Handwriting recognition
- Export to Word/Excel

## Screen Inventory & Navigation

### Navigation: 2 tabs + central FAB
- **Library** tab (left): document grid/list, folders, search
- **Scan FAB** (center): large circular button launching camera
- **Settings** tab (right): preferences, upgrade, about

### Screens
1. **Library Screen** — main home, grid/list of documents, search bar, folder chips, sort, multi-select
2. **Camera Screen** — full-bleed dark camera preview, edge detection overlay, shutter button, flash toggle, batch controls, mode selector (Document/ID Card)
3. **Editor Screen** — captured page(s) with corner handles, filter strip, rotate, brightness/contrast, page thumbnails for multi-page, reorder
4. **Document Detail Screen** — page viewer (swipeable), OCR status, export/share actions
5. **OCR Text Screen** — recognized text displayed, copy/share actions
6. **Export Sheet** — bottom sheet with format, quality, filename options
7. **Folder Manager** — bottom sheet for create/rename/delete folders
8. **Onboarding Screen** — camera permission request with darkroom-themed explanation
9. **Settings Screen** — default filter, export quality, storage usage, app lock, upgrade, privacy/terms, rate, version
10. **Paywall Screen** — Reticle Pro features, pricing, trial info
11. **Storage Screen** — usage breakdown, cleanup orphaned files

### Key Flows

**Scan Document:** FAB → Camera (edge detection) → auto-capture → Editor (corners, filters) → Save → Library
**Scan ID Card:** FAB long-press or mode selector → "Scan front" → capture → "Scan back" → capture → auto-layout A4 → Editor → Save
**OCR:** Document Detail → "Recognize Text" → progress → OCR Reveal animation → text view (copy/share)
**Export:** Document Detail → Export sheet → format + quality → share intent
**Search:** Library search bar → queries title + OCR text via FTS5

## Data Model

### ScanDocuments
- `id` INTEGER PK AUTOINCREMENT
- `title` TEXT NOT NULL
- `folderId` INTEGER NULLABLE FK → ScanFolders
- `pageCount` INTEGER DEFAULT 0
- `ocrStatus` TEXT DEFAULT 'none' — values: none, partial, complete
- `createdAt` INTEGER NOT NULL (epoch ms)
- `updatedAt` INTEGER NOT NULL (epoch ms)

### ScanPages
- `id` INTEGER PK AUTOINCREMENT
- `documentId` INTEGER NOT NULL FK → ScanDocuments
- `sortOrder` INTEGER NOT NULL
- `originalImagePath` TEXT NOT NULL
- `processedImagePath` TEXT NULLABLE
- `thumbnailPath` TEXT NULLABLE
- `filterType` TEXT DEFAULT 'original' — values: original, enhanced, bw, grayscale, blueprint
- `cornerPointsJson` TEXT NULLABLE — JSON array of 4 {x,y} points
- `rotation` INTEGER DEFAULT 0 — values: 0, 90, 180, 270
- `recognizedText` TEXT DEFAULT ''
- `textBlocksJson` TEXT DEFAULT '[]' — JSON bounding boxes for PDF overlay
- `createdAt` INTEGER NOT NULL (epoch ms)

### ScanFolders
- `id` INTEGER PK AUTOINCREMENT
- `name` TEXT NOT NULL
- `colorHex` TEXT DEFAULT '#6B6B6B'
- `sortOrder` INTEGER DEFAULT 0
- `createdAt` INTEGER NOT NULL (epoch ms)

### AppSettings
- `key` TEXT PK
- `value` TEXT NOT NULL

### Full-Text Search
- `ScanPagesFts` — FTS5 virtual table indexing `recognizedText` from ScanPages, joined via `documentId` for library search

### File Storage
- Base path: `getApplicationDocumentsDirectory()/reticle/`
- Originals: `reticle/originals/{docId}/{pageId}.jpg`
- Processed: `reticle/processed/{docId}/{pageId}.jpg`
- Thumbnails: `reticle/thumbs/{docId}/{pageId}.jpg` (200px width)
- Orphan cleanup on app start

## Monetization Plan

### Free Tier
- Unlimited scans and exports, NO watermark
- All 5 filters, ID-card mode
- 5 OCR pages per day
- Up to 3 folders
- One small banner ad on library screen only
- NEVER ads on camera, editor, or export flows; no interstitials

### Pro Tier
- Unlimited OCR and searchable PDFs
- Unlimited folders
- Password-protected PDFs
- App lock (biometric/PIN)
- Signature placement on pages
- Batch export
- No ads

### Pricing (Google Play Kenya regional)
- Monthly: KES 249/month (no trial)
- Annual: KES 1,999/year (7-day free trial)
- Lifetime: KES 3,999 (one-time)

### Paywall Triggers
- 6th OCR page in a day
- 4th folder creation
- Locked export option (password PDF, batch export)
- "Upgrade" row in Settings
- No dark patterns; price and terms always shown clearly

## Design Brief

### Palette (8 roles)

| Role | Light | Dark |
|------|-------|------|
| Surface | #F5F3F0 | #141414 |
| Surface Elevated | #EDEAE5 | #1E1E1E |
| Surface Container | #E4E0DA | #282828 |
| Ink (onSurface) | #1A1A1A | #E8E6E2 |
| Ink Muted | #6B6B6B | #8A8A8A |
| Signal (accent) | #D43030 | #E23B3B |
| Signal Surface | #FDE8E8 | #2D1515 |
| Outline | #D0CCC6 | #333333 |

Semantic: Success #1B8A4A, Warning #C06800, Error #B00020

### Typography
- Display/Headings: Space Grotesk SemiBold (geometric, technical, built-in tabular figures)
- Body/UI: Inter Regular/Medium
- Tabular figures: Space Grotesk with FontFeature.tabularFigures() for page counts, file sizes, dates

### Shape Language
- Crop-mark corners (2px hairline L-shapes at corners, no full border) on document thumbnails
- Radii: 2px document surfaces, 6px cards/buttons, 12px sheets, full-round chips
- Borders over shadows everywhere except floating elements (FAB, sheets)
- Icons: Phosphor Icons thin weight, optically aligned at 20px

### Motion
- Standard: 200ms easeInOutCubic
- Enter: 200ms easeOut
- Exit: 150ms easeIn
- Edge Lock sequence: 250ms total
- Paper Shuffle: 300ms with spring curve
- OCR Reveal wave: 50ms stagger per block

### Signature Moments
1. **Edge Lock:** Four crop-mark corners animate from edges to lock onto document corners. Horizontal scan-line sweeps down (200ms). Haptic tick (mediumImpact). Auto-capture after 800ms stable lock.
2. **Paper Shuffle:** Captured page flies as card toward page-stack thumbnail, rotating slightly, settling with paper-tap haptic (lightImpact). Page counter ticks up with slot-machine digit roll.
3. **OCR Reveal:** Recognized text blocks highlight in wave from top-left to bottom-right (50ms stagger per block), then highlights fade and text becomes copyable. "Recognized" badge appears.

### Icon
Adaptive launcher icon: four crop-mark corners forming an abstract page with one corner lifted (folded). Bold silhouette readable at 48px. Signal Red accent on the lifted corner. Carbon background. No letters.

## Technical Notes

### Packages (beyond template)
- `cunning_document_scanner` — native edge detection via ML Kit (Android)
- `camera` — custom camera preview for overlay UI
- `google_mlkit_text_recognition` — on-device OCR, Latin script
- `image` (dart) — filters, brightness/contrast, thumbnails in isolates
- `local_auth` — biometric/PIN app lock (Pro)
- `permission_handler` — camera permission with rationale

### Architecture
- Edge detection: cunning_document_scanner handles native camera + ML Kit scanning
- Perspective correction: handled natively by cunning_document_scanner
- Image processing: Dart `image` package in isolates for filters/adjustments
- Searchable PDF: `pdf` package with PdfColor(0,0,0,0) transparent text overlay positioned at OCR bounding box coordinates
- All heavy work off UI thread

### Performance Targets
- Capture → processed preview: < 1.5s
- OCR per page: < 3s
- 20-page PDF export: < 10s
- Memory stable on 50-page document (lazy thumbnail loading, max 10 full-res cached)

### Permissions
- CAMERA only — pre-permission explanation, deep link to settings if denied
- No broad storage permission — scoped storage + share intents

### minSdkVersion
- Bumped to 24 (required by cunning_document_scanner / ML Kit)
- Target device (itel A666L, Android 13) well above this

## Play Store / Data Safety

### Data Safety Answers
- **Data collected:** Device identifiers (AdMob, free tier only)
- **Data shared:** None — documents never leave the device
- **Data encrypted in transit:** Yes (AdMob uses HTTPS)
- **Data deletion:** User can delete any document; uninstall removes all data
- **Camera permission:** Used to capture document images for scanning; images stored locally only

### Privacy Policy Points
- All document processing is on-device
- No cloud upload, no account, no tracking beyond AdMob (free tier)
- Camera used solely for document capture
- AdMob collects device identifiers per Google's Ad policy (free tier)
- Pro tier removes all ad-related data collection

### Content Rating
- PEGI 3 / Everyone — utility app, no objectionable content

## Acceptance Criteria

### M1 — Skeleton & Data
- Full navigation working (2 tabs + FAB)
- Library with grid/list views, search bar, folder chips, sort
- Camera screen visually complete (dark theme, crop marks, shutter button, flash toggle)
- Editor and export screens as styled shells
- Drift schema with all tables + FTS5
- Seed documents (receipt, ID card, certificate) with realistic content
- Every screen feels like a finished product visually

### M2 — Core
- Real capture with edge detection and auto-capture via cunning_document_scanner
- Corner adjustment and perspective correction
- All 5 filters working
- Multi-page batch sessions
- Reorder and delete pages
- ID-card mode (front + back → A4)
- On-device OCR with reveal animation
- Text view and copy
- Searchable PDF and JPG export
- Share and print
- Crash-safe drafts
- Performance targets met
- Unit tests for page pipeline, ordering, export logic

### M3 — Onboarding, Settings, Monetization
- Onboarding earns camera permission gracefully
- Settings: default filter, export quality, storage usage/cleanup, app lock
- Paywall with Pro features listed
- Daily OCR limit (5 free → paywall on 6th)
- Folder limit (3 free → paywall on 4th)
- Banner ad on library only
- RevenueCat mock mode, TEST ad IDs
- All behind feature flags; flipping each flag behaves correctly

### M4 — Polish & Release
- DESIGN & CRAFT BAR audit passed
- Original adaptive launcher icon and splash
- Low-light/glare handling
- Animation smoothness
- Text scaling to 200% without overflow
- WCAG AA contrast
- Small and large phone layouts
- versionName/versionCode set, R8 enabled
- Signing setup guide (never create keystore)
- Privacy policy draft
- Release APK installed on phone
- No jank, no debug leftovers, clean analyze

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| cunning_document_scanner native UI conflicts with custom overlay | Medium | Medium | Use as processing backend; our UI handles entry/exit |
| Image processing slow on mid-range phone | Low | High | Run in Dart isolate; use thumbnails for previews |
| FTS5 not cleanly supported in Drift | Low | Medium | Fallback: LIKE queries on recognizedText with index |
| Searchable PDF text misaligned | Medium | Medium | Careful coordinate scaling; test with multiple doc sizes |
| App size bloat from ML Kit | Low | Low | Monitor APK size; unbundled ML Kit if needed |
| minSdkVersion 24 excludes old devices | Low | Low | Target market (Kenya 2020+) is Android 10+ |
