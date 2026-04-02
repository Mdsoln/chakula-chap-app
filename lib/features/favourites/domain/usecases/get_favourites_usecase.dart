import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../repositories/favourite_repository.dart';

@injectable
class GetFavouritesUseCase extends NoParamsUseCase<Set<String>> {
  final FavouriteRepository _repo;
  GetFavouritesUseCase(this._repo);

  @override
  Future<Either<Failure, Set<String>>> call() =>
      _repo.getMyFavouriteIds();
}