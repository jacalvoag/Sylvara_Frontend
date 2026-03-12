import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sylvara_frontend/core/api/api_client.dart';
import 'package:sylvara_frontend/core/api/api_config.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final _apiClient = ApiClient();

  late final GoogleSignIn? _googleSignIn = kIsWeb
      ? null
      : GoogleSignIn(
          serverClientId:
              '530170205990-ed6rjnd9mgjamin33ksukunj0f9ppngb.apps.googleusercontent.com',
          scopes: ['https://www.googleapis.com/auth/bigquery'],
        );

  Future<bool> signInWithGoogleMobile() async {
    if (kIsWeb) return false;

    try {
      print('=== GOOGLE SIGN IN START ===');
      await _googleSignIn!.signOut();
      print('signOut OK');

      final account = await _googleSignIn!.signIn();
      print('account: $account');
      if (account == null) {
        print('ERROR: account es null');
        return false;
      }

      print('email: ${account.email}');
      print('serverAuthCode: ${account.serverAuthCode}');

      final serverAuthCode = account.serverAuthCode;
      if (serverAuthCode == null) {
        print('ERROR: serverAuthCode es null - verifica serverClientId');
        return false;
      }

      print('Enviando serverAuthCode al backend...');
      final response = await _apiClient.post(
        '${ApiConfig.baseUrl}/auth/google/mobile',
        body: {'serverAuthCode': serverAuthCode},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e, stack) {
      print('ERROR: $e');
      print('STACK: $stack');
      return false;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn?.signOut();
    }
  }
}