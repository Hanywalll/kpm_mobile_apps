import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';

class AdminEnrollKeysScreen extends StatefulWidget {
  const AdminEnrollKeysScreen({super.key});

  @override
  State<AdminEnrollKeysScreen> createState() => _AdminEnrollKeysScreenState();
}

class _AdminEnrollKeysScreenState extends State<AdminEnrollKeysScreen> {
  bool _isLoading = true;
  List<AdminEnrollKeyItem> _keys = [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadEnrollKeys();
  }

  Future<void> _loadEnrollKeys() async {
    setState(() => _isLoading = true);
    final adminService = Provider.of<AdminService>(context, listen: false);
    final list = await adminService.getEnrollKeys();
    if (mounted) {
      setState(() {
        _keys = list;
        _isLoading = false;
      });
    }
  }

  List<AdminEnrollKeyItem> get _filteredKeys {
    if (_selectedFilter == 'all') return _keys;
    if (_selectedFilter == 'available') return _keys.where((k) => !k.isUsed && k.expiredAt.isAfter(DateTime.now())).toList();
    if (_selectedFilter == 'used') return _keys.where((k) => k.isUsed).toList();
    if (_selectedFilter == 'expired') return _keys.where((k) => !k.isUsed && k.expiredAt.isBefore(DateTime.now())).toList();
    return _keys;
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kunci akses "$code" berhasil disalin ke papan klip!'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showGenerateKeyModal(bool isDark) {
    final batchController = TextEditingController(text: 'Batch Sekolah Mitra 2026');
    final packageController = TextEditingController(text: 'Paket Intensif OSN Matematika SMA 2026');
    int validityDays = 90;

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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                      Text(
                        'Generate Kunci Akses Siswa Baru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Buat token kunci akses untuk siswa atau sekolah mitra pendaftaran massal.',
                        style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                      ),
                      const SizedBox(height: 16),
                      Text('Nama Batch / Kelompok:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: batchController,
                        style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Contoh: Batch Bimbel SMAN 5 Bandung',
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          filled: true,
                          fillColor: isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Paket Belajar Target:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: packageController,
                        style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Nama paket belajar yang dibuka',
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          filled: true,
                          fillColor: isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Masa Berlaku Kunci:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                      const SizedBox(height: 6),
                      Row(
                        children: [30, 60, 90, 180].map((days) {
                          final isSelected = validityDays == days;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: ChoiceChip(
                                label: Text('$days Hari'),
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) setModalState(() => validityDays = days);
                                },
                                selectedColor: AppTheme.primaryBlue,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
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
                            final codeNumber = DateTime.now().millisecondsSinceEpoch % 10000;
                            final newKey = AdminEnrollKeyItem(
                              id: 'k-${DateTime.now().millisecondsSinceEpoch}',
                              code: 'KPM-KEY-${DateFormat('yyMM').format(DateTime.now())}-X$codeNumber',
                              packageName: packageController.text.trim(),
                              batch: batchController.text.trim(),
                              expiredAt: DateTime.now().add(Duration(days: validityDays)),
                              isUsed: false,
                            );
                            setState(() {
                              _keys.insert(0, newKey);
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Kunci akses ${newKey.code} berhasil dibuat!'),
                                backgroundColor: const Color(0xFF10B981),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.vpn_key_rounded, size: 16),
                          label: const Text('Buat Kunci Akses Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalAvailable = _keys.where((k) => !k.isUsed && k.expiredAt.isAfter(DateTime.now())).length;
    final totalUsed = _keys.where((k) => k.isUsed).length;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
        leading: AppTheme.backButton(context),
        titleSpacing: 0,
        title: Text(
          'Kunci Akses Siswa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 22, color: AppTheme.primaryBlue),
            tooltip: 'Buat Kunci Akses Baru',
            onPressed: () => _showGenerateKeyModal(isDark),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Buat Kunci Akses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        onPressed: () => _showGenerateKeyModal(isDark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Metric Cards
                Container(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetricMini(
                          label: 'Total Kunci',
                          value: '${_keys.length}',
                          color: const Color(0xFF2563EB),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricMini(
                          label: 'Tersedia',
                          value: '$totalAvailable',
                          color: const Color(0xFF10B981),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricMini(
                          label: 'Terpakai',
                          value: '$totalUsed',
                          color: Colors.grey,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
                // Filter Tabs
                Container(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'Semua (${_keys.length})', isDark),
                        const SizedBox(width: 6),
                        _buildFilterChip('available', 'Tersedia ($totalAvailable)', isDark),
                        const SizedBox(width: 6),
                        _buildFilterChip('used', 'Terpakai ($totalUsed)', isDark),
                        const SizedBox(width: 6),
                        _buildFilterChip('expired', 'Expired', isDark),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // Keys List
                Expanded(
                  child: _filteredKeys.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada kunci akses pada filter ini',
                            style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadEnrollKeys,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                            itemCount: _filteredKeys.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final item = _filteredKeys[idx];
                              return _buildKeyCard(item, isDark);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildMetricMini({required String label, required String value, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterId, String label, bool isDark) {
    final isSelected = _selectedFilter == filterId;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = filterId);
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

  Widget _buildKeyCard(AdminEnrollKeyItem item, bool isDark) {
    final isExpired = !item.isUsed && item.expiredAt.isBefore(DateTime.now());

    Color statusColor;
    String statusLabel;
    if (item.isUsed) {
      statusColor = Colors.grey;
      statusLabel = 'TERPAKAI';
    } else if (isExpired) {
      statusColor = Colors.red;
      statusLabel = 'KADALUARSA';
    } else {
      statusColor = const Color(0xFF10B981);
      statusLabel = 'TERSEDIA';
    }

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.key_rounded, size: 16, color: AppTheme.primaryBlue),
                    const SizedBox(width: 6),
                    Flexible(
                      child: SelectableText(
                        item.code,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 16),
                tooltip: 'Salin Kode',
                color: AppTheme.primaryBlue,
                onPressed: () => _copyToClipboard(item.code),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.packageName,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            item.batch,
            style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.event_outlined, size: 12, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                'Kadaluarsa: ${DateFormat('dd MMM yyyy', 'id_ID').format(item.expiredAt)}',
                style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
              ),
              const Spacer(),
              if (item.isUsed && item.usedBy != null) ...[
                Text(
                  'Digunakan oleh siswa',
                  style: TextStyle(fontSize: 9.5, fontStyle: FontStyle.italic, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
