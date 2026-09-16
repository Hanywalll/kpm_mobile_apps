import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../widgets/question_card.dart';
import '../../widgets/question_navigator_sheet.dart';
import '../../widgets/timer_widget.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final List<QuestionModel> _dummyQuestions = List.generate(
    20,
    (index) => QuestionModel(
      id: 'q_${index + 1}',
      questionText: 'Berapakah hasil dari 2^${index + 1} + ${index * 5}?',
      options: [
        QuestionOption(key: 'A', text: '${(1 << (index + 1)) + index * 5}'),
        QuestionOption(key: 'B', text: '${(1 << (index + 1)) + index * 5 + 2}'),
        QuestionOption(key: 'C', text: '${(1 << (index + 1)) + index * 5 + 4}'),
        QuestionOption(key: 'D', text: '${(1 << (index + 1)) + index * 5 - 1}'),
        QuestionOption(key: 'E', text: 'Tidak ada jawaban yang benar'),
      ],
    ),
  );

  int _currentIndex = 0;
  final Map<String, String?> _answers = {};
  final Set<String> _flagged = {};

  void _showNavigatorSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => QuestionNavigatorSheet(
        totalQuestions: _dummyQuestions.length,
        currentIndex: _currentIndex,
        answers: _answers,
        flaggedQuestions: _flagged,
        questionIds: _dummyQuestions.map((e) => e.id).toList(),
        onSelectQuestion: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  void _submitExam() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kumpulkan Jawaban?'),
        content: Text(
          'Anda telah menjawab ${_answers.length} dari ${_dummyQuestions.length} soal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/result');
            },
            child: const Text('Kumpulkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _dummyQuestions[_currentIndex];
    final qId = currentQ.id;
    final isFlagged = _flagged.contains(qId);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _submitExam();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tryout CBT'),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TimerWidget(
                initialSeconds: 3600,
                onTimeUp: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Waktu habis! Menyerahkan jawaban...')),
                  );
                  Navigator.pushReplacementNamed(context, '/result');
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: QuestionCard(
                questionNumber: _currentIndex + 1,
                question: currentQ,
                selectedAnswer: _answers[qId],
                onOptionSelected: (key) {
                  setState(() {
                    _answers[qId] = key;
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFlagged ? Colors.orange : Colors.grey.shade200,
                      foregroundColor: isFlagged ? Colors.white : Colors.black87,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isFlagged) {
                          _flagged.remove(qId);
                        } else {
                          _flagged.add(qId);
                        }
                      });
                    },
                    icon: Icon(isFlagged ? Icons.bookmark : Icons.bookmark_border, size: 18),
                    label: Text(isFlagged ? 'Ragu-ragu' : 'Ragu'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.grid_view_rounded, color: Colors.blue, size: 28),
                    onPressed: _showNavigatorSheet,
                  ),
                  if (_currentIndex < _dummyQuestions.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex++;
                        });
                      },
                      child: const Text('Lanjut'),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: _submitExam,
                      child: const Text('Submit'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
