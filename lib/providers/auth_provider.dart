import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _bootstrap();
  }

  void _bootstrap() {
    _service.authState.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else {
        final profile = await _service.fetchProfile(firebaseUser.uid);
        _user = profile;
        _status = AuthStatus.authenticated;
        notifyListeners();
      }
    });
  }

  Future<bool> login(String email, String password) async {
    _setLoading();
    try {
      _user = await _service.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanize(e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading();
    try {
      _user = await _service.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      await _service.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanize(e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    if (_user == null) return;
    final updated = _user!.copyWith(name: name, phone: phone);
    await _service.updateProfile(updated);
    _user = updated;
    notifyListeners();
  }

  void _setLoading() {
    _error = null;
    _status = AuthStatus.loading;
    notifyListeners();
  }

  String _humanize(Object e) {
    final msg = e.toString();
    if (msg.contains('user-not-found')) return 'Email belum terdaftar.';
    if (msg.contains('wrong-password')) return 'Password salah.';
    if (msg.contains('email-already-in-use')) return 'Email sudah digunakan.';
    if (msg.contains('weak-password')) return 'Password terlalu lemah.';
    if (msg.contains('invalid-email')) return 'Format email tidak valid.';
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
