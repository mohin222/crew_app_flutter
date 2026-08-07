import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Don't attach token to login/refresh calls
          final isAuthCall = options.path.contains(ApiConfig.tokenEndpoint) ||
              options.path.contains(ApiConfig.refreshEndpoint);

          if (!isAuthCall) {
            final token = await TokenStorage.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          // If access token expired, try refreshing once
          if (error.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final newToken = await TokenStorage.getAccessToken();
              final retryRequest = error.requestOptions;
              retryRequest.headers['Authorization'] = 'Bearer $newToken';

              try {
                final response = await dio.fetch(retryRequest);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)).post(
        ApiConfig.refreshEndpoint,
        data: {'refresh': refreshToken},
      );

      final newAccess = response.data['access'];
      final newRefresh = response.data['refresh'];

      await TokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      return true;
    } catch (e) {
      await TokenStorage.clearTokens();
      return false;
    }
  }
}