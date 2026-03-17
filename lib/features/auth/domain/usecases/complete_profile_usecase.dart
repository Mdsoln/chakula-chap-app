
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class CompleteProfileUseCase extends UseCase<UserEntity, CompleteProfileParams> {
  final AuthRepository _repo;
  CompleteProfileUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(CompleteProfileParams params) =>
      _repo.completeProfile(
        fullName: params.fullName,
        email: params.email,
      );
}

class CompleteProfileParams extends Equatable {
  final String fullName;
  final String? email; // optional

  const CompleteProfileParams({required this.fullName, this.email});

  @override
  List<Object?> get props => [fullName, email];
}