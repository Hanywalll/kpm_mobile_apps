import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AuthGuard {
  /// Cek apakah pengguna sudah login.
  /// Jika sudah, langsung jalankan [onAuthenticated].
  /// Jika belum, munculkan Bottom Sheet ajakan daftar/masuk.
  static Future<void> check(
    BuildContext context, {
    required VoidCallback onAuthenticated,
    String? featureName,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      onAuthenticated();
      return;
    }

    final bool? loggedIn = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AuthRequiredBottomSheet(featureName: featureName),
    );

    if (loggedIn == true && context.mounted) {
      final updatedAuth = Provider.of<AuthProvider>(context, listen: false);
      if (updatedAuth.isAuthenticated) {
        onAuthenticated();
      }
    }
  }
}

class AuthRequiredBottomSheet extends StatelessWidget {
  final String? featureName;

  const AuthRequiredBottomSheet({super.key, this.featureName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Icon Header
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: AppTheme.ruangguruGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_open_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Yuk, Daftar Akun Dulu! 🚀',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              featureName != null
                  ? 'Untuk mengakses $featureName, kamu perlu mendaftar atau masuk ke akunmu terlebih dahulu.'
                  : 'Buat akun gratis dalam 1 menit untuk mulai mengerjakan soal, simpan progres belajar, dan konsultasi dengan AI Tutor.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Feature Highlights Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _benefitRow(Icons.check_circle_rounded, 'Simpan skor tryout & analisis sistem IRT'),
                  const SizedBox(height: 8),
                  _benefitRow(Icons.check_circle_rounded, 'Akses penuh ke Tanya AI Tutor 24/7'),
                  const SizedBox(height: 8),
                  _benefitRow(Icons.check_circle_rounded, 'Klaim diskon paket belajar & kode kelas'),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Tombol 1: Daftar Akun Baru (Primary)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final res = await Navigator.pushNamed(context, '/register');
                  if (res == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text(
                  'Daftar Akun Baru (Gratis)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol 2: Sudah Punya Akun? Masuk (Secondary)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                  side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final res = await Navigator.pushNamed(context, '/login');
                  if (res == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text(
                  'Sudah punya akun? Masuk',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tombol 3: Nanti Saja
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Nanti Saja, Mau Jelajah Dulu',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00B894), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
