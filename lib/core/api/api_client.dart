import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({String? baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // If 401 Unauthorized and not already on auth path, attempt refresh token
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/')) {
            final refreshToken = await SecureStorage.getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: dio.options.baseUrl,
                    headers: {'Content-Type': 'application/json'},
                  ),
                );
                final res = await refreshDio.post(
                  ApiEndpoints.refreshToken,
                  data: {'refresh_token': refreshToken},
                );

                if (res.statusCode == 200 && res.data['data'] != null) {
                  final newTokens = res.data['data']['tokens'];
                  final newAccessToken = newTokens?['access_token'];
                  final newRefreshToken = newTokens?['refresh_token'];
                  final expiresAt = newTokens?['expires_at'];

                  if (newAccessToken != null) {
                    await SecureStorage.saveTokens(
                      accessToken: newAccessToken,
                      refreshToken: newRefreshToken,
                      expiresAt: expiresAt,
                    );

                    // Retry original request with new access token
                    error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                    final retryRes = await dio.fetch(error.requestOptions);
                    return handler.resolve(retryRes);
                  }
                }
              } catch (_) {
                // If refresh token also fails, clear tokens
                await SecureStorage.deleteToken();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
