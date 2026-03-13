import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/menu_item_entity.dart';
import '../repositories/menu_repository.dart';

@injectable
class GetCategoriesUseCase extends NoParamsUseCase<List<CategoryEntity>> {
  final MenuRepository _repo;
  GetCategoriesUseCase(this._repo);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call() =>
      _repo.getCategories();
}

@injectable
class GetMenuItemsUseCase extends UseCase<List<MenuItemEntity>, GetMenuItemsParams> {
  final MenuRepository _repo;
  GetMenuItemsUseCase(this._repo);

  @override
  Future<Either<Failure, List<MenuItemEntity>>> call(GetMenuItemsParams params) =>
      _repo.getMenuItems(
        categoryId: params.categoryId,
        search: params.search,
        page: params.page,
        pageSize: params.pageSize,
      );
}

class GetMenuItemsParams extends Equatable {
  final String? categoryId;
  final String? search;
  final int page;
  final int pageSize;

  const GetMenuItemsParams({
    this.categoryId,
    this.search,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [categoryId, search, page, pageSize];
}

@injectable
class GetMenuItemByIdUseCase extends UseCase<MenuItemEntity, String> {
  final MenuRepository _repo;
  GetMenuItemByIdUseCase(this._repo);

  @override
  Future<Either<Failure, MenuItemEntity>> call(String id) =>
      _repo.getMenuItemById(id);
}

@injectable
class GetFeaturedItemsUseCase extends NoParamsUseCase<List<MenuItemEntity>> {
  final MenuRepository _repo;
  GetFeaturedItemsUseCase(this._repo);

  @override
  Future<Either<Failure, List<MenuItemEntity>>> call() =>
      _repo.getFeaturedItems();
}