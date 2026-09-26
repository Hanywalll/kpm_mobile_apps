import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

class PromoPosterDialog extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onAction;

  const PromoPosterDialog({
    super.key,
    this.imageUrl,
    this.title = 'Diskon Spesial Siswa KPM! 🎉',
    this.subtitle = 'Tingkatkan prestasimu bersama KPM Academy. Dapatkan akses ribuan soal MNR, video materi, dan bimbel interaktif sekarang!',
    this.buttonText = 'Lihat Promo & Paket Belajar',
    this.onAction,
  });

  static bool _hasShownInCurrentSession = false;

  /// Check whether promo poster should be shown (shown on each fresh app launch / session)
  static Future<bool> shouldShowPromo({bool force = false}) async {
    if (force) return true;
    return !_hasShownInCurrentSession;
  }

  /// Mark promo poster as shown for current application lifecycle session
  static Future<void> markAsShown() async {
    _hasShownInCurrentSession = true;
  }

  /// Reset session flag (for testing or re-launch simulation)
  static void resetSession() {
    _hasShownInCurrentSession = false;
  }

  /// Helper to display the dialog with smooth entrance animation
  static Future<void> show(
    BuildContext context, {
    String? imageUrl,
    String? title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onAction,
  }) async {
    await markAsShown();
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: PromoPosterDialog(
            imageUrl: imageUrl ?? 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800&auto=format&fit=crop&q=80',
            title: title ?? 'Diskon Spesial KPM Academy! 🎉',
            subtitle: subtitle ?? 'Akses lengkap Paket Bimbel Matematika Nalaria Realistik (MNR), Tryout CBT Nasional, dan AI Tutor 24/7!',
            buttonText: buttonText ?? 'Lihat Paket Belajar Sekarang',
            onAction: onAction,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topRight,
        children: [
          // Main Poster Card
          Container(
            width: size.width * 0.88,
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardColor : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Poster Graphic (PNG/JPG with modern aspect ratio)
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.campaign_rounded, size: 64, color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay at bottom of poster graphic
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                (isDark ? AppTheme.darkCardColor : Colors.white).withValues(alpha: 0.8),
                                isDark ? AppTheme.darkCardColor : Colors.white,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Floating Badge "SPECIAL PROMO"
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48), // Vivid Crimson
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'HOT PROMO 🔥',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. Content Info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 3. CTA Action Button
                        Container(
                          width: double.infinity,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)], // Deep Blue
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E40AF).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                Navigator.of(context).pop();
                                if (onAction != null) {
                                  onAction!();
                                } else {
                                  Navigator.pushNamed(context, '/package_list');
                                }
                              },
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      buttonText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        // "Tutup / Nanti Saja" text button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Nanti Saja',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Close button (Floating Circular 'X' at top right)
          Positioned(
            top: -12,
            right: -12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
