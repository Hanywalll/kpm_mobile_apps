import 'package:flutter/material.dart';
import '../core/storage/secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  UserModel? _user;
  AuthState _state = AuthState.uninitialized;
  String? _errorMessage;

  AuthProvider(this._authService);

  UserModel? get user => _user;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;

  Future<void> initAuth() async {
    final token = await SecureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      await loadProfile();
    } else {
      _state = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.login(email, password);
      final token = res['token'] ?? res['data']?['token'];
      if (token != null) {
        await SecureStorage.saveToken(token);
        await loadProfile();
        return true;
      } else {
        _errorMessage = 'Token tidak ditemukan dalam respons.';
        _state = AuthState.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.loginWithGoogle(
        email: 'google.siswa@kpm.com',
        googleId: 'google_oauth_id_987654',
      );
      final token = res['token'] ?? res['data']?['token'];
      if (token != null) {
        await SecureStorage.saveToken(token);
        await loadProfile();
        return true;
      } else {
        _state = AuthState.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String whatsapp,
    required String gradeLevel,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        whatsapp: whatsapp,
        gradeLevel: gradeLevel,
      );
      final token = res['token'] ?? res['data']?['token'];
      if (token != null) {
        await SecureStorage.saveToken(token);
        await loadProfile();
        return true;
      } else {
        _state = AuthState.unauthenticated;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadProfile() async {
    try {
      _user = await _authService.getProfile();
      _state = AuthState.authenticated;
    } catch (e) {
      _state = AuthState.unauthenticated;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
