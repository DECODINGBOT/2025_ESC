import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({this.token});
  String? token;

  // CHANGED: 에뮬레이터/웹 대응
  String get base {
    if (kIsWeb) return 'http://localhost:8080';           // Flutter Web
    if (Platform.isAndroid) return 'http://10.0.2.2:8080'; // Android 에뮬레이터
    return 'http://localhost:8080';                        // iOS/Windows/macOS
  }

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$base/api/auth/register');
    final res = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200 || res.statusCode == 201) {
      return res.body.isNotEmpty ? jsonDecode(res.body) : <String, dynamic>{};
    }
    throw Exception('Register failed: ${res.statusCode} ${res.body}');
  }

  // CHANGED: 백엔드가 TokenResponse(token) 반환
Future<String> login({
  required String username,
  required String password,
}) async {
  final uri = Uri.parse('$base/api/auth/login');
  final res = await http
      .post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username.trim(), 'password': password}),
      )
      .timeout(const Duration(seconds: 10));

  if (res.statusCode == 200) {
    final map = res.body.isNotEmpty
        ? (jsonDecode(res.body) as Map<String, dynamic>)
        : <String, dynamic>{};

    final token = (map['token'] ??
        map['accessToken'] ??
        map['access_token'] ??
        map['jwt']) as String?;

    if (token == null || token.isEmpty) {
      throw Exception('Login ok but token missing. body=${res.body}');
    }
    return token;
  }

  throw Exception('Login failed: ${res.statusCode} ${res.body}');
}


  // NEW: 로그아웃(토큰 블랙리스트 등록)
  Future<void> logout() async {
    final uri = Uri.parse('$base/api/auth/logout');
    final res = await http.post(uri, headers: _jsonHeaders).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Logout failed: ${res.statusCode} ${res.body}');
    }
  }

  // NEW: 인증 필요한 GET/POST 헬퍼
  Future<Map<String, dynamic>> getJson(String path) async {
    final res = await http.get(Uri.parse('$base$path'), headers: _jsonHeaders);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isNotEmpty ? jsonDecode(res.body) : <String, dynamic>{};
    }
    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$base$path'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isNotEmpty ? jsonDecode(res.body) : <String, dynamic>{};
    }
    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }
}
