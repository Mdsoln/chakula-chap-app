import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/network_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<bool> sendOtp(String phone);
  Future<AuthSessionModel> verifyOtp({required String phone, required String otp});
  Future<AuthSessionModel> refreshToken(String refreshToken);
  Future<bool> logout();
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<bool> sendOtp(String phone) async {
    try {
      await _client.dio.post(
        ApiEndpoints.sendOtp,
        data: {'phone': phone},
      );
      return true;
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.verifyOtp,
        data: {'phone': phone, 'otp': otp},
      );
      return AuthSessionModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<AuthSessionModel> refreshToken(String refreshToken) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      return AuthSessionModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _client.dio.post(ApiEndpoints.logout);
      return true;
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }
}