import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Called on app start when a session already exists (e.g. after splash).
  Future<void> init() async {
    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (_) {
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authService.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String namaLengkap,
    required String nim,
    required String nomorKamar,
    required String nomorHp,
    String nik = '',
    String asalUniversitas = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        namaLengkap: namaLengkap,
        nim: nim,
        nomorKamar: nomorKamar,
        nomorHp: nomorHp,
        nik: nik,
        asalUniversitas: asalUniversitas,
      );
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return;
    try {
      await _authService.updateProfile(_currentUser!.id, data);
      _currentUser = await _authService.getUserProfile(_currentUser!.id);
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('Invalid login credentials') ||
        error.contains('invalid_credentials')) {
      return 'Email atau kata sandi salah';
    } else if (error.contains('already registered') ||
        error.contains('already exists')) {
      return 'Email sudah terdaftar';
    } else if (error.contains('network') || error.contains('SocketException')) {
      return 'Tidak ada koneksi internet';
    } else if (error.contains('Email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek kotak masuk email Anda.';
    }
    return 'Terjadi kesalahan, coba lagi';
  }
}
