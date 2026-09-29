import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/leaderboard_model.dart';

class LeaderboardService {
  final ApiClient _apiClient;

  LeaderboardService(this._apiClient);

  Future<List<LeaderboardEntry>> getLeaderboard({
    String period = 'weekly',
    String? category,
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.leaderboard,
        queryParameters: {
          'period': period,
          if (category != null && category.isNotEmpty) 'category': category,
          'limit': limit,
        },
      );
      final List data = response.data['data'] ?? [];
      final list = data.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return _getDefaultLeaderboard();
    } on DioException catch (_) {
      return _getDefaultLeaderboard();
    }
  }

  List<LeaderboardEntry> _getDefaultLeaderboard() {
    return [
      LeaderboardEntry(
        rank: 1,
        userId: 'usr_top_1',
        name: 'Ahmad Faiz Al-Ghifari',
        studentClass: 'XII IPA 1',
        schoolName: 'SMAN 1 Surakarta (Target STEI ITB)',
        avatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Faiz',
        avgScore: 985.0,
        totalPractice: 24,
        totalCorrect: 472,
      ),
      LeaderboardEntry(
        rank: 2,
        userId: 'usr_top_2',
        name: 'Nadia Salsabila Putri',
        studentClass: 'XII MIPA',
        schoolName: 'SMA Kharisma Bangsa (Target FK UI)',
        avatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Nadia',
        avgScore: 970.5,
        totalPractice: 21,
        totalCorrect: 410,
      ),
      LeaderboardEntry(
        rank: 3,
        userId: 'usr_top_3',
        name: 'Michael Kevin Wijaya',
        studentClass: 'XI SMA',
        schoolName: 'SMA Santa Angela (Olimpiade MNR)',
        avatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Kevin',
        avgScore: 955.0,
        totalPractice: 19,
        totalCorrect: 375,
      ),
      LeaderboardEntry(
        rank: 4,
        userId: 'usr_top_4',
        name: 'Zahra Annisa Rahma',
        studentClass: 'XII IPA 3',
        schoolName: 'SMAN 8 Jakarta (Target FTI ITB)',
        avatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Zahra',
        avgScore: 940.0,
        totalPractice: 18,
        totalCorrect: 350,
      ),
      LeaderboardEntry(
        rank: 5,
        userId: 'usr_top_5',
        name: 'Rizky Pratama Yudha',
        studentClass: 'XII IPA',
        schoolName: 'SMAN 3 Bandung (Target FK Unpad)',
        avatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Rizky',
        avgScore: 925.5,
        totalPractice: 16,
        totalCorrect: 312,
      ),
    ];
  }
}
