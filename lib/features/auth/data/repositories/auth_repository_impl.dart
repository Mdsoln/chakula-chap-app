import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implements the domain contract.
/// Orchestrates remote API calls + local caching.
/// Maps exceptions → failures — domain layer never sees raw exceptions.
@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, OtpSentEntity>> sendOtp(String phone) async {
    try {
      final model = await _remote.sendOtp(phone);
      return Right(OtpSentEntity(
        phone: model.phone,
        maskedPhone: model.maskedPhone,
        expiresInSeconds: model.expiresInSeconds,
      ));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, fieldErrors: e.fieldErrors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AuthSessionEntity>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final session = await _remote.verifyOtp(phone: phone, otp: otp);
      await _local.cacheSession(session);
      return Right(session.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException catch (e) {
      return Left(OtpFailure(message: e.message));
    } on ServerException catch (e) {
      if (e.statusCode == null) {
        return Left(OtpFailure(message: e.message));
      }
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _local.getCachedUser();
      return Right(user?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AuthSessionEntity>> refreshToken() async {
    try {
      final refreshToken = await _local.getRefreshToken();
      if (refreshToken == null) {
        return const Left(AuthFailure(message: 'No refresh token found.'));
      }
      final session = await _remote.refreshToken(refreshToken);
      await _local.cacheSession(session);
      return Right(session.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      await _local.clearSession();
      return const Left(AuthFailure(message: 'Session expired. Please log in again.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _remote.logout().catchError((_) => false);
      await _local.clearSession();
      return const Right(true);
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<bool> get isAuthenticated => _local.isLoggedIn;

  @override
  Future<Either<Failure, UserEntity>> completeProfile({
    required String phone,
    required String fullName,
    String? email,
  }) async {
    try {
      final userModel = await _remote.completeProfile(
        phone: phone,
        fullName: fullName,
        email: email,
      );
      await _local.cacheUpdatedUser(userModel);
      return Right(userModel.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, fieldErrors: e.fieldErrors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}