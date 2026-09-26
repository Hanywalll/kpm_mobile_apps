import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/practice_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const List<String> _presetAvatars = [
    'https://api.dicebear.com/7.x/bottts/png?seed=KPM1',
    'https://api.dicebear.com/7.x/bottts/png?seed=KPM2',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Felix',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Aneka',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Leo',
    'https://api.dicebear.com/7.x/fun-emoji/png?seed=Einstein',
  ];

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

  Future<void> _pickLocalImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked == null) return;

      final fileLength = await picked.length();
      const int maxSizeBytes = 2 * 1024 * 1024; // 2 MB

      if (fileLength > maxSizeBytes) {
        final sizeMb = (fileLength / (1024 * 1024)).toStringAsFixed(2);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Ukuran foto ($sizeMb MB) melebihi batas maksimal 2 MB! Silakan pilih foto lain.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Save locally to App Documents
      final appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'kpm_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedPath = '${appDir.path}/$fileName';
      await File(picked.path).copy(savedPath);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateProfile({
        'profile_photo': savedPath,
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diubah dari perangkat! 📸✨'),
            backgroundColor: AppTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAvatarPickerModal() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final urlController = TextEditingController(text: user?.profilePhoto ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardColor : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Pilih Foto Profil 📷',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Maks. 2 MB',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Ambil foto dari galeri HP atau kamera langsung:',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // 2 Big Action Buttons: Galeri & Kamera
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          foregroundColor: isDark ? Colors.white : AppTheme.primaryBlueDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _pickLocalImage(ImageSource.gallery);
                        },
                        icon: const Icon(Icons.photo_library_rounded, color: AppTheme.primaryBlue),
                        label: const Text(
                          'Galeri HP',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          foregroundColor: isDark ? Colors.white : AppTheme.primaryBlueDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _pickLocalImage(ImageSource.camera);
                        },
                        icon: const Icon(Icons.camera_alt_rounded, color: AppTheme.accentGreen),
                        label: const Text(
                          'Kamera',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Atau Pilih Karakter Avatar KPM:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 74,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetAvatars.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final avatarUrl = _presetAvatars[index];
                      final isSelected = user?.profilePhoto == avatarUrl;
                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(ctx);
                          final success = await authProvider.updateProfile({
                            'profile_photo': avatarUrl,
                          });
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Foto avatar berhasil diubah! 🌟'),
                                backgroundColor: AppTheme.accentGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.backgroundColor,
                            backgroundImage: NetworkImage(avatarUrl),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: 'Atau Masukkan URL Gambar Web',
                    hintText: 'https://example.com/avatar.png',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final customUrl = urlController.text.trim();
                      if (customUrl.isNotEmpty) {
                        final success = await authProvider.updateProfile({
                          'profile_photo': customUrl,
                        });
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Foto profil berhasil diperbarui! ✨'),
                              backgroundColor: AppTheme.accentGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Gunakan URL Foto', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    final nameController = TextEditingController(text: user?.name ?? '');
    final studentNameController = TextEditingController(text: user?.studentName ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final classController = TextEditingController(text: user?.studentClass ?? '');
    final schoolController = TextEditingController(text: user?.schoolName ?? '');
    final addressController = TextEditingController(text: user?.address ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardColor : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Edit Data Siswa ✏️',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Akun', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: studentNameController,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap Siswa', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'No. WhatsApp / HP', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: classController,
                    decoration: const InputDecoration(labelText: 'Jenjang / Kelas (contoh: 5 SD / 8 SMP / 11 SMA)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: schoolController,
                    decoration: const InputDecoration(labelText: 'Asal Sekolah / Target Belajar', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Alamat / Kota', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final success = await authProvider.updateProfile({
                          'name': nameController.text.trim(),
                          'student_name': studentNameController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'student_class': classController.text.trim(),
                          'school_name': schoolController.text.trim(),
                          'address': addressController.text.trim(),
                        });
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profil berhasil diperbarui! ✅'),
                              backgroundColor: Color(0xFF00B894),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = authProvider.user;
    final String initialChar = (user?.fullName != null && user!.fullName.isNotEmpty)
        ? user.fullName[0].toUpperCase()
        : 'S';
    final avatarImg = _getAvatarImage(user?.profilePhoto);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Profil Siswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan & Akun',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Data Profil',
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card with Photo and Change Avatar Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.bentoBoxDecoration(context: context),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppTheme.primaryBlue,
                        backgroundImage: avatarImg,
                        child: avatarImg == null
                            ? Text(
                                initialChar,
                                style: const TextStyle(fontSize: 34, color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showAvatarPickerModal,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppTheme.darkCardColor : Colors.white,
                                width: 2.5,
                              ),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.fullName ?? 'Siswa KPM',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Role: ${user?.role.toUpperCase() ?? "USER"}',
                          style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Terverifikasi ✅',
                          style: TextStyle(color: AppTheme.accentGreen, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _showAvatarPickerModal,
                    icon: const Icon(Icons.add_photo_alternate_outlined, size: 16, color: AppTheme.primaryBlue),
                    label: const Text('Ganti Foto / Avatar Profil', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Detail Data Siswa
            Container(
              decoration: AppTheme.bentoBoxDecoration(context: context),
              child: Column(
                children: [
                  _profileInfoTile(
                    context,
                    Icons.school_outlined,
                    'Jenjang / Kelas',
                    user?.studentClass ?? user?.gradeLevel ?? 'Belum diisi',
                  ),
                  const Divider(height: 1),
                  _profileInfoTile(
                    context,
                    Icons.account_balance_outlined,
                    'Asal Sekolah / Target Belajar',
                    user?.schoolName ?? user?.targetSchool ?? 'Belum diisi',
                  ),
                  const Divider(height: 1),
                  _profileInfoTile(
                    context,
                    Icons.phone_outlined,
                    'No. WhatsApp / HP',
                    (user?.phone.isNotEmpty == true) ? user!.phone : 'Belum diisi',
                  ),
                  if (user?.address != null && user!.address!.isNotEmpty) ...[
                    const Divider(height: 1),
                    _profileInfoTile(
                      context,
                      Icons.location_on_outlined,
                      'Alamat / Kota',
                      user.address!,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Menu Akses Cepat & Pengaturan
            Container(
              decoration: AppTheme.bentoBoxDecoration(context: context),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: AppTheme.primaryBlue),
                    title: Text(
                      'Pengaturan & Akun',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Notifikasi, pengingat belajar, tema & keamanan',
                      style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryBlue),
                    title: Text(
                      'Keranjang Belajar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Lihat paket belajar yang telah Anda pilih',
                      style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history_edu_rounded, color: AppTheme.accentOrange),
                    title: Text(
                      'Riwayat Pesanan Saya',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Lihat seluruh invoice & status pembayaran',
                      style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () => Navigator.pushNamed(context, '/order_history'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined, color: AppTheme.accentGreen),
                    title: Text(
                      'Resi & Bukti Pembayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Cek struk resmi pembelian paket belajar',
                      style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () => Navigator.pushNamed(context, '/receipt'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  try {
                    Provider.of<PracticeProvider>(context, listen: false).reset();
                  } catch (_) {}
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileInfoTile(BuildContext context, IconData icon, String title, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
        ),
      ),
    );
  }
}
