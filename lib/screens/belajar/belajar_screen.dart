import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/module_model.dart';
import '../../models/video_model.dart';
import '../../providers/package_provider.dart';
import '../../services/dashboard_service.dart';
import '../../services/video_service.dart';

class BelajarScreen extends StatefulWidget {
  const BelajarScreen({super.key});

  @override
  State<BelajarScreen> createState() => _BelajarScreenState();
}

class _BelajarScreenState extends State<BelajarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<VideoModel> _videos = VideoService.getDemoVideosList();
  List<ModuleModel> _modules = DashboardService.getDefaultModules();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadVideos();
    _loadModules();
  }

  void _loadModules() async {
    try {
      final dashboardService = Provider.of<DashboardService>(context, listen: false);
      final list = await dashboardService.getModules();
      if (mounted && list.isNotEmpty) {
        setState(() => _modules = list);
      }
    } catch (_) {}
  }

  void _loadVideos() async {
    final videoService = Provider.of<VideoService>(context, listen: false);
    final list = await videoService.getVideos();
    if (mounted && list.isNotEmpty) {
      setState(() => _videos = list);
    }
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
        title: const Text('Menu Belajar KPM'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: AppTheme.compactTabBar(
            controller: _tabController,
            tabs: const ['Kelas Saya', 'Materi & Modul', 'Video Belajar'],
            context: context,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKelasSayaSection(isDark),
          _buildMateriSection(isDark),
          _buildVideoSection(isDark),
        ],
      ),
    );
  }

  // Pipih / Compact Card Kelas Saya
  Widget _buildKelasSayaSection(bool isDark) {
    final packageProvider = Provider.of<PackageProvider>(context);
    final packages = packageProvider.packages;

    if (packageProvider.isLoading && packages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 48, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
            const SizedBox(height: 8),
            Text(
              'Belum ada kelas yang diikuti',
              style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final pkg = packages[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppTheme.bentoBoxDecoration(context: context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.school_rounded, color: AppTheme.primaryBlue, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pkg.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${pkg.kelas.isNotEmpty ? pkg.kelas : "Semua Jenjang"} • ${pkg.totalCards > 0 ? "${pkg.totalCards} Modul" : "Kartu Materi Aktif"}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 0.75,
                  minHeight: 5,
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progres Belajar: 75%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      packageProvider.fetchPackageDetail(pkg.id);
                      Navigator.pushNamed(context, '/package_detail', arguments: pkg);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Lanjut', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(width: 3),
                          Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Materi & Modul (Clean & Compact)
  Widget _buildMateriSection(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: _modules.length,
      itemBuilder: (context, index) {
        final m = _modules[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppTheme.bentoBoxDecoration(context: context),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_outlined, color: AppTheme.primaryBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${m.description} • ${m.fileSize}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.download_for_offline_outlined, size: 20, color: AppTheme.primaryBlue),
            ],
          ),
        );
      },
    );
  }

  // Unified Video Pembelajaran Tab (Real VideoModel from VideoService)
  Widget _buildVideoSection(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final vid = _videos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.bentoBoxDecoration(context: context),
          child: Row(
            children: [
              // Thumbnail box with play icon
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/video_player', arguments: vid),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 54,
                        color: const Color(0xFF1E293B),
                        child: CachedNetworkImage(
                          imageUrl: vid.safeThumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const Icon(Icons.videocam_rounded, color: Colors.white54, size: 24),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vid.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.hd_rounded, size: 13, color: AppTheme.primaryBlue),
                        const SizedBox(width: 3),
                        Text(
                          'HD • ${vid.durationFormatted}',
                          style: const TextStyle(fontSize: 10, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Watch Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/video_player', arguments: vid),
                child: const Text('Tonton', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
