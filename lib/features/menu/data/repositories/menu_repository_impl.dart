import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_local_datasource.dart';
import '../datasources/menu_remote_datasource.dart';

@Injectable(as: MenuRepository)
class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource _remote;
  final MenuLocalDataSource _local;

  MenuRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      // Serve from cache first
      final cached = await _local.getCachedCategories();
      if (cached != null) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      final fresh = await _remote.getCategories();
      await _local.cacheCategories(fresh);
      return Right(fresh.map((m) => m.toEntity()).toList());
    } on NetworkException {
      // Network error — try cache as fallback
      try {
        final cached = await _local.getCachedCategories();
        if (cached != null) return Right(cached.map((m) => m.toEntity()).toList());
      } catch (_) {}
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems({
    String? categoryId,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final cacheKey = 'items_${categoryId ?? 'all'}_p$page';
    try {
      // Only use cache for first page with no search
      if (page == 1 && (search == null || search.isEmpty)) {
        final cached = await _local.getCachedMenuItems(cacheKey);
        if (cached != null) {
          return Right(cached.map((m) => m.toEntity()).toList());
        }
      }
      final fresh = await _remote.getMenuItems(
        categoryId: categoryId,
        search: search,
        page: page,
        pageSize: pageSize,
      );
      if (page == 1 && (search == null || search.isEmpty)) {
        await _local.cacheMenuItems(cacheKey, fresh);
      }
      return Right(fresh.map((m) => m.toEntity()).toList());
    } on NetworkException {
      final cached = await _local.getCachedMenuItems(cacheKey).catchError((_) => null);
      if (cached != null) return Right(cached.map((m) => m.toEntity()).toList());
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, MenuItemEntity>> getMenuItemById(String id) async {
    try {
      final item = await _remote.getMenuItemById(id);
      return Right(item.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getFeaturedItems() async {
    try {
      final items = await _remote.getFeaturedItems();
      return Right(items.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Stream<Either<Failure, List<MenuItemEntity>>> watchMenuItems({
    String? categoryId,
  }) async* {
    // Emit cached immediately
    final cacheKey = 'items_${categoryId ?? 'all'}_p1';
    try {
      final cached = await _local.getCachedMenuItems(cacheKey);
      if (cached != null) {
        yield Right(cached.map((m) => m.toEntity()).toList());
      }
    } catch (_) {}

    // Then emit fresh from network
    final fresh = await getMenuItems(categoryId: categoryId);
    yield fresh;
  }
}