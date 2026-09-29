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
import '../../services/video_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentNavIndex = 0;
  AdminDashboardStats _stats = AdminDashboardStats();
  bool _isLoading = true;

  // Selected filter inside Content CMS tab
  String _selectedContentFilter = 'all';

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

    // Security Guard: Role Check
    if (!authProvider.isAdmin) {
      return _buildAccessDeniedScreen(context, authProvider, isDark);
    }

    final pages = [
      _buildOverviewTab(packageProvider, isDark, authProvider),
      _buildContentCMSTab(isDark),
      _buildPackagesAndLiveTab(packageProvider, isDark),
      _buildOrdersAndTransactionsTab(isDark),
      _buildAdminSettingsTab(authProvider, isDark),
    ];

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
              child: pages[_currentNavIndex],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardColor : Colors.white,
          border: Border(top: BorderSide(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _currentNavIndex,
            onDestinationSelected: (idx) => setState(() => _currentNavIndex = idx),
            backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
            indicatorColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
            elevation: 0,
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard_rounded, color: AppTheme.primaryBlue),
                label: 'Ringkasan',
              ),
              NavigationDestination(
                icon: const Icon(Icons.auto_awesome_mosaic_outlined),
                selectedIcon: const Icon(Icons.auto_awesome_mosaic_rounded, color: AppTheme.primaryBlue),
                label: 'Konten CMS',
              ),
              NavigationDestination(
                icon: const Icon(Icons.school_outlined),
                selectedIcon: const Icon(Icons.school_rounded, color: AppTheme.primaryBlue),
                label: 'Paket & Live',
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryBlue),
                label: 'Pesanan',
              ),
              NavigationDestination(
                icon: const Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primaryBlue),
                label: 'Akun Admin',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: (_currentNavIndex == 1 || _currentNavIndex == 2)
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Tambah Konten', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () => _showQuickAddBottomSheet(isDark),
            )
          : null,
    );
  }

  // --- Header AppBar (Clean, Zero Overflow) ---
  PreferredSizeWidget _buildAppBar(BuildContext context, AuthProvider authProvider, bool isDark) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      leading: Navigator.canPop(context)
          ? AppTheme.backButton(context)
          : Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: AppTheme.primaryBlue, size: 20),
            ),
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(
            child: Text(
              'KPM CMS Admin',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 20),
          tooltip: 'Mode Tinjau Siswa',
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          tooltip: 'Refresh Data',
          onPressed: _loadAllAdminData,
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
          tooltip: 'Logout',
          onPressed: () => _confirmLogout(context, authProvider),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // =========================================================================
  // TAB 0: RINGKASAN & OVERVIEW (Executive Bento Dashboard)
  // =========================================================================
  Widget _buildOverviewTab(PackageProvider packageProvider, bool isDark, AuthProvider authProvider) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Welcome Card
          Container(
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
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Color(0xFF4ADE80), size: 7),
                          SizedBox(width: 5),
                          Text('Go Backend Online', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      authProvider.user?.email ?? 'admin@kpmacademy.com',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Selamat Datang, Admin! 👋',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pantau dan kelola seluruh komponen ekosistem KPM Academy.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Revenue Highlight Bento Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
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
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF10B981), size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Omset & Pendapatan',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          currencyFormatter.format(_stats.totalRevenue),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
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
                  child: const Text('LUNAS', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. 2x2 Metric Tiles Grid
          Row(
            children: [
              Expanded(
                child: _buildSimpleMetricCard(
                  title: 'Total Siswa',
                  value: '${_stats.totalUsers}',
                  subtitle: 'Akun Terdaftar',
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF2563EB),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSimpleMetricCard(
                  title: 'Pesanan Sukses',
                  value: '${_stats.totalOrders}',
                  subtitle: 'Transaksi Masuk',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF0891B2),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildSimpleMetricCard(
                  title: 'Paket Belajar',
                  value: '${packageProvider.packages.length}',
                  subtitle: 'Katalog Aktif',
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFF8B5CF6),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSimpleMetricCard(
                  title: 'Live Streaming',
                  value: '${_liveClasses.length}',
                  subtitle: 'Sesi Terjadwal',
                  icon: Icons.videocam_rounded,
                  color: const Color(0xFFEF4444),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 4. Quick Action Shortcuts Section
          Row(
            children: [
              Container(width: 3, height: 14, decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Text('Aksi Cepat Administrator', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildShortcutButton(
                  icon: Icons.add_photo_alternate_rounded,
                  label: 'Tambah Banner',
                  color: const Color(0xFF3B82F6),
                  onTap: () => _showAddBannerModal(isDark),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShortcutButton(
                  icon: Icons.video_call_rounded,
                  label: 'Jadwal Live',
                  color: const Color(0xFFEF4444),
                  onTap: () => _showAddLiveClassModal(isDark),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShortcutButton(
                  icon: Icons.post_add_rounded,
                  label: 'Buat Paket',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => _showAddPackageModal(isDark),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 1: MANAJEMEN KONTEN CMS (Banners, Video HD, Modul PDF, Kupon Voucher)
  // =========================================================================
  Widget _buildContentCMSTab(bool isDark) {
    final filters = [
      {'id': 'all', 'label': 'Semua (${_banners.length + _videos.length + _modules.length + _vouchers.length})'},
      {'id': 'banner', 'label': 'Banner (${_banners.length})'},
      {'id': 'video', 'label': 'Video HD (${_videos.length})'},
      {'id': 'module', 'label': 'Modul PDF (${_modules.length})'},
      {'id': 'voucher', 'label': 'Kupon (${_vouchers.length})'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: filters.map((f) {
                final isSelected = _selectedContentFilter == f['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(f['label']!),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedContentFilter = f['id']!),
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

          const SizedBox(height: 14),

          // 1. Banners
          if (_selectedContentFilter == 'all' || _selectedContentFilter == 'banner') ...[
            _buildSectionHeaderWithAdd('🖼️ Banner Promo Carousel', () => _showAddBannerModal(isDark), isDark),
            if (_banners.isEmpty)
              _buildEmptyPlaceholder('Belum ada banner promo.', isDark)
            else
              ..._banners.map((b) => _buildBannerCard(b, isDark)),
            const SizedBox(height: 14),
          ],

          // 2. Videos
          if (_selectedContentFilter == 'all' || _selectedContentFilter == 'video') ...[
            _buildSectionHeaderWithAdd('🎬 Video Materi HD', () => _showAddVideoModal(isDark), isDark),
            if (_videos.isEmpty)
              _buildEmptyPlaceholder('Belum ada video materi.', isDark)
            else
              ..._videos.map((v) => _buildVideoCard(v, isDark)),
            const SizedBox(height: 14),
          ],

          // 3. Modules
          if (_selectedContentFilter == 'all' || _selectedContentFilter == 'module') ...[
            _buildSectionHeaderWithAdd('📚 Modul & E-Book PDF', () => _showAddModuleModal(isDark), isDark),
            if (_modules.isEmpty)
              _buildEmptyPlaceholder('Belum ada modul bacaan PDF.', isDark)
            else
              ..._modules.map((m) => _buildModuleCard(m, isDark)),
            const SizedBox(height: 14),
          ],

          // 4. Vouchers
          if (_selectedContentFilter == 'all' || _selectedContentFilter == 'voucher') ...[
            _buildSectionHeaderWithAdd('🎟️ Kupon Promo & Diskon', () => _showAddVoucherModal(isDark), isDark),
            ..._vouchers.map((vc) => _buildVoucherCard(vc, isDark)),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 2: PAKET TRYOUT & LIVE STREAMING
  // =========================================================================
  Widget _buildPackagesAndLiveTab(PackageProvider packageProvider, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Classes
          _buildSectionHeaderWithAdd('🔴 Sesi Live Class & Zoom Streaming', () => _showAddLiveClassModal(isDark), isDark),
          if (_liveClasses.isEmpty)
            _buildEmptyPlaceholder('Belum ada jadwal Live Class.', isDark)
          else
            ..._liveClasses.map((lc) => _buildLiveClassCard(lc, isDark)),

          const SizedBox(height: 20),

          // Packages
          _buildSectionHeaderWithAdd('📦 Paket Belajar & Tryout UTBK', () => _showAddPackageModal(isDark), isDark),
          if (packageProvider.packages.isEmpty)
            _buildEmptyPlaceholder('Belum ada paket belajar aktif.', isDark)
          else
            ...packageProvider.packages.map((pkg) => _buildPackageCard(pkg, isDark)),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 3: TRANSAKSI & PESANAN SISWA
  // =========================================================================
  Widget _buildOrdersAndTransactionsTab(bool isDark) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final mockOrders = [
      {'id': 'ORD-2026-9812', 'student': 'Ahmad Fauzan', 'package': 'Paket Intensif SNBT 2026', 'amount': 129000, 'status': 'PAID', 'date': '29 Sep 2026, 10:14'},
      {'id': 'ORD-2026-9811', 'student': 'Siti Nurhaliza', 'package': 'Tryout UTBK TPS & Literasi', 'amount': 75000, 'status': 'PAID', 'date': '29 Sep 2026, 09:30'},
      {'id': 'ORD-2026-9810', 'student': 'Budi Santoso', 'package': 'Mastering Penalaran MNR', 'amount': 199000, 'status': 'PAID', 'date': '28 Sep 2026, 21:05'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daftar Transaksi Siswa Masuk', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('Midtrans Gateway', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...mockOrders.map((ord) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardColor : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ord['id'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(ord['status'] as String, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(ord['student'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                  Text(ord['package'] as String, style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary)),
                  const Divider(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ord['date'] as String, style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
                      Text(currencyFormatter.format(ord['amount']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 4: AKUN ADMINISTRATOR & SISTEM
  // =========================================================================
  Widget _buildAdminSettingsTab(AuthProvider authProvider, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.user?.name ?? 'Admin KPM Academy',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        authProvider.user?.email ?? 'admin@kpmacademy.com',
                        style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                        child: const Text('Super Administrator', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Menu Options
          _buildSettingsTile(
            icon: Icons.remove_red_eye_outlined,
            title: 'Buka Mode Tampilan Siswa',
            subtitle: 'Lihat tampilan beranda persis seperti kacamata siswa',
            onTap: () => Navigator.pushNamed(context, '/home'),
            isDark: isDark,
          ),
          _buildSettingsTile(
            icon: Icons.sync_rounded,
            title: 'Sinkronisasi Ulang Database',
            subtitle: 'Muat ulang seluruh paket, live class, dan data transaksi',
            onTap: _loadAllAdminData,
            isDark: isDark,
          ),
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: 'Keluar dari Sesi Administrator',
            subtitle: 'Akhiri sesi CMS dan kembali ke halaman utama',
            isDestructive: true,
            onTap: () => _confirmLogout(context, authProvider),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : AppTheme.primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: color),
        ),
        title: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDestructive ? Colors.redAccent : (isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary))),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      ),
    );
  }

  // --- Subcomponents & Helpers ---
  Widget _buildSimpleMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
            ),
          ),
          Text(
            subtitle,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeaderWithAdd(String title, VoidCallback onAdd, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
            ),
          ),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 12, color: AppTheme.primaryBlue),
                  SizedBox(width: 3),
                  Text('Tambah', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String text, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Center(
        child: Text(text, style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
      ),
    );
  }

  // --- Cards ---
  Widget _buildBannerCard(BannerModel b, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
            child: CachedNetworkImage(
              imageUrl: b.imageUrl,
              width: 80,
              height: 60,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, width: 80, height: 60),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.tag, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                Text(b.route ?? '/', style: TextStyle(fontSize: 9, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.videocam_rounded, color: Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lc.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                Text('${lc.instructor} • ${lc.subject}', style: TextStyle(fontSize: 9, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary)),
                Text('Zoom: ${lc.zoomUrl}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: AppTheme.primaryBlue)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.school_rounded, color: Color(0xFF8B5CF6), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                Text(
                  '${Formatter.formatRupiah(pkg.effectivePrice)} • ${pkg.jenjang}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6)),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoModel vid, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: vid.thumbnail ?? 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=600&auto=format&fit=crop&q=80',
              width: 68,
              height: 44,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, width: 68, height: 44),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vid.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                Text(vid.isFree ? 'GRATIS' : Formatter.formatRupiah(vid.price), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF10B981), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                Text('${m.tag} • ${m.totalChapters} Bab • ${m.fileSize}', style: TextStyle(fontSize: 9, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEC4899).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(v['code'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFEC4899))),
              ),
              const SizedBox(height: 2),
              Text(v['title'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
              Text('Terpakai: ${v['usage']}', style: TextStyle(fontSize: 9, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
            ],
          ),
          Text(v['discount'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
        ],
      ),
    );
  }

  // --- Quick Add BottomSheet ---
  void _showQuickAddBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tambah Konten Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                dense: true,
                leading: const Icon(Icons.view_carousel_rounded, color: Color(0xFF3B82F6)),
                title: const Text('Banner Promo Carousel'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddBannerModal(isDark);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.videocam_rounded, color: Color(0xFFEF4444)),
                title: const Text('Jadwal Live Class Zoom'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddLiveClassModal(isDark);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.school_rounded, color: Color(0xFF8B5CF6)),
                title: const Text('Paket Belajar & Tryout'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddPackageModal(isDark);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFF59E0B)),
                title: const Text('Video Pembelajaran HD'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddVideoModal(isDark);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF10B981)),
                title: const Text('Modul & E-Book PDF'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddModuleModal(isDark);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.confirmation_number_rounded, color: Color(0xFFEC4899)),
                title: const Text('Kupon Voucher Promo'),
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

  // --- Add Modals ---
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
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Banner Promo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: tagCtrl, decoration: const InputDecoration(labelText: 'Tag (Contoh: PROMO)')),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Banner')),
            TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URL Gambar Banner')),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner baru berhasil diterbitkan! 🚀')));
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
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buat Jadwal Live Class Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Topik Live Class')),
            TextField(controller: tutorCtrl, decoration: const InputDecoration(labelText: 'Nama Tutor / Pembina')),
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Mata Pelajaran')),
            TextField(controller: zoomCtrl, decoration: const InputDecoration(labelText: 'Tautan Zoom')),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
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
                child: const Text('Buat Jadwal', style: TextStyle(fontWeight: FontWeight.bold)),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tambah Paket Belajar Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Nama Paket')),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Normal (Rp)')),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paket baru berhasil disimpan! 📚')));
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
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tambah Video Materi Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Video')),
            TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL Video MP4')),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
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
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tambah Modul PDF Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Modul')),
            TextField(controller: tagCtrl, decoration: const InputDecoration(labelText: 'Mata Pelajaran')),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
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
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Buat Kupon Voucher Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Kode Kupon (Misal: DISKON25)')),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Keterangan Promo')),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings_outlined, size: 64, color: Colors.redAccent),
              ),
              const SizedBox(height: 20),
              Text(
                'Akses Khusus Administrator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                authProvider.isAuthenticated
                    ? 'Akun Anda (${authProvider.user?.email}) tidak memiliki izin Administrator.'
                    : 'Silakan login dengan akun Administrator KPM Academy.',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (!authProvider.isAuthenticated)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: const Text('Login Akun Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
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
            SizedBox(width: 8),
            Text('Logout Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari sesi Administrator KPM Academy?', style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
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
