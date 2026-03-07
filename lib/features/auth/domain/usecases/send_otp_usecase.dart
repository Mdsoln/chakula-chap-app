import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendOtpUseCase extends UseCase<bool, SendOtpParams> {
  final AuthRepository _repository;
  SendOtpUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(SendOtpParams params) {
    return _repository.sendOtp(params.phone);
  }
}

class SendOtpParams extends Equatable {
  final String phone;
  const SendOtpParams({required this.phone});

  @override
  List<Object?> get props => [phone];
}