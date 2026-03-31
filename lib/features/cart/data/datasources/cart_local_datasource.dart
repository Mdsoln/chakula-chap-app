import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../domain/entities/cart_entity.dart';

abstract class CartLocalDataSource {
  Future<CartEntity> getCart();
  Future<CartEntity> addItem({
    required MenuItemEntity menuItem,
    required int quantity,
    MenuItemVariantEntity? variant,
    List<MenuItemExtraEntity> extras,
    String? note,
  });
  Future<CartEntity> removeItem(String cartItemId);
  Future<CartEntity> updateQuantity(String cartItemId, int quantity);
  Future<CartEntity> clearCart();
  Stream<CartEntity> watchCart();
}

@Injectable(as: CartLocalDataSource)
class CartLocalDataSourceImpl implements CartLocalDataSource {
  final Box<dynamic> _box;
  final _cartController = StreamController<CartEntity>.broadcast();
  static const _key = 'cart_data';
  static const _uuid = Uuid();

  CartLocalDataSourceImpl(@Named('cartBox') this._box);

  @override
  Future<CartEntity> getCart() async {
    try {
      return _readCart();
    } catch (e) {
      throw CacheException(message: 'Failed to load cart: $e');
    }
  }

  @override
  Future<CartEntity> addItem({
    required MenuItemEntity menuItem,
    required int quantity,
    MenuItemVariantEntity? variant,
    List<MenuItemExtraEntity> extras = const [],
    String? note,
  }) async {
    final cart = _readCart();

    // Check if identical item already in cart → increase qty instead
    final existingIndex = cart.items.indexWhere((i) =>
    i.menuItem.id == menuItem.id &&
        i.selectedVariant?.id == variant?.id &&
        _extrasMatch(i.selectedExtras, extras));

    List<CartItemEntity> updatedItems;
    if (existingIndex >= 0) {
      updatedItems = [...cart.items];
      updatedItems[existingIndex] = updatedItems[existingIndex]
          .copyWith(quantity: updatedItems[existingIndex].quantity + quantity);
    } else {
      updatedItems = [
        ...cart.items,
        CartItemEntity(
          cartItemId: _uuid.v4(),
          menuItem: menuItem,
          quantity: quantity,
          selectedVariant: variant,
          selectedExtras: extras,
          note: note,
        ),
      ];
    }

    final updated = _recalcDelivery(cart.copyWith(items: updatedItems));
    await _saveAndNotify(updated);
    return updated;
  }

  @override
  Future<CartEntity> removeItem(String cartItemId) async {
    final cart = _readCart();
    final updated = _recalcDelivery(cart.copyWith(
      items: cart.items.where((i) => i.cartItemId != cartItemId).toList(),
    ));
    await _saveAndNotify(updated);
    return updated;
  }

  @override
  Future<CartEntity> updateQuantity(String cartItemId, int quantity) async {
    final cart = _readCart();
    List<CartItemEntity> updatedItems;
    if (quantity <= 0) {
      updatedItems = cart.items.where((i) => i.cartItemId != cartItemId).toList();
    } else {
      updatedItems = cart.items.map((i) {
        return i.cartItemId == cartItemId ? i.copyWith(quantity: quantity) : i;
      }).toList();
    }
    final updated = _recalcDelivery(cart.copyWith(items: updatedItems));
    await _saveAndNotify(updated);
    return updated;
  }

  @override
  Future<CartEntity> clearCart() async {
    await _saveAndNotify(CartEntity.empty);
    return CartEntity.empty;
  }

  @override
  Stream<CartEntity> watchCart() {
    // Emit current cart immediately on subscribe
    Future.microtask(() {
      try {
        _cartController.add(_readCart());
      } catch (_) {
        _cartController.add(CartEntity.empty);
      }
    });
    return _cartController.stream;
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  CartEntity _readCart() {
    final raw = _box.get(_key) as String?;
    if (raw == null) return CartEntity.empty;
    return _cartFromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _saveAndNotify(CartEntity cart) async {
    await _box.put(_key, jsonEncode(_cartToJson(cart)));
    _cartController.add(cart);
  }

  CartEntity _recalcDelivery(CartEntity cart) {
    final fee = cart.qualifiesForFreeDelivery ? 0.0 : 3000.0;
    return cart.copyWith(deliveryFee: fee);
  }

  bool _extrasMatch(List<MenuItemExtraEntity> a, List<MenuItemExtraEntity> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((e) => e.id).toSet();
    final bIds = b.map((e) => e.id).toSet();
    return aIds.containsAll(bIds);
  }

  // Minimal JSON serialization (no code gen needed for local storage)
  Map<String, dynamic> _cartToJson(CartEntity cart) => {
    'items': cart.items.map(_itemToJson).toList(),
    'delivery_fee': cart.deliveryFee,
    'promo_code': cart.promoCode,
    'discount': cart.discount,
  };

  Map<String, dynamic> _itemToJson(CartItemEntity item) => {
    'cart_item_id': item.cartItemId,
    'menu_item_id': item.menuItem.id,
    'menu_item_name': item.menuItem.name,
    'menu_item_price': item.menuItem.price,
    'menu_item_emoji': item.menuItem.emoji,
    'menu_item_image_url': item.menuItem.imageUrl,
    'quantity': item.quantity,
    'variant_id': item.selectedVariant?.id,
    'variant_label': item.selectedVariant?.label,
    'variant_price_modifier': item.selectedVariant?.priceModifier,
    'extras': item.selectedExtras.map((e) => {
      'id': e.id,
      'name': e.name,
      'price': e.price,
    }).toList(),
    'note': item.note,
  };

  CartEntity _cartFromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson.map((e) => _itemFromJson(e as Map<String, dynamic>)).toList();
    return CartEntity(
      items: items,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 3000,
      promoCode: json['promo_code'] as String?,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
    );
  }

  CartItemEntity _itemFromJson(Map<String, dynamic> json) {
    MenuItemVariantEntity? variant;
    if (json['variant_id'] != null) {
      variant = MenuItemVariantEntity(
        id: json['variant_id'] as String,
        label: json['variant_label'] as String? ?? '',
        priceModifier: (json['variant_price_modifier'] as num?)?.toDouble() ?? 0,
      );
    }
    final extrasJson = json['extras'] as List<dynamic>? ?? [];
    final extras = extrasJson.map((e) {
      final m = e as Map<String, dynamic>;
      return MenuItemExtraEntity(
        id: m['id'] as String,
        name: m['name'] as String,
        price: (m['price'] as num).toDouble(),
      );
    }).toList();

    // Rebuild a minimal MenuItemEntity from persisted data
    final menuItem = MenuItemEntity(
      id: json['menu_item_id'] as String,
      name: json['menu_item_name'] as String,
      description: '',
      price: (json['menu_item_price'] as num).toDouble(),
      categoryId: '',
      emoji: json['menu_item_emoji'] as String? ?? '🍽️',
      imageUrl: json['menu_item_image_url'] as String?,
      rating: 0,
      reviewCount: 0,
      prepTimeMinutes: 0,
      calories: 0,
      available: true,
      featured: false,
      variants: const [],
      extras: const [],
    );

    return CartItemEntity(
      cartItemId: json['cart_item_id'] as String,
      menuItem: menuItem,
      quantity: json['quantity'] as int,
      selectedVariant: variant,
      selectedExtras: extras,
      note: json['note'] as String?,
    );
  }
}