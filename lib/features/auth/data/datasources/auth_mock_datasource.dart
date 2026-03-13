import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

@dev
@Injectable(as: AuthRemoteDataSource)
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  static const _mockOtp = '123456';
  static const _fakeDelay = Duration(milliseconds: 1500);

  @override
  Future<bool> sendOtp(String phone) async {
    await Future.delayed(_fakeDelay);
    // Simulate a rejected number to test error state (optional)
    if (phone.endsWith('0000')) {
      throw const ServerException(
        message: 'This number is blocked for testing.',
        statusCode: 602,
      );
    }
    return true;
  }

  @override
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    await Future.delayed(_fakeDelay);

    if (otp != _mockOtp) {
      throw const UnauthorizedException(message: 'Invalid OTP. Use 123456.');
    }

    return AuthSessionModel(
      accessToken: 'mock-access-token-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock-refresh-token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      user: UserModel(
        id: 'mock-user-001',
        phone: phone,
        name: 'Mdsoln',
        email: 'mdsoln@chakulachap.co.tz',
        avatarUrl: null,
        isVerified: true,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<AuthSessionModel> refreshToken(String refreshToken) async {
    await Future.delayed(_fakeDelay);
    return AuthSessionModel(
      accessToken: 'mock-access-token-refreshed',
      refreshToken: 'mock-refresh-token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      user: UserModel(
        id: 'mock-user-001',
        phone: '+255700000001',
        name: 'Mdsoln',
        email: 'mdsoln@chakulachap.co.tz',
        avatarUrl: null,
        isVerified: true,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<bool> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}