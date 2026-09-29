import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Selected filter inside CMS tab
  String _selectedCMSFilter = 'all';

  List<BannerModel> _banners = [];
  List<LiveClassModel> _liveClasses = [];
  List<ModuleModel> _modules = [];
  List<VideoModel> _videos = [];

  final TextEditingController _orderSearchController = TextEditingController();
  String _orderSearchQuery = '';

  final List<Map<String, dynamic>> _vouchers = [
    {'id': 'v1', 'code': 'KPMJUARA2026', 'title': 'Diskon 25% Persiapan Ujian', 'discount': '25%', 'usage': '142/500'},
    {'id': 'v2', 'code': 'MNRINDONESIA', 'title': 'Potongan Rp 50.000 Belajar', 'discount': 'Rp 50rb', 'usage': '89/300'},
    {'id': 'v3', 'code': 'MIPABERSAMA', 'title': 'Cashback 15% Ujian Online', 'discount': '15%', 'usage': '210/1000'},
  ];

  @override
  void initState() {
    super.initState();
    _orderSearchController.addListener(() {
      if (mounted) {
        setState(() {
          _orderSearchQuery = _orderSearchController.text.trim().toLowerCase();
        });
      }
    });
    _loadAllAdminData();
  }

  @override
  void dispose() {
    _orderSearchController.dispose();
    super.dispose();
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

    // Security Guard: Admin role check
    if (!authProvider.isAdmin) {
      return _buildAccessDeniedScreen(context, authProvider, isDark);
    }

    final pages = [
      _buildOverviewTab(packageProvider, isDark, authProvider),
      _buildUnifiedCMSTab(packageProvider, isDark),
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
              blurRadius: 8,
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
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryBlue),
                label: 'Ringkasan',
              ),
              NavigationDestination(
                icon: Icon(Icons.layers_outlined),
                selectedIcon: Icon(Icons.layers_rounded, color: AppTheme.primaryBlue),
                label: 'CMS',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded, color: AppTheme.primaryBlue),
                label: 'Pesanan',
              ),
              NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primaryBlue),
                label: 'Akun Admin',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _currentNavIndex == 1
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

  // --- Header AppBar ---
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('CMS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
          tooltip: 'Mode Tinjau Siswa',
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          tooltip: 'Perbarui Data',
          onPressed: _loadAllAdminData,
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
          tooltip: 'Keluar',
          onPressed: () => _confirmLogout(context, authProvider),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // =========================================================================
  // TAB 0: RINGKASAN & OVERVIEW
  // =========================================================================
  Widget _buildOverviewTab(PackageProvider packageProvider, bool isDark, AuthProvider authProvider) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Welcome Card
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
                          Text('Backend Online & Sinkron', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                  'Selamat Datang, Administrator',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pantau analitik dan kontrol seluruh komponen aplikasi secara terpusat.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Revenue Highlight Card
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
                        'Total Omset Pembelian',
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

          // Metric Cards 2x2
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Total Siswa',
                  value: '${_stats.totalUsers}',
                  subtitle: 'Akun Terdaftar',
                  icon: Icons.people_alt_outlined,
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
                  icon: Icons.receipt_long_outlined,
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
                child: _buildMetricTile(
                  title: 'Paket Belajar',
                  value: '${packageProvider.packages.length}',
                  subtitle: 'Katalog Tayang',
                  icon: Icons.school_outlined,
                  color: const Color(0xFF8B5CF6),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  title: 'Live Class',
                  value: '${_liveClasses.length}',
                  subtitle: 'Sesi Terjadwal',
                  icon: Icons.videocam_outlined,
                  color: const Color(0xFFEF4444),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick Action Hub
          Row(
            children: [
              Container(width: 3, height: 14, decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Text('Aksi Pintar CMS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildShortcutButton(
                  icon: Icons.view_carousel_outlined,
                  label: 'Tambah Banner',
                  color: const Color(0xFF3B82F6),
                  onTap: () => _showAddBannerModal(isDark),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShortcutButton(
                  icon: Icons.videocam_outlined,
                  label: 'Jadwal Live',
                  color: const Color(0xFFEF4444),
                  onTap: () => _showAddLiveClassModal(isDark),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShortcutButton(
                  icon: Icons.school_outlined,
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
  // TAB 1: UNIFIED CMS (All 6 Components with Complete CRUD)
  // =========================================================================
  Widget _buildUnifiedCMSTab(PackageProvider packageProvider, bool isDark) {
    final filters = [
      {'id': 'all', 'label': 'Semua (${_banners.length + _liveClasses.length + packageProvider.packages.length + _videos.length + _modules.length + _vouchers.length})'},
      {'id': 'banner', 'label': 'Banner (${_banners.length})'},
      {'id': 'live', 'label': 'Live Class (${_liveClasses.length})'},
      {'id': 'package', 'label': 'Paket (${packageProvider.packages.length})'},
      {'id': 'video', 'label': 'Video (${_videos.length})'},
      {'id': 'module', 'label': 'Modul (${_modules.length})'},
      {'id': 'voucher', 'label': 'Kupon (${_vouchers.length})'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: filters.map((f) {
                final isSelected = _selectedCMSFilter == f['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(f['label']!),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCMSFilter = f['id']!),
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

          // 1. Banner Slider Section
          if (_selectedCMSFilter == 'all' || _selectedCMSFilter == 'banner') ...[
            _buildSectionHeaderWithAdd('Banner Promo Carousel', Icons.view_carousel_outlined, () => _showAddBannerModal(isDark), isDark),
            if (_banners.isEmpty)
              _buildEmptyPlaceholder('Belum ada banner promo.', isDark)
            else
              ..._banners.map((b) => _buildBannerCard(b, isDark)),
            const SizedBox(height: 14),
          ],

          // 2. Live Class Section
          if (_selectedCMSFilter == 'all' || _selectedCMSFilter == 'live') ...[
            _buildSectionHeaderWithAdd('Live Class & Streaming Zoom', Icons.videocam_outlined, () => _showAddLiveClassModal(isDark), isDark),
            if (_liveClasses.isEmpty)
              _buildEmptyPlaceholder('Belum ada jadwal live class.', isDark)
            else
              ..._liveClasses.map((lc) => _buildLiveClassCard(lc, isDark)),
            const SizedBox(height: 14),
          ],

          // 3. Paket Belajar Section
          if (_selectedCMSFilter == 'all' || _selectedCMSFilter == 'package') ...[
            _buildSectionHeaderWithAdd('Paket Belajar & Tryout UTBK', Icons.school_outlined, () => _showAddPackageModal(isDark), isDark),
            if (packageProvider.packages.isEmpty)
              _buildEmptyPlaceholder('Belum ada paket belajar aktif.', isDark)
            else
              ...packageProvider.packages.map((pkg) => _buildPackageCard(pkg, isDark)),
            const SizedBox(height: 14),
          ],

          // 4. Video Materi Section
          if (_selectedCMSFilter == 'all' || _selectedCMSFilter == 'video') ...[
            _buildSectionHeaderWithAdd('Video Materi Pembelajaran HD', Icons.play_circle_outline_rounded, () => _showAddVideoModal(isDark), isDark),
            if (_videos.isEmpty)
              _buildEmptyPlaceholder('Belum ada video materi.', isDark)
            else
              ..._videos.map((v) => _buildVideoCard(v, isDark)),
            const SizedBox(height: 14),
          ],

          // 5. Modul PDF Section
          if (_selectedCMSFilter == 'all' || _selectedCMSFilter == 'module') ...[
            _buildSectionHeaderWithAdd('Modul Bacaan & E-Book PDF', Icons.picture_as_pdf_outlined, () => _showAddModuleModal(isDark), isDark),
            if (_modules.isEmpty)
              _buildEmptyPlaceholder('Belum ada file modul PDF.', isDark)
            else
              ..._modules.map((m) => _buildModuleCard(m, isDark)),
            const SizedBox(height: 14),
          ],

          // 6. Voucher Section
          if (_selectedCMSFilter == 'all' || _selectedCMSFilter == 'voucher') ...[
            _buildSectionHeaderWithAdd('Kupon Voucher & Promo Diskon', Icons.confirmation_number_outlined, () => _showAddVoucherModal(isDark), isDark),
            ..._vouchers.map((vc) => _buildVoucherCard(vc, isDark)),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 2: TRANSAKSI & PESANAN (With Real-time Search & Clean Receipt View)
  // =========================================================================
  Widget _buildOrdersAndTransactionsTab(bool isDark) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final mockOrders = [
      {
        'id': 'ORD-2026-9812',
        'student': 'Ahmad Fauzan',
        'school': 'SMA Negeri 1 Jakarta',
        'phone': '0812-9876-5432',
        'package': 'Paket Intensif SNBT 2026',
        'originalAmount': 154000,
        'discountAmount': 25000,
        'voucherCode': 'KPMJUARA2026',
        'amount': 129000,
        'status': 'PAID',
        'paymentMethod': 'Midtrans QRIS / GoPay',
        'date': '29 Sep 2026, 10:14 WIB',
        'accessDuration': '180 Hari Aktif',
      },
      {
        'id': 'ORD-2026-9811',
        'student': 'Siti Nurhaliza',
        'school': 'SMA Negeri 3 Surabaya',
        'phone': '0857-1234-5678',
        'package': 'Tryout UTBK TPS & Literasi',
        'originalAmount': 100000,
        'discountAmount': 25000,
        'voucherCode': 'MNRINDONESIA',
        'amount': 75000,
        'status': 'PAID',
        'paymentMethod': 'Virtual Account BCA',
        'date': '29 Sep 2026, 09:30 WIB',
        'accessDuration': '90 Hari Aktif',
      },
      {
        'id': 'ORD-2026-9810',
        'student': 'Budi Santoso',
        'school': 'SMA Negeri 8 Bandung',
        'phone': '0813-8888-9999',
        'package': 'Mastering Penalaran MNR',
        'originalAmount': 199000,
        'discountAmount': 0,
        'voucherCode': null,
        'amount': 199000,
        'status': 'PAID',
        'paymentMethod': 'Virtual Account Mandiri',
        'date': '28 Sep 2026, 21:05 WIB',
        'accessDuration': '365 Hari Aktif',
      },
      {
        'id': 'ORD-2026-9809',
        'student': 'Dewi Lestari',
        'school': 'SMA Negeri 1 Yogyakarta',
        'phone': '0812-3344-5566',
        'package': 'Paket Super Intensif Kedokteran',
        'originalAmount': 250000,
        'discountAmount': 50000,
        'voucherCode': 'MIPABERSAMA',
        'amount': 200000,
        'status': 'PAID',
        'paymentMethod': 'Virtual Account BNI',
        'date': '28 Sep 2026, 18:40 WIB',
        'accessDuration': '180 Hari Aktif',
      },
      {
        'id': 'ORD-2026-9808',
        'student': 'Rizky Pratama',
        'school': 'SMAN 5 Semarang',
        'phone': '0878-9900-1122',
        'package': 'Modul & Video Matematika MNR',
        'originalAmount': 85000,
        'discountAmount': 0,
        'voucherCode': null,
        'amount': 85000,
        'status': 'PAID',
        'paymentMethod': 'ShopeePay QRIS',
        'date': '27 Sep 2026, 14:15 WIB',
        'accessDuration': '90 Hari Aktif',
      },
    ];

    final query = _orderSearchQuery.trim().toLowerCase();
    final filteredOrders = mockOrders.where((ord) {
      if (query.isEmpty) return true;
      final invoiceId = (ord['id'] as String? ?? '').toLowerCase();
      final student = (ord['student'] as String? ?? '').toLowerCase();
      final school = (ord['school'] as String? ?? '').toLowerCase();
      final package = (ord['package'] as String? ?? '').toLowerCase();
      final voucher = (ord['voucherCode'] as String? ?? '').toLowerCase();
      final payment = (ord['paymentMethod'] as String? ?? '').toLowerCase();

      return invoiceId.contains(query) ||
          student.contains(query) ||
          school.contains(query) ||
          package.contains(query) ||
          voucher.contains(query) ||
          payment.contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Transaksi & Kwitansi Siswa',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('Midtrans Gateway', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Cari dan ketuk pesanan untuk melihat bukti kwitansi resmi, rincian potongan kupon & status pembayaran.',
            style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
          ),
          const SizedBox(height: 10),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBackgroundColor : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
            ),
            child: TextField(
              controller: _orderSearchController,
              onChanged: (val) {
                setState(() {
                  _orderSearchQuery = val.trim().toLowerCase();
                });
              },
              style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari nomor invoice (misal: 9812) atau nama siswa...',
                hintStyle: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.primaryBlue),
                suffixIcon: _orderSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.cancel_rounded, size: 18, color: AppTheme.textMuted),
                        onPressed: () {
                          _orderSearchController.clear();
                          setState(() {
                            _orderSearchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (filteredOrders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardColor : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 40, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                  const SizedBox(height: 8),
                  Text(
                    'Pesanan Tidak Ditemukan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tidak ada transaksi yang cocok dengan "$_orderSearchQuery". Silakan periksa kembali nomor invoice atau nama siswa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      _orderSearchController.clear();
                      setState(() {
                        _orderSearchQuery = '';
                      });
                    },
                    icon: const Icon(Icons.clear_all_rounded, size: 16),
                    label: const Text('Reset Pencarian', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          else
            ...filteredOrders.map((ord) {
              final hasVoucher = ord['voucherCode'] != null;

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _showOrderVoucherReceiptModal(ord, isDark),
                child: Container(
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
                          Row(
                            children: [
                              Text(ord['id'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
                              const SizedBox(width: 8),
                              if (hasVoucher)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFEC4899).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text('Kupon: ${ord['voucherCode']}', style: const TextStyle(color: Color(0xFFEC4899), fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(ord['status'] as String, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(ord['student'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                      const SizedBox(height: 1),
                      Text('${ord['package']} • ${ord['school']}', style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 12, color: Colors.green),
                            SizedBox(width: 6),
                            Text('Akses Belajar Langsung Aktif Otomatis', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.green)),
                          ],
                        ),
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(ord['date'] as String, style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
                          Row(
                            children: [
                              Text(currencyFormatter.format(ord['amount']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.receipt_outlined, size: 12, color: AppTheme.primaryBlue),
                                    SizedBox(width: 4),
                                    Text('Lihat Kwitansi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // --- E-Voucher & Receipt Digital Sheet Modal ---
  void _showOrderVoucherReceiptModal(Map<String, dynamic> ord, bool isDark) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.receipt_long_outlined, color: AppTheme.primaryBlue, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bukti Kwitansi & Pembelian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('KPM Academy Payment Verification', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: const Text('LUNAS / PAID', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Invoice Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                        : [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NOMOR INVOICE PESANAN', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            ord['id'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                          tooltip: 'Salin Invoice',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: ord['id'] as String));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nomor Invoice disalin ke clipboard!')));
                          },
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Masa Akses: ${ord['accessDuration']}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 14),
                            SizedBox(width: 4),
                            Text('Akses Otomatis Aktif', style: TextStyle(color: Color(0xFF4ADE80), fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Rincian Siswa
              Text('Data Siswa & Pembeli', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
              const SizedBox(height: 6),
              _buildReceiptRow('Nama Siswa', ord['student'] as String, isDark),
              _buildReceiptRow('Sekolah', ord['school'] as String, isDark),
              _buildReceiptRow('WhatsApp', ord['phone'] as String, isDark),
              _buildReceiptRow('Paket Belajar', ord['package'] as String, isDark),

              const Divider(height: 20),

              // Rincian Biaya & Kupon
              Text('Rincian Pembayaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
              const SizedBox(height: 6),
              _buildReceiptRow('Harga Paket Normal', currencyFormatter.format(ord['originalAmount']), isDark),
              if (ord['voucherCode'] != null)
                _buildReceiptRow('Potongan Kupon (${ord['voucherCode']})', '-${currencyFormatter.format(ord['discountAmount'])}', isDark, isHighlight: true),
              _buildReceiptRow('Metode Pembayaran', ord['paymentMethod'] as String, isDark),
              _buildReceiptRow('Waktu Transaksi', ord['date'] as String, isDark),

              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran Bersih', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                    Text(currencyFormatter.format(ord['amount']), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Salin Invoice', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: ord['id'] as String));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nomor Invoice berhasil disalin!')));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Tutup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isHighlight ? const Color(0xFFEC4899) : (isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 3: AKUN ADMINISTRATOR & SISTEM
  // =========================================================================
  Widget _buildAdminSettingsTab(AuthProvider authProvider, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    color: AppTheme.primaryBlue,
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
                        authProvider.user?.name ?? 'Administrator KPM',
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
            subtitle: 'Akhiri sesi CMS dan kembali ke halaman login',
            isDestructive: true,
            onTap: () => _confirmLogout(context, authProvider),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Widget _buildMetricTile({
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

  Widget _buildSectionHeaderWithAdd(String title, IconData icon, VoidCallback onAdd, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primaryBlue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                  ),
                ),
              ],
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

  // =========================================================================
  // CARDS WITH FULL CRUD (Edit, Delete, Toggle)
  // =========================================================================

  // 1. Banner Card (CRUD)
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
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 18),
            tooltip: 'Edit Banner',
            onPressed: () => _showEditBannerModal(b, isDark),
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
            tooltip: 'Hapus Banner',
            onPressed: () => _confirmDelete('Banner', b.title, () {
              setState(() => _banners.removeWhere((item) => item.id == b.id));
            }),
          ),
        ],
      ),
    );
  }

  // 2. Live Class Card (CRUD)
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
            child: const Icon(Icons.videocam_outlined, color: Colors.redAccent, size: 20),
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
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 18),
            tooltip: 'Edit Jadwal',
            onPressed: () => _showEditLiveClassModal(lc, isDark),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
            tooltip: 'Hapus Sesi',
            onPressed: () => _confirmDelete('Live Class', lc.title, () {
              setState(() => _liveClasses.removeWhere((item) => item.id == lc.id));
            }),
          ),
        ],
      ),
    );
  }

  // 3. Package Card (CRUD)
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
            child: const Icon(Icons.school_outlined, color: Color(0xFF8B5CF6), size: 18),
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
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 18),
            tooltip: 'Edit Paket',
            onPressed: () => _showEditPackageModal(pkg, isDark),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
            tooltip: 'Hapus Paket',
            onPressed: () => _confirmDelete('Paket Belajar', pkg.title, () {
              // local remove preview
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paket belajar dinonaktifkan dari katalog')));
            }),
          ),
        ],
      ),
    );
  }

  // 4. Video Card (CRUD)
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
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 18),
            tooltip: 'Edit Video',
            onPressed: () => _showEditVideoModal(vid, isDark),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
            tooltip: 'Hapus Video',
            onPressed: () => _confirmDelete('Video Materi', vid.title, () {
              setState(() => _videos.removeWhere((item) => item.id == vid.id));
            }),
          ),
        ],
      ),
    );
  }

  // 5. Module Card (CRUD)
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
            child: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF10B981), size: 18),
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
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 18),
            tooltip: 'Edit Modul',
            onPressed: () => _showEditModuleModal(m, isDark),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
            tooltip: 'Hapus Modul',
            onPressed: () => _confirmDelete('Modul PDF', m.title, () {
              setState(() => _modules.removeWhere((item) => item.id == m.id));
            }),
          ),
        ],
      ),
    );
  }

  // 6. Voucher Card (CRUD)
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
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFEC4899).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(v['code'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFEC4899))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                Text('Kupon Diskon: ${v['discount']} • Kuota: ${v['usage']}', style: TextStyle(fontSize: 9, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 18),
            tooltip: 'Edit Kupon',
            onPressed: () => _showEditVoucherModal(v, isDark),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
            tooltip: 'Hapus Kupon',
            onPressed: () => _confirmDelete('Kupon Voucher', v['code'], () {
              setState(() => _vouchers.removeWhere((item) => item['id'] == v['id']));
            }),
          ),
        ],
      ),
    );
  }

  // Confirmation Dialog Helper
  void _confirmDelete(String itemType, String itemName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Hapus $itemType', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus "$itemName"? Tindakan ini tidak dapat dibatalkan.', style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$itemType berhasil dihapus')));
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // QUICK ADD BOTTOMSHEET
  // =========================================================================
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
                leading: const Icon(Icons.view_carousel_outlined, color: Color(0xFF3B82F6)),
                title: const Text('Banner Promo Carousel'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddBannerModal(isDark);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.videocam_outlined, color: Color(0xFFEF4444)),
                title: const Text('Jadwal Live Class Zoom'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddLiveClassModal(isDark);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.school_outlined, color: Color(0xFF8B5CF6)),
                title: const Text('Paket Belajar & Tryout'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddPackageModal(isDark);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.play_circle_outline_rounded, color: Color(0xFFF59E0B)),
                title: const Text('Video Pembelajaran HD'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddVideoModal(isDark);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF10B981)),
                title: const Text('Modul & E-Book PDF'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddModuleModal(isDark);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.confirmation_number_outlined, color: Color(0xFFEC4899)),
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

  // =========================================================================
  // CREATE / EDIT MODALS
  // =========================================================================

  // 1. Banner Create & Edit
  void _showAddBannerModal(bool isDark) {
    _showBannerFormModal(isDark: isDark, isEdit: false);
  }

  void _showEditBannerModal(BannerModel b, bool isDark) {
    _showBannerFormModal(isDark: isDark, isEdit: true, initialBanner: b);
  }

  void _showBannerFormModal({required bool isDark, required bool isEdit, BannerModel? initialBanner}) {
    final titleCtrl = TextEditingController(text: initialBanner?.title ?? '');
    final tagCtrl = TextEditingController(text: initialBanner?.tag ?? 'PROMO');
    final imageCtrl = TextEditingController(text: initialBanner?.imageUrl ?? 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=900&auto=format&fit=crop&q=80');

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
            Text(isEdit ? 'Edit Banner Promo' : 'Tambah Banner Promo', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                      if (isEdit && initialBanner != null) {
                        final idx = _banners.indexWhere((item) => item.id == initialBanner.id);
                        if (idx != -1) {
                          _banners[idx] = BannerModel(
                            id: initialBanner.id,
                            tag: tagCtrl.text.trim(),
                            subTag: initialBanner.subTag,
                            title: titleCtrl.text.trim(),
                            subtitle: initialBanner.subtitle,
                            imageUrl: imageCtrl.text.trim(),
                            route: initialBanner.route,
                          );
                        }
                      } else {
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
                      }
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Banner berhasil diperbarui!' : 'Banner baru berhasil diterbitkan!')));
                  }
                },
                child: Text(isEdit ? 'Simpan Perubahan' : 'Terbitkan Banner', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Live Class Create & Edit
  void _showAddLiveClassModal(bool isDark) {
    _showLiveClassFormModal(isDark: isDark, isEdit: false);
  }

  void _showEditLiveClassModal(LiveClassModel lc, bool isDark) {
    _showLiveClassFormModal(isDark: isDark, isEdit: true, initialLiveClass: lc);
  }

  void _showLiveClassFormModal({required bool isDark, required bool isEdit, LiveClassModel? initialLiveClass}) {
    final titleCtrl = TextEditingController(text: initialLiveClass?.title ?? '');
    final tutorCtrl = TextEditingController(text: initialLiveClass?.instructor ?? 'Dr. Ir. R. Ridwan Hasan Saputra, M.Si.');
    final subjectCtrl = TextEditingController(text: initialLiveClass?.subject ?? 'Matematika MNR');
    final zoomCtrl = TextEditingController(text: initialLiveClass?.zoomUrl ?? 'https://zoom.us/j/kpmacademy');

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
            Text(isEdit ? 'Edit Jadwal Live Class' : 'Buat Jadwal Live Class Baru', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                      if (isEdit && initialLiveClass != null) {
                        final idx = _liveClasses.indexWhere((item) => item.id == initialLiveClass.id);
                        if (idx != -1) {
                          _liveClasses[idx] = LiveClassModel(
                            id: initialLiveClass.id,
                            title: titleCtrl.text.trim(),
                            instructor: tutorCtrl.text.trim(),
                            subject: subjectCtrl.text.trim(),
                            jenjang: initialLiveClass.jenjang,
                            scheduledAt: initialLiveClass.scheduledAt,
                            durationMinutes: initialLiveClass.durationMinutes,
                            zoomUrl: zoomCtrl.text.trim(),
                            status: initialLiveClass.status,
                            bannerUrl: initialLiveClass.bannerUrl,
                          );
                        }
                      } else {
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
                      }
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Jadwal Live Class diperbarui!' : 'Jadwal Live Class baru berhasil dibuat!')));
                  }
                },
                child: Text(isEdit ? 'Simpan Perubahan' : 'Buat Jadwal', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Package Create & Edit
  void _showAddPackageModal(bool isDark) {
    _showPackageFormModal(isDark: isDark, isEdit: false);
  }

  void _showEditPackageModal(PackageModel pkg, bool isDark) {
    _showPackageFormModal(isDark: isDark, isEdit: true, initialPackage: pkg);
  }

  void _showPackageFormModal({required bool isDark, required bool isEdit, PackageModel? initialPackage}) {
    final titleCtrl = TextEditingController(text: initialPackage?.title ?? '');
    final priceCtrl = TextEditingController(text: initialPackage != null ? '${initialPackage.price.toInt()}' : '199000');

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
            Text(isEdit ? 'Edit Paket Belajar' : 'Tambah Paket Belajar Baru', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Paket belajar berhasil diperbarui!' : 'Paket baru berhasil disimpan!')));
                  }
                },
                child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Paket', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Video Create & Edit
  void _showAddVideoModal(bool isDark) {
    _showVideoFormModal(isDark: isDark, isEdit: false);
  }

  void _showEditVideoModal(VideoModel vid, bool isDark) {
    _showVideoFormModal(isDark: isDark, isEdit: true, initialVideo: vid);
  }

  void _showVideoFormModal({required bool isDark, required bool isEdit, VideoModel? initialVideo}) {
    final titleCtrl = TextEditingController(text: initialVideo?.title ?? '');
    final urlCtrl = TextEditingController(text: initialVideo?.videoUrl ?? 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');

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
            Text(isEdit ? 'Edit Video Materi' : 'Tambah Video Materi Baru', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
                      if (isEdit && initialVideo != null) {
                        final idx = _videos.indexWhere((item) => item.id == initialVideo.id);
                        if (idx != -1) {
                          _videos[idx] = VideoModel(
                            id: initialVideo.id,
                            title: titleCtrl.text.trim(),
                            description: initialVideo.description,
                            thumbnail: initialVideo.thumbnail,
                            videoUrl: urlCtrl.text.trim(),
                            price: initialVideo.price,
                            accessDurationDays: initialVideo.accessDurationDays,
                          );
                        }
                      } else {
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
                      }
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Video materi berhasil diperbarui!' : 'Video materi baru berhasil diunggah!')));
                  }
                },
                child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Video', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Module Create & Edit
  void _showAddModuleModal(bool isDark) {
    _showModuleFormModal(isDark: isDark, isEdit: false);
  }

  void _showEditModuleModal(ModuleModel m, bool isDark) {
    _showModuleFormModal(isDark: isDark, isEdit: true, initialModule: m);
  }

  void _showModuleFormModal({required bool isDark, required bool isEdit, ModuleModel? initialModule}) {
    final titleCtrl = TextEditingController(text: initialModule?.title ?? '');
    final tagCtrl = TextEditingController(text: initialModule?.tag ?? 'Matematika');

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
            Text(isEdit ? 'Edit Modul PDF' : 'Tambah Modul PDF Baru', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
                      if (isEdit && initialModule != null) {
                        final idx = _modules.indexWhere((item) => item.id == initialModule.id);
                        if (idx != -1) {
                          _modules[idx] = ModuleModel(
                            id: initialModule.id,
                            title: titleCtrl.text.trim(),
                            description: initialModule.description,
                            tag: tagCtrl.text.trim(),
                            totalChapters: initialModule.totalChapters,
                            fileUrl: initialModule.fileUrl,
                            fileSize: initialModule.fileSize,
                          );
                        }
                      } else {
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
                      }
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Modul PDF berhasil diperbarui!' : 'Modul PDF baru berhasil diterbitkan!')));
                  }
                },
                child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Modul', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Voucher Create & Edit
  void _showAddVoucherModal(bool isDark) {
    _showVoucherFormModal(isDark: isDark, isEdit: false);
  }

  void _showEditVoucherModal(Map<String, dynamic> v, bool isDark) {
    _showVoucherFormModal(isDark: isDark, isEdit: true, initialVoucher: v);
  }

  void _showVoucherFormModal({required bool isDark, required bool isEdit, Map<String, dynamic>? initialVoucher}) {
    final codeCtrl = TextEditingController(text: initialVoucher?['code'] ?? '');
    final titleCtrl = TextEditingController(text: initialVoucher?['title'] ?? '');
    final discountCtrl = TextEditingController(text: initialVoucher?['discount'] ?? '25%');

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
            Text(isEdit ? 'Edit Kupon Voucher' : 'Buat Kupon Voucher Baru', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Kode Kupon (Misal: DISKON25)')),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Keterangan Promo')),
            TextField(controller: discountCtrl, decoration: const InputDecoration(labelText: 'Besaran Diskon (Contoh: 25% / Rp 50rb)')),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (codeCtrl.text.isNotEmpty) {
                    setState(() {
                      if (isEdit && initialVoucher != null) {
                        final idx = _vouchers.indexWhere((item) => item['id'] == initialVoucher['id']);
                        if (idx != -1) {
                          _vouchers[idx] = {
                            'id': initialVoucher['id'],
                            'code': codeCtrl.text.trim(),
                            'title': titleCtrl.text.trim(),
                            'discount': discountCtrl.text.trim(),
                            'usage': initialVoucher['usage'],
                          };
                        }
                      } else {
                        _vouchers.insert(0, {
                          'id': 'v_${DateTime.now().millisecondsSinceEpoch}',
                          'code': codeCtrl.text.trim().toUpperCase(),
                          'title': titleCtrl.text.trim(),
                          'discount': discountCtrl.text.trim(),
                          'usage': '0/500',
                        });
                      }
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Kupon voucher berhasil diperbarui!' : 'Kupon voucher baru berhasil diaktifkan!')));
                  }
                },
                child: Text(isEdit ? 'Simpan Perubahan' : 'Aktifkan Voucher', style: const TextStyle(fontWeight: FontWeight.bold)),
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
