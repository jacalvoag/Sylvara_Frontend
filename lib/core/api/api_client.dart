import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sylvara_frontend/core/api/token_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _tokenStorage = TokenStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String url) async {
    final headers = await _authHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> post(String url, {Map<String, dynamic>? body}) async {
    final headers = await _authHeaders();
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> postNoAuth(String url, {required Map<String, dynamic> body}) async {
    return await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }
}