import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../repositories/auth_repository.dart';

@injectable
class LogoutUseCase extends NoParamsUseCase<bool> {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call() => _repository.logout();
}