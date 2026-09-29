import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../models/banner_model.dart';
import '../../models/live_class_model.dart';
import '../../models/module_model.dart';
import '../../models/package_model.dart';
import '../../models/video_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/package_provider.dart';
import '../../services/admin_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/package_service.dart';
import '../../services/video_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminDashboardStats _stats = AdminDashboardStats();
  bool _isLoading = true;

  // Selected filter for content management
  String _selectedSection = 'all'; // 'all', 'banner', 'live', 'package', 'video', 'module', 'voucher'

  List<BannerModel> _banners = [];
  List<LiveClassModel> _liveClasses = [];
  List<ModuleModel> _modules = [];
  List<VideoModel> _videos = [];

  final List<Map<String, dynamic>> _vouchers = [
    {'code': 'KPMJUARA2026', 'title': 'Diskon 25% Persiapan Ujian', 'discount': '25%', 'usage': '142/500'},
    {'code': 'MNRINDONESIA', 'title': 'Potongan Rp 50.000 Belajar', 'discount': 'Rp 50rb', 'usage': '89/300'},
    {'code': 'MIPABERSAMA', 'title': 'Cashback 15% Ujian Online', 'discount': '15%', 'usage': '210/1000'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllAdminData();
  }

  void _loadAllAdminData() async {
    setState(() => _isLoading = true);
    try {
      final adminService = Provider.of<AdminService>(context, listen: false);
      final dashboardService = Provider.of<DashboardService>(context, listen: false);
      final videoService = Provider.of<VideoService>(context, listen: false);

      final stats = await adminService.getDashboardStats();
      final banners = await dashboardService.getBanners();
      final liveClasses = await dashboardService.getLiveClasses();
      final modules = await dashboardService.getModules();
      final videos = await videoService.getVideos();

      if (mounted) {
        setState(() {
          _stats = stats;
          _banners = banners;
          _liveClasses = liveClasses;
          _modules = modules;
          _videos = videos;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final packageProvider = Provider.of<PackageProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Security Guard: Check Admin role
    if (!authProvider.isAdmin) {
      return _buildAccessDeniedScreen(context, authProvider, isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, authProvider, isDark),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Memuat Panel Kontrol CMS...', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadAllAdminData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Welcome & Server Status Hero Card
                    _buildHeroHeader(authProvider, isDark),

                    const SizedBox(height: 16),

                    // 2. Executive Analytics Bento Cards (Zero-Overflow Layout)
                    _buildAnalyticsBentoGrid(isDark),

                    const SizedBox(height: 20),

                    // 3. CMS Control Hub Modules (Grid Selector)
                    _buildCMSModuleGrid(packageProvider, isDark),

                    const SizedBox(height: 24),

                    // 4. Content Management Header with Filter Pills
                    _buildContentSectionHeader(isDark),

                    const SizedBox(height: 12),

                    // 5. Active Managed Components List
                    _buildManagedComponentsList(packageProvider, isDark),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('Tambah Konten', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        onPressed: () => _showQuickAddBottomSheet(isDark),
      ),
    );
  }

  // --- AppBar ---
  PreferredSizeWidget _buildAppBar(BuildContext context, AuthProvider authProvider, bool isDark) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      leading: Navigator.canPop(context)
          ? AppTheme.backButton(context)
          : Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primaryBlue, size: 22),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('KPM Control Panel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('CMS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          Text(
            'Administrator Console',
            style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
          ),
        ],
      ),
      actions: [
        // Tinjau Mode Siswa Button
        IconButton(
          icon: const Icon(Icons.remove_red_eye_outlined),
          tooltip: 'Tinjau Tampilan Siswa',
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        // Refresh Button
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Perbarui Data',
          onPressed: _loadAllAdminData,
        ),
        // Logout Button
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          tooltip: 'Keluar dari Admin',
          onPressed: () => _confirmLogout(context, authProvider),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // --- 1. Welcome & Status Hero Card ---
  Widget _buildHeroHeader(AuthProvider authProvider, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
              : [const Color(0xFF1E3A8A), const Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
            blurRadius: 12,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Color(0xFF4ADE80), size: 8),
                    SizedBox(width: 6),
                    Text('Go Backend Online & Realtime', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.visibility_outlined, size: 14),
                label: const Text('Mode Siswa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pushNamed(context, '/home'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Selamat Datang, Administrator 👋',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelola seluruh konten, banner, live streaming, paket belajar & materi ujian yang tampil di aplikasi siswa.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  // --- 2. Executive Analytics Bento Grid (Responsive & Overflow Free) ---
  Widget _buildAnalyticsBentoGrid(bool isDark) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      children: [
        // Primary Revenue Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF10B981), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pendapatan Kursus',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currencyFormatter.format(_stats.totalRevenue),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 4),
                    Text('+18.4%', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 2x2 Responsive Metric Sub-Cards
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Total Siswa',
                value: '${_stats.totalUsers}',
                subtitle: 'Siswa Terdaftar',
                icon: Icons.people_alt_rounded,
                color: const Color(0xFF2563EB),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Pesanan Masuk',
                value: '${_stats.totalOrders}',
                subtitle: 'Transaksi Lunas',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF0891B2),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  // --- 3. CMS Control Hub Modules (Grid Cards) ---
  Widget _buildCMSModuleGrid(PackageProvider packageProvider, bool isDark) {
    final modules = [
      {
        'id': 'banner',
        'title': 'Banner Slider',
        'count': '${_banners.length} Aktif',
        'icon': Icons.view_carousel_rounded,
        'color': const Color(0xFF3B82F6),
      },
      {
        'id': 'live',
        'title': 'Live Class Zoom',
        'count': '${_liveClasses.length} Sesi',
        'icon': Icons.videocam_rounded,
        'color': const Color(0xFFEF4444),
      },
      {
        'id': 'package',
        'title': 'Paket Tryout',
        'count': '${packageProvider.packages.length} Paket',
        'icon': Icons.inventory_2_rounded,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'id': 'video',
        'title': 'Video Materi HD',
        'count': '${_videos.length} Video',
        'icon': Icons.play_circle_fill_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'id': 'module',
        'title': 'Modul E-Book',
        'count': '${_modules.length} PDF',
        'icon': Icons.picture_as_pdf_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'id': 'voucher',
        'title': 'Kupon Diskon',
        'count': '${_vouchers.length} Kupon',
        'icon': Icons.confirmation_number_rounded,
        'color': const Color(0xFFEC4899),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Modul Pengelolaan CMS',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
            ),
            Text(
              'Pilih untuk fokus',
              style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final item = modules[index];
            final isSelected = _selectedSection == item['id'];
            final Color color = item['color'] as Color;

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  _selectedSection = isSelected ? 'all' : item['id'] as String;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : (isDark ? AppTheme.darkCardColor : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item['icon'] as IconData, size: 20, color: color),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['count'] as String,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- 4. Content Header & Filter Pills ---
  Widget _buildContentSectionHeader(bool isDark) {
    final filters = [
      {'id': 'all', 'label': 'Semua Komponen'},
      {'id': 'banner', 'label': 'Banner'},
      {'id': 'live', 'label': 'Live Class'},
      {'id': 'package', 'label': 'Paket Tryout'},
      {'id': 'video', 'label': 'Video HD'},
      {'id': 'module', 'label': 'Modul PDF'},
      {'id': 'voucher', 'label': 'Kupon Promo'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 8),
                Text(
                  'Daftar Konten Aktif di User',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: filters.map((f) {
              final isSelected = _selectedSection == f['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedSection = f['id']!);
                  },
                  selectedColor: AppTheme.primaryBlue,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                  ),
                  backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryBlue : (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- 5. Managed Components List ---
  Widget _buildManagedComponentsList(PackageProvider packageProvider, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banners
        if (_selectedSection == 'all' || _selectedSection == 'banner') ...[
          _buildCategorySubHeader('🖼️ Banner Promo Beranda (${_banners.length})', () => _showAddBannerModal(isDark), isDark),
          if (_banners.isEmpty)
            _buildEmptyState('Belum ada banner aktif.', isDark)
          else
            ..._banners.map((b) => _buildBannerCard(b, isDark)),
          const SizedBox(height: 16),
        ],

        // Live Classes
        if (_selectedSection == 'all' || _selectedSection == 'live') ...[
          _buildCategorySubHeader('🔴 Live Class & Zoom Streaming (${_liveClasses.length})', () => _showAddLiveClassModal(isDark), isDark),
          if (_liveClasses.isEmpty)
            _buildEmptyState('Belum ada sesi Live Class terjadwal.', isDark)
          else
            ..._liveClasses.map((lc) => _buildLiveClassCard(lc, isDark)),
          const SizedBox(height: 16),
        ],

        // Packages
        if (_selectedSection == 'all' || _selectedSection == 'package') ...[
          _buildCategorySubHeader('📦 Paket Belajar & Tryout (${packageProvider.packages.length})', () => _showAddPackageModal(isDark), isDark),
          if (packageProvider.packages.isEmpty)
            _buildEmptyState('Belum ada paket belajar tayang.', isDark)
          else
            ...packageProvider.packages.map((pkg) => _buildPackageCard(pkg, isDark)),
          const SizedBox(height: 16),
        ],

        // Videos
        if (_selectedSection == 'all' || _selectedSection == 'video') ...[
          _buildCategorySubHeader('🎬 Video Materi Pembelajaran HD (${_videos.length})', () => _showAddVideoModal(isDark), isDark),
          if (_videos.isEmpty)
            _buildEmptyState('Belum ada video materi pembelajaran.', isDark)
          else
            ..._videos.map((v) => _buildVideoCard(v, isDark)),
          const SizedBox(height: 16),
        ],

        // Modules
        if (_selectedSection == 'all' || _selectedSection == 'module') ...[
          _buildCategorySubHeader('📚 Modul & E-Book PDF (${_modules.length})', () => _showAddModuleModal(isDark), isDark),
          if (_modules.isEmpty)
            _buildEmptyState('Belum ada file modul PDF.', isDark)
          else
            ..._modules.map((m) => _buildModuleCard(m, isDark)),
          const SizedBox(height: 16),
        ],

        // Vouchers
        if (_selectedSection == 'all' || _selectedSection == 'voucher') ...[
          _buildCategorySubHeader('🎟️ Kupon & Voucher Diskon (${_vouchers.length})', () => _showAddVoucherModal(isDark), isDark),
          ..._vouchers.map((vc) => _buildVoucherCard(vc, isDark)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildCategorySubHeader(String title, VoidCallback onAdd, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
            ),
          ),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 14, color: AppTheme.primaryBlue),
                  SizedBox(width: 4),
                  Text('Tambah', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Center(
        child: Text(text, style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
      ),
    );
  }

  // --- Cards ---
  Widget _buildBannerCard(BannerModel b, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(13)),
            child: CachedNetworkImage(
              imageUrl: b.imageUrl,
              width: 90,
              height: 68,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, width: 90, height: 68, child: const Icon(Icons.broken_image_rounded, size: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(b.tag, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ),
                const SizedBox(height: 2),
                Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                Text(b.route ?? '/', style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () {
              setState(() => _banners.removeWhere((item) => item.id == b.id));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner berhasil dihapus')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLiveClassCard(LiveClassModel lc, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.videocam_rounded, color: Colors.redAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lc.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text('${lc.instructor} • ${lc.subject}', style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary)),
                Text('Zoom: ${lc.zoomUrl}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppTheme.primaryBlue)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () {
              setState(() => _liveClasses.removeWhere((item) => item.id == lc.id));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesi Live Class berhasil dihapus')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(PackageModel pkg, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.school_rounded, color: Color(0xFF8B5CF6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  '${Formatter.formatRupiah(pkg.effectivePrice)} • ${pkg.jenjang} (${pkg.membershipDurationDays} Hari)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6)),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoModel vid, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: vid.thumbnail ?? 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=600&auto=format&fit=crop&q=80',
              width: 76,
              height: 48,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, width: 76, height: 48),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vid.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(vid.isFree ? 'GRATIS' : Formatter.formatRupiah(vid.price), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () {
              setState(() => _videos.removeWhere((item) => item.id == vid.id));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video materi berhasil dihapus')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(ModuleModel m, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF10B981), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text('${m.tag} • ${m.totalChapters} Bab • ${m.fileSize}', style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () {
              setState(() => _modules.removeWhere((item) => item.id == m.id));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modul PDF berhasil dihapus')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(Map<String, dynamic> v, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEC4899).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(v['code'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFEC4899))),
              ),
              const SizedBox(height: 4),
              Text(v['title'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
              Text('Terpakai: ${v['usage']}', style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
            ],
          ),
          Text(v['discount'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
        ],
      ),
    );
  }

  // --- Quick Add Selector BottomSheet ---
  void _showQuickAddBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Jenis Komponen Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.view_carousel_rounded, color: Color(0xFF3B82F6)),
                title: const Text('Banner Slider Beranda'),
                subtitle: const Text('Pasang banner promosi dan pengumuman baru'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddBannerModal(isDark);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_rounded, color: Color(0xFFEF4444)),
                title: const Text('Jadwal Live Class & Zoom'),
                subtitle: const Text('Jadwalkan sesi bimbingan tatap muka online'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddLiveClassModal(isDark);
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2_rounded, color: Color(0xFF8B5CF6)),
                title: const Text('Paket Belajar & Tryout'),
                subtitle: const Text('Buat paket belajar intensif atau asesmen UTBK'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddPackageModal(isDark);
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFF59E0B)),
                title: const Text('Video Materi Pembelajaran HD'),
                subtitle: const Text('Unggah materi video interaktif ke katalog'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddVideoModal(isDark);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF10B981)),
                title: const Text('Modul & E-Book PDF'),
                subtitle: const Text('Terbitkan dokumen bacaan belajar mandiri'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddModuleModal(isDark);
                },
              ),
              ListTile(
                leading: const Icon(Icons.confirmation_number_rounded, color: Color(0xFFEC4899)),
                title: const Text('Kupon & Voucher Promo'),
                subtitle: const Text('Buat kupon potongan harga checkout'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddVoucherModal(isDark);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Modals for Adding Components ---
  void _showAddBannerModal(bool isDark) {
    final titleCtrl = TextEditingController();
    final tagCtrl = TextEditingController(text: 'PROMO');
    final imageCtrl = TextEditingController(text: 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=900&auto=format&fit=crop&q=80');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Banner Promo Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: tagCtrl, decoration: const InputDecoration(labelText: 'Tag Banner (Contoh: UJIAN ONLINE)')),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Banner')),
            TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URL Gambar Banner (HD)')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    setState(() {
                      _banners.insert(
                        0,
                        BannerModel(
                          id: 'banner_${DateTime.now().millisecondsSinceEpoch}',
                          tag: tagCtrl.text.trim(),
                          subTag: 'Promo Baru',
                          title: titleCtrl.text.trim(),
                          subtitle: 'Penawaran spesial siswa KPM Academy',
                          imageUrl: imageCtrl.text.trim(),
                          route: '/package_list',
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner baru berhasil diterbitkan di Beranda! 🚀')));
                  }
                },
                child: const Text('Terbitkan Banner', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLiveClassModal(bool isDark) {
    final titleCtrl = TextEditingController();
    final tutorCtrl = TextEditingController(text: 'Dr. Ir. R. Ridwan Hasan Saputra, M.Si.');
    final subjectCtrl = TextEditingController(text: 'Matematika MNR');
    final zoomCtrl = TextEditingController(text: 'https://zoom.us/j/kpmacademy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buat Jadwal Live Class Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Topik Live Class')),
            TextField(controller: tutorCtrl, decoration: const InputDecoration(labelText: 'Nama Tutor / Pembina')),
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Mata Pelajaran')),
            TextField(controller: zoomCtrl, decoration: const InputDecoration(labelText: 'Tautan Zoom / Streaming')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    setState(() {
                      _liveClasses.insert(
                        0,
                        LiveClassModel(
                          id: 'live_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleCtrl.text.trim(),
                          instructor: tutorCtrl.text.trim(),
                          subject: subjectCtrl.text.trim(),
                          jenjang: 'SD, SMP, & SMA',
                          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
                          durationMinutes: 90,
                          zoomUrl: zoomCtrl.text.trim(),
                          status: 'upcoming',
                          bannerUrl: 'https://images.unsplash.com/photo-1588072432836-e10032774350?w=800&auto=format&fit=crop&q=80',
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal Live Class baru berhasil dibuat! 🎥')));
                  }
                },
                child: const Text('Buat Jadwal Live Class', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPackageModal(bool isDark) {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '199000');
    final discountCtrl = TextEditingController(text: '129000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tambah Paket Belajar Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Nama Paket')),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Normal (Rp)')),
            TextField(controller: discountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Diskon (Rp)')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paket belajar baru berhasil ditambahkan ke katalog! 📚')));
                  }
                },
                child: const Text('Simpan Paket', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVideoModal(bool isDark) {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController(text: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tambah Video Materi Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Video Materi')),
            TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL Video MP4 / Streaming')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    setState(() {
                      _videos.insert(
                        0,
                        VideoModel(
                          id: 'vid_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleCtrl.text.trim(),
                          description: 'Video materi pembelajaran interaktif KPM Academy.',
                          thumbnail: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=600&auto=format&fit=crop&q=80',
                          videoUrl: urlCtrl.text.trim(),
                          price: 0,
                          accessDurationDays: 60,
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video pembelajaran baru berhasil diunggah! 🎬')));
                  }
                },
                child: const Text('Simpan Video', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddModuleModal(bool isDark) {
    final titleCtrl = TextEditingController();
    final tagCtrl = TextEditingController(text: 'Matematika');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tambah Modul PDF Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Modul')),
            TextField(controller: tagCtrl, decoration: const InputDecoration(labelText: 'Mata Pelajaran / Tag')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    setState(() {
                      _modules.insert(
                        0,
                        ModuleModel(
                          id: 'mod_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleCtrl.text.trim(),
                          description: 'Modul konsep dan latihan soal mandiri.',
                          tag: tagCtrl.text.trim(),
                          totalChapters: 4,
                          fileUrl: 'https://kpmacademic.io/modules/sample.pdf',
                          fileSize: '3.0 MB',
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modul PDF baru berhasil diterbitkan! 📑')));
                  }
                },
                child: const Text('Simpan Modul', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVoucherModal(bool isDark) {
    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Buat Kupon Voucher Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Kode Voucher (Contoh: KPMHEMAT50)')),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Keterangan Promo')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (codeCtrl.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kupon voucher baru berhasil diaktifkan! 🎟️')));
                  }
                },
                child: const Text('Aktifkan Voucher', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Access Denied Screen ---
  Widget _buildAccessDeniedScreen(BuildContext context, AuthProvider authProvider, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Akses Ditolak'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings_outlined, size: 72, color: Colors.redAccent),
              ),
              const SizedBox(height: 24),
              Text(
                'Akses Khusus Administrator',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                authProvider.isAuthenticated
                    ? 'Akun Anda (${authProvider.user?.email}) terdaftar sebagai Siswa dan tidak memiliki izin Administrator untuk mengakses halaman CMS ini.'
                    : 'Halaman ini dilindungi dan hanya dapat diakses setelah melakukan login dengan akun Administrator KPM Academy.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (!authProvider.isAuthenticated)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.login_rounded, size: 20),
                  label: const Text('Login Akun Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Kembali ke Beranda'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Logout Dialog ---
  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Logout Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari sesi Administrator KPM Academy?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              }
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
