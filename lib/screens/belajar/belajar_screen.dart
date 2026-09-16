import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/pattern_card.dart';

class BelajarScreen extends StatefulWidget {
  const BelajarScreen({super.key});

  @override
  State<BelajarScreen> createState() => _BelajarScreenState();
}

class _BelajarScreenState extends State<BelajarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Menu Belajar 📚'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '🎓 Kelas Saya'),
            Tab(text: '📖 Materi & Modul'),
            Tab(text: '🎥 Video Pembelajaran'),
            Tab(text: '📄 Rangkuman'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKelasSayaSection(),
          _buildMateriSection(),
          _buildVideoSection(),
          _buildRangkumanSection(),
        ],
      ),
    );
  }

  Widget _buildKelasSayaSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        PatternCard(
          title: 'Kelas TPS Kuantitatif SNBT',
          subtitle: 'Tutor: Dr. Budi Pratama • 18/20 Modul Selesai',
          badge: '⚡ KELAS AKTIF (90%)',
          icon: Icons.school_rounded,
          gradient: AppTheme.ruangguruGradient,
          onTap: () => Navigator.pushNamed(context, '/package_detail'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 0.9,
                  minHeight: 8,
                  backgroundColor: Colors.white30,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Lanjutkan Bab 19: Logaritma', style: TextStyle(color: Colors.white, fontSize: 12)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Text('Lanjut ▶', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ),
        PatternCard(
          title: 'Kelas Intensif Fisika MIPA',
          subtitle: 'Tutor: Ir. Ahmad Fauzi • 10/15 Modul Selesai',
          badge: '📚 KELAS AKTIF (66%)',
          icon: Icons.science_rounded,
          gradient: AppTheme.purpleGradient,
          onTap: () => Navigator.pushNamed(context, '/package_detail'),
        ),
        PatternCard(
          title: 'Kelas Kimia Dasar & Reaksi',
          subtitle: 'Tutor: Dr. Maya Kartika • Selesai 100%',
          badge: '✅ KELAS SELESAI',
          icon: Icons.verified_rounded,
          gradient: AppTheme.emeraldGradient,
          onTap: () => Navigator.pushNamed(context, '/package_detail'),
        ),
      ],
    );
  }

  Widget _buildMateriSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        const Text('Modul Belajar & PDF 📄', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _materiTile('Modul TPS Penalaran Umum', '24 Halaman PDF • 12 MB', AppTheme.primaryBlue, Icons.menu_book_rounded),
        _materiTile('Modul Fisika Kinematika & Dinamika', '18 Halaman PDF • 8 MB', AppTheme.primaryPurple, Icons.auto_stories_rounded),
        _materiTile('Modul Kimia Ikatan & Larutan', '30 Halaman PDF • 15 MB', AppTheme.accentGreen, Icons.science_rounded),
      ],
    );
  }

  Widget _buildVideoSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        PatternCard(
          title: 'Streaming Video Pembelajaran HD',
          subtitle: 'Akses 100+ video penjelasan konsep dari Master Tutor.',
          badge: '🎥 FULL AKSES',
          icon: Icons.play_circle_fill_rounded,
          gradient: AppTheme.orangeGradient,
          onTap: () => Navigator.pushNamed(context, '/video_list'),
        ),
      ],
    );
  }

  Widget _buildRangkumanSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _materiTile('Rangkuman Rumus Cepat Matematika', 'Cheatsheet Rumus UTBK', Colors.orange, Icons.stars_rounded),
        _materiTile('Rangkuman Tata Nama Kimia Organik', 'Infografis Ringkas', Colors.purple, Icons.auto_awesome_rounded),
      ],
    );
  }

  Widget _materiTile(String title, String sub, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 26),
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
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppTheme.primaryBlue),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
