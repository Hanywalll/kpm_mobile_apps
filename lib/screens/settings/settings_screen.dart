import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/local_notification_service.dart';
import '../../services/notification_service.dart';
import '../../services/support_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ImageProvider? _getAvatarImage(String? photo) {
    if (photo == null || photo.trim().isEmpty) return null;
    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return NetworkImage(photo);
    }
    final file = File(photo);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return NetworkImage(photo);
  }
  bool _pushNotifications = true;
  bool _studyReminder = true;
  List<TimeOfDay> _reminderTimes = [
    const TimeOfDay(hour: 7, minute: 0),
    const TimeOfDay(hour: 12, minute: 0),
    const TimeOfDay(hour: 16, minute: 0),
    const TimeOfDay(hour: 19, minute: 0),
  ];

  static const String _prefKeyTimes = 'kpm_settings_reminder_times_v2';

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final push = prefs.getBool('kpm_settings_push_notifications') ?? true;
      final reminder = prefs.getBool('kpm_settings_study_reminder') ?? true;
      
      final String? timesJson = prefs.getString(_prefKeyTimes);
      List<TimeOfDay> loadedTimes = [];
      if (timesJson != null && timesJson.isNotEmpty) {
        final List decoded = jsonDecode(timesJson);
        loadedTimes = decoded.map((item) {
          final map = Map<String, dynamic>.from(item);
          return TimeOfDay(hour: map['hour'] as int, minute: map['minute'] as int);
        }).toList();
      }

      if (loadedTimes.isEmpty) {
        // Migration from old single time setting if exists
        final oldHour = prefs.getInt('kpm_settings_reminder_hour') ?? 19;
        final oldMinute = prefs.getInt('kpm_settings_reminder_minute') ?? 0;
        loadedTimes = [
          const TimeOfDay(hour: 7, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 16, minute: 0),
          TimeOfDay(hour: oldHour, minute: oldMinute),
        ];
      }

      if (mounted) {
        setState(() {
          _pushNotifications = push;
          _studyReminder = reminder;
          _reminderTimes = loadedTimes;
        });
      }
    } catch (_) {}
  }

  Future<void> _savePushNotifications(bool val) async {
    setState(() => _pushNotifications = val);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('kpm_settings_push_notifications', val);
    } catch (_) {}
  }

  Future<void> _saveStudyReminder(bool val) async {
    setState(() => _studyReminder = val);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('kpm_settings_study_reminder', val);
      if (val) {
        await LocalNotificationService.scheduleMultipleDailyStudyReminders(_reminderTimes);
      } else {
        await LocalNotificationService.cancelAllStudyReminders();
      }
    } catch (_) {}
  }

  Future<void> _saveReminderTimes(List<TimeOfDay> times) async {
    setState(() => _reminderTimes = times);
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(times.map((t) => {'hour': t.hour, 'minute': t.minute}).toList());
      await prefs.setString(_prefKeyTimes, encoded);

      if (_studyReminder) {
        await LocalNotificationService.scheduleMultipleDailyStudyReminders(times);
      }
    } catch (_) {}
  }

  Future<void> _addReminderTime() async {
    if (_reminderTimes.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal 5 jadwal pengingat belajar per hari!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
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
      final updated = List<TimeOfDay>.from(_reminderTimes)..add(picked);
      // Sort times chronologically
      updated.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      await _saveReminderTimes(updated);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Jadwal pengingat pukul ${picked.format(context)} berhasil ditambahkan! ⏰'),
            backgroundColor: AppTheme.primaryBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _editReminderTime(int index) async {
    final current = _reminderTimes[index];
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: current,
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
      final updated = List<TimeOfDay>.from(_reminderTimes);
      updated[index] = picked;
      updated.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      await _saveReminderTimes(updated);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Jadwal berhasil diubah ke pukul ${picked.format(context)} ⏰'),
            backgroundColor: AppTheme.primaryBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteReminderTime(int index) async {
    if (_reminderTimes.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal harus ada 1 jadwal pengingat belajar aktif.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final removed = _reminderTimes[index];
    final updated = List<TimeOfDay>.from(_reminderTimes)..removeAt(index);
    await _saveReminderTimes(updated);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jadwal pengingat pukul ${removed.format(context)} telah dihapus'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
                    backgroundColor: success ? const Color(0xFF1E40AF) : Colors.redAccent,
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
                      backgroundColor: Color(0xFF1E40AF),
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

  void _showTermsDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.description_outlined, color: AppTheme.primaryBlue, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Syarat & Ketentuan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang di aplikasi pembelajaran KPM Academy (Klinik Pendidikan MIPA). Dengan menggunakan aplikasi ini, Anda menyetujui ketentuan berikut:',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLegalPoint('1. Akun Siswa', 'Setiap akun bersifat personal untuk satu siswa terdaftar. Penyebaran akun atau berbagi akses tidak diperkenankan.'),
                _buildLegalPoint('2. Hak Cipta & Materi', 'Seluruh modul pembelajaran MNR, video materi, dan bank soal ujian dilindungi hak cipta KPM. Dilarang menggandakan atau menyebarluaskan materi tanpa izin resmi.'),
                _buildLegalPoint('3. Pembelian & Akses', 'Akses paket belajar, simulasi ujian online, dan live class aktif secara otomatis setelah pembayaran terverifikasi melalui sistem Midtrans.'),
                _buildLegalPoint('4. Integritas Belajar & Ujian', 'Peserta simulasi ujian online dan olimpiade diharapkan menjunjung tinggi kejujuran akademik saat mengerjakan ujian online.'),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Saya Mengerti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.privacy_tip_outlined, color: AppTheme.primaryBlue, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Kebijakan Privasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Klinik Pendidikan MIPA (KPM) berkomitmen menjaga keamanan data pribadi seluruh siswa dan orang tua:',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLegalPoint('1. Pengumpulan Data', 'Kami hanya mengumpulkan data yang diperlukan seperti nama, jenjang kelas, asal sekolah, alamat email, dan riwayat belajar/ujian online.'),
                _buildLegalPoint('2. Penggunaan Informasi', 'Data digunakan untuk personalisasi materi belajar, penerbitan sertifikat/peringkat olimpiade, dan pengiriman notifikasi pengingat.'),
                _buildLegalPoint('3. Keamanan Data', 'Kata sandi Anda dienkripsi dengan standar industri (Hash bcrypt) dan kami tidak pernah menjual data siswa kepada pihak ketiga manapun.'),
                _buildLegalPoint('4. Hak Privasi Anda', 'Anda dapat memperbarui profil atau meminta penghapusan akun sewaktu-waktu melalui Pusat Bantuan KPM.'),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(fontSize: 12, height: 1.35),
          ),
        ],
      ),
    );
  }

  String _getTimeLabel(int hour) {
    if (hour < 11) return 'Pagi';
    if (hour < 15) return 'Siang';
    if (hour < 18) return 'Sore';
    return 'Malam';
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
                        backgroundImage: _getAvatarImage(user?.profilePhoto),
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
                                  'Daftar atau masuk untuk simpan progres belajar & simulasi ujian online.',
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

          _sectionTitle('PREFERENSI & NOTIFIKASI PENGINGAT', isDark),
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
                'Jadwal kelas, paket ujian baru, dan pengumuman',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                ),
              ),
              value: _pushNotifications,
              onChanged: (val) {
                _savePushNotifications(val);
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
              secondary: const Icon(Icons.alarm_rounded, color: AppTheme.primaryBlue),
              title: Text(
                'Pengingat Belajar Harian',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                '${_reminderTimes.length} Jadwal alarm aktif per hari (Maks 5x)',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                ),
              ),
              value: _studyReminder,
              onChanged: (val) {
                _saveStudyReminder(val);
                if (val && _reminderTimes.isEmpty) {
                  _addReminderTime();
                }
              },
            ),
            if (_studyReminder) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'JADWAL PENGINGAT BELAJAR (${_reminderTimes.length}/5)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.primaryBlue,
                      ),
                    ),
                    if (_reminderTimes.length < 5)
                      GestureDetector(
                        onTap: _addReminderTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, size: 14, color: AppTheme.primaryBlue),
                              SizedBox(width: 4),
                              Text(
                                'Tambah Jam',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // List of Scheduled Reminder Times
              ...List.generate(_reminderTimes.length, (index) {
                final time = _reminderTimes[index];
                final period = _getTimeLabel(time.hour);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  title: Text(
                    'Pukul ${time.format(context)} ($period)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Alarm belajar harian berulang',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 18),
                        tooltip: 'Ubah Jam',
                        onPressed: () => _editReminderTime(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                        tooltip: 'Hapus Jam',
                        onPressed: () => _deleteReminderTime(index),
                      ),
                    ],
                  ),
                  onTap: () => _editReminderTime(index),
                );
              }),

              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_to_mobile_rounded, color: AppTheme.primaryBlue, size: 18),
                ),
                title: Text(
                  'Uji Coba Kirim Notifikasi 🔔',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Kirim notifikasi motivasi belajar langsung ke status bar HP',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Kirim 🚀',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                  ),
                ),
                onTap: () async {
                  await LocalNotificationService.showInstantNotification(
                    title: '⏰ Waktunya Belajar di KPM Academy!',
                    body: 'Ayo lanjutkan latihan penalaran Matematika Nalaria & Sains hari ini untuk raih prestasi terbaik!',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifikasi uji coba berhasil dikirim ke bilah status HP! 🔔'),
                        backgroundColor: AppTheme.primaryBlue,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
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
              _showTermsDialog,
            ),
            _settingsTile(
              context,
              Icons.privacy_tip_outlined,
              'Kebijakan Privasi',
              'Perlindungan data dan kerahasiaan siswa',
              _showPrivacyDialog,
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
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            )
          : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}
