import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import '../../../core/design/tokens.dart';

/// Full-bleed dark camera screen with viewfinder overlay.
/// In M1 this is a visual stub; real capture comes in M2.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, this.mode = 'document'});

  final String mode; // 'document' or 'idcard'

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _flashOn = false;
  String _currentMode = 'document';

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
    // Force dark status bar for camera
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview placeholder (dark surface with subtle grid)
          Container(
            color: const Color(0xFF0A0A0A),
            child: CustomPaint(
              painter: _ViewfinderGridPainter(),
            ),
          ),

          // Top controls
          Positioned(
            top: mq.padding.top + Spacing.sm,
            left: Spacing.md,
            right: Spacing.md,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                _CameraButton(
                  icon: PhosphorIconsRegular.x,
                  onTap: () => Navigator.of(context).pop(),
                ),
                // Flash toggle
                _CameraButton(
                  icon: _flashOn
                      ? PhosphorIconsFill.lightning
                      : PhosphorIconsRegular.lightning,
                  onTap: () => setState(() => _flashOn = !_flashOn),
                  isActive: _flashOn,
                ),
              ],
            ),
          ),

          // Viewfinder crop marks (center of screen)
          Center(
            child: AspectRatio(
              aspectRatio: _currentMode == 'idcard' ? 1.586 : 0.707,
              child: Container(
                margin: const EdgeInsets.all(Spacing.xl),
                child: CustomPaint(
                  painter: _CropMarkOverlayPainter(
                    color: const Color(0xFFE23B3B).withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),

          // Mode indicator
          if (_currentMode == 'idcard')
            Positioned(
              top: mq.padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: Radii.chipAll,
                  ),
                  child: Text(
                    'Scan front of ID',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),

          // Steady-hand hint
          Positioned(
            bottom: 160,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Hold steady over the document',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: mq.padding.bottom + Spacing.lg,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Mode selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ModeChip(
                      label: 'Document',
                      isSelected: _currentMode == 'document',
                      onTap: () =>
                          setState(() => _currentMode = 'document'),
                    ),
                    const SizedBox(width: Spacing.sm),
                    _ModeChip(
                      label: 'ID Card',
                      isSelected: _currentMode == 'idcard',
                      onTap: () =>
                          setState(() => _currentMode = 'idcard'),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                // Shutter row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery import
                    _CameraButton(
                      icon: PhosphorIconsRegular.image,
                      onTap: () {
                        // M2: import from gallery
                      },
                    ),
                    // Shutter button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        // M2: capture
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Page stack (batch indicator)
                    _CameraButton(
                      icon: PhosphorIconsRegular.stack,
                      onTap: () {},
                      badge: '0',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? const Color(0xFFE23B3B).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (badge != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE23B3B),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: Radii.chipAll,
          border: Border.all(
            color: isSelected ? Colors.white30 : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Subtle grid lines for the viewfinder placeholder.
class _ViewfinderGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    // Draw thirds
    for (var i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Four crop-mark corners for the viewfinder guide.
class _CropMarkOverlayPainter extends CustomPainter {
  _CropMarkOverlayPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const l = 24.0;
    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawLine(const Offset(0, 0), Offset(l, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, l), paint);
    // Top-right
    canvas.drawLine(Offset(w, 0), Offset(w - l, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, l), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, h), Offset(l, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - l), paint);
    // Bottom-right
    canvas.drawLine(Offset(w, h), Offset(w - l, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - l), paint);
  }

  @override
  bool shouldRepaint(covariant _CropMarkOverlayPainter old) =>
      old.color != color;
}
