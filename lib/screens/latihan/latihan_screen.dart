import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/auth_guard_bottom_sheet.dart';
import '../../widgets/pattern_card.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Latihan & Tryout 📝'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '🏆 Tryout & CBT'),
            Tab(text: '✍️ Soal Harian'),
            Tab(text: '📚 Bank Soal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTryoutSection(),
          _buildSoalHarianSection(),
          _buildBankSoalSection(),
        ],
      ),
    );
  }

  Widget _buildTryoutSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        PatternCard(
          title: 'Simulasi Tryout SNBT 2025 #1',
          subtitle: 'Durasi: 60 Menit • 20 Soal • Sistem Penilaian IRT',
          badge: '🔥 TRYOUT UTAMA',
          icon: Icons.assignment_rounded,
          gradient: AppTheme.orangeGradient,
          onTap: () => AuthGuard.check(
            context,
            featureName: 'Simulasi Tryout SNBT',
            onAuthenticated: () => Navigator.pushNamed(context, '/pretest'),
          ),
        ),
        PatternCard(
          title: 'Tryout Mini TPS Kuantitatif',
          subtitle: 'Durasi: 30 Menit • 10 Soal HOTS',
          badge: '⚡ SIMULASI CEPAT',
          icon: Icons.timer_rounded,
          gradient: AppTheme.ruangguruGradient,
          onTap: () => AuthGuard.check(
            context,
            featureName: 'Tryout Mini TPS',
            onAuthenticated: () => Navigator.pushNamed(context, '/pretest'),
          ),
        ),
        PatternCard(
          title: 'Hasil Tryout Terakhir (85.0)',
          subtitle: 'Akurasi 85% • Rank #3 dari 1,250 Peserta',
          badge: '📊 RAPORT & PEMBAHASAN',
          icon: Icons.analytics_rounded,
          gradient: AppTheme.emeraldGradient,
          onTap: () => AuthGuard.check(
            context,
            featureName: 'Raport & Pembahasan',
            onAuthenticated: () => Navigator.pushNamed(context, '/result'),
          ),
        ),
      ],
    );
  }

  Widget _buildSoalHarianSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        const Text('Tantangan Soal Harian 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _soalCard('Soal Harian #102: Logaritma & Eksponen', 'Estimasi 5 Menit • +20 XP', Colors.blue),
        _soalCard('Soal Harian #101: Kinematika Vektor', 'Estimasi 5 Menit • +20 XP', Colors.purple),
        _soalCard('Soal Harian #100: Reaksi Redoks', 'Estimasi 5 Menit • +20 XP', Colors.green),
      ],
    );
  }

  Widget _buildBankSoalSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _soalCard('Bank Soal TPS UTBK (500+ Soal)', 'Pembahasan Lengkap per-Bab', Colors.indigo),
        _soalCard('Bank Soal Fisika Terpadu', 'Materi Kelas 10, 11, 12', Colors.red),
        _soalCard('Bank Soal Kimia SBMPTN / SNBT', 'Latihan Mandiri Interaktif', Colors.teal),
      ],
    );
  }

  Widget _soalCard(String title, String sub, Color color) {
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.quiz_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              minimumSize: const Size(60, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => AuthGuard.check(
              context,
              featureName: title,
              onAuthenticated: () => Navigator.pushNamed(context, '/pretest'),
            ),
            child: const Text('Mulai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
