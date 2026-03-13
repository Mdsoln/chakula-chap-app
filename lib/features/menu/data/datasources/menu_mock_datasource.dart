
import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_data.dart';
import '../models/menu_models.dart';
import 'menu_remote_datasource.dart';

class MockMenuRemoteDataSource implements MenuRemoteDataSource {
  MockMenuRemoteDataSource._();
  static final MockMenuRemoteDataSource instance = MockMenuRemoteDataSource._();

  static const _networkDelay = Duration(milliseconds: 900);

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(_networkDelay);
    return List.unmodifiable(MockData.categories);
  }

  @override
  Future<List<MenuItemModel>> getMenuItems({
    String? categoryId,
    String? search,
    required int page,
    required int pageSize,
  }) async {
    await Future.delayed(_networkDelay);

    var items = MockData.menuItems.toList();

    // Filter by category
    if (categoryId != null) {
      items = items.where((i) => i.categoryId == categoryId).toList();
    }

    // Filter by search query
    if (search != null && search.trim().isNotEmpty) {
      final query = search.trim().toLowerCase();
      items = items.where((i) {
        return i.name.toLowerCase().contains(query) ||
            i.description.toLowerCase().contains(query) ||
            i.emoji.contains(query);
      }).toList();
    }

    // Paginate
    final start = (page - 1) * pageSize;
    if (start >= items.length) return [];
    final end = (start + pageSize).clamp(0, items.length);

    return items.sublist(start, end);
  }

  @override
  Future<MenuItemModel> getMenuItemById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final item = MockData.menuItems.where((i) => i.id == id).firstOrNull;
    if (item == null) {
      throw ServerException(
        message: 'Menu item "$id" not found.',
        statusCode: 404,
      );
    }
    return item;
  }

  @override
  Future<List<MenuItemModel>> getFeaturedItems() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return MockData.menuItems
        .where((i) => i.isFeatured && i.isAvailable)
        .take(8) // Cap featured items for the banner carousel
        .toList();
  }
}