import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Abstract contract defined in domain — implemented in data layer.
abstract class AuthRepository {
  /// Send OTP to the given phone number
  Future<Either<Failure, bool>> sendOtp(String phone);

  /// Verify OTP and return an auth session on success
  Future<Either<Failure, AuthSessionEntity>> verifyOtp({
    required String phone,
    required String otp,
  });

  /// Get the currently authenticated user from local storage
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Refresh the access token using stored refresh token
  Future<Either<Failure, AuthSessionEntity>> refreshToken();

  /// Log the user out and clear all stored credentials
  Future<Either<Failure, bool>> logout();

  /// Check if user has a valid session
  Future<bool> get isAuthenticated;

  Future<Either<Failure, UserEntity>> completeProfile({
    required String fullName,
    String? email,
  });
}