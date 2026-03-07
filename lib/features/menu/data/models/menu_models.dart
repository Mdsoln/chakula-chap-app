import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/menu_item_entity.dart';

part 'menu_models.g.dart';

@JsonSerializable()
class CategoryModel {
  final String id;
  final String name;
  final String emoji;
  @JsonKey(name: 'item_count', defaultValue: 0)
  final int itemCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.itemCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  CategoryEntity toEntity() => CategoryEntity(
    id: id,
    name: name,
    emoji: emoji,
    itemCount: itemCount,
  );
}

@JsonSerializable()
class MenuItemVariantModel {
  final String id;
  final String label;
  @JsonKey(name: 'price_modifier', defaultValue: 0.0)
  final double priceModifier;

  const MenuItemVariantModel({
    required this.id,
    required this.label,
    required this.priceModifier,
  });

  factory MenuItemVariantModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemVariantModelFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemVariantModelToJson(this);

  MenuItemVariantEntity toEntity() => MenuItemVariantEntity(
    id: id,
    label: label,
    priceModifier: priceModifier,
  );
}

@JsonSerializable()
class MenuItemExtraModel {
  final String id;
  final String name;
  final double price;

  const MenuItemExtraModel({
    required this.id,
    required this.name,
    required this.price,
  });

  factory MenuItemExtraModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemExtraModelFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemExtraModelToJson(this);

  MenuItemExtraEntity toEntity() =>
      MenuItemExtraEntity(id: id, name: name, price: price);
}

@JsonSerializable()
class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  @JsonKey(name: 'category_id')
  final String categoryId;
  final String emoji;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(defaultValue: 0.0)
  final double rating;
  @JsonKey(name: 'review_count', defaultValue: 0)
  final int reviewCount;
  @JsonKey(name: 'prep_time_minutes', defaultValue: 15)
  final int prepTimeMinutes;
  @JsonKey(defaultValue: 0)
  final int calories;
  @JsonKey(name: 'is_available', defaultValue: true)
  final bool isAvailable;
  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;
  final String? tag;
  @JsonKey(defaultValue: [])
  final List<MenuItemVariantModel> variants;
  @JsonKey(defaultValue: [])
  final List<MenuItemExtraModel> extras;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.emoji,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.prepTimeMinutes,
    required this.calories,
    required this.isAvailable,
    required this.isFeatured,
    this.tag,
    required this.variants,
    required this.extras,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemModelToJson(this);

  MenuItemEntity toEntity() => MenuItemEntity(
    id: id,
    name: name,
    description: description,
    price: price,
    categoryId: categoryId,
    emoji: emoji,
    imageUrl: imageUrl,
    rating: rating,
    reviewCount: reviewCount,
    prepTimeMinutes: prepTimeMinutes,
    calories: calories,
    isAvailable: isAvailable,
    isFeatured: isFeatured,
    tag: tag,
    variants: variants.map((v) => v.toEntity()).toList(),
    extras: extras.map((e) => e.toEntity()).toList(),
  );
}
