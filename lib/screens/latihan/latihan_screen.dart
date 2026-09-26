import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/package_provider.dart';
import '../../widgets/auth_guard_bottom_sheet.dart';

class LatihanScreen extends StatefulWidget {
  const LatihanScreen({super.key});

  @override
  State<LatihanScreen> createState() => _LatihanScreenState();
}

class _LatihanScreenState extends State<LatihanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Latihan & Tryout'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: AppTheme.compactTabBar(
            controller: _tabController,
            tabs: const ['Ujian Online', 'Soal Harian', 'Bank Soal'],
            context: context,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTryoutSection(isDark),
          _buildSoalHarianSection(isDark),
          _buildBankSoalSection(isDark),
        ],
      ),
    );
  }

  Widget _buildTryoutSection(bool isDark) {
    final packageProvider = Provider.of<PackageProvider>(context);
    final packages = packageProvider.packages;

    final List<Map<String, dynamic>> defaultTryouts = [
      {
        'title': 'Simulasi Ujian Matematika Nalaria Terpadu',
        'sub': '60 Menit • 20 Soal • Pembahasan Komprehensif',
        'tag': 'UJIAN UTAMA',
        'pkgId': packages.isNotEmpty ? packages.first.id : 'pkg_kpm_1',
      },
      {
        'title': 'Mini Tryout Logika & Sains MIPA',
        'sub': '30 Menit • 10 Soal • Evaluasi Cepat',
        'tag': 'SIMULASI CEPAT',
        'pkgId': packages.length > 1 ? packages[1].id : 'pkg_kpm_2',
      },
      {
        'title': 'Evaluasi Hasil & Rapor Skor Ujian',
        'sub': 'Lihat detail jawaban, akurasi, dan perbaikan',
        'tag': 'RAPOR SKOR',
        'route': '/result',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: defaultTryouts.length,
      itemBuilder: (context, index) {
        final item = defaultTryouts[index];
        final bool isResult = item['route'] != null;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppTheme.bentoBoxDecoration(context: context),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isResult ? AppTheme.kpmGold.withValues(alpha: 0.1) : AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isResult ? Icons.analytics_outlined : Icons.assignment_outlined,
                  color: isResult ? AppTheme.kpmGold : AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['sub'],
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isResult ? AppTheme.kpmGold : AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(54, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (isResult) {
                    Navigator.pushNamed(context, '/result');
                  } else {
                    AuthGuard.check(
                      context,
                      featureName: item['title'],
                      onAuthenticated: () => Navigator.pushNamed(
                        context,
                        '/pretest',
                        arguments: item['pkgId'],
                      ),
                    );
                  }
                },
                child: Text(isResult ? 'Lihat' : 'Mulai', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSoalHarianSection(bool isDark) {
    final List<Map<String, dynamic>> soalHarian = [
      {'title': 'Soal Harian: Logika Aritmatika Nalaria', 'sub': '5 Menit • 5 Soal • Kategori Logika', 'code': 'SH_01'},
      {'title': 'Soal Harian: Analisis Pola Bilangan MIPA', 'sub': '5 Menit • 5 Soal • Kategori Aljabar', 'code': 'SH_02'},
      {'title': 'Soal Harian: Pemecahan Masalah Geometri', 'sub': '5 Menit • 5 Soal • Kategori Geometri', 'code': 'SH_03'},
      {'title': 'Soal Harian: Eksperimen Penalaran Sains', 'sub': '5 Menit • 5 Soal • Kategori Sains', 'code': 'SH_04'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: soalHarian.length,
      itemBuilder: (context, index) {
        final sh = soalHarian[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppTheme.bentoBoxDecoration(context: context),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.kpmSky.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.quiz_outlined, color: AppTheme.kpmSky, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sh['title'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sh['sub'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kpmSky,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(54, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => AuthGuard.check(
                  context,
                  featureName: sh['title'] as String,
                  onAuthenticated: () => Navigator.pushNamed(context, '/exam', arguments: sh['code']),
                ),
                child: const Text('Kerjakan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBankSoalSection(bool isDark) {
    final List<Map<String, dynamic>> bankSoal = [
      {'title': 'Bank Soal Matematika Nalaria SD/SMP', 'sub': '150+ Soal & Pembahasan Lengkap'},
      {'title': 'Bank Soal Sains & Olimpiade MIPA', 'sub': '120+ Soal Terstandar KPM'},
      {'title': 'Bank Soal Asesmen Kompetensi Nasional', 'sub': '100+ Soal Latihan Mandiri'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: bankSoal.length,
      itemBuilder: (context, index) {
        final bs = bankSoal[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppTheme.bentoBoxDecoration(context: context),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book_outlined, color: AppTheme.primaryPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bs['title'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bs['sub'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(54, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/package_list'),
                child: const Text('Buka', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
