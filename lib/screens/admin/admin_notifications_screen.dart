import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  bool _isLoading = true;
  List<AdminNotificationItem> _notifications = [];
  String _selectedFilter = 'all';

  final List<Map<String, String>> _filterTabs = [
    {'id': 'all', 'label': 'Semua'},
    {'id': 'unread', 'label': 'Belum Dibaca'},
    {'id': 'payment', 'label': 'Pembayaran'},
    {'id': 'order', 'label': 'Pesanan'},
    {'id': 'support', 'label': 'Tiket Siswa'},
    {'id': 'testimonial', 'label': 'Testimoni'},
    {'id': 'tryout', 'label': 'Tryout CBT'},
    {'id': 'user', 'label': 'Siswa Baru'},
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final adminService = Provider.of<AdminService>(context, listen: false);
    final list = await adminService.getAdminNotifications();
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi berhasil ditandai telah dibaca'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _markItemRead(AdminNotificationItem item) {
    setState(() {
      item.isRead = true;
    });
  }

  List<AdminNotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'all') return _notifications;
    if (_selectedFilter == 'unread') return _notifications.where((n) => !n.isRead).toList();
    return _notifications.where((n) => n.type == _selectedFilter).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
        leading: AppTheme.backButton(context),
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              'Notifikasi Aktivitas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount Baru',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: 16, color: AppTheme.primaryBlue),
              label: const Text('Baca Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Horizontal filter chips
                Container(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _filterTabs.map((tab) {
                        final isSelected = _selectedFilter == tab['id'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(tab['label']!),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedFilter = tab['id']!);
                            },
                            selectedColor: AppTheme.primaryBlue,
                            backgroundColor: isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF1F5F9),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // Notifications feed
                Expanded(
                  child: _filteredNotifications.isEmpty
                      ? _buildEmptyState(isDark)
                      : RefreshIndicator(
                          onRefresh: _loadNotifications,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredNotifications.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final item = _filteredNotifications[idx];
                              return _buildNotificationCard(item, isDark);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildNotificationCard(AdminNotificationItem item, bool isDark) {
    Color typeColor;
    IconData typeIcon;
    String typeLabel;

    switch (item.type) {
      case 'payment':
        typeColor = const Color(0xFF10B981);
        typeIcon = Icons.payments_rounded;
        typeLabel = 'PEMBAYARAN';
        break;
      case 'order':
        typeColor = const Color(0xFF2563EB);
        typeIcon = Icons.shopping_bag_rounded;
        typeLabel = 'PESANAN';
        break;
      case 'support':
        typeColor = const Color(0xFFF59E0B);
        typeIcon = Icons.headset_mic_rounded;
        typeLabel = 'BANTUAN';
        break;
      case 'testimonial':
        typeColor = const Color(0xFF8B5CF6);
        typeIcon = Icons.star_rounded;
        typeLabel = 'TESTIMONI';
        break;
      case 'tryout':
        typeColor = const Color(0xFF06B6D4);
        typeIcon = Icons.emoji_events_rounded;
        typeLabel = 'TRYOUT CBT';
        break;
      case 'user':
        typeColor = const Color(0xFF4F46E5);
        typeIcon = Icons.person_add_alt_1_rounded;
        typeLabel = 'SISWA BARU';
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.notifications_rounded;
        typeLabel = 'AKTIVITAS';
    }

    final timeString = DateFormat('dd MMM, HH:mm', 'id_ID').format(item.createdAt);

    return InkWell(
      onTap: () {
        if (!item.isRead) _markItemRead(item);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: !item.isRead
                ? AppTheme.primaryBlue.withValues(alpha: 0.4)
                : (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
            width: !item.isRead ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: !item.isRead ? 0.04 : 0.01),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                        ),
                      ),
                      if (!item.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: !item.isRead ? FontWeight.bold : FontWeight.w600,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 54, color: isDark ? Colors.white24 : Colors.grey.shade300),
            const SizedBox(height: 14),
            Text(
              'Belum Ada Notifikasi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Aktivitas siswa atau transaksi baru akan langsung tercatat di sini secara otomatis.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
