import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sylvara_frontend/core/api/api_client.dart';
import 'package:sylvara_frontend/core/api/api_config.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final _apiClient = ApiClient();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '530170205990-ed6rjnd9mgjamin33ksukunj0f9ppngb.apps.googleusercontent.com',
    serverClientId: '530170205990-ed6rjnd9mgjamin33ksukunj0f9ppngb.apps.googleusercontent.com',
    scopes: ['https://www.googleapis.com/auth/bigquery'],
  );

  bool get isWeb => kIsWeb;

  Future<bool> signInWithGoogleMobile() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false;

      final auth = await account.authentication;
      final accessToken = auth.accessToken;

      if (accessToken == null) return false;

      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}/auth/google/mobile',
        body: {
          'access_token': accessToken,
          'email': account.email,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error en Google Sign-In móvil: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }
}