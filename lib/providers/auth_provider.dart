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
  bool _isDisposed = false;

  AuthProvider(this._authService);

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

  UserModel? get user => _user;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;

  Future<void> initAuth() async {
    // 1. First restore cached user data for instant UI rendering
    final cachedJson = await SecureStorage.getUserData();
    if (cachedJson != null) {
      _user = UserModel.fromJson(cachedJson);
      _state = AuthState.authenticated;
      notifyListeners();
    }

    final token = await SecureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      await loadProfile();
    } else {
      if (_user == null) {
        _state = AuthState.unauthenticated;
      }
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.login(email, password);
      final tokens = res['tokens'] as Map<String, dynamic>?;
      final accessToken = tokens?['access_token']?.toString() ?? res['token']?.toString();
      final refreshToken = tokens?['refresh_token']?.toString();
      final expiresAt = (tokens?['expires_at'] as num?)?.toInt();

      if (accessToken != null && accessToken.isNotEmpty) {
        await SecureStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        );

        if (res['user'] != null && res['user'] is Map) {
          final userJson = Map<String, dynamic>.from(res['user'] as Map);
          _user = UserModel.fromJson(userJson);
          await SecureStorage.saveUserData(_user!.toJson());
        } else {
          await loadProfile();
        }

        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Token tidak ditemukan dalam respons login.';
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

  Future<bool> loginWithGoogle({
    String? email,
    String? name,
    String? googleId,
    String? photoUrl,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final userEmail = email ?? 'siswa.google@kpmacademic.com';
      final res = await _authService.loginWithGoogle(
        email: userEmail,
        name: name,
        googleId: googleId,
        photoUrl: photoUrl,
      );

      final tokens = res['tokens'] as Map<String, dynamic>?;
      final accessToken = tokens?['access_token']?.toString() ?? res['token']?.toString();
      final refreshToken = tokens?['refresh_token']?.toString();
      final expiresAt = (tokens?['expires_at'] as num?)?.toInt();

      if (accessToken != null && accessToken.isNotEmpty) {
        await SecureStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        );

        if (res['user'] != null && res['user'] is Map) {
          final userJson = Map<String, dynamic>.from(res['user'] as Map);
          _user = UserModel.fromJson(userJson);
          await SecureStorage.saveUserData(_user!.toJson());
        } else {
          await loadProfile();
        }

        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal memproses autentikasi Google.';
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
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      final tokens = res['tokens'] as Map<String, dynamic>?;
      final accessToken = tokens?['access_token']?.toString() ?? res['token']?.toString();
      final refreshToken = tokens?['refresh_token']?.toString();
      final expiresAt = (tokens?['expires_at'] as num?)?.toInt();

      if (accessToken != null && accessToken.isNotEmpty) {
        await SecureStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        );

        if (res['user'] != null && res['user'] is Map) {
          final userJson = Map<String, dynamic>.from(res['user'] as Map);
          _user = UserModel.fromJson(userJson);
          await SecureStorage.saveUserData(_user!.toJson());
        }

        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      }

      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
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
      await SecureStorage.saveUserData(_user!.toJson());
      _state = AuthState.authenticated;
    } catch (_) {
      if (_user == null) {
        _state = AuthState.unauthenticated;
      }
    }
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _state = AuthState.loading;
    notifyListeners();
    try {
      _user = await _authService.updateProfile(data);
      await SecureStorage.saveUserData(_user!.toJson());
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.authenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await _authService.forgotPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    await SecureStorage.deleteToken();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
