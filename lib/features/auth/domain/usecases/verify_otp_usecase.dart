import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyOtpUseCase extends UseCase<AuthSessionEntity, VerifyOtpParams> {
  final AuthRepository _repository;
  VerifyOtpUseCase(this._repository);

  @override
  Future<Either<Failure, AuthSessionEntity>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(phone: params.phone, otp: params.otp);
  }
}

class VerifyOtpParams extends Equatable {
  final String phone;
  final String otp;
  const VerifyOtpParams({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}