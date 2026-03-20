import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../constants/app_constants.dart';

@injectable
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  late final Dio _refreshDio;

  AuthInterceptor(this._storage) {
    _refreshDio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
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
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken =
        await _storage.read(key: AppConstants.kRefreshToken);
        if (refreshToken == null) {
          await _storage.deleteAll();
          return handler.next(err);
        }

        final response = await _refreshDio.post(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        final data =
        response.data['data'] as Map<String, dynamic>?;
        if (data == null) {
          await _storage.deleteAll();
          return handler.next(err);
        }

        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String;

        // Persist rotated tokens
        await Future.wait([
          _storage.write(
              key: AppConstants.kAccessToken, value: newAccessToken),
          _storage.write(
              key: AppConstants.kRefreshToken, value: newRefreshToken),
        ]);

        // Retry original request with new access token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _refreshDio.fetch(opts);
        return handler.resolve(retryResponse);
      } catch (_) {
        await _storage.deleteAll();
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}