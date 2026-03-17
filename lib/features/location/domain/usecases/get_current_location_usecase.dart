
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/user_location_entity.dart';
import '../repositories/location_repository.dart';

@injectable
class GetCurrentLocationUseCase extends NoParamsUseCase<UserLocationEntity> {
  final LocationRepository _repo;
  GetCurrentLocationUseCase(this._repo);

  @override
  Future<Either<Failure, UserLocationEntity>> call() =>
      _repo.getCurrentLocation();
}