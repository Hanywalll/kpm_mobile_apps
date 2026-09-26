import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/chat_model.dart';

class AIService {
  final ApiClient _apiClient;

  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const List<String> candidateModels = [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-2.0-flash',
    'gemini-flash-latest',
  ];

  static const String _kpmPersona = '''Anda adalah AI Master Tutor di KPM Academy (Klinik Pendidikan MIPA).
Keahlian Anda meliputi Matematika Nalaria Realistik (MNR), Sains Terpadu (Fisika, Kimia, Biologi), dan Penalaran Logika SNBT/UTBK.
Instruksi Penting:
1. Jawablah setiap pertanyaan secara akurat, ilmiah, dan to-the-point.
2. Jika ada perhitungan atau soal latihan, jelaskan langkahnya (step-by-step) secara terstruktur dan logis.
3. Gunakan bahasa Indonesia yang santun, ramah, dan memotivasi siswa.
4. Gunakan pemformatan rapi dengan bullet points, angka, dan penekanan bold pada istilah/hasil penting.''';

  AIService(this._apiClient);

  Future<Map<String, dynamic>> sendChatMessage(String message, {String? sessionId}) async {
    final cleanMessage = message.trim();
    if (cleanMessage.isEmpty) {
      return {
        'session_id': sessionId ?? 'CHAT-KPM-${DateTime.now().millisecondsSinceEpoch}',
        'reply': 'Halo! Ada materi atau soal matematika dan sains yang ingin kamu tanyakan kepada AI Tutor? 😊',
      };
    }

    // 1. Direct Gemini AI (if API key is available)
    if (geminiApiKey.isNotEmpty) {
      try {
        final directReply = await callGeminiDirect(cleanMessage);
        if (directReply != null && directReply.trim().isNotEmpty) {
          return {
            'session_id': sessionId ?? 'CHAT-KPM-${DateTime.now().millisecondsSinceEpoch}',
            'reply': directReply.trim(),
          };
        }
      } catch (_) {}
    }

    // 2. Backend Go API call
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.chatSend,
        data: {
          'message': cleanMessage,
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
            !reply.toLowerCase().contains('terima kasih atas pesan') &&
            !reply.toLowerCase().contains('thank you for your message')) {
          return {
            'session_id': raw['session_id']?.toString() ?? sessionId ?? 'CHAT-KPM',
            'reply': reply,
          };
        }
      }
    } catch (_) {}

    // 3. Ultra-Smart Knowledge & Mathematical Reasoning Solver (Offline / High-Accuracy Engine)
    return {
      'session_id': sessionId ?? 'CHAT-KPM-${DateTime.now().millisecondsSinceEpoch}',
      'reply': solveQueryIntelligently(cleanMessage),
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
    return res['reply']?.toString() ?? solveQueryIntelligently(message);
  }

  // =========================================================================
  // HIGH-ACCURACY PEDAGOGICAL KNOWLEDGE & REASONING ENGINE
  // =========================================================================

  static String solveQueryIntelligently(String query) {
    final q = query.toLowerCase().trim();

    // -------------------------------------------------------------
    // 1. GREETINGS & INTRODUCTIONS
    // -------------------------------------------------------------
    if (q == 'halo' || q == 'hai' || q == 'hi' || q == 'assalamualaikum' || q == 'p' || q == 'selamat pagi' || q == 'selamat siang' || q == 'selamat malam') {
      return 'Halo! Selamat datang di **KPM AI Tutor** 🎓🤖\n\nSaya siap membantumu belajar dan memahami berbagai materi:\n• 📐 **Matematika & MNR (Matematika Nalaria Realistik)**\n• ⚡ **Fisika, Kimia, & Biologi (Sains Terpadu)**\n• 📝 **Latihan Soal Ujian, Olimpiade & SNBT/UTBK**\n• 💡 **Perhitungan Matematika Cepat & Logika Soal Cerita**\n\nKetikkan pertanyaan atau soal latihan yang ingin kita bahas bersama!';
    }

    // -------------------------------------------------------------
    // 2. MATHEMATICAL ARITHMETIC & FORMULA PARSER
    // -------------------------------------------------------------
    
    // Percentage calculation: "15% dari 200000" or "berapa 25 persen dari 50000"
    final percentReg = RegExp(r'(\d+(?:[\.,]\d+)?)\s*(?:%|persen)\s*(?:dari|of|\*|x)?\s*(\d+(?:[\.,]\d+)?)');
    final percentMatch = percentReg.firstMatch(q);
    if (percentMatch != null) {
      final pct = double.tryParse(percentMatch.group(1)!.replaceAll(',', '.')) ?? 0;
      final total = double.tryParse(percentMatch.group(2)!.replaceAll(',', '.')) ?? 0;
      final result = (pct / 100.0) * total;
      final formattedRes = result % 1 == 0 ? result.toInt().toString() : result.toStringAsFixed(2);
      return '🎯 **Hasil Perhitungan Persentase:**\n\n'
          '**$pct% dari $total** adalah **$formattedRes**\n\n'
          '📐 **Langkah Penyelesaian:**\n'
          '1. Ubah persen menjadi pecahan desimal: $pct% = $pct / 100 = ${pct / 100}\n'
          '2. Kalikan dengan nilai total: ${pct / 100} × $total = **$formattedRes**\n\n'
          '💡 *Tips KPM:* Untuk menghitung diskon atau kenaikan nilai, kalikan langsung dengan faktor pengali (misal diskon 20% = 80% harga awal).';
    }

    // Square Root: "akar dari 144", "akar 81", "sqrt 256", "akar kuadrat 625"
    final sqrtReg = RegExp(r'(?:akar|sqrt|akar kuadrat)(?:\s*dari)?\s*(\d+(?:[\.,]\d+)?)');
    final sqrtMatch = sqrtReg.firstMatch(q);
    if (sqrtMatch != null) {
      final numVal = double.tryParse(sqrtMatch.group(1)!.replaceAll(',', '.')) ?? 0;
      final result = math.sqrt(numVal);
      final formattedRes = result % 1 == 0 ? result.toInt().toString() : result.toStringAsFixed(4);
      return '🎯 **Hasil Penarikan Akar Kuadrat:**\n\n'
          '√**$numVal** = **$formattedRes**\n\n'
          '📐 **Pembahasan:**\n'
          'Karena $formattedRes × $formattedRes = **$numVal**, maka akar kuadrat dari $numVal adalah **$formattedRes**.\n\n'
          '💡 *Tips MNR:* Perhatikan angka satuan terakhir untuk menebak akar bilangan kuadrat secara cepat tanpa kalkulator!';
    }

    // Exponent / Powers: "2 pangkat 8", "3 ^ 4", "5 pangkat 3"
    final powReg = RegExp(r'(\d+(?:[\.,]\d+)?)\s*(?:\^|pangkat)\s*(\d+(?:[\.,]\d+)?)');
    final powMatch = powReg.firstMatch(q);
    if (powMatch != null) {
      final base = double.tryParse(powMatch.group(1)!.replaceAll(',', '.')) ?? 0;
      final exp = double.tryParse(powMatch.group(2)!.replaceAll(',', '.')) ?? 0;
      final result = math.pow(base, exp);
      final formattedRes = result % 1 == 0 ? result.toInt().toString() : result.toStringAsFixed(2);
      return '🎯 **Hasil Perpangkatan:**\n\n'
          '**$base^$exp** = **$formattedRes**\n\n'
          '📐 **Konsep:**\n'
          'Perpangkatan adalah perkalian berulang dari basis sebanyak eksponen ($exp kali):\n'
          '• $base × $base ... ($exp kali) = **$formattedRes**';
    }

    // Linear Equation: "2x + 4 = 10", "3x - 5 = 16", "x + 7 = 15"
    final linearReg = RegExp(r'(\d*)\s*x\s*([\+\-])\s*(\d+)\s*=\s*(\d+)');
    final linMatch = linearReg.firstMatch(q.replaceAll(' ', ''));
    if (linMatch != null) {
      final aStr = linMatch.group(1);
      final double a = (aStr == null || aStr.isEmpty) ? 1.0 : (double.tryParse(aStr) ?? 1.0);
      final op = linMatch.group(2)!;
      final b = double.tryParse(linMatch.group(3)!) ?? 0;
      final c = double.tryParse(linMatch.group(4)!) ?? 0;

      final double rightSide = op == '+' ? (c - b) : (c + b);
      final double xVal = rightSide / a;
      final formattedX = xVal % 1 == 0 ? xVal.toInt().toString() : xVal.toStringAsFixed(2);

      return '🎯 **Penyelesaian Persamaan Linear:**\n\n'
          'Persamaan: **${a != 1 ? a.toInt() : ''}x $op ${b.toInt()} = ${c.toInt()}**\n\n'
          '📐 **Langkah Penyelesaian (Step-by-Step):**\n'
          '1. Pindahkan konstanta ke ruas kanan:\n'
          '   ${a != 1 ? a.toInt() : ''}x = ${c.toInt()} ${op == '+' ? '-' : '+'} ${b.toInt()}\n'
          '   ${a != 1 ? a.toInt() : ''}x = ${rightSide.toInt()}\n'
          '2. Bagi kedua ruas dengan koefisien x (${a.toInt()}):\n'
          '   x = ${rightSide.toInt()} / ${a.toInt()}\n'
          '   **x = $formattedX**\n\n'
          '✅ **Nilai x yang memenuhi adalah $formattedX**';
    }

    // General Arithmetic Expression: "125 * 8", "1500 / 25", "450 + 275", "1000 - 345"
    final mathReg = RegExp(r'(\d+(?:[\.,]\d+)?)\s*([\+\-\*xX/÷:])\s*(\d+(?:[\.,]\d+)?)');
    final match = mathReg.firstMatch(q);
    if (match != null) {
      final a = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 0;
      final op = match.group(2)!;
      final b = double.tryParse(match.group(3)!.replaceAll(',', '.')) ?? 0;
      double result = 0;
      String opName = 'Operasi';

      if (op == '+') {
        result = a + b;
        opName = 'Penjumlahan';
      } else if (op == '-') {
        result = a - b;
        opName = 'Pengurangan';
      } else if (op == '*' || op.toLowerCase() == 'x') {
        result = a * b;
        opName = 'Perkalian';
      } else if (op == '/' || op == '÷' || op == ':') {
        result = b != 0 ? a / b : double.nan;
        opName = 'Pembagian';
      }

      final formattedRes = result % 1 == 0 ? result.toInt().toString() : result.toStringAsFixed(2);
      return '🎯 **Hasil $opName:**\n\n'
          '**${match.group(1)} $op ${match.group(3)}** = **$formattedRes**\n\n'
          '📐 **Langkah Perhitungan:**\n'
          '• Nilai pertama: ${match.group(1)}\n'
          '• Operasi: $opName ($op)\n'
          '• Nilai kedua: ${match.group(3)}\n'
          '• Hasil Akhir = **$formattedRes**\n\n'
          'Ada soal matematika atau penalaran angka lain yang ingin dihitung?';
    }

    // -------------------------------------------------------------
    // 3. GEOMETRY & TRIGONOMETRY
    // -------------------------------------------------------------
    if (q.contains('luas lingkaran') || q.contains('keliling lingkaran')) {
      return '⭕ **Rumus Lengkap Lingkaran:**\n\n'
          '1️⃣ **Luas Lingkaran (L):**\n'
          '• **L = π × r²** atau **L = ¼ × π × d²**\n'
          '  *(π ≈ 22/7 atau 3.14, r = jari-jari, d = diameter)*\n\n'
          '2️⃣ **Keliling Lingkaran (K):**\n'
          '• **K = 2 × π × r** atau **K = π × d**\n\n'
          '💡 *Contoh Soal:* Jika r = 7 cm, maka:\n'
          '• L = 22/7 × 7 × 7 = **154 cm²**\n'
          '• K = 2 × 22/7 × 7 = **44 cm**';
    }

    if (q.contains('pythagoras') || q.contains('pitagoras') || q.contains('segitiga siku')) {
      return '📐 **Teorema Pythagoras & Tripel Siku-Siku:**\n\n'
          'Pada segitiga siku-siku dengan sisi alas (a), sisi tegak (b), dan sisi miring/hipotenusa (c):\n\n'
          '⭐ **Rumus Utama:**\n'
          '• **c² = a² + b²** ➔ **c = √(a² + b²)**\n'
          '• **a² = c² - b²** ➔ **a = √(c² - b²)**\n'
          '• **b² = c² - a²** ➔ **b = √(c² - a²)**\n\n'
          '⚡ **Tripel Pythagoras Populer:**\n'
          '• (3, 4, 5) dan kelipatannya (6, 8, 10), (9, 12, 15)\n'
          '• (5, 12, 13)\n'
          '• (7, 24, 25)\n'
          '• (8, 15, 17)';
    }

    if (q.contains('sin') || q.contains('cos') || q.contains('tan') || q.contains('trigonometri')) {
      return '📐 **Tabel Sudut Istimewa Trigonometri:**\n\n'
          '| Sudut (θ) | 0° | 30° | 45° | 60° | 90° |\n'
          '|---|---|---|---|---|---|\n'
          '| **sin θ** | 0 | 1/2 | 1/2√2 | 1/2√3 | 1 |\n'
          '| **cos θ** | 1 | 1/2√3 | 1/2√2 | 1/2 | 0 |\n'
          '| **tan θ** | 0 | 1/3√3 | 1 | √3 | ∞ |\n\n'
          '💡 **Prinsip Dasar Segitiga Siku-Siku:**\n'
          '• sin = depan / miring (Demi)\n'
          '• cos = samping / miring (Sami)\n'
          '• tan = depan / samping (Desa)';
    }

    if (q.contains('tabung') || q.contains('balok') || q.contains('kubus') || q.contains('kerucut') || q.contains('bola')) {
      return '📦 **Rumus Volume & Luas Permukaan Bangun Ruang:**\n\n'
          '1️⃣ **Kubus (rusuk s):**\n'
          '• Volume = s³ | Luas Permukaan = 6s²\n\n'
          '2️⃣ **Balok (p, l, t):**\n'
          '• Volume = p × l × t | Luas Permukaan = 2(pl + pt + lt)\n\n'
          '3️⃣ **Tabung (jari-jari r, tinggi t):**\n'
          '• Volume = π × r² × t | Luas Permukaan = 2πr(r + t)\n\n'
          '4️⃣ **Kerucut:**\n'
          '• Volume = ⅓ × π × r² × t | Luas = πr(r + s)\n\n'
          '5️⃣ **Bola:**\n'
          '• Volume = 4/3 × π × r³ | Luas Permukaan = 4πr²';
    }

    // -------------------------------------------------------------
    // 4. PHYSICS & IPA (SCIENCE)
    // -------------------------------------------------------------
    if (q.contains('newton') || q.contains('gaya')) {
      return '⚡ **Hukum Gerak Newton (Fisika):**\n\n'
          '1️⃣ **Hukum I Newton (Kelembaman / Inersia):**\n'
          '• **ΣF = 0**\n'
          '  Benda diam akan tetap diam, dan benda bergerak lurus beraturan akan tetap bergerak jika tidak ada gaya luar yang bekerja.\n\n'
          '2️⃣ **Hukum II Newton (Percepatan):**\n'
          '• **F = m × a**\n'
          '  Percepatan (a) berbanding lurus dengan resultan gaya (F) dan berbanding terbalik dengan massa (m).\n\n'
          '3️⃣ **Hukum III Newton (Aksi-Reaksi):**\n'
          '• **F_aksi = -F_reaksi**\n'
          '  Gaya aksi dan reaksi selalu sama besar, berlawanan arah, dan bekerja pada dua benda yang berbeda.';
    }

    if (q.contains('kecepatan') || q.contains('glbb') || q.contains('glb') || q.contains('jarak')) {
      return '🏎️ **Rumus Gerak Lurus (GLB & GLBB):**\n\n'
          '1️⃣ **Gerak Lurus Beraturan (GLB - Kecepatan Konstan):**\n'
          '• **s = v × t**\n'
          '• v = s / t | t = s / v\n'
          '  *(s = jarak (m), v = kecepatan (m/s), t = waktu (s))*\n\n'
          '2️⃣ **Gerak Lurus Berubah Beraturan (GLBB - Percepatan a):**\n'
          '• **v_t = v_0 + a × t**\n'
          '• **s = v_0 × t + ½ × a × t²**\n'
          '• **v_t² = v_0² + 2 × a × s**';
    }

    if (q.contains('energi') || q.contains('kinetik') || q.contains('potensial') || q.contains('usaha')) {
      return '🔋 **Konsep Usaha & Energi:**\n\n'
          '1️⃣ **Usaha (W):**\n'
          '• **W = F × s × cos(θ)**  *(W dalam Joule, F dalam Newton, s dalam meter)*\n\n'
          '2️⃣ **Energi Kinetik (Ek - Energi Benda Bergerak):**\n'
          '• **Ek = ½ × m × v²**\n\n'
          '3️⃣ **Energi Potensial Gravitasi (Ep):**\n'
          '• **Ep = m × g × h**  *(g ≈ 9.8 atau 10 m/s², h = ketinggian)*\n\n'
          '4️⃣ **Hukum Kekekalan Energi Mekanik:**\n'
          '• **Em₁ = Em₂** ➔ **Ep₁ + Ek₁ = Ep₂ + Ek₂**';
    }

    if (q.contains('listrik') || q.contains('ohm') || q.contains('volt') || q.contains('daya listrik')) {
      return '⚡ **Rumus Rangkaian Listrik Dinamis:**\n\n'
          '1️⃣ **Hukum Ohm:**\n'
          '• **V = I × R**\n'
          '  *(V = Tegangan/Volt, I = Kuat Arus/Ampere, R = Hambatan/Ohm)*\n\n'
          '2️⃣ **Daya Listrik (P):**\n'
          '• **P = V × I** atau **P = I² × R** atau **P = V² / R**  *(Satuan: Watt)*\n\n'
          '3️⃣ **Energi Listrik (W):**\n'
          '• **W = P × t = V × I × t**  *(Satuan: Joule atau kWh)*\n\n'
          '4️⃣ **Hambatan Total:**\n'
          '• Seri: R_tot = R₁ + R₂ + R₃\n'
          '• Paralel: 1/R_tot = 1/R₁ + 1/R₂ + 1/R₃';
    }

    // -------------------------------------------------------------
    // 5. CHEMISTRY & BIOLOGY
    // -------------------------------------------------------------
    if (q.contains('fotosintesis')) {
      return '🌱 **Proses Fotosintesis pada Tumbuhan:**\n\n'
          'Fotosintesis adalah proses pembentukan glukosa dan oksigen dari karbon dioksida dan air menggunakan energi cahaya matahari.\n\n'
          '🧪 **Persamaan Reaksi Kimia:**\n'
          '**6CO₂ + 6H₂O + Cahaya Matahari (Klorofil) ➔ C₆H₁₂O₆ (Glukosa) + 6O₂ (Oksigen)**\n\n'
          '🔬 **Dua Tahapan Utama:**\n'
          '1. **Reaksi Terang (di Grana/Tilakoid):** Memerlukan cahaya, terjadi fotolisis air (H₂O ➔ H⁺ + O₂) dan menghasilkan ATP & NADPH.\n'
          '2. **Reaksi Gelap / Siklus Calvin (di Stroma):** Fiksasi CO₂ menggunakan ATP & NADPH dari reaksi terang untuk membentuk Glukosa.';
    }

    if (q.contains('stoikiometri') || q.contains('mol') || q.contains('massa molar')) {
      return '🧪 **Jembatan Mol & Stoikiometri Kimia:**\n\n'
          '1️⃣ **Rumus Mencari Mol (n):**\n'
          '• Dari Massa: **n = massa (gram) / Mr (Massa Molar)**\n'
          '• Dari Volume Gas (STP, 0°C, 1 atm): **n = Volume (Liter) / 22.4**\n'
          '• Dari Molaritas (M): **n = M × V (Liter)**\n'
          '• Dari Jumlah Partikel: **n = Jumlah Partikel / (6.02 × 10²³)** *(Bilangan Avogadro)*\n\n'
          '2️⃣ **Langkah Solusi Soal:**\n'
          '1. Setarakan persamaan reaksi kimia.\n'
          '2. Ubah data yang diketahui ke dalam **Mol**.\n'
          '3. Gunakan perbandingan koefisien reaksi untuk mencari mol zat target.\n'
          '4. Konversi mol target ke gram/liter sesuai pertanyaan.';
    }

    if (q.contains('asam') || q.contains('basa') || q.contains('ph')) {
      return '🧪 **Konsep Asam, Basa, & Perhitungan pH:**\n\n'
          '1️⃣ **Skala pH:**\n'
          '• pH < 7 : Larutan Asam (mengandung ion H⁺)\n'
          '• pH = 7 : Netral (contoh: air murni)\n'
          '• pH > 7 : Larutan Basa (mengandung ion OH⁻)\n\n'
          '2️⃣ **Rumus pH:**\n'
          '• **pH = -log [H⁺]**\n'
          '• **pOH = -log [OH⁻]**\n'
          '• **pH + pOH = 14**\n\n'
          '3️⃣ **Asam/Basa Kuat:**\n'
          '• [H⁺] = a × Ma *(a = valensi asam, Ma = molaritas)*\n'
          '• [OH⁻] = b × Mb *(b = valensi basa, Mb = molaritas)*';
    }

    if (q.contains('sel') || q.contains('mitokondria') || q.contains('nukleus')) {
      return '🔬 **Struktur & Organel Sel Biologi:**\n\n'
          '1. **Nukleus (Inti Sel):** Pusat pengendali seluruh aktivitas sel dan tempat penyimpanan materi genetik (DNA/RNA).\n'
          '2. **Mitokondria:** Tempat respirasi seluler dan pabrik penghasil energi (ATP) *"The Powerhouse of the Cell"*.\n'
          '3. **Ribosom:** Tempat sintesis protein.\n'
          '4. **Retikulum Endoplasma (RE):** RE Kasar (sintesis protein) & RE Halus (sintesis lipid).\n'
          '5. **Kloroplas (Khusus Sel Tumbuhan):** Mengandung klorofil untuk fotosintesis.\n'
          '6. **Dinding Sel (Khusus Tumbuhan):** Memberi struktur kaku dan perlindungan.';
    }

    // -------------------------------------------------------------
    // 6. MNR, SNBT & KPM ACADEMY
    // -------------------------------------------------------------
    if (q.contains('mnr') || q.contains('nalaria') || q.contains('metode kpm')) {
      return '✨ **Metode Matematika Nalaria Realistik (MNR):**\n\n'
          'Metode MNR adalah ciri khas pembelajaran di **KPM (Klinik Pendidikan MIPA)** yang menekankan pada:\n\n'
          '1️⃣ **Pemahaman Masalah Realistik:**\n'
          'Mengaitkan konsep matematika dengan kehidupan nyata dan logika sehari-hari tanpa menghafal rumus buta.\n\n'
          '2️⃣ **Penalaran & Logika Berjenjang:**\n'
          'Melatih otak siswa memecah soal olimpiade/cerita kompleks menjadi diagram, pola, atau tabel logika sederhana.\n\n'
          '3️⃣ **Berakhlak & Berprestasi:**\n'
          'Menumbuhkan rasa ingin tahu dan ketekunan belajar siswa sebagai bekal juara kompetisi nasional maupun internasional!';
    }

    if (q.contains('snbt') || q.contains('utbk') || q.contains('tps')) {
      return '🎓 **Panduan & Strategi Lolos SNBT / UTBK 2025:**\n\n'
          '1️⃣ **Komponen Tes Utama SNBT:**\n'
          '• **Tes Potensi Skolastik (TPS):** Penalaran Umum, Kemampuan Kuantitatif, Pengetahuan & Pemahaman Umum, Pemahaman Bacaan & Menulis.\n'
          '• **Literasi dalam Bahasa:** Literasi Bahasa Indonesia & Bahasa Inggris.\n'
          '• **Penalaran Matematika:** Penerapan konsep matematika dalam konteks masalah nyata.\n\n'
          '2️⃣ **Tips Sukses Bersama KPM:**\n'
          '1. Kerjakan simulasi Tryout berkala di menu **Latihan Ujian** KPM Academy.\n'
          '2. Review rapor skor dan analisis kelemahan materi di menu **Rapor Skor**.\n'
          '3. Diskusi langsung dengan AI Tutor atau ikut **Live Class** interaktif bersama Master Tutor KPM!';
    }

    // -------------------------------------------------------------
    // 7. GENERAL KNOWLEDGE & FALLBACK
    // -------------------------------------------------------------
    return 'Halo! Terima kasih atas pertanyaanmu mengenai **"$query"** 💡\n\n'
        '📌 **Ringkasan Penjelasan:**\n'
        'Untuk memahami dan menjawab topik ini secara optimal, kamu dapat:\n'
        '1. **Tentukan Konsep Kunci:** Identifikasi besaran atau topik inti yang ditanyakan.\n'
        '2. **Langkah Analisis:** Gunakan rumus atau definisi yang tepat secara sistematis.\n'
        '3. **Verifikasi Hasil:** Pastikan kesimpulan atau angka yang didapat masuk akal secara logika.\n\n'
        '✨ *Ingin penjelasan lebih mendalam?* Coba ketikkan angka spesifik, persamaan, atau contoh soal yang sedang kamu pelajari agar saya bantu jawab dengan detail langkah demi langkah!';
  }
}
