import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/practice_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PracticeProvider>(context, listen: false).fetchStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final practice = Provider.of<PracticeProvider>(context);
    final stats = practice.statistics;

    final double avgScore = stats?.avgScore ?? 0.0;
    final int totalSessions = stats?.totalSessions ?? 0;
    final int totalCorrect = stats?.totalCorrect ?? 0;
    final int totalWrong = stats?.totalWrong ?? 0;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Progress Belajar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Summary Score Card (Modern Blue Gradient)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppTheme.blueGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'EVALUASI KOMPREHENSIF',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      '$totalSessions Sesi Selesai',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      avgScore.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text('/ 100', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Rapor Aktif',
                        style: TextStyle(color: AppTheme.primaryBlueDark, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Quick Correct / Wrong Counter Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: AppTheme.bentoBoxDecoration(context: context),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: AppTheme.primaryBlue, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$totalCorrect',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Jawaban Benar',
                            style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: AppTheme.bentoBoxDecoration(context: context),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.red, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$totalWrong',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Jawaban Salah',
                            style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3. Visualisasi Grafik Batang
          Text(
            'Grafik Performa Mingguan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.bentoBoxDecoration(context: context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nilai Evaluasi 7 Hari Terakhir',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Rata-rata: 85%',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryBlueDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildBarChart(isDark),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 4. Performa per Bidang Studi (Persentase Saja)
          Text(
            'Penguasaan Bidang Studi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildSubjectPerformanceCard('Matematika Nalaria Realistik', 92, AppTheme.primaryBlue, isDark),
          _buildSubjectPerformanceCard('Logika & Penalaran Pola', 85, AppTheme.kpmSky, isDark),
          _buildSubjectPerformanceCard('Sains & Konsep MIPA', 78, AppTheme.kpmGold, isDark),
          _buildSubjectPerformanceCard('Eksperimen & Analisis Masalah', 88, AppTheme.primaryPurple, isDark),
        ],
      ),
    );
  }

  // Grafik Batang Flat Modern
  Widget _buildBarChart(bool isDark) {
    final List<Map<String, dynamic>> barData = [
      {'day': 'Sen', 'val': 75},
      {'day': 'Sel', 'val': 80},
      {'day': 'Rab', 'val': 65},
      {'day': 'Kam', 'val': 90},
      {'day': 'Jum', 'val': 85},
      {'day': 'Sab', 'val': 95},
      {'day': 'Min', 'val': 88},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: barData.map((d) {
        final int val = d['val'] as int;
        final double heightFactor = (val / 100.0) * 110;
        final bool isHighest = val >= 95;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$val',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isHighest ? AppTheme.primaryBlue : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 22,
              height: heightFactor,
              decoration: BoxDecoration(
                color: isHighest ? AppTheme.primaryBlue : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              d['day'] as String,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isHighest ? FontWeight.bold : FontWeight.w500,
                color: isHighest ? AppTheme.primaryBlue : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // Card Bidang Studi dengan Persentase Murni (Tanpa "Mahir")
  Widget _buildSubjectPerformanceCard(String subject, int percentage, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              subject,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
