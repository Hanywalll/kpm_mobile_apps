import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/package_model.dart';
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
    final enrolled = packageProvider.enrolledPackages;

    if (enrolled.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_late_outlined, size: 48, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 16),
              Text(
                'Tryout CBT Terikat Paket Belajar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Simulasi Ujian Online (CBT) dan tryout terstandar disesuaikan dengan kurikulum paket belajar yang Anda miliki. Aktifkan paket belajar untuk mulai mengerjakan tryout!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => Navigator.pushNamed(context, '/package_list'),
                icon: const Icon(Icons.school_rounded, size: 16),
                label: const Text('Pilih Paket Belajar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/result'),
                icon: const Icon(Icons.analytics_outlined, size: 16, color: AppTheme.kpmGold),
                label: const Text('Lihat Riwayat Skor & Evaluasi Terakhir', style: TextStyle(fontSize: 12, color: AppTheme.kpmGold, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }

    final List<Map<String, dynamic>> tryouts = [];

    // Dynamically populate tryouts from enrolled packages
    for (final pkg in enrolled) {
      final cards = pkg.parsedCards;
      for (final card in cards) {
        tryouts.add({
          'title': 'Tryout CBT: ${pkg.title}',
          'sub': '${card.title} • ${card.durationMinutes} Menit • ${card.totalQuestions} Soal • ${pkg.jenjang} ${pkg.kelas}',
          'tag': 'CBT AKTIF',
          'pkgId': pkg.id,
        });
      }
    }

    // Append report card entry
    tryouts.add({
      'title': 'Evaluasi Hasil & Rapor Skor Ujian',
      'sub': 'Lihat detail jawaban, akurasi pengerjaan, dan analisis kemampuan',
      'tag': 'RAPOR SKOR',
      'route': '/result',
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: tryouts.length,
      itemBuilder: (context, index) {
        final item = tryouts[index];
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
    final packageProvider = Provider.of<PackageProvider>(context);
    final enrolled = packageProvider.enrolledPackages;

    if (enrolled.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded, size: 48, color: AppTheme.primaryPurple),
              ),
              const SizedBox(height: 16),
              Text(
                'Bank Soal Terikat Paket Belajar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bank soal dan pembahasan nalar lengkap disesuaikan secara khusus dengan kurikulum paket belajar yang Anda miliki. Aktifkan paket belajar untuk membuka bank soal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => Navigator.pushNamed(context, '/package_list'),
                icon: const Icon(Icons.school_rounded, size: 16),
                label: const Text('Pilih Paket Belajar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
      );
    }

    final List<Map<String, dynamic>> bankSoal = enrolled.map((pkg) => {
      'title': 'Bank Soal: ${pkg.title}',
      'sub': 'Koleksi Soal Terstruktur ${pkg.jenjang} • Kelas ${pkg.kelas} • Pembahasan Lengkap',
      'pkg': pkg,
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: bankSoal.length,
      itemBuilder: (context, index) {
        final bs = bankSoal[index];
        final pkg = bs['pkg'] as PackageModel;
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
                onPressed: () => Navigator.pushNamed(context, '/video_list', arguments: pkg),
                child: const Text('Buka', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
