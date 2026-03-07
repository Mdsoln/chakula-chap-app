import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../constants/app_constants.dart';

@injectable
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  // Separate Dio instance for token refresh to avoid infinite loops
  late final Dio _refreshDio;

  AuthInterceptor(this._storage) {
    _refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  }

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _storage.read(key: AppConstants.kAccessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    // Auto-refresh token on 401
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await _storage.read(key: AppConstants.kRefreshToken);
        if (refreshToken == null) return handler.next(err);

        final response = await _refreshDio.post(
          ApiEndpoints.refreshToken,
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken = response.data['access_token'] as String;
        await _storage.write(key: AppConstants.kAccessToken, value: newAccessToken);

        // Retry original request with new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _refreshDio.fetch(opts);
        return handler.resolve(retryResponse);
      } catch (_) {
        // Refresh failed — clear tokens, redirect to login
        await _storage.deleteAll();
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}