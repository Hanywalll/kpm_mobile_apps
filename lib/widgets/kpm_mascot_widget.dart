import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class KpmMascotWidget extends StatefulWidget {
  final double size;
  final String? message;
  final bool showBubble;
  final bool isAnimated;

  const KpmMascotWidget({
    super.key,
    this.size = 110,
    this.message,
    this.showBubble = true,
    this.isAnimated = true,
  });

  @override
  State<KpmMascotWidget> createState() => _KpmMascotWidgetState();
}

class _KpmMascotWidgetState extends State<KpmMascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    if (widget.isAnimated) {
      _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.repeat(reverse: true);
    } else {
      _floatAnimation = const AlwaysStoppedAnimation(0.0);
      _scaleAnimation = const AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Motivational Speech Bubble
                if (widget.showBubble && widget.message != null && widget.message!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D4ED8).withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            widget.message!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Circular Animated Character Badge
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF60A5FA), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(widget.size),
                        child: Image.asset(
                          'assets/images/login_character.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.school_rounded,
                                size: widget.size * 0.5,
                                color: const Color(0xFF1D4ED8),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class KpmLoadingOverlay extends StatelessWidget {
  final String message;

  const KpmLoadingOverlay({
    super.key,
    this.message = 'Sedang menyiapkan materi terbaikmu...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KpmMascotWidget(
              size: 100,
              message: message,
              showBubble: true,
              isAnimated: true,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D4ED8)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'KPM ACADEMY',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextMuted : const Color(0xFF94A3B8),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
