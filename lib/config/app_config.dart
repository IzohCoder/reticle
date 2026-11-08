/// App-level configuration flags and constants for Reticle.
library;

import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Feature flags
// ---------------------------------------------------------------------------
const bool enableOnboarding = true;
const bool enablePaywall = true;
const bool enableAds = true;
const bool enableIAP = true;

// ---------------------------------------------------------------------------
// App identity
// ---------------------------------------------------------------------------
const String appName = 'Reticle';
const String appTagline = 'Capture. Recognize. Share.';
const String appSupportEmail = 'support@reticle.app';
const String appPrivacyPolicyUrl = 'https://reticle.app/privacy';
const String appTermsUrl = 'https://reticle.app/terms';
const String appPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=com.isaac.reticle';

// ---------------------------------------------------------------------------
// RevenueCat
// ---------------------------------------------------------------------------
const String revenueCatApiKeyAndroid = 'YOUR_REVENUECAT_ANDROID_KEY';
const bool revenueCatMockMode = true;

const String rcMonthlyEntitlement = 'pro_monthly';
const String rcAnnualEntitlement = 'pro_annual';
const String rcLifetimeEntitlement = 'pro_lifetime';
const String rcProEntitlement = 'pro';

// ---------------------------------------------------------------------------
// AdMob
// ---------------------------------------------------------------------------
const String admobAppId = 'ca-app-pub-3940256099942544~3347511713'; // TEST
const String admobBannerAdUnitId =
    'ca-app-pub-3940256099942544/6300978111'; // TEST banner

// ---------------------------------------------------------------------------
// Scanner-specific limits
// ---------------------------------------------------------------------------
/// Number of free OCR pages per day (free tier).
const int freeOcrPagesPerDay = 5;

/// Maximum folders on free tier.
const int freeFolderLimit = 3;

// ---------------------------------------------------------------------------
// Export quality presets (JPEG quality 0-100)
// ---------------------------------------------------------------------------
const int exportQualitySmall = 40;
const int exportQualityBalanced = 70;
const int exportQualityHigh = 92;

// ---------------------------------------------------------------------------
// Debug helpers
// ---------------------------------------------------------------------------
bool get isDebugMode => kDebugMode;
