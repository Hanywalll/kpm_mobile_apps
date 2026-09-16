import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/pattern_card.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key});

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> with SingleTickerProviderStateMixin {
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
        title: const Text('Live Class & Tutor 👨‍🏫'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '🎥 Live Class'),
            Tab(text: '👨‍🏫 Tutor Les Privat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveClassSection(),
          _buildTutorSection(),
        ],
      ),
    );
  }

  Widget _buildLiveClassSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        PatternCard(
          title: 'Live Class: Strategi Lulus UTBK 2025',
          subtitle: 'Dr. Budi Pratama • Hari Ini, 19:30 WIB',
          badge: '🔴 SEDANG BERLANGSUNG',
          icon: Icons.live_tv_rounded,
          gradient: AppTheme.purpleGradient,
          onTap: () => Navigator.pushNamed(context, '/video_player'),
        ),
        const PatternCard(
          title: 'Jadwal Besok: Bedah Soal Penalaran Matematika',
          subtitle: 'Siti Rahma, S.Si. • Besok, 16:00 WIB',
          badge: '📅 JADWAL MENDATANG',
          icon: Icons.event_rounded,
          gradient: AppTheme.ruangguruGradient,
        ),
      ],
    );
  }

  Widget _buildTutorSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _tutorCard('Dr. Budi Pratama, M.Sc.', 'Master Tutor Matematika', '⭐ 4.9 • 1,200 Sesi', AppTheme.primaryBlue),
        _tutorCard('Siti Rahma, S.Si.', 'Tutor Fisika & IPA', '⭐ 4.8 • 950 Sesi', AppTheme.primaryPurple),
        _tutorCard('Ir. Ahmad Fauzi', 'Tutor Kimia SBMPTN', '⭐ 4.9 • 1,100 Sesi', AppTheme.accentGreen),
      ],
    );
  }

  Widget _tutorCard(String name, String sub, String stats, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.15),
            child: Text(name[0], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(stats, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              minimumSize: const Size(60, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pushNamed(context, '/ai_chat'),
            child: const Text('Chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
