import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final int itemCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.emoji,
    required this.itemCount,
  });

  @override
  List<Object?> get props => [id, name, emoji, itemCount];
}

class MenuItemEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String emoji;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final int prepTimeMinutes;
  final int calories;
  final bool available;
  final bool featured;
  final String? tag;
  final List<MenuItemVariantEntity> variants;
  final List<MenuItemExtraEntity> extras;

  const MenuItemEntity({
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
    required this.available,
    required this.featured,
    this.tag,
    required this.variants,
    required this.extras,
  });

  @override
  List<Object?> get props => [id, name, price, categoryId, available];
}

class MenuItemVariantEntity extends Equatable {
  final String id;
  final String label; // "Regular", "Large", "XL"
  final double priceModifier; // 0 = no change, +2000 = add 2000

  const MenuItemVariantEntity({
    required this.id,
    required this.label,
    required this.priceModifier,
  });

  @override
  List<Object?> get props => [id, label, priceModifier];
}

class MenuItemExtraEntity extends Equatable {
  final String id;
  final String name; // "Extra Cheese"
  final double price;

  const MenuItemExtraEntity({
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, price];
}