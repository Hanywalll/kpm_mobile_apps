import 'package:flutter/material.dart';
import '../models/practice_model.dart';
import '../models/question_model.dart';
import '../services/practice_service.dart';

class PracticeProvider with ChangeNotifier {
  final PracticeService _practiceService;

  PracticeSessionModel? _currentSession;
  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  final Map<String, String?> _answers = {};
  final Set<String> _flaggedQuestions = {};
  bool _isLoading = false;
  String? _errorMessage;
  PracticeSessionModel? _lastResult;
  List<PracticeSessionModel> _history = [];
  PracticeStatisticsModel? _statistics;
  bool _isDisposed = false;

  PracticeProvider(this._practiceService);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  PracticeSessionModel? get currentSession => _currentSession;
  List<QuestionModel> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, String?> get answers => _answers;
  Set<String> get flaggedQuestions => _flaggedQuestions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PracticeSessionModel? get lastResult => _lastResult;
  List<PracticeSessionModel> get history => _history;
  PracticeStatisticsModel? get statistics => _statistics;

  QuestionModel? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex < 0 || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  Future<bool> startSession(String packageId, {String cardId = 'card_1', List<QuestionModel>? customQuestions}) async {
    _isLoading = true;
    _errorMessage = null;
    _answers.clear();
    _flaggedQuestions.clear();
    _currentQuestionIndex = 0;
    notifyListeners();

    try {
      _currentSession = await _practiceService.startPractice(packageId, cardId: cardId);
      _questions = customQuestions ?? _generateDefaultQuestions();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectAnswer(String questionId, String optionKey) {
    _answers[questionId] = optionKey;
    notifyListeners();
  }

  void toggleFlag(String questionId) {
    if (_flaggedQuestions.contains(questionId)) {
      _flaggedQuestions.remove(questionId);
    } else {
      _flaggedQuestions.add(questionId);
    }
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  Future<bool> submitSession({int durationSeconds = 1800}) async {
    if (_currentSession == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Calculate score & correct answers
      int correct = 0;
      int wrong = 0;
      for (final q in _questions) {
        final userAns = _answers[q.id];
        if (userAns != null && userAns.isNotEmpty) {
          if (q.correctAnswer != null && q.correctAnswer!.toUpperCase() == userAns.toUpperCase()) {
            correct++;
          } else if (q.correctAnswer == null) {
            // Default sample rule
            if (userAns == 'A' || userAns == 'B') {
              correct++;
            } else {
              wrong++;
            }
          } else {
            wrong++;
          }
        }
      }

      final totalScore = _questions.isNotEmpty
          ? ((correct / _questions.length) * 1000).toDouble()
          : 850.0;

      _lastResult = await _practiceService.submitAnswers(
        _currentSession!.id,
        _answers,
        duration: durationSeconds,
        totalScore: totalScore,
        correctAnswer: correct,
        wrongAnswer: wrong,
      );

      await fetchHistory();
      await fetchStatistics();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _currentSession = null;
    _questions = [];
    _currentQuestionIndex = 0;
    _answers.clear();
    _flaggedQuestions.clear();
    _errorMessage = null;
    _lastResult = null;
    _history = [];
    _statistics = PracticeStatisticsModel(
      totalSessions: 0,
      avgScore: 0.0,
      totalCorrect: 0,
      totalWrong: 0,
    );
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _history = await _practiceService.getHistory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStatistics() async {
    try {
      _statistics = await _practiceService.getStatistics();
      notifyListeners();
    } catch (_) {
      _statistics = PracticeStatisticsModel(
        totalSessions: 0,
        avgScore: 0.0,
        totalCorrect: 0,
        totalWrong: 0,
      );
      notifyListeners();
    }
  }

  List<QuestionModel> _generateDefaultQuestions() {
    return List.generate(
      20,
      (index) => QuestionModel(
        id: 'q_${index + 1}',
        questionText: 'Soal Nomor ${index + 1}: Diketahui deret aritmatika dengan suku pertama a = ${index + 2} dan beda b = 3. Berapakah nilai suku ke-10 (U10)?',
        options: [
          QuestionOption(key: 'A', text: '${(index + 2) + 9 * 3}'),
          QuestionOption(key: 'B', text: '${(index + 2) + 9 * 3 + 2}'),
          QuestionOption(key: 'C', text: '${(index + 2) + 9 * 3 - 3}'),
          QuestionOption(key: 'D', text: '${(index + 2) + 8 * 3}'),
          QuestionOption(key: 'E', text: 'Tidak dapat ditentukan'),
        ],
        correctAnswer: 'A',
        explanation: 'Rumus suku ke-n deret aritmatika adalah Un = a + (n - 1)b. Untuk U10 = a + 9b.',
      ),
    );
  }
}
