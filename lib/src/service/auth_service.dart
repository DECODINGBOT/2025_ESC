// CHANGED: Firebase 제거, JWT 토큰 기반으로 전면 교체
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_client.dart';
import 'token_store.dart';

class AuthService extends ChangeNotifier {
  final _store = TokenStore();
  late ApiClient _api;

  String? _token;
  String? _username; // 선택: UI 표시용

  AuthService() {
    _api = ApiClient();
    _loadToken();
  }

  bool get isLoggedIn => _token != null;
  String? get token => _token;
  String? get username => _username;

  Future<void> _loadToken() async {
    _token = await _store.load();
    if (_token != null) {
      _api.token = _token;
      notifyListeners();
    }
  }

  // CHANGED: 회원가입 → 백엔드
  Future<void> signUpBackend({
    required String username,
    required String password,
    required VoidCallback onSuccess,
    required void Function(String err) onError,
  }) async {
    try {
      if (username.isEmpty) throw '아이디를 입력해 주세요.';
      if (password.isEmpty) throw '비밀번호를 입력해 주세요.';
      await _api.register(username: username, password: password);
      onSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }

  // CHANGED: 로그인 → 백엔드(JWT 저장)
  Future<void> signInBackend({
    required String username,
    required String password,
    required VoidCallback onSuccess,
    required void Function(String err) onError,
  }) async {
    try {
      if (username.isEmpty) throw '아이디를 입력해 주세요.';
      if (password.isEmpty) throw '비밀번호를 입력해 주세요.';

      final t = await _api.login(username: username, password: password);
      _token = t;
      _username = username;
      _api.token = t;
      await _store.save(t);

      onSuccess();
      notifyListeners();
    } catch (e) {
      onError(e.toString());
    }
  }

  // NEW: 로그아웃
  Future<void> signOutBackend() async {
    try {
      if (_token != null) {
        await _api.logout(); // 서버 블랙리스트 등록
      }
    } catch (_) {
      // 서버 실패해도 클라이언트 토큰 정리는 진행
    }
    _token = null;
    _username = null;
    _api.token = null;
    await _store.clear();
    notifyListeners();
  }
}
