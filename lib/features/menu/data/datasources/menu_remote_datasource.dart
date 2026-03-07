import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/network_client.dart';
import '../models/menu_models.dart';

abstract class MenuRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<MenuItemModel>> getMenuItems({
    String? categoryId,
    String? search,
    required int page,
    required int pageSize,
  });
  Future<MenuItemModel> getMenuItemById(String id);
  Future<List<MenuItemModel>> getFeaturedItems();
}

@Injectable(as: MenuRemoteDataSource)
class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final NetworkClient _client;
  MenuRemoteDataSourceImpl(this._client);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await _client.dio.get(ApiEndpoints.categories);
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<MenuItemModel>> getMenuItems({
    String? categoryId,
    String? search,
    required int page,
    required int pageSize,
  }) async {
    try {
      final res = await _client.dio.get(
        ApiEndpoints.menuItems,
        queryParameters: {
          if (categoryId != null) 'category_id': categoryId,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'per_page': pageSize,
        },
      );
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<MenuItemModel> getMenuItemById(String id) async {
    try {
      final res = await _client.dio.get(ApiEndpoints.menuItemById(id));
      return MenuItemModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<MenuItemModel>> getFeaturedItems() async {
    try {
      final res = await _client.dio.get(
        ApiEndpoints.menuItems,
        queryParameters: {'featured': true, 'per_page': 6},
      );
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }
}