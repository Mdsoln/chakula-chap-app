import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import 'auth_interceptor.dart';
import 'connectivity_checker.dart';

@singleton
class NetworkClient {
  late final Dio _dio;

  NetworkClient(
      AuthInterceptor authInterceptor,
      ConnectivityChecker connectivity,
      ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Version': AppConstants.appVersion,
          'X-Platform': 'flutter',
        },
      ),
    );

    _dio.interceptors.addAll([
      authInterceptor,
      ConnectivityInterceptor(connectivity),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    ]);
  }

  Dio get dio => _dio;
}

/// Checks internet connectivity before every request
class ConnectivityInterceptor extends Interceptor {
  final ConnectivityChecker _connectivity;

  ConnectivityInterceptor(this._connectivity);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final isConnected = await _connectivity.isConnected;
    if (!isConnected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const NetworkException(),
        ),
      );
    }
    handler.next(options);
  }
}

/// Maps DioException → typed app exceptions
class DioErrorMapper {
  static Exception map(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final message = _extractMessage(data) ?? 'An error occurred.';

        if (statusCode == 401) return UnauthorizedException(message: message);

        if (statusCode == 422) {
          return ValidationException(
            message: message,
            fieldErrors: _extractFieldErrors(data),
          );
        }

        return ServerException(message: message, statusCode: statusCode, data: data);
      default:
        return ServerException(message: e.message ?? 'Unknown error.');
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }

  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors.map((k, v) => MapEntry(k, List<String>.from(v as List)));
      }
    }
    return null;
  }
}