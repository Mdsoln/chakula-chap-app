
import 'package:json_annotation/json_annotation.dart';

part 'favourite_model.g.dart';

@JsonSerializable()
class FavouriteToggleResponseModel {
  @JsonKey(name: 'menuItemId')
  final String menuItemId;

  @JsonKey(name: 'favourite')
  final bool favourite;

  const FavouriteToggleResponseModel({
    required this.menuItemId,
    required this.favourite,
  });

  factory FavouriteToggleResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FavouriteToggleResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$FavouriteToggleResponseModelToJson(this);
}

@JsonSerializable()
class FavouriteItemModel {
  final String menuItemId;

  const FavouriteItemModel({required this.menuItemId});

  factory FavouriteItemModel.fromJson(Map<String, dynamic> json) =>
      _$FavouriteItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$FavouriteItemModelToJson(this);
}