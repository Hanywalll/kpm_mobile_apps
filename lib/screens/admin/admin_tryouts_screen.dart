import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';

class AdminTryoutsScreen extends StatefulWidget {
  const AdminTryoutsScreen({super.key});

  @override
  State<AdminTryoutsScreen> createState() => _AdminTryoutsScreenState();
}

class _AdminTryoutsScreenState extends State<AdminTryoutsScreen> {
  bool _isLoading = true;
  List<AdminTryoutItem> _tryouts = [];
  AdminTryoutItem? _selectedTryout;
  List<AdminTryoutLeaderboardEntry> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadTryoutData();
  }

  Future<void> _loadTryoutData() async {
    setState(() => _isLoading = true);
    final adminService = Provider.of<AdminService>(context, listen: false);
    final tryouts = await adminService.getTryouts();
    if (tryouts.isNotEmpty) {
      final selected = tryouts.first;
      final lb = await adminService.getTryoutLeaderboard(selected.id);
      if (mounted) {
        setState(() {
          _tryouts = tryouts;
          _selectedTryout = selected;
          _leaderboard = lb;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTryout(AdminTryoutItem item) async {
    setState(() {
      _selectedTryout = item;
      _isLoading = true;
    });
    final adminService = Provider.of<AdminService>(context, listen: false);
    final lb = await adminService.getTryoutLeaderboard(item.id);
    if (mounted) {
      setState(() {
        _leaderboard = lb;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
        leading: AppTheme.backButton(context),
        titleSpacing: 0,
        title: Text(
          'Hasil & Ranking Tryout CBT',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tryout Selector Chips
                Container(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _tryouts.map((t) {
                        final isSelected = _selectedTryout?.id == t.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => _selectTryout(t),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : (isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryBlue
                                      : (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : (isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${t.category} • ${t.participantsCount} Peserta',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white.withValues(alpha: 0.8) : (isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // Selected Tryout Summary Metrics
                if (_selectedTryout != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                            : [const Color(0xFF1E3A8A), const Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics_outlined, color: Colors.amberAccent, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _selectedTryout!.title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryMetric('Rata-rata Skor', '${_selectedTryout!.averageScore}'),
                            _buildDivider(),
                            _buildSummaryMetric('Skor Tertinggi', '${_selectedTryout!.highestScore}'),
                            _buildDivider(),
                            _buildSummaryMetric('Kelulusan', '${_selectedTryout!.passingRate}%'),
                            _buildDivider(),
                            _buildSummaryMetric('Peserta', '${_selectedTryout!.participantsCount}'),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Leaderboard title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: Row(
                    children: [
                      Container(width: 3, height: 14, decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 6),
                      Text(
                        'Peringkat & Nilai Siswa (Leaderboard)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Leaderboard list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: _leaderboard.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final item = _leaderboard[idx];
                      return _buildLeaderboardTile(item, isDark);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryMetric(String title, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 9.5)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.2));
  }

  Widget _buildLeaderboardTile(AdminTryoutLeaderboardEntry item, bool isDark) {
    Color rankColor;
    if (item.rank == 1) {
      rankColor = const Color(0xFFEAB308); // Gold
    } else if (item.rank == 2) {
      rankColor = const Color(0xFF94A3B8); // Silver
    } else if (item.rank == 3) {
      rankColor = const Color(0xFFD97706); // Bronze
    } else {
      rankColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.rank <= 3
              ? rankColor.withValues(alpha: 0.3)
              : (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
          width: item.rank <= 3 ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${item.rank}',
                style: TextStyle(color: rankColor, fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
                Text(
                  '${item.correctCount}/${item.totalQuestions} Benar • Waktu: ${item.durationMinutesText}',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.score}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF059669),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: item.isPassed ? const Color(0xFF10B981).withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.isPassed ? 'LULUS' : 'REMEDIAL',
                  style: TextStyle(
                    color: item.isPassed ? const Color(0xFF10B981) : Colors.red,
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
