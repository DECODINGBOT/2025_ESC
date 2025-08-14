import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 메인 isolate(로그인 성공 후 등)에서만 사용하세요.
/// 백그라운드 isolate(Firebase Messaging 백그라운드 핸들러 등)에서는 호출 금지.
class TokenStore {
  static const _kAccessToken = 'access_token';

  // 기본 옵션: 플랫폼별 안전한 기본 저장소 사용
  // (Android는 가능한 경우 EncryptedSharedPreferences, 아니면 SharedPreferences)
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  const TokenStore();

  Future<void> save(String token) {
    return _storage.write(key: _kAccessToken, value: token);
  }

  Future<String?> load() {
    return _storage.read(key: _kAccessToken);
  }

  Future<bool> hasToken() async {
    final v = await load();
    return v != null && v.isNotEmpty;
  }

  Future<void> clear() {
    return _storage.delete(key: _kAccessToken);
  
  }
}
