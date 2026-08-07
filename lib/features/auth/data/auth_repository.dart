import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;

  AuthResult.success() : success = true, errorMessage = null;
  AuthResult.failure(this.errorMessage) : success = false;
}

class AuthRepository {
  final Dio _dio = ApiClient().dio;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.tokenEndpoint,
        data: {'email': email, 'password': password},
      );

      await TokenStorage.saveTokens(
        accessToken: response.data['access'],
        refreshToken: response.data['refresh'],
      );

      return AuthResult.success();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return AuthResult.failure('Invalid email or password');
      }
      return AuthResult.failure('Network error. Please try again.');
    } catch (e) {
      return AuthResult.failure('Something went wrong.');
    }
  }
}