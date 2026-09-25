import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/support_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _studyReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);

  void _showChangePasswordDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ubah Kata Sandi 🔒', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Lama', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru (min 8 karakter)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await authProvider.changePassword(
                oldPasswordController.text.trim(),
                newPasswordController.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Password berhasil diperbarui!' : (authProvider.errorMessage ?? 'Gagal mengubah password')),
                    backgroundColor: success ? const Color(0xFF00B894) : Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    final supportService = Provider.of<SupportService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final questionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Kirim Tiket Bantuan 🎧', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tuliskan kendala atau pertanyaan Anda kepada tim support KPM Academy.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: questionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tuliskan pertanyaan/kendala di sini...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await supportService.submitSupportTicket(
                  name: user?.fullName ?? 'Siswa KPM',
                  email: user?.email ?? 'siswa@kpm.com',
                  question: questionController.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tiket bantuan berhasil dikirim! Tim kami akan segera merespons.'),
                      backgroundColor: Color(0xFF00B894),
                    ),
                  );
                }
              } catch (_) {}
            },
            child: const Text('Kirim Tiket'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengingat belajar harian diatur ke pukul ${_reminderTime.format(context)} ⏰'),
            backgroundColor: AppTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = authProvider.user;
    final isLoggedIn = authProvider.isAuthenticated;
    
    final String initialChar = (isLoggedIn && user?.fullName != null && user!.fullName.isNotEmpty)
        ? user.fullName[0].toUpperCase()
        : 'T';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Pengaturan & Akun'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const ClampingScrollPhysics(),
        children: [
          // User Profile Card / Guest Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.bentoBoxDecoration(context: context),
            child: isLoggedIn
                ? Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryBlue,
                        backgroundImage: (user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty)
                            ? NetworkImage(user.profilePhoto!)
                            : null,
                        child: (user?.profilePhoto == null || user!.profilePhoto!.isEmpty)
                            ? Text(
                                initialChar,
                                style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Siswa KPM',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              user?.email ?? 'siswa@kpm.com',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.kpmGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Role: ${user?.role.toUpperCase() ?? "USER"}',
                                style: const TextStyle(fontSize: 10, color: AppTheme.kpmGold, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
                        onPressed: () => Navigator.pushNamed(context, '/profile'),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
                            child: const Icon(Icons.person_search_rounded, color: AppTheme.primaryBlue, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mode Akses Tamu 👋',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Daftar atau masuk untuk simpan progres belajar & tryout.',
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 42),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/register'),
                              child: const Text('Daftar Akun 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryBlue,
                                minimumSize: const Size(0, 42),
                                side: const BorderSide(color: AppTheme.primaryBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/login'),
                              child: const Text('Masuk 🔑', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20),

          if (isLoggedIn) ...[
            _sectionTitle('AKUN & KEAMANAN', isDark),
            _settingsGroup(context, [
              _settingsTile(
                context,
                Icons.person_outline_rounded,
                'Data Diri Siswa',
                'Nama, Jenjang Kelas, WhatsApp & Asal Sekolah',
                () => Navigator.pushNamed(context, '/profile'),
              ),
              _settingsTile(
                context,
                Icons.lock_outline_rounded,
                'Ubah Kata Sandi',
                'Ganti kata sandi akun KPM',
                _showChangePasswordDialog,
              ),
              _settingsTile(
                context,
                Icons.security_rounded,
                'Status Akun',
                'Terverifikasi & Aktif',
                () {},
                trailingText: 'Aktif ✅',
              ),
            ]),
            const SizedBox(height: 20),
          ],

          _sectionTitle('PREFERENSI & NOTIFIKASI', isDark),
          _settingsGroup(context, [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined, color: AppTheme.primaryBlue),
              title: Text(
                'Notifikasi Push',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                'Jadwal kelas, tryout baru, dan pengumuman',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                ),
              ),
              value: _pushNotifications,
              onChanged: (val) {
                setState(() => _pushNotifications = val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(val ? 'Notifikasi push diaktifkan 🔔' : 'Notifikasi push dinonaktifkan'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.alarm_rounded, color: AppTheme.primaryPurple),
              title: Text(
                'Pengingat Belajar Harian',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                'Ingatkan jadwal belajar harian setiap ${_reminderTime.format(context)}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                ),
              ),
              value: _studyReminder,
              onChanged: (val) {
                setState(() => _studyReminder = val);
                if (val) {
                  _pickReminderTime();
                }
              },
            ),
            if (_studyReminder) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.schedule_rounded, color: AppTheme.primaryBlue),
                title: Text(
                  'Waktu Pengingat Belajar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Atur jam pengingat belajar harian',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _reminderTime.format(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_outlined, size: 14, color: AppTheme.primaryBlue),
                    ],
                  ),
                ),
                onTap: _pickReminderTime,
              ),
            ],
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined, color: AppTheme.kpmGold),
              title: Text(
                'Tampilan Mode Gelap',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                'Aktifkan tema gelap untuk kenyamanan mata saat belajar',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                ),
              ),
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
          ]),
          const SizedBox(height: 20),

          _sectionTitle('BANTUAN & INFORMASI', isDark),
          _settingsGroup(context, [
            _settingsTile(
              context,
              Icons.headset_mic_outlined,
              'Pusat Bantuan / Kirim Tiket',
              'Hubungi Tim Support & Layanan KPM',
              _showSupportDialog,
            ),
            _settingsTile(
              context,
              Icons.description_outlined,
              'Syarat & Ketentuan',
              'Aturan penggunaan & lisensi KPM Academy',
              () {},
            ),
            _settingsTile(
              context,
              Icons.privacy_tip_outlined,
              'Kebijakan Privasi',
              'Perlindungan data dan kerahasiaan siswa',
              () {},
            ),
          ]),
          const SizedBox(height: 24),

          if (isLoggedIn) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50,
                foregroundColor: Colors.redAccent,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 20),
          ],

          Center(
            child: Text(
              'KPM Academy v1.0.0+1 • Production API Ready',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _settingsGroup(BuildContext context, List<Widget> children) {
    return Container(
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Column(children: children),
    );
  }

  Widget _settingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    VoidCallback onTap, {
    String? trailingText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        sub,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        ),
      ),
      trailing: trailingText != null
          ? Text(
              trailingText,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentGreen),
            )
          : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}
