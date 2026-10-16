import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  bool _isLoading = true;
  List<AdminSupportTicket> _tickets = [];
  String _selectedStatusFilter = 'all';

  final List<Map<String, String>> _statusTabs = [
    {'id': 'all', 'label': 'Semua'},
    {'id': 'OPEN', 'label': 'Menunggu Respon'},
    {'id': 'IN_PROGRESS', 'label': 'Diproses'},
    {'id': 'RESOLVED', 'label': 'Selesai'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    final adminService = Provider.of<AdminService>(context, listen: false);
    final list = await adminService.getSupportTickets();
    if (mounted) {
      setState(() {
        _tickets = list;
        _isLoading = false;
      });
    }
  }

  List<AdminSupportTicket> get _filteredTickets {
    if (_selectedStatusFilter == 'all') return _tickets;
    return _tickets.where((t) => t.status == _selectedStatusFilter).toList();
  }

  void _showReplyModal(AdminSupportTicket ticket, bool isDark) {
    final replyController = TextEditingController(text: ticket.adminReply ?? '');
    String currentStatus = ticket.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Detail & Balas Tiket Bantuan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getStatusColor(currentStatus).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              currentStatus,
                              style: TextStyle(
                                color: _getStatusColor(currentStatus),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ticket.subject,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dari: ${ticket.studentName} (${ticket.studentEmail})',
                        style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          ticket.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Status Tiket:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildStatusChoice('OPEN', 'Menunggu', currentStatus, (val) => setModalState(() => currentStatus = val), isDark),
                          const SizedBox(width: 6),
                          _buildStatusChoice('IN_PROGRESS', 'Diproses', currentStatus, (val) => setModalState(() => currentStatus = val), isDark),
                          const SizedBox(width: 6),
                          _buildStatusChoice('RESOLVED', 'Selesai', currentStatus, (val) => setModalState(() => currentStatus = val), isDark),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Balasan Administrator:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: replyController,
                        maxLines: 3,
                        style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Tuliskan respon atau solusi untuk siswa...',
                          hintStyle: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          filled: true,
                          fillColor: isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            setState(() {
                              ticket.adminReply = replyController.text.trim();
                              ticket.status = currentStatus;
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tiket bantuan berhasil direspon & status diperbarui'),
                                backgroundColor: Color(0xFF10B981),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text('Simpan & Kirim Jawaban', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChoice(String val, String label, String currentVal, Function(String) onSelect, bool isDark) {
    final isSelected = currentVal == val;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(val),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _getStatusColor(val) : (isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return const Color(0xFFEF4444);
      case 'IN_PROGRESS':
        return const Color(0xFFF59E0B);
      case 'RESOLVED':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final openCount = _tickets.where((t) => t.status == 'OPEN').length;

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
              'Pusat Bantuan Siswa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            if (openCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$openCount Open',
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
                // Filter status chips
                Container(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _statusTabs.map((tab) {
                        final isSelected = _selectedStatusFilter == tab['id'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(tab['label']!),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedStatusFilter = tab['id']!);
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

                // Tickets list
                Expanded(
                  child: _filteredTickets.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada tiket pada kategori ini',
                            style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTickets,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredTickets.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final ticket = _filteredTickets[idx];
                              return _buildTicketCard(ticket, isDark);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTicketCard(AdminSupportTicket ticket, bool isDark) {
    final statusColor = _getStatusColor(ticket.status);

    return InkWell(
      onTap: () => _showReplyModal(ticket, isDark),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ticket.status == 'OPEN'
                ? const Color(0xFFEF4444).withValues(alpha: 0.4)
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
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.status,
                    style: TextStyle(color: statusColor, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM, HH:mm', 'id_ID').format(ticket.createdAt),
                  style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.subject,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ticket.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 14, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  ticket.studentName,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                ),
                const Spacer(),
                if (ticket.adminReply != null && ticket.adminReply!.isNotEmpty) ...[
                  const Icon(Icons.reply_all_rounded, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  const Text('Dibalas', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                ] else ...[
                  const Text('Klik untuk balas >', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
