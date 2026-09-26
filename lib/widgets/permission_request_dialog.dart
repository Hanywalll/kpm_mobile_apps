import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import '../services/local_notification_service.dart';

class PermissionRequestDialog extends StatelessWidget {
  final VoidCallback? onGranted;

  const PermissionRequestDialog({super.key, this.onGranted});

  static const String _prefKey = 'kpm_permission_prompt_completed';

  /// Check whether the initial permission dialog should be displayed
  static Future<bool> shouldShowDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool(_prefKey) ?? false);
    } catch (_) {
      return false;
    }
  }

  /// Mark permission prompt as completed
  static Future<void> markCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, true);
    } catch (_) {}
  }

  /// Show the permission request dialog
  static Future<void> show(BuildContext context, {VoidCallback? onGranted}) async {
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: PermissionRequestDialog(
          onGranted: onGranted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.88,
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardColor : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon Header
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security_update_good_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Izin Akses KPM Academy 🔔',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Untuk pengalaman belajar terbaik dan interaktif, KPM Academy memerlukan izin akses berikut:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            // Permission Items
            _buildPermissionRow(
              icon: Icons.notifications_active_rounded,
              iconColor: const Color(0xFF3B82F6),
              bgColor: const Color(0xFFDBEAFE),
              title: 'Notifikasi & Pengingat',
              desc: 'Jadwal kelas live, pengingat belajar harian, dan notifikasi nilai Ujian Online.',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildPermissionRow(
              icon: Icons.file_download_rounded,
              iconColor: const Color(0xFF10B981),
              bgColor: const Color(0xFFD1FAE5),
              title: 'Penyimpanan & Unduhan',
              desc: 'Menyimpan bukti resi transaksi PDF dan modul materi offline.',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildPermissionRow(
              icon: Icons.camera_alt_rounded,
              iconColor: const Color(0xFF8B5CF6),
              bgColor: const Color(0xFFEDE9FE),
              title: 'Kamera & Galeri',
              desc: 'Mengunggah foto profil siswa dan foto soal untuk AI Tutor.',
              isDark: isDark,
            ),

            const SizedBox(height: 22),

            // Action Buttons
            Container(
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
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
                  onTap: () async {
                    await markCompleted();
                    await LocalNotificationService.requestPermission();
                    if (context.mounted) {
                      Navigator.pop(context);
                      if (onGranted != null) onGranted!();
                    }
                  },
                  child: const Center(
                    child: Text(
                      'Izinkan & Lanjutkan 🚀',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                await markCompleted();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Nanti Saja',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
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

  Widget _buildPermissionRow({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? bgColor.withValues(alpha: 0.15) : bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
