import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AdminPreviewGuard {
  /// Memeriksa apakah pengguna saat ini adalah Admin yang sedang melihat mode pratinjau siswa.
  /// Jika Admin, munculkan dialog bahwa akun admin berada dalam mode Read-Only dan kembalikan false.
  /// Jika bukan Admin, kembalikan true.
  static bool checkActionAllowed(
    BuildContext context, {
    String actionName = 'melakukan transaksi / pembelian paket',
  }) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAdmin) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          icon: const Icon(Icons.shield_outlined, color: Colors.amber, size: 36),
          title: const Text(
            'Mode Pratinjau Administrator',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Akun Administrator berada dalam mode pratinjau siswa (Read-Only) dan tidak dapat $actionName demi menjaga integritas data & sistem transaksi.',
            style: const TextStyle(fontSize: 12, height: 1.4),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }
}
