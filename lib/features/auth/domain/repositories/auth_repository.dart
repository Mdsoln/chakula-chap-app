import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Abstract contract defined in domain — implemented in data layer.
abstract class AuthRepository {
  Future<Either<Failure, OtpSentEntity>> sendOtp(String phone);

  Future<Either<Failure, AuthSessionEntity>> verifyOtp({
    required String phone,
    required String otp,
  });

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, AuthSessionEntity>> refreshToken();
  Future<Either<Failure, bool>> logout();
  Future<bool> get isAuthenticated;

  Future<Either<Failure, UserEntity>> completeProfile({
    required String phone,
    required String fullName,
    String? email,
  });
}