
part of 'menu_models.dart';

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      itemCount: json['itemCount'] as int? ?? 0,
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'emoji': instance.emoji,
      'itemCount': instance.itemCount,
    };

MenuItemVariantModel _$MenuItemVariantModelFromJson(
    Map<String, dynamic> json) =>
    MenuItemVariantModel(
      id: json['id'] as String,
      label: json['label'] as String,
      priceModifier: (json['priceModifier'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$MenuItemVariantModelToJson(
    MenuItemVariantModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'priceModifier': instance.priceModifier,
    };

MenuItemExtraModel _$MenuItemExtraModelFromJson(Map<String, dynamic> json) =>
    MenuItemExtraModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$MenuItemExtraModelToJson(MenuItemExtraModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
    };

MenuItemModel _$MenuItemModelFromJson(Map<String, dynamic> json) =>
    MenuItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      emoji: json['emoji'] as String,
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 15,
      calories: json['calories'] as int? ?? 0,
      available: json['available'] as bool? ?? true,
      featured: json['featured'] as bool? ?? false,
      tag: json['tag'] as String?,
      variants: (json['variants'] as List<dynamic>?)
          ?.map((e) =>
          MenuItemVariantModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      extras: (json['extras'] as List<dynamic>?)
          ?.map((e) =>
          MenuItemExtraModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );

Map<String, dynamic> _$MenuItemModelToJson(MenuItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'categoryId': instance.categoryId,
      'emoji': instance.emoji,
      'imageUrl': instance.imageUrl,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'prepTimeMinutes': instance.prepTimeMinutes,
      'calories': instance.calories,
      'available': instance.available,
      'featured': instance.featured,
      'tag': instance.tag,
      'variants': instance.variants.map((e) => e.toJson()).toList(),
      'extras': instance.extras.map((e) => e.toJson()).toList(),
    };