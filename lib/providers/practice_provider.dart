import 'package:flutter/material.dart';
import '../models/practice_model.dart';
import '../models/question_model.dart';
import '../services/practice_service.dart';

class PracticeProvider with ChangeNotifier {
  final PracticeService _practiceService;

  PracticeSessionModel? _currentSession;
  int _currentQuestionIndex = 0;
  final Map<String, String?> _answers = {};
  final Set<String> _flaggedQuestions = {};
  bool _isLoading = false;
  String? _errorMessage;
  PracticeResultModel? _lastResult;
  List<PracticeResultModel> _history = [];

  PracticeProvider(this._practiceService);

  PracticeSessionModel? get currentSession => _currentSession;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, String?> get answers => _answers;
  Set<String> get flaggedQuestions => _flaggedQuestions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PracticeResultModel? get lastResult => _lastResult;
  List<PracticeResultModel> get history => _history;

  QuestionModel? get currentQuestion {
    if (_currentSession == null || _currentSession!.questions.isEmpty) return null;
    return _currentSession!.questions[_currentQuestionIndex];
  }

  Future<bool> startSession(String practiceId) async {
    _isLoading = true;
    _errorMessage = null;
    _answers.clear();
    _flaggedQuestions.clear();
    _currentQuestionIndex = 0;
    notifyListeners();

    try {
      _currentSession = await _practiceService.startPractice(practiceId);
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
    if (_currentSession != null && index >= 0 && index < _currentSession!.questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  Future<bool> submitSession() async {
    if (_currentSession == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastResult = await _practiceService.submitAnswers(_currentSession!.id, _answers);
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

  Future<void> fetchHistory() async {
    _isLoading = true;
    _errorMessage = null;
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
}
