import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/leaderboard_model.dart';
import '../../services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedPeriod = 'weekly';
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() async {
    setState(() => _isLoading = true);
    final service = Provider.of<LeaderboardService>(context, listen: false);
    final list = await service.getLeaderboard(period: _selectedPeriod);
    if (mounted) {
      setState(() {
        _entries = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Papan Skor & Peringkat Siswa'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadLeaderboard(),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                physics: const ClampingScrollPhysics(),
                children: [
                  // 1. Filter Chips (Mingguan, Bulanan, Sepanjang Waktu)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCardColor : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                    ),
                    child: Row(
                      children: [
                        _buildPeriodTab('weekly', 'Mingguan 🔥', isDark),
                        _buildPeriodTab('monthly', 'Bulanan 📅', isDark),
                        _buildPeriodTab('all_time', 'All Time 🏆', isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 2. Podium Top 3 (if entries >= 3)
                  if (_entries.length >= 3) _buildPodiumSection(_entries.take(3).toList(), isDark),

                  const SizedBox(height: 20),

                  // 3. Header Rank List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Peringkat Nasional Top Siswa',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Sistem IRT Live',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 4. List of entries from rank 4 onwards (or all if < 3)
                  ...(_entries.length >= 3 ? _entries.skip(3) : _entries).map((entry) {
                    return _buildRankItemTile(entry, isDark);
                  }),
                ],
              ),
      ),
    );
  }

  Widget _buildPeriodTab(String key, String label, bool isDark) {
    final isSelected = _selectedPeriod == key;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedPeriod != key) {
            setState(() => _selectedPeriod = key);
            _loadLeaderboard();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumSection(List<LeaderboardEntry> top3, bool isDark) {
    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '👑 PODIUM JUARA KPM',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1.1),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Rank 2 (Silver)
              if (second != null) _buildPodiumColumn(second, 2, const Color(0xFFE2E8F0), 80),
              // Rank 1 (Gold)
              _buildPodiumColumn(first, 1, const Color(0xFFFBBF24), 105),
              // Rank 3 (Bronze)
              if (third != null) _buildPodiumColumn(third, 3, const Color(0xFFFB923C), 65),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn(LeaderboardEntry entry, int rank, Color badgeColor, double barHeight) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: rank == 1 ? 26 : 22,
                backgroundColor: badgeColor.withValues(alpha: 0.3),
                child: CircleAvatar(
                  radius: rank == 1 ? 24 : 20,
                  backgroundImage: CachedNetworkImageProvider(
                    entry.avatar ?? 'https://api.dicebear.com/7.x/adventurer/png?seed=${entry.name}',
                  ),
                ),
              ),
              Positioned(
                bottom: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            '${entry.avgScore.toStringAsFixed(1)} Pts',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor),
          ),
          const SizedBox(height: 6),
          Container(
            height: barHeight,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: rank == 1 ? 0.25 : 0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                '${entry.totalPractice} Sesi\n${entry.totalCorrect} Benar',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, color: Colors.white70, height: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankItemTile(LeaderboardEntry entry, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Row(
        children: [
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundImage: CachedNetworkImageProvider(
              entry.avatar ?? 'https://api.dicebear.com/7.x/adventurer/png?seed=${entry.name}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${entry.studentClass ?? 'Siswa'} • ${entry.schoolName ?? 'KPM Academy'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.avgScore.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryBlue,
                ),
              ),
              Text(
                '${entry.totalPractice} Latihan',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
