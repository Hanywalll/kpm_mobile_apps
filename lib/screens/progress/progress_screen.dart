import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/pattern_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Progress & Achievement 📊'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '📊 Performa & Nilai'),
            Tab(text: '🏆 Badges & Streak'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPerformaSection(),
          _buildAchievementSection(),
        ],
      ),
    );
  }

  Widget _buildPerformaSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        PatternCard(
          title: 'Skor IRT Tryout Terakhir: 850 / 1000',
          subtitle: 'Peluang Lulus ITB Informatika: 92% 🎯',
          badge: '📈 ESTIMASI KELULUSAN SANGAT TINGGI',
          icon: Icons.trending_up_rounded,
          gradient: AppTheme.ruangguruGradient,
          onTap: () => Navigator.pushNamed(context, '/result'),
        ),
        const SizedBox(height: 10),
        const Text('Performa per Mata Pelajaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _performaTile('TPS Penalaran Umum', '92% Akurasi', 0.92, Colors.green),
        _performaTile('TPS Kuantitatif', '85% Akurasi', 0.85, Colors.blue),
        _performaTile('Literasi Bahasa Indonesia', '88% Akurasi', 0.88, Colors.orange),
        _performaTile('Literasi Bahasa Inggris', '78% Akurasi', 0.78, Colors.purple),
      ],
    );
  }

  Widget _buildAchievementSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        const PatternCard(
          title: '🔥 7 Hari Belajar Berturut-turut!',
          subtitle: 'Konsistensi adalah kunci sukses SNBT. Pertahankan!',
          badge: 'STREAK MASTER',
          icon: Icons.local_fire_department_rounded,
          gradient: AppTheme.orangeGradient,
        ),
        const SizedBox(height: 10),
        const Text('Koleksi Badges 🎖️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _badgeItem('🔥 7 Day Streak', Colors.orange, true),
            _badgeItem('🏆 Top 10 IRT', Colors.amber, true),
            _badgeItem('📚 100 Soal HOTS', Colors.blue, true),
            _badgeItem('🎯 Perfect Score', Colors.purple, false),
            _badgeItem('⚡ Speed Master', Colors.green, false),
            _badgeItem('🎓 SNBT Pass', Colors.red, false),
          ],
        ),
      ],
    );
  }

  Widget _performaTile(String mapel, String acc, double progress, Color color) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mapel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(acc, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeItem(String title, Color color, bool unlocked) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: unlocked ? color.withOpacity(0.12) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: unlocked ? color : Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            unlocked ? Icons.verified_rounded : Icons.lock_rounded,
            color: unlocked ? color : Colors.grey,
            size: 30,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: unlocked ? AppTheme.textPrimary : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
