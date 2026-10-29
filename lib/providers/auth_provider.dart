
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _loading = false;
  String? _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _loading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;

  Future<bool> register(String email, String password) async {
    _setLoading(true);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _translateError(e.code);
      return false;
    } catch (_) {
      _errorMessage = 'Pendaftaran gagal. Periksa koneksi internet.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _translateError(e.code);
      return false;
    } catch (_) {
      _errorMessage = 'Login gagal. Periksa koneksi internet.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String _translateError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah.';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Email atau kata sandi salah.';
      case 'network-request-failed':
        return 'Periksa koneksi internet kamu.';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}
