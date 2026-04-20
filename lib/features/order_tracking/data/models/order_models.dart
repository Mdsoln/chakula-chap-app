import 'package:json_annotation/json_annotation.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../domain/entities/order_entity.dart';

part 'order_models.g.dart';

// ── OrderItemExtra ─────────────────────────────────────────────────────────────

@JsonSerializable()
class OrderItemExtraModel {
  @JsonKey(name: 'extraId')
  final String extraId;
  @JsonKey(name: 'extraName')
  final String extraName;
  final double price;

  const OrderItemExtraModel({
    required this.extraId,
    required this.extraName,
    required this.price,
  });

  factory OrderItemExtraModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemExtraModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemExtraModelToJson(this);

  MenuItemExtraEntity toEntity() => MenuItemExtraEntity(
    id: extraId,
    name: extraName,
    price: price,
  );
}

// ── Rider ──────────────────────────────────────────────────────────────────────

@JsonSerializable()
class RiderModel {
  final String id;
  final String name;
  final String phone;
  @JsonKey(defaultValue: 0.0)
  final double rating;
  @JsonKey(name: 'total_deliveries', defaultValue: 0)
  final int totalDeliveries;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  const RiderModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.totalDeliveries,
    this.avatarUrl,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) =>
      _$RiderModelFromJson(json);
  Map<String, dynamic> toJson() => _$RiderModelToJson(this);

  RiderEntity toEntity() => RiderEntity(
    id: id,
    name: name,
    phone: phone,
    rating: rating,
    totalDeliveries: totalDeliveries,
    avatarUrl: avatarUrl,
  );
}

// ── Delivery Address ───────────────────────────────────────────────────────────

@JsonSerializable()
class DeliveryAddressModel {
  final String label;
  final String street;
  final String area;
  final String city;
  final double? latitude;
  final double? longitude;
  final String? instructions;

  const DeliveryAddressModel({
    required this.label,
    required this.street,
    required this.area,
    required this.city,
    this.latitude,
    this.longitude,
    this.instructions,
  });

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryAddressModelFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryAddressModelToJson(this);

  DeliveryAddressEntity toEntity() => DeliveryAddressEntity(
    label: label,
    street: street,
    area: area,
    city: city,
    latitude: latitude,
    longitude: longitude,
    instructions: instructions,
  );
}

// ── Order Item ─────────────────────────────────────────────────────────────────

@JsonSerializable()
class OrderItemModel {
  @JsonKey(name: 'menuItemId')
  final String menuItemId;
  @JsonKey(name: 'menuItemName')
  final String menuItemName;
  @JsonKey(name: 'menuItemEmoji')
  final String menuItemEmoji;
  @JsonKey(name: 'unitPrice')
  final double unitPrice;
  final int quantity;
  @JsonKey(name: 'lineTotal')
  final double lineTotal;
  @JsonKey(name: 'variantLabel')
  final String? variantLabel;
  @JsonKey(name: 'note')
  final String? note;
  @JsonKey(defaultValue: [])
  final List<OrderItemExtraModel> extras;

  const OrderItemModel({
    required this.menuItemId,
    required this.menuItemName,
    required this.menuItemEmoji,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.variantLabel,
    this.note,
    this.extras = const [],
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  CartItemEntity toEntity() {
    // Rebuild a minimal MenuItemEntity from the snapshotted order data.
    final menuItem = MenuItemEntity(
      id: menuItemId,
      name: menuItemName,
      description: '',
      price: unitPrice,
      categoryId: '',
      emoji: menuItemEmoji,
      rating: 0,
      reviewCount: 0,
      prepTimeMinutes: 0,
      calories: 0,
      available: true,
      featured: false,
      variants: const [],
      extras: const [],
    );

    // Rebuild a variant stub when a label was snapshotted.
    final variant = variantLabel != null
        ? MenuItemVariantEntity(
      id: '',
      label: variantLabel!,
      priceModifier: 0,
    )
        : null;

    return CartItemEntity(
      cartItemId: menuItemId,
      menuItem: menuItem,
      quantity: quantity,
      selectedVariant: variant,
      selectedExtras: extras.map((e) => e.toEntity()).toList(),
      note: note,
    );
  }
}

// ── Order ──────────────────────────────────────────────────────────────────────

@JsonSerializable()
class OrderModel {
  final String id;
  @JsonKey(name: 'orderNumber')
  final String orderNumber;
  final List<OrderItemModel> items;
  @JsonKey(name: 'deliveryAddress')
  final DeliveryAddressModel deliveryAddress;
  @JsonKey(name: 'paymentMethod')
  final String paymentMethod;
  final String status;
  final double subtotal;
  @JsonKey(name: 'deliveryFee')
  final double deliveryFee;
  @JsonKey(defaultValue: 0.0)
  final double discount;
  final double total;
  @JsonKey(name: 'paymentReference')
  final String? paymentReference;
  @JsonKey(name: 'controlNumber')
  final String? controlNumber;
  final String? notes;
  @JsonKey(name: 'placedAt')
  final DateTime placedAt;
  @JsonKey(name: 'estimatedDeliveryAt')
  final DateTime? estimatedDeliveryAt;
  final RiderModel? rider;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    this.paymentReference,
    this.controlNumber,
    this.notes,
    required this.placedAt,
    this.estimatedDeliveryAt,
    this.rider,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderEntity toEntity() => OrderEntity(
    id: id,
    orderNumber: orderNumber,
    items: items.map((i) => i.toEntity()).toList(),
    deliveryAddress: deliveryAddress.toEntity(),
    paymentMethod: _parsePaymentMethod(paymentMethod),
    status: _parseOrderStatus(status),
    subtotal: subtotal,
    deliveryFee: deliveryFee,
    discount: discount,
    total: total,
    paymentReference: paymentReference,
    controlNumber: controlNumber,
    notes: notes,
    placedAt: placedAt,
    estimatedDeliveryAt: estimatedDeliveryAt,
    rider: rider?.toEntity(),
  );

  /// Maps the backend's SCREAMING_SNAKE_CASE values to the Flutter enum.
  /// Falls back to [PaymentMethod.cashOnDelivery] for any unknown value
  /// so a single unrecognised method never breaks the whole list parse.
  static PaymentMethod _parsePaymentMethod(String raw) {
    const map = {
      'MPESA': PaymentMethod.mpesa,
      'MIX_BY_YAS': PaymentMethod.mixxYas,
      'AIRTEL_MONEY': PaymentMethod.airtelMoney,
      'AZAM_PESA': PaymentMethod.azamPesa,
      'SELCOM': PaymentMethod.selcom,
      'CASH_ON_DELIVERY': PaymentMethod.cashOnDelivery,
    };
    return map[raw.toUpperCase()] ?? PaymentMethod.cashOnDelivery;
  }

  /// Maps the backend's UPPER_CASE values to the Flutter enum.
  /// Falls back to [OrderStatus.pending] for any unknown value.
  static OrderStatus _parseOrderStatus(String raw) {
    const map = {
      'PENDING': OrderStatus.pending,
      'CONFIRMED': OrderStatus.confirmed,
      'PREPARING': OrderStatus.preparing,
      'READY': OrderStatus.ready,
      'PICKED_UP': OrderStatus.pickedUp,
      'DELIVERED': OrderStatus.delivered,
      'CANCELLED': OrderStatus.cancelled,
      'FAILED': OrderStatus.failed,
    };
    return map[raw.toUpperCase()] ?? OrderStatus.pending;
  }
}