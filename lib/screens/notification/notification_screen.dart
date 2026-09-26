import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../services/local_notification_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_alert_dialog.dart';

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

  void _simulateReminderNotification() async {
    final notifService = Provider.of<NotificationService>(context, listen: false);
    final now = DateTime.now();
    final newNotif = NotificationModel(
      id: 'notif_sim_${now.millisecondsSinceEpoch}',
      userId: 'user_local',
      title: '⏰ Waktunya Belajar di KPM Academy!',
      message: 'Ayo lanjutkan latihan penalaran Matematika Nalaria & Sains hari ini untuk raih prestasi terbaik!',
      type: 'reminder',
      createdAt: now.toIso8601String(),
    );

    await notifService.addNotification(newNotif);
    await LocalNotificationService.showInstantNotification(
      title: newNotif.title,
      body: newNotif.message,
    );
    _loadNotifications();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi pengingat belajar berhasil dikirim ke status bar! 🔔'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Bersihkan Notifikasi',
            onPressed: () async {
              if (_notifications.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Daftar notifikasi sudah kosong.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              final confirmed = await CustomAlertDialog.show(
                context,
                title: 'Bersihkan Notifikasi?',
                message: 'Apakah Anda yakin ingin menghapus semua riwayat notifikasi? Tindakan ini tidak dapat dibatalkan.',
                confirmText: 'Bersihkan',
                cancelText: 'Batal',
                isDanger: true,
              );

              if (confirmed == true && mounted) {
                await notifService.clearAllNotifications();
                _loadNotifications();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua riwayat notifikasi berhasil dibersihkan 🗑️'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
            physics: const ClampingScrollPhysics(),
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
                          physics: const ClampingScrollPhysics(),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final n = filteredList[index];
                            final bool isReminder = n.type == 'reminder' || n.title.contains('Streak') || n.title.contains('Pengingat');

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  if (!n.isRead) {
                                    await notifService.markRead(n.id);
                                    _loadNotifications();
                                  }
                                  if (context.mounted) {
                                    AppModal.showInfo(
                                      context,
                                      title: n.title,
                                      message: n.message,
                                    );
                                  }
                                },
                                child: Container(
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
                                          isReminder ? Icons.alarm_rounded : Icons.notifications_active_rounded,
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
                                ),
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
