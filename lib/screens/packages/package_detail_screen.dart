import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../widgets/auth_guard_bottom_sheet.dart';
import '../../widgets/primary_button.dart';

class PackageDetailScreen extends StatelessWidget {
  const PackageDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Detail Paket Belajar'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppTheme.ruangguruGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '🔥 INTENSIF UTBK 2025',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Paket Complete Success SNBT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Lengkap dengan Live Class & AI Tutor 24/7',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.school_rounded, size: 72, color: Colors.white24),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DetailStat(label: 'Rating', value: '⭐ 4.9'),
                        _DetailStat(label: 'Modul Materi', value: '25 Modul'),
                        _DetailStat(label: 'Bank Soal', value: '1500 Soal'),
                        _DetailStat(label: 'Masa Aktif', value: '90 Hari'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Keunggulan Paket Ini ✨',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),

                  const SizedBox(height: 12),

                  _featureItem(Icons.live_tv_rounded, 'Akses 100+ Video Pembelajaran HD', 'Penjelasan konsep step-by-step dari Master Tutor.'),
                  _featureItem(Icons.assignment_turned_in_rounded, 'Simulasi Tryout CBT Real-Time', 'Sistem penilaian IRT eksak seperti UTBK asli.'),
                  _featureItem(Icons.auto_awesome_rounded, 'AI Tutor Personal 24/7', 'Bantu selesaikan soal matematika/IPA kapan saja.'),
                  _featureItem(Icons.analytics_rounded, 'Analisis Rapor & Peluang PTN', 'Rekomendasi jurusan berdasarkan skor IRT.'),

                  const SizedBox(height: 20),

                  const Text(
                    'Deskripsi Paket:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Paket ini dirancang khusus bagi siswa SMA & Alumni yang menargetkan lulus SNBT / UTBK 2025 di PTN Favorit (UI, ITB, UGM, ITS, Unpad, dll.).',
                    style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Harga Paket', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      Formatter.currency(150000),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: PrimaryButton(
                    text: 'Beli Paket 🚀',
                    onPressed: () {
                      AuthGuard.check(
                        context,
                        featureName: 'Pembelian Paket Belajar',
                        onAuthenticated: () => Navigator.pushNamed(context, '/checkout'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;

  const _DetailStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
