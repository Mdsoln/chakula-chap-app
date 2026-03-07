import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/menu_item_entity.dart';

abstract class MenuRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems({
    String? categoryId,
    String? search,
    int page,
    int pageSize,
  });

  Future<Either<Failure, MenuItemEntity>> getMenuItemById(String id);

  Future<Either<Failure, List<MenuItemEntity>>> getFeaturedItems();

  /// Returns cached items instantly, then fetches fresh from API
  Stream<Either<Failure, List<MenuItemEntity>>> watchMenuItems({String? categoryId});
}