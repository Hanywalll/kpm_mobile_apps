import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';

class PretestScreen extends StatelessWidget {
  const PretestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Petunjuk Tryout')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simulasi CBT SNBT 2025 #1',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.timer, color: Colors.blue),
                SizedBox(width: 8),
                Text('Durasi: 60 Menit'),
                SizedBox(width: 24),
                Icon(Icons.help_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text('Jumlah: 20 Soal'),
              ],
            ),
            const Divider(height: 32),
            const Text(
              'Petunjuk Pengerjaan:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text('1. Pastikan koneksi internet stabil selama pengerjaan.'),
            const Text('2. Jawaban tersimpan secara otomatis secara real-time.'),
            const Text('3. Gunakan navigasi nomor soal untuk berpindah dengan cepat.'),
            const Text('4. Jika waktu habis, jawaban Anda akan disubmit otomatis.'),
            const Spacer(),
            PrimaryButton(
              text: 'Mulai Pengerjaan',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/exam', arguments: 'demo_session');
              },
            ),
          ],
        ),
      ),
    );
  }
}
