import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/menu_models.dart';

abstract class MenuLocalDataSource {
  Future<void> cacheMenuItems(String key, List<MenuItemModel> items);
  Future<List<MenuItemModel>?> getCachedMenuItems(String key);
  Future<void> cacheCategories(List<CategoryModel> categories);
  Future<List<CategoryModel>?> getCachedCategories();
  Future<void> clearMenuCache();
}

@Injectable(as: MenuLocalDataSource)
class MenuLocalDataSourceImpl implements MenuLocalDataSource {
  final Box<dynamic> _box;

  // Injected by name from DI — the 'menuCacheBox' instance
  MenuLocalDataSourceImpl(@Named('menuCacheBox') this._box);

  static const _categoriesKey = 'categories';
  static const _timestampSuffix = '_ts';

  @override
  Future<void> cacheMenuItems(String key, List<MenuItemModel> items) async {
    try {
      await _box.put(key, jsonEncode(items.map((e) => e.toJson()).toList()));
      await _box.put(
        '$key$_timestampSuffix',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache menu items: $e');
    }
  }

  @override
  Future<List<MenuItemModel>?> getCachedMenuItems(String key) async {
    try {
      final ts = _box.get('$key$_timestampSuffix') as int?;
      if (ts == null) return null;

      // Invalidate cache if expired
      final cacheAge = DateTime.now().millisecondsSinceEpoch - ts;
      if (cacheAge > AppConstants.menuCacheDuration.inMilliseconds) {
        await _box.delete(key);
        return null;
      }

      final raw = _box.get(key) as String?;
      if (raw == null) return null;

      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to read menu cache: $e');
    }
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    try {
      await _box.put(
        _categoriesKey,
        jsonEncode(categories.map((e) => e.toJson()).toList()),
      );
      await _box.put(
        '$_categoriesKey$_timestampSuffix',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache categories: $e');
    }
  }

  @override
  Future<List<CategoryModel>?> getCachedCategories() async {
    try {
      final raw = _box.get(_categoriesKey) as String?;
      if (raw == null) return null;
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to read categories cache: $e');
    }
  }

  @override
  Future<void> clearMenuCache() => _box.clear().then((_) => null);
}