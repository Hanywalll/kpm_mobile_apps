import 'package:flutter/material.dart';
import '../models/question_model.dart';
import 'option_tile.dart';

class QuestionCard extends StatelessWidget {
  final int questionNumber;
  final QuestionModel question;
  final String? selectedAnswer;
  final Function(String optionKey) onOptionSelected;

  const QuestionCard({
    super.key,
    required this.questionNumber,
    required this.question,
    required this.selectedAnswer,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soal No. $questionNumber',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question.questionText,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          if (question.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                question.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ...question.options.map((option) {
            final isSelected = selectedAnswer == option.key;
            return OptionTile(
              optionKey: option.key,
              text: option.text,
              isSelected: isSelected,
              onTap: () => onOptionSelected(option.key),
            );
          }),
        ],
      ),
    );
  }
}
