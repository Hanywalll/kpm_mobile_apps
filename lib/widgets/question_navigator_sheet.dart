import 'package:flutter/material.dart';

class QuestionNavigatorSheet extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final Map<String, String?> answers;
  final Set<String> flaggedQuestions;
  final List<String> questionIds;
  final Function(int index) onSelectQuestion;

  const QuestionNavigatorSheet({
    super.key,
    required this.totalQuestions,
    required this.currentIndex,
    required this.answers,
    required this.flaggedQuestions,
    required this.questionIds,
    required this.onSelectQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Navigasi Soal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _legendItem(Colors.green, 'Dijawab'),
              const SizedBox(width: 16),
              _legendItem(Colors.orange, 'Ragu-ragu'),
              const SizedBox(width: 16),
              _legendItem(Colors.grey.shade300, 'Belum'),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: GridView.builder(
              itemCount: totalQuestions,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final qId = questionIds[index];
                final isAnswered = answers[qId] != null;
                final isFlagged = flaggedQuestions.contains(qId);
                final isCurrent = currentIndex == index;

                Color bgColor = Colors.grey.shade200;
                Color textColor = Colors.black87;

                if (isFlagged) {
                  bgColor = Colors.orange;
                  textColor = Colors.white;
                } else if (isAnswered) {
                  bgColor = Colors.green;
                  textColor = Colors.white;
                }

                return InkWell(
                  onTap: () {
                    onSelectQuestion(index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrent
                          ? Border.all(color: Theme.of(context).primaryColor, width: 3)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
