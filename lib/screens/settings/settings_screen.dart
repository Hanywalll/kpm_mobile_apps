import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _studyReminder = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final String initialChar = (user?.fullName != null && user!.fullName.isNotEmpty)
        ? user.fullName[0].toUpperCase()
        : 'S';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Pengaturan & Akun ⚙️'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryBlue,
                  child: Text(
                    initialChar,
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? 'Siswa', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(user?.email ?? 'siswa@kpm.com', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(6)),
                        child: Text('Paket ${user?.membershipStatus ?? 'Premium'}', style: TextStyle(fontSize: 10, color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('AKUN & KEAMANAN'),
          _settingsGroup([
            _settingsTile(Icons.person_outline_rounded, 'Data Diri Siswa', 'Nama, Jenjang, WhatsApp & PTN Impian', () => Navigator.pushNamed(context, '/profile')),
            _settingsTile(Icons.lock_outline_rounded, 'Ubah Password', 'Ganti kata sandi akun', () {}),
            _settingsTile(Icons.security_rounded, 'Verifikasi Email & HP', 'Status Terverifikasi', () {}, trailingText: 'Terverifikasi ✅'),
          ]),
          const SizedBox(height: 20),
          _sectionTitle('PREFERENSI & NOTIFIKASI'),
          _settingsGroup([
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined, color: AppTheme.primaryBlue),
              title: const Text('Notifikasi Push', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('Jadwal kelas, tryout, dan pengumuman', style: TextStyle(fontSize: 11, color: Colors.grey)),
              value: _pushNotifications,
              onChanged: (val) => setState(() => _pushNotifications = val),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.alarm_rounded, color: AppTheme.primaryPurple),
              title: const Text('Pengingat Belajar Harian', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('Notifikasi harian untuk menjaga streak', style: TextStyle(fontSize: 11, color: Colors.grey)),
              value: _studyReminder,
              onChanged: (val) => setState(() => _studyReminder = val),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined, color: Colors.orange),
              title: const Text('Tampilan Mode Gelap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('Aktifkan tema gelap untuk kenyamanan mata', style: TextStyle(fontSize: 11, color: Colors.grey)),
              value: _darkMode,
              onChanged: (val) => setState(() => _darkMode = val),
            ),
          ]),
          const SizedBox(height: 20),
          _sectionTitle('BANTUAN & INFORMASI'),
          _settingsGroup([
            _settingsTile(Icons.help_outline_rounded, 'Pusat Bantuan & FAQ', 'Pertanyaan sering diajukan', () {}),
            _settingsTile(Icons.headset_mic_outlined, 'Hubungi Customer Service', 'WhatsApp Support 24/7', () {}),
            _settingsTile(Icons.description_outlined, 'Syarat & Ketentuan', 'Aturan penggunaan KPM Academy', () {}),
            _settingsTile(Icons.privacy_tip_outlined, 'Kebijakan Privasi', 'Perlindungan data pengguna', () {}),
          ]),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            label: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'KPM Academy v1.0.0+1 • Production',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
      ),
    );
  }

  Widget _settingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsTile(IconData icon, String title, String sub, VoidCallback onTap, {String? trailingText}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: trailingText != null
          ? Text(trailingText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green))
          : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}
