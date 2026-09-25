import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/practice_provider.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final practice = Provider.of<PracticeProvider>(context);
    final questions = practice.questions;
    final answers = practice.answers;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Pembahasan Soal CBT'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: questions.isNotEmpty ? questions.length : 5,
        itemBuilder: (context, index) {
          final q = questions.isNotEmpty ? questions[index] : null;
          final userAns = q != null ? answers[q.id] : (index == 2 ? 'C' : 'A');
          final isCorrect = q != null
              ? (q.correctAnswer == null || userAns == q.correctAnswer)
              : (index != 2);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nomor ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCorrect ? const Color(0xFF00B894).withValues(alpha: 0.12) : const Color(0xFFFF416C).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isCorrect ? '✅ Jawaban Benar' : '❌ Jawaban Salah',
                        style: TextStyle(
                          color: isCorrect ? const Color(0xFF00B894) : const Color(0xFFFF416C),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  q?.questionText ?? 'Soal Nomor ${index + 1}: Diketahui deret aritmatika dengan suku pertama a = 5 dan b = 3. Tentukan U10.',
                  style: const TextStyle(fontSize: 14, height: 1.4, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Jawaban Anda: ', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    Text(
                      userAns ?? 'Tidak dijawab',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isCorrect ? const Color(0xFF00B894) : const Color(0xFFFF416C),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Kunci: ', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    Text(
                      q?.correctAnswer ?? 'A',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Text('Pembahasan Lengkap:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryPurple)),
                const SizedBox(height: 4),
                Text(
                  q?.explanation ?? 'Gunakan rumus dasar Un = a + (n - 1)b. Substitusi a = 5, n = 10, b = 3 didapatkan U10 = 5 + 9(3) = 32.',
                  style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
