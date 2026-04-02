import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../repositories/favourite_repository.dart';

@injectable
class ToggleFavouriteUseCase extends UseCase<bool, String> {
  final FavouriteRepository _repo;
  ToggleFavouriteUseCase(this._repo);

  @override
  Future<Either<Failure, bool>> call(String menuItemId) =>
      _repo.toggleFavourite(menuItemId);
}