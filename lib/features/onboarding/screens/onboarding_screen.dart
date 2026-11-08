import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/app_typography.dart';

/// Onboarding screen that earns camera permission gracefully.
/// Darkroom-themed, not a generic feature slideshow.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<double> _cropMarkScale;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _cropMarkScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated crop-mark icon
              FadeTransition(
                opacity: _fadeIn,
                child: ScaleTransition(
                  scale: _cropMarkScale,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _OnboardingCropMarkPainter(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: Spacing.xl),

              // Title
              FadeTransition(
                opacity: _fadeIn,
                child: Text(
                  'Reticle',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: Spacing.sm),

              FadeTransition(
                opacity: _fadeIn,
                child: Text(
                  'Point. Snap. Done.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: Spacing.xxl),

              // Camera permission explanation
              FadeTransition(
                opacity: _fadeIn,
                child: Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: Radii.cardAll,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE23B3B).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          PhosphorIconsRegular.camera,
                          color: Color(0xFFE23B3B),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Camera access needed',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Reticle uses your camera to capture documents. '
                              'Images are processed on your device and never uploaded.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // CTA button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // M3: request camera permission via permission_handler
                    // For now, just navigate to library
                    context.go('/library');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE23B3B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: Radii.buttonAll,
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: Spacing.md),

              Text(
                'No account required · Everything stays on your phone',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white30,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws animated crop-mark corners forming an abstract page.
class _OnboardingCropMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final accentPaint = Paint()
      ..color = const Color(0xFFE23B3B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final subtlePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;
    const l = 28.0;

    // Outer crop marks (subtle)
    // Top-left
    canvas.drawLine(const Offset(0, 0), Offset(l, 0), subtlePaint);
    canvas.drawLine(const Offset(0, 0), Offset(0, l), subtlePaint);
    // Top-right
    canvas.drawLine(Offset(w, 0), Offset(w - l, 0), subtlePaint);
    canvas.drawLine(Offset(w, 0), Offset(w, l), subtlePaint);
    // Bottom-left
    canvas.drawLine(Offset(0, h), Offset(l, h), subtlePaint);
    canvas.drawLine(Offset(0, h), Offset(0, h - l), subtlePaint);
    // Bottom-right (accent — the "lifted corner")
    canvas.drawLine(Offset(w, h), Offset(w - l, h), accentPaint);
    canvas.drawLine(Offset(w, h), Offset(w, h - l), accentPaint);

    // Inner page fold triangle (lifted corner)
    final foldPath = Path()
      ..moveTo(w - 20, h)
      ..lineTo(w, h - 20)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      foldPath,
      Paint()
        ..color = const Color(0xFFE23B3B).withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
