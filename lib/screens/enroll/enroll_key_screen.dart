import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class EnrollKeyScreen extends StatefulWidget {
  const EnrollKeyScreen({super.key});

  @override
  State<EnrollKeyScreen> createState() => _EnrollKeyScreenState();
}

class _EnrollKeyScreenState extends State<EnrollKeyScreen> {
  final _keyController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Klaim Enroll Key'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktivasi Paket Belajar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Masukkan kode Enroll Key yang didapatkan dari Mitra Bimbel atau Sekolah.'),
            const SizedBox(height: 24),
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Kode Enroll Key (Contoh: KPM-2025-XXXX)',
                prefixIcon: Icon(Icons.key_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Aktivasi Sekarang',
              onPressed: () {
                if (_keyController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Masukkan kode terlebih dahulu')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kode berhasil diaktivasi! Paket Anda telah aktif.')),
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
