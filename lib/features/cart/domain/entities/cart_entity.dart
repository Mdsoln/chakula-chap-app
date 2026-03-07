import 'package:equatable/equatable.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';

class CartItemEntity extends Equatable {
  final String cartItemId; // unique per cart line
  final MenuItemEntity menuItem;
  final int quantity;
  final MenuItemVariantEntity? selectedVariant;
  final List<MenuItemExtraEntity> selectedExtras;
  final String? note;

  const CartItemEntity({
    required this.cartItemId,
    required this.menuItem,
    required this.quantity,
    this.selectedVariant,
    this.selectedExtras = const [],
    this.note,
  });

  double get lineTotal {
    final variantMod = selectedVariant?.priceModifier ?? 0;
    final extrasTotal = selectedExtras.fold<double>(0, (sum, e) => sum + e.price);
    return (menuItem.price + variantMod + extrasTotal) * quantity;
  }

  double get unitPrice {
    final variantMod = selectedVariant?.priceModifier ?? 0;
    final extrasTotal = selectedExtras.fold<double>(0, (sum, e) => sum + e.price);
    return menuItem.price + variantMod + extrasTotal;
  }

  CartItemEntity copyWith({int? quantity, String? note}) => CartItemEntity(
    cartItemId: cartItemId,
    menuItem: menuItem,
    quantity: quantity ?? this.quantity,
    selectedVariant: selectedVariant,
    selectedExtras: selectedExtras,
    note: note ?? this.note,
  );

  @override
  List<Object?> get props => [cartItemId, menuItem, quantity, selectedVariant, selectedExtras];
}

class CartEntity extends Equatable {
  final List<CartItemEntity> items;
  final double deliveryFee;
  final String? promoCode;
  final double discount;

  const CartEntity({
    required this.items,
    required this.deliveryFee,
    this.promoCode,
    this.discount = 0,
  });

  double get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);
  double get total => subtotal + deliveryFee - discount;
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  bool get isEmpty => items.isEmpty;
  bool get qualifiesForFreeDelivery => subtotal >= 20000;

  CartEntity copyWith({
    List<CartItemEntity>? items,
    double? deliveryFee,
    String? promoCode,
    double? discount,
  }) =>
      CartEntity(
        items: items ?? this.items,
        deliveryFee: deliveryFee ?? this.deliveryFee,
        promoCode: promoCode ?? this.promoCode,
        discount: discount ?? this.discount,
      );

  static const CartEntity empty = CartEntity(items: [], deliveryFee: 3000);

  @override
  List<Object?> get props => [items, deliveryFee, promoCode, discount];
}