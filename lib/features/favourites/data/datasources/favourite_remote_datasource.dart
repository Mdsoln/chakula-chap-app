
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/network_client.dart';
import '../models/favourite_model.dart';

abstract class FavouriteRemoteDataSource {
  Future<bool> toggleFavourite(String menuItemId);
  Future<Set<String>> getMyFavouriteIds();
}

@Injectable(as: FavouriteRemoteDataSource)
class FavouriteRemoteDataSourceImpl implements FavouriteRemoteDataSource {
  final NetworkClient _client;
  FavouriteRemoteDataSourceImpl(this._client);

  @override
  Future<bool> toggleFavourite(String menuItemId) async {
    try {
      final res = await _client.dio.post(
        ApiEndpoints.toggleFavourite(menuItemId),
      );
      final data = res.data['data'] as Map<String, dynamic>;
      final model = FavouriteToggleResponseModel.fromJson(data);
      return model.favourite;
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<Set<String>> getMyFavouriteIds() async {
    try {
      final res = await _client.dio.get(ApiEndpoints.myFavourites);
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => FavouriteItemModel.fromJson(e as Map<String, dynamic>))
          .map((m) => m.menuItemId)
          .toSet();
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }
}