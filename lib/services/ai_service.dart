import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/chat_model.dart';

class AIService {
  final ApiClient _apiClient;

  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const List<String> candidateModels = [
    'gemini-3.5-flash',
    'gemini-3.1-flash-lite',
    'gemini-flash-latest',
  ];

  static const String _kpmPersona = '''Anda adalah AI Master Tutor di KPM Academy (Klinik Pendidikan MIPA).
Keahlian Anda meliputi Matematika Nalaria Realistik (MNR), Sains Terpadu (Fisika, Kimia, Biologi), dan Penalaran Logika.
Instruksi Penting:
1. Jawablah setiap pertanyaan secara akurat, tepat, dan to the point.
2. Jika ada perhitungan matematika, jelaskan langkahnya (step-by-step) secara logis dan runtut.
3. Gunakan bahasa Indonesia yang jelas, bersahabat, dan memotivasi.
4. Gunakan pemformatan rapi dengan bullet points atau penomoran untuk memudahkan membaca.''';

  AIService(this._apiClient);

  Future<Map<String, dynamic>> sendChatMessage(String message, {String? sessionId}) async {
    // 1. Direct Gemini AI with multi-model fallback & retry
    try {
      final directReply = await callGeminiDirect(message);
      if (directReply != null && directReply.trim().isNotEmpty) {
        return {
          'session_id': sessionId ?? 'CHAT-KPM-${DateTime.now().millisecondsSinceEpoch}',
          'reply': directReply.trim(),
        };
      }
    } catch (_) {}

    // 2. Try Backend Go API
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.chatSend,
        data: {
          'message': message,
          if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
        },
      );
      final raw = response.data['data'] ?? response.data;
      if (raw is Map<String, dynamic>) {
        final assistant = raw['assistant_message'];
        final assistantText = (assistant is Map ? assistant['message'] : null)?.toString();
        final reply = raw['reply']?.toString() ?? assistantText;
        if (reply != null &&
            reply.isNotEmpty &&
            !reply.toLowerCase().contains('tanggapan') &&
            !reply.toLowerCase().contains('thank you for your message')) {
          return {
            'session_id': raw['session_id']?.toString() ?? sessionId ?? 'CHAT-KPM',
            'reply': reply,
          };
        }
      }
    } catch (_) {}

    // 3. Smart Pedagogical Offline Fallback
    return {
      'session_id': sessionId ?? 'CHAT-KPM-${DateTime.now().millisecondsSinceEpoch}',
      'reply': _generateSmartResponse(message),
    };
  }

  Future<String?> callGeminiDirect(String message) async {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ));

    for (final model in candidateModels) {
      try {
        final response = await dio.post(
          '/models/$model:generateContent?key=$geminiApiKey',
          data: {
            'systemInstruction': {
              'parts': [
                {'text': _kpmPersona}
              ]
            },
            'contents': [
              {
                'parts': [
                  {'text': message}
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.7,
              'topP': 0.9,
              'maxOutputTokens': 1500,
            }
          },
        );

        final candidates = response.data?['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]['content']?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text']?.toString();
            if (text != null && text.trim().isNotEmpty) {
              return text;
            }
          }
        }
      } catch (_) {
        // Try next candidate model
        continue;
      }
    }
    return null;
  }

  Future<List<ChatModel>> getChatHistory(String sessionId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.chatHistory,
        queryParameters: {'session_id': sessionId},
      );
      final List data = response.data['data'] ?? [];
      return data.map((e) => ChatModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (_) {
      return [];
    }
  }

  Future<String> askAITutor(String message, {String? imageBase64, String? sessionId}) async {
    final res = await sendChatMessage(message, sessionId: sessionId);
    return res['reply']?.toString() ?? _generateSmartResponse(message);
  }

  String _generateSmartResponse(String query) {
    final q = query.toLowerCase().trim();

    // Check arithmetic patterns like "15 x 12", "15 * 12", "15 + 12", "100 / 4"
    final mathReg = RegExp(r'(\d+)\s*([\+\-\*xX/÷:])\s*(\d+)');
    final match = mathReg.firstMatch(q);
    if (match != null) {
      final a = double.tryParse(match.group(1)!) ?? 0;
      final op = match.group(2)!;
      final b = double.tryParse(match.group(3)!) ?? 0;
      double result = 0;
      String opName = 'perkalian';
      if (op == '+' ) { result = a + b; opName = 'penjumlahan'; }
      else if (op == '-' ) { result = a - b; opName = 'pengurangan'; }
      else if (op == '*' || op.toLowerCase() == 'x') { result = a * b; opName = 'perkalian'; }
      else if (op == '/' || op == '÷' || op == ':') { result = b != 0 ? a / b : double.nan; opName = 'pembagian'; }

      final formattedRes = result % 1 == 0 ? result.toInt().toString() : result.toStringAsFixed(2);
      return 'Hasil $opName dari **${match.group(1)} $op ${match.group(3)}** adalah **$formattedRes**.\n\n✨ **Langkah Perhitungan:**\n• ${match.group(1)} $op ${match.group(3)} = **$formattedRes**\n\nAda soal lain yang ingin kamu hitung bersama AI Tutor KPM?';
    }

    if (q.contains('logaritma')) {
      return '💡 **Konsep & Trik Cepat Logaritma:**\n\n1️⃣ **Sifat Utama:**\n• ^a\\log(b × c) = ^a\\log(b) + ^a\\log(c)\n• ^a\\log(b / c) = ^a\\log(b) - ^a\\log(c)\n• ^a\\log(bⁿ) = n × ^a\\log(b)\n\n2️⃣ **Trik Cepat:**\nJika ^a\\log(b) = x, maka aˣ = b. Selalu samakan basis numerus terlebih dahulu sebelum mengoperasikan penjumlahan atau pengurangan!\n\nAda contoh soal logaritma yang ingin kamu bedah bersama?';
    }
    if (q.contains('stoikiometri') || q.contains('kimia')) {
      return '🧪 **Panduan Stoikiometri Kimia:**\n\n1️⃣ **Rumus Utama Mol (n):**\n• n = massa (gram) / Mr (Massa Molar)\n• n = Volume gas (STP) / 22.4 Liter\n• n = Molaritas (M) × Volume (L)\n\n2️⃣ **Langkah Penyelesaian Soal:**\n1. Setarakan persamaan reaksi kimia.\n2. Ubah semua besaran yang diketahui ke dalam satuan **Mol**.\n3. Gunakan perbandingan koefisien untuk mencari mol zat yang ditanyakan.\n4. Konversi mol tersebut ke gram atau liter sesuai pertanyaan!';
    }
    if (q.contains('kuadrat') || q.contains('aljabar')) {
      return '📐 **Rumus Kuadrat Sempurna & Aljabar:**\n\n1️⃣ Bentuk: (a + b)² = a² + 2ab + b²\n2️⃣ Bentuk: (a - b)² = a² - 2ab + b²\n3️⃣ Selisih Kuadrat: a² - b² = (a + b)(a - b)\n\n⚡ **Rumus ABC untuk persamaan kuadrat ax² + bx + c = 0:**\nx = (-b ± √(b² - 4ac)) / (2a)\n\nIngin membahas variasi soal kuadrat atau pemfaktoran?';
    }
    if (q.contains('mnr') || q.contains('nalaria') || q.contains('matematika')) {
      return '✨ **Metode Matematika Nalaria Realistik (MNR) KPM:**\n\nMetode MNR melatih 3 tahapan berpikir nalar:\n1. **Memahami Masalah:** Identifikasi fakta, data, dan pola angka tanpa rumus kaku.\n2. **Bernalar Kreatif:** Mengubah soal cerita kompleks menjadi skema logika sederhana.\n3. **Verifikasi:** Mengecek kembali kewajaran hasil jawaban.\n\nKetikkan soal matematika MNR yang sedang kamu pelajari, AI Tutor siap bantu langkah demi langkah!';
    }
    return 'Halo! Pertanyaan kamu mengenai "$query" sangat menarik. 🤖✨\n\n💡 **Penjelasan Singkat:**\nUntuk memahami dan menyelesaikan permasalahan ini, pastikan kamu mengidentifikasi hal yang diketahui, konsep rumus yang berkaitan, serta tujuan akhir perhitungan.\n\nSilakan ketikkan rincian soal atau angka yang ingin dihitung secara spesifik agar saya bantu jawab dengan tepat!';
  }
}
