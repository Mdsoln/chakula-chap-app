import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/network_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<OtpSentModel> sendOtp(String phone);
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String otp,
    String? deviceInfo,
  });
  Future<AuthSessionModel> refreshToken(String refreshToken);
  Future<bool> logout();
  Future<UserModel> completeProfile({required String phone, required String fullName, String? email});
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<OtpSentModel> sendOtp(String phone) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.sendOtp,
        data: {'phone': phone},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return OtpSentModel.fromJson(data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String otp,
    String? deviceInfo,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone': phone,
          'otp': otp,
          if (deviceInfo != null) 'deviceInfo': deviceInfo,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthSessionModel.fromJson(data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<AuthSessionModel> refreshToken(String refreshToken) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthSessionModel.fromJson(data);
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

  @override
  Future<UserModel> completeProfile({
    required String phone,
    required String fullName,
    String? email,
  }) async {
    try {
      final res = await _client.dio.post(
        ApiEndpoints.profile,
        data: {
          'phone': phone,
          'name': fullName,
          if (email != null) 'email': email,
        },
      );
      return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

}