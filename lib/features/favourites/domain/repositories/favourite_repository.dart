
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class FavouriteRepository {
  Future<Either<Failure, bool>> toggleFavourite(String menuItemId);
  Future<Either<Failure, Set<String>>> getMyFavouriteIds();
}