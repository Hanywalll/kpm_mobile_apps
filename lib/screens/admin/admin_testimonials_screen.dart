import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';

class AdminTestimonialsScreen extends StatefulWidget {
  const AdminTestimonialsScreen({super.key});

  @override
  State<AdminTestimonialsScreen> createState() => _AdminTestimonialsScreenState();
}

class _AdminTestimonialsScreenState extends State<AdminTestimonialsScreen> {
  bool _isLoading = true;
  List<AdminTestimonialItem> _testimonials = [];
  String _selectedTab = 'pending';

  @override
  void initState() {
    super.initState();
    _loadTestimonials();
  }

  Future<void> _loadTestimonials() async {
    setState(() => _isLoading = true);
    final adminService = Provider.of<AdminService>(context, listen: false);
    final list = await adminService.getTestimonials();
    if (mounted) {
      setState(() {
        _testimonials = list;
        _isLoading = false;
      });
    }
  }

  List<AdminTestimonialItem> get _filteredList {
    if (_selectedTab == 'all') return _testimonials;
    return _testimonials.where((t) => t.status == _selectedTab).toList();
  }

  void _moderate(AdminTestimonialItem item, String status) {
    setState(() {
      item.status = status;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'approved'
              ? 'Testimoni dari "${item.studentName}" berhasil disetujui untuk tayang publik!'
              : 'Testimoni dari "${item.studentName}" ditolak.',
        ),
        backgroundColor: status == 'approved' ? const Color(0xFF10B981) : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pendingCount = _testimonials.where((t) => t.status == 'pending').length;

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
              'Moderasi Testimoni',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            if (pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$pendingCount Perlu Review',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Horizontal Filter Tabs
                Container(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabButton('pending', 'Menunggu ($pendingCount)', isDark),
                      _buildTabButton('approved', 'Disetujui', isDark),
                      _buildTabButton('rejected', 'Ditolak', isDark),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // Testimonials List
                Expanded(
                  child: _filteredList.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada ulasan pada kategori ini',
                            style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTestimonials,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              final item = _filteredList[idx];
                              return _buildTestimonialCard(item, isDark);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabButton(String tabId, String label, bool isDark) {
    final isSelected = _selectedTab == tabId;
    return InkWell(
      onTap: () => setState(() => _selectedTab = tabId),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppTheme.primaryBlue : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(AdminTestimonialItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.status == 'pending'
              ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
              : (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
                child: Text(
                  item.studentName.isNotEmpty ? item.studentName[0].toUpperCase() : 'S',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.studentName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      item.studentRole,
                      style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (starIdx) {
                  return Icon(
                    starIdx < item.rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 15,
                    color: const Color(0xFFF59E0B),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Paket: ${item.courseName}',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${item.content}"',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                DateFormat('dd MMM yyyy', 'id_ID').format(item.createdAt),
                style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
              ),
              const Spacer(),
              if (item.status == 'pending') ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => _moderate(item, 'rejected'),
                  icon: const Icon(Icons.close_rounded, size: 14),
                  label: const Text('Tolak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => _moderate(item, 'approved'),
                  icon: const Icon(Icons.check_rounded, size: 14),
                  label: const Text('Setujui', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.status == 'approved'
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.status == 'approved' ? 'TAYANG PUBLIK' : 'DITOLAK',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: item.status == 'approved' ? const Color(0xFF10B981) : Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
