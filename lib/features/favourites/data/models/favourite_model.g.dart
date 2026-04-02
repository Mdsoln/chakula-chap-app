// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavouriteToggleResponseModel _$FavouriteToggleResponseModelFromJson(
    Map<String, dynamic> json) =>
    FavouriteToggleResponseModel(
      menuItemId: json['menuItemId'] as String,
      favourite: json['favourite'] as bool,
    );

Map<String, dynamic> _$FavouriteToggleResponseModelToJson(
    FavouriteToggleResponseModel instance) =>
    <String, dynamic>{
      'menuItemId': instance.menuItemId,
      'favourite': instance.favourite,
    };

FavouriteItemModel _$FavouriteItemModelFromJson(Map<String, dynamic> json) =>
    FavouriteItemModel(
      menuItemId: json['menuItemId'] as String,
    );

Map<String, dynamic> _$FavouriteItemModelToJson(FavouriteItemModel instance) =>
    <String, dynamic>{
      'menuItemId': instance.menuItemId,
    };