import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Pengumuman', 'Promo', 'Jadwal Live'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() async {
    final notifService = Provider.of<NotificationService>(context, listen: false);
    final list = await notifService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  void _simulateReminderNotification() {
    final newNotif = NotificationModel(
      id: 'notif_sim_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_local',
      title: 'Pengingat Belajar KPM',
      message: 'Waktunya menyelesaikan latihan soal Matematika Nalaria & Sains KPM hari ini!',
      type: 'reminder',
      createdAt: DateTime.now().toIso8601String(),
    );

    setState(() {
      _notifications.insert(0, newNotif);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengingat harian simulasi berhasil diterima! 🔔'),
        backgroundColor: AppTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifService = Provider.of<NotificationService>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredList = _selectedFilter == 'Semua'
        ? _notifications
        : _notifications.where((n) {
            if (_selectedFilter == 'Pengumuman') return n.type == 'info' || n.type == 'general';
            if (_selectedFilter == 'Promo') return n.type == 'promo';
            if (_selectedFilter == 'Jadwal Live') return n.type == 'live' || n.type == 'reminder';
            return true;
          }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Notifikasi & Pengingat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm_rounded),
            tooltip: 'Simulasi Pengingat Harian',
            onPressed: _simulateReminderNotification,
          ),
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Tandai semua dibaca',
            onPressed: () async {
              await notifService.markAllRead();
              _loadNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua notifikasi ditandai telah dibaca ✅'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Modern Minimalist Grey Tabs)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                            : (isDark ? AppTheme.darkCardColor : Colors.white),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1))
                              : (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Notification List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_none_rounded, size: 54, color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Belum ada notifikasi di kategori ini',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Pemberitahuan kelas, materi, dan pengingat akan muncul di sini',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadNotifications(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(18),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final n = filteredList[index];
                            final bool isReminder = n.type == 'reminder' || n.title.contains('Streak') || n.title.contains('Pengingat');

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: AppTheme.bentoBoxDecoration(context: context),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isReminder
                                          ? AppTheme.kpmGold.withValues(alpha: 0.15)
                                          : AppTheme.primaryBlue.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      isReminder ? Icons.local_fire_department_rounded : Icons.notifications_active_rounded,
                                      color: isReminder ? AppTheme.kpmGold : AppTheme.primaryBlue,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                n.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                                ),
                                              ),
                                            ),
                                            if (!n.isRead)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: AppTheme.primaryBlue,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          n.message,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          n.createdAt.contains('T') ? n.createdAt.split('T').first : n.createdAt,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
