import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../constants/app_constants.dart';

@injectable
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  late final Dio _refreshDio;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingQueue = [];

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
    if (err.response?.statusCode != 401 ||
        err.requestOptions.path.contains(ApiEndpoints.refreshToken)) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      final completer = Completer<Response>();
      _pendingQueue.add(_PendingRequest(err.requestOptions, completer));
      try {
        handler.resolve(await completer.future);
      } catch (e) {
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;

    try {
      final newAccessToken = await _performRefresh();

      if (newAccessToken == null) {
        await _clearSessionAndRedirect();
        _rejectPendingQueue(err);
        return handler.next(err);
      }

      final retryResponse = await _retryRequest(
        err.requestOptions,
        newAccessToken,
      );

      _resolvePendingQueue(newAccessToken);

      handler.resolve(retryResponse);
    } catch (_) {
      await _clearSessionAndRedirect();
      _rejectPendingQueue(err);
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _storage.read(key: AppConstants.kRefreshToken);
    if (refreshToken == null) return null;

    try {
      final response = await _refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      final newAccessToken = data?['accessToken'] as String?;
      final newRefreshToken = data?['refreshToken'] as String?;

      if (newAccessToken == null) return null;

      await Future.wait([
        _storage.write(key: AppConstants.kAccessToken, value: newAccessToken),
        if (newRefreshToken != null)
          _storage.write(
              key: AppConstants.kRefreshToken, value: newRefreshToken),
      ]);

      return newAccessToken;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        return null;
      }
      rethrow;
    }
  }

  Future<Response> _retryRequest(
      RequestOptions original,
      String accessToken,
      ) async {
    final opts = Options(
      method: original.method,
      headers: {
        ...original.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );
    return _refreshDio.request<dynamic>(
      original.path,
      data: original.data,
      queryParameters: original.queryParameters,
      options: opts,
    );
  }

  void _resolvePendingQueue(String newAccessToken) {
    for (final pending in _pendingQueue) {
      _retryRequest(pending.options, newAccessToken)
          .then(pending.completer.complete)
          .catchError(pending.completer.completeError);
    }
    _pendingQueue.clear();
  }

  void _rejectPendingQueue(DioException err) {
    for (final pending in _pendingQueue) {
      pending.completer.completeError(err);
    }
    _pendingQueue.clear();
  }

  Future<void> _clearSessionAndRedirect() async {
    await _storage.deleteAll();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = AppNavigatorKey.navigatorKey.currentContext;
      if (context != null) {
        context.go(AppRoutes.login);
      }
    });
  }
}


class _PendingRequest {
  final RequestOptions options;
  final Completer<Response> completer;

  const _PendingRequest(this.options, this.completer);
}


abstract class AppNavigatorKey {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
}