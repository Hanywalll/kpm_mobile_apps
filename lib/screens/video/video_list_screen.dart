import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  String _selectedSubject = 'Semua';
  final List<String> _subjects = ['Semua', 'Matematika', 'Fisika', 'Kimia', 'TPS UTBK'];

  final List<Map<String, dynamic>> _videos = [
    {
      'title': 'Trik Cepat TPS Kuantitatif SNBT',
      'subject': 'TPS UTBK',
      'tutor': 'Dr. Budi Pratama, M.Sc.',
      'duration': '18:45',
      'gradient': AppTheme.ruangguruGradient,
      'views': '12.4K Selesai Nonton',
    },
    {
      'title': 'Konsep Dasar Kalkulus & Turunan',
      'subject': 'Matematika',
      'tutor': 'Siti Rahma, S.Si.',
      'duration': '22:10',
      'gradient': AppTheme.purpleGradient,
      'views': '9.8K Selesai Nonton',
    },
    {
      'title': 'Hukum Newton & Kinematika Gerak',
      'subject': 'Fisika',
      'tutor': 'Ir. Ahmad Fauzi',
      'duration': '15:30',
      'gradient': AppTheme.emeraldGradient,
      'views': '15.1K Selesai Nonton',
    },
    {
      'title': 'Stoikiometri & Reaksi Kimia Dasar',
      'subject': 'Kimia',
      'tutor': 'Dr. Maya Kartika',
      'duration': '20:00',
      'gradient': AppTheme.orangeGradient,
      'views': '8.2K Selesai Nonton',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedSubject == 'Semua'
        ? _videos
        : _videos.where((v) => v['subject'] == _selectedSubject).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Video Pembelajaran 🎥'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final sub = _subjects[index];
                final isSelected = sub == _selectedSubject;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(sub),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryPurple,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryPurple : Colors.grey.shade300,
                      ),
                    ),
                    onSelected: (val) {
                      setState(() => _selectedSubject = sub);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final v = filtered[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/video_player', arguments: v);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                          width: 120,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: v['gradient'],
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 44),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    v['duration'],
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryPurple.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    v['subject'],
                                    style: const TextStyle(fontSize: 10, color: AppTheme.primaryPurple, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  v['title'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  v['tutor'],
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
