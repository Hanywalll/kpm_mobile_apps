import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = true;
  List<AdminUserItem> _users = [];
  String _selectedRoleFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
      }
    });
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final adminService = Provider.of<AdminService>(context, listen: false);
    final list = await adminService.getUsers();
    if (mounted) {
      setState(() {
        _users = list;
        _isLoading = false;
      });
    }
  }

  List<AdminUserItem> get _filteredUsers {
    return _users.where((user) {
      final matchesRole = _selectedRoleFilter == 'all' || user.role == _selectedRoleFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery) ||
          user.email.toLowerCase().contains(_searchQuery) ||
          user.phone.contains(_searchQuery);
      return matchesRole && matchesSearch;
    }).toList();
  }

  void _toggleUserStatus(AdminUserItem user) {
    setState(() {
      user.isActive = !user.isActive;
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status pengguna "${user.name}" diubah menjadi: ${user.isActive ? "AKTIF" : "NONAKTIF"}'),
        backgroundColor: user.isActive ? const Color(0xFF10B981) : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showUserDetailDialog(AdminUserItem user, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardColor : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.15),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getRoleColor(user.role),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow('Peran Akun', _getRoleName(user.role), isDark),
              _buildDetailRow('Nomor Kontak', user.phone.isNotEmpty ? user.phone : '-', isDark),
              _buildDetailRow('Terdaftar Sejak', DateFormat('dd MMMM yyyy', 'id_ID').format(user.createdAt), isDark),
              _buildDetailRow('Paket Dimiliki', '${user.coursesEnrolled} Paket Belajar', isDark),
              _buildDetailRow('Status Akun', user.isActive ? 'Aktif Normal' : 'Dinonaktifkan', isDark, isStatus: true, isActive: user.isActive),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: user.isActive ? Colors.red : const Color(0xFF10B981),
                        side: BorderSide(color: user.isActive ? Colors.red.shade200 : Colors.green.shade200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _toggleUserStatus(user),
                      icon: Icon(user.isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded, size: 18),
                      label: Text(user.isActive ? 'Nonaktifkan Akun' : 'Aktifkan Akun', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {bool isStatus = false, bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary)),
          if (!isStatus)
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary))
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF10B981).withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF10B981) : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.amber.shade700;
      case 'teacher':
        return const Color(0xFF8B5CF6);
      case 'student':
      default:
        return const Color(0xFF2563EB);
    }
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'teacher':
        return 'Guru / Tutor';
      case 'student':
      default:
        return 'Siswa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalStudents = _users.where((u) => u.role == 'student').length;
    final totalTeachers = _users.where((u) => u.role == 'teacher').length;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
        leading: AppTheme.backButton(context),
        titleSpacing: 0,
        title: Text(
          'Pengguna & Siswa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Search and Filter Bar
                Container(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Column(
                    children: [
                      // Search TextField
                      TextField(
                        controller: _searchController,
                        style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Cari nama, email, atau no handphone...',
                          hintStyle: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 16),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor: isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Role filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildRoleFilterChip('all', 'Semua (${_users.length})', isDark),
                            const SizedBox(width: 6),
                            _buildRoleFilterChip('student', 'Siswa ($totalStudents)', isDark),
                            const SizedBox(width: 6),
                            _buildRoleFilterChip('teacher', 'Guru ($totalTeachers)', isDark),
                            const SizedBox(width: 6),
                            _buildRoleFilterChip('admin', 'Admin', isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // Users list
                Expanded(
                  child: _filteredUsers.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada data pengguna ditemukan',
                            style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredUsers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final user = _filteredUsers[idx];
                              return _buildUserCard(user, isDark);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildRoleFilterChip(String roleId, String label, bool isDark) {
    final isSelected = _selectedRoleFilter == roleId;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedRoleFilter = roleId);
      },
      selectedColor: AppTheme.primaryBlue,
      backgroundColor: isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF1F5F9),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryBlue : (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
      ),
    );
  }

  Widget _buildUserCard(AdminUserItem user, bool isDark) {
    final roleColor = _getRoleColor(user.role);

    return InkWell(
      onTap: () => _showUserDetailDialog(user, isDark),
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: roleColor.withValues(alpha: 0.15),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getRoleName(user.role),
                          style: TextStyle(color: roleColor, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.school_outlined, size: 12, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${user.coursesEnrolled} Paket',
                        style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: user.isActive ? const Color(0xFF10B981) : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.isActive ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: user.isActive ? const Color(0xFF10B981) : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
