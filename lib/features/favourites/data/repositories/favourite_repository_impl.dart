
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/favourite_repository.dart';
import '../datasources/favourite_remote_datasource.dart';

@Injectable(as: FavouriteRepository)
class FavouriteRepositoryImpl implements FavouriteRepository {
  final FavouriteRemoteDataSource _remote;
  FavouriteRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, bool>> toggleFavourite(String menuItemId) async {
    try {
      final isFavourited = await _remote.toggleFavourite(menuItemId);
      return Right(isFavourited);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getMyFavouriteIds() async {
    try {
      final ids = await _remote.getMyFavouriteIds();
      return Right(ids);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Right({});
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}