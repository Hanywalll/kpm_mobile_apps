import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Tryout'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.stars, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            const Text('Selamat, Anda Telah Selesai!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                children: [
                  Text('Skor Akhir', style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                  SizedBox(height: 8),
                  Text('85.0', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue)),
                  Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Benar', style: TextStyle(color: Colors.grey)),
                          Text('17', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Salah', style: TextStyle(color: Colors.grey)),
                          Text('3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Akurasi', style: TextStyle(color: Colors.grey)),
                          Text('85%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Lihat Pembahasan',
              onPressed: () {
                Navigator.pushNamed(context, '/review', arguments: 'demo_session');
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }
}
