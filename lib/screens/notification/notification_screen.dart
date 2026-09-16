import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifs = [
      {
        'title': '🔥 Pengingat Belajar Harian',
        'sub': 'Waktunya mengerjakan 5 soal harian untuk menjaga streak belajar kamu!',
        'time': '10 Menit yang lalu',
        'color': Colors.orange,
        'icon': Icons.notifications_active_rounded,
      },
      {
        'title': '🎥 Live Class Dimulai 30 Menit Lagi',
        'sub': 'Bedah Soal Penalaran Matematika bersama Dr. Budi Pratama.',
        'time': '1 Jam yang lalu',
        'color': Colors.purple,
        'icon': Icons.live_tv_rounded,
      },
      {
        'title': '📊 Hasil Tryout SNBT #1 Rilis',
        'sub': 'Skor IRT kamu 850. Cek analisis pembahasan dan peringkat nasional.',
        'time': 'Kemarin',
        'color': Colors.blue,
        'icon': Icons.analytics_rounded,
      },
      {
        'title': '🎉 Promo Diskon Paket UTBK 50%',
        'sub': 'Gunakan kode promo "SNBT2025" untuk klaim potongan harga spesial.',
        'time': '2 Hari lalu',
        'color': Colors.green,
        'icon': Icons.local_offer_rounded,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Notifikasi 🔔')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: notifs.length,
        itemBuilder: (context, index) {
          final n = notifs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: (n['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                  child: Icon(n['icon'], color: n['color'], size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(n['sub'], style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
                      const SizedBox(height: 6),
                      Text(n['time'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
