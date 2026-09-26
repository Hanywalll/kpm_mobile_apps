import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/practice_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final practice = Provider.of<PracticeProvider>(context);
    final result = practice.lastResult;

    final double score = (result != null && result.totalScore > 0)
        ? (result.totalScore > 100 ? result.totalScore / 10 : result.totalScore)
        : 85.0;
    final int correct = result?.correctAnswer ?? 17;
    final int wrong = result?.wrongAnswer ?? 3;
    final int empty = 0;
    final int total = (correct + wrong + empty) > 0 ? (correct + wrong + empty) : 20;
    final int accuracy = ((correct / total) * 100).round();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context, onPressed: () {
          Navigator.pushReplacementNamed(context, '/home');
        }),
        title: const Text('Rapor Skor & Evaluasi Ujian'),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Primary Score Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.blueGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
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
                          'HASIL UJIAN KPM',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Predikat: A (Sangat Baik)',
                          style: TextStyle(color: AppTheme.primaryBlueDark, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        score.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6, left: 4),
                        child: Text(
                          '/ 100 Poin',
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Status Kelulusan', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LULUS KKM (75.0)',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Metric Counters Row
            Row(
              children: [
                _metricCounterTile('Benar', '$correct', AppTheme.accentGreen, Icons.check_circle_outline_rounded, isDark),
                const SizedBox(width: 8),
                _metricCounterTile('Salah', '$wrong', Colors.redAccent, Icons.highlight_off_rounded, isDark),
                const SizedBox(width: 8),
                _metricCounterTile('Akurasi', '$accuracy%', AppTheme.primaryBlue, Icons.pie_chart_outline_rounded, isDark),
                const SizedBox(width: 8),
                _metricCounterTile('Waktu', '24 Mnt', AppTheme.kpmGold, Icons.timer_outlined, isDark),
              ],
            ),
            const SizedBox(height: 18),

            // 3. Detail Analisis Topik / Bab
            Text(
              'Detail Pemahaman per Topik',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.bentoBoxDecoration(context: context),
              child: Column(
                children: [
                  _topicProgressRow('Matematika Nalaria Realistik (MNR)', 5, 5, AppTheme.primaryBlue, isDark),
                  const Divider(height: 16),
                  _topicProgressRow('Logika & Penalaran Pola', 4, 5, AppTheme.kpmSky, isDark),
                  const Divider(height: 16),
                  _topicProgressRow('Sains & Konsep MIPA', 4, 5, AppTheme.kpmGold, isDark),
                  const Divider(height: 16),
                  _topicProgressRow('Pemecahan Masalah & Analisis', 4, 5, AppTheme.primaryPurple, isDark),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 4. Peta Distribusi Butir Soal (1 - 20)
            Text(
              'Peta Lembar Jawaban Soal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.bentoBoxDecoration(context: context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _legendBullet(AppTheme.accentGreen, 'Benar ($correct)'),
                      const SizedBox(width: 12),
                      _legendBullet(Colors.redAccent, 'Salah ($wrong)'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(total, (i) {
                      // Mark questions 5, 12, 17 as wrong in demo
                      final bool isWrongQ = (i == 4 || i == 11 || i == 16);
                      final Color qColor = isWrongQ ? Colors.redAccent : AppTheme.accentGreen;

                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: qColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: qColor.withValues(alpha: 0.5)),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: qColor,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/review'),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('Buka Pembahasan Lengkap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : AppTheme.textPrimary,
                  side: BorderSide(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _metricCounterTile(String label, String value, Color color, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topicProgressRow(String topic, int correct, int total, Color color, bool isDark) {
    final double percent = (correct / total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                topic,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$correct / $total Benar',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 5,
            backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _legendBullet(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
      ],
    );
  }
}
