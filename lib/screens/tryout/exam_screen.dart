import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/question_model.dart';
import '../../providers/practice_provider.dart';
import '../../widgets/question_card.dart';
import '../../widgets/question_navigator_sheet.dart';
import '../../widgets/timer_widget.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _currentIndex = 0;
  final Map<String, String?> _answers = {};
  final Set<String> _flagged = {};
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final practice = Provider.of<PracticeProvider>(context, listen: false);
      if (practice.questions.isEmpty) {
        practice.startSession('pkg_utbk_1');
      }
    });
  }

  void _showNavigatorSheet(List<QuestionModel> questions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => QuestionNavigatorSheet(
        totalQuestions: questions.length,
        currentIndex: _currentIndex,
        answers: _answers,
        flaggedQuestions: _flagged,
        questionIds: questions.map((e) => e.id).toList(),
        onSelectQuestion: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  void _submitExam() {
    final practice = Provider.of<PracticeProvider>(context, listen: false);
    final questions = practice.questions;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kumpulkan Jawaban?'),
        content: Text(
          'Anda telah menjawab ${_answers.length} dari ${questions.length} butir soal CBT.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Copy answers to provider
              for (final e in _answers.entries) {
                if (e.value != null) {
                  practice.selectAnswer(e.key, e.value!);
                }
              }
              await practice.submitSession(durationSeconds: _elapsedSeconds);
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/result');
              }
            },
            child: const Text('Kumpulkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final practice = Provider.of<PracticeProvider>(context);
    final questions = practice.questions.isNotEmpty
        ? practice.questions
        : List.generate(
            20,
            (index) => QuestionModel(
              id: 'q_${index + 1}',
              questionText: 'Soal Nomor ${index + 1}: Diketahui f(x) = 2x + 3 dan g(x) = x^2. Tentukan nilai (f o g)(2).',
              options: [
                QuestionOption(key: 'A', text: '11'),
                QuestionOption(key: 'B', text: '14'),
                QuestionOption(key: 'C', text: '19'),
                QuestionOption(key: 'D', text: '25'),
                QuestionOption(key: 'E', text: '36'),
              ],
              correctAnswer: 'A',
            ),
          );

    if (_currentIndex >= questions.length) {
      _currentIndex = 0;
    }

    final currentQ = questions[_currentIndex];
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
          title: const Text('Tryout CBT — IRT'),
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
                  _submitExam();
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
                    _elapsedSeconds += 10;
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
                    color: Colors.black.withValues(alpha: 0.05),
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
                    onPressed: () => _showNavigatorSheet(questions),
                  ),
                  if (_currentIndex < questions.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex++;
                        });
                      },
                      child: const Text('Lanjut ➔'),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B894)),
                      onPressed: _submitExam,
                      child: const Text('Selesai ✨'),
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
