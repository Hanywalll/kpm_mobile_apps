import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/video_model.dart';
import '../../services/video_service.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  String _selectedSubject = 'Semua';
  final List<String> _subjects = ['Semua', 'Matematika', 'Sains/Fisika', 'Kimia', 'Olimpiade'];
  List<VideoModel> _videos = VideoService.getDemoVideosList();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  void _loadVideos() async {
    final videoService = Provider.of<VideoService>(context, listen: false);
    final list = await videoService.getVideos();
    if (mounted && list.isNotEmpty) {
      setState(() {
        _videos = list;
        _isLoading = false;
      });
    }
  }

  List<VideoModel> get _filteredVideos {
    if (_selectedSubject == 'Semua') return _videos;
    final q = _selectedSubject.toLowerCase();
    return _videos.where((v) {
      final t = v.title.toLowerCase();
      final d = v.description.toLowerCase();
      if (q.contains('matematika')) return t.contains('matematika') || t.contains('logaritma') || t.contains('eksponen') || t.contains('tps');
      if (q.contains('fisika') || q.contains('sains')) return t.contains('fisika') || t.contains('kinematika') || t.contains('gerak') || d.contains('fisika');
      if (q.contains('kimia')) return t.contains('kimia') || t.contains('stoikiometri') || d.contains('kimia');
      if (q.contains('olimpiade')) return t.contains('olimpiade') || t.contains('mnr') || d.contains('olimpiade');
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final videos = _filteredVideos;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Video Pembelajaran KPM'),
      ),
      body: Column(
        children: [
          // Minimalist Compact Grey Horizontal Category Tabs
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final cat = _subjects[index];
                final isSelected = cat == _selectedSubject;

                return GestureDetector(
                  onTap: () => setState(() => _selectedSubject = cat),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF475569) : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: _isLoading && videos.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : videos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam_off_outlined, size: 54, color: Colors.grey),
                            const SizedBox(height: 10),
                            const Text('Belum ada video untuk kategori ini.', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => setState(() => _selectedSubject = 'Semua'),
                              child: const Text('Lihat Semua Video'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadVideos(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const ClampingScrollPhysics(),
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            final vid = videos[index];
                            return _buildCompactVideoCard(context, vid, isDark);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactVideoCard(BuildContext context, VideoModel vid, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Thumbnail Banner with Play Overlay
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/video_player', arguments: vid),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    color: const Color(0xFF1E293B),
                    child: CachedNetworkImage(
                      imageUrl: vid.safeThumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppTheme.blueGradient,
                        ),
                        child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppTheme.blueGradient,
                        ),
                        child: const Icon(Icons.videocam_rounded, color: Colors.white54, size: 48),
                      ),
                    ),
                  ),

                  // Semi-transparent Play Button
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 1.5),
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                  ),

                  // Duration Badge
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            vid.durationFormatted,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Free / Premium Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: vid.isFree ? AppTheme.accentGreen : const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vid.isFree ? 'AKSES GRATIS' : 'PREMIUM KPM',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vid.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                if (vid.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    vid.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Divider(height: 1, color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.hd_rounded, size: 16, color: AppTheme.primaryBlue),
                        SizedBox(width: 4),
                        Text(
                          '1080p Full HD • Tutor KPM',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/video_player', arguments: vid),
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text('Putar Video', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
