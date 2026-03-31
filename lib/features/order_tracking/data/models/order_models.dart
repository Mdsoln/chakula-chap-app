import 'package:json_annotation/json_annotation.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../domain/entities/order_entity.dart';

part 'order_models.g.dart';

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

@JsonSerializable()
class OrderItemModel {
  @JsonKey(name: 'menu_item_id')
  final String menuItemId;
  @JsonKey(name: 'menu_item_name')
  final String menuItemName;
  @JsonKey(name: 'menu_item_emoji')
  final String menuItemEmoji;
  @JsonKey(name: 'unit_price')
  final double unitPrice;
  final int quantity;
  @JsonKey(name: 'line_total')
  final double lineTotal;

  const OrderItemModel({
    required this.menuItemId,
    required this.menuItemName,
    required this.menuItemEmoji,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  CartItemEntity toEntity() {
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
    return CartItemEntity(
      cartItemId: menuItemId,
      menuItem: menuItem,
      quantity: quantity,
    );
  }
}

@JsonSerializable()
class OrderModel {
  final String id;
  @JsonKey(name: 'order_number')
  final String orderNumber;
  final List<OrderItemModel> items;
  @JsonKey(name: 'delivery_address')
  final DeliveryAddressModel deliveryAddress;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  final String status;
  final double subtotal;
  @JsonKey(name: 'delivery_fee')
  final double deliveryFee;
  @JsonKey(defaultValue: 0.0)
  final double discount;
  final double total;
  @JsonKey(name: 'payment_reference')
  final String? paymentReference;
  @JsonKey(name: 'control_number')
  final String? controlNumber;
  final String? notes;
  @JsonKey(name: 'placed_at')
  final DateTime placedAt;
  @JsonKey(name: 'estimated_delivery_at')
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

  static PaymentMethod _parsePaymentMethod(String raw) {
    return PaymentMethod.values.firstWhere(
          (e) => e.name == raw,
      orElse: () => PaymentMethod.cashOnDelivery,
    );
  }

  static OrderStatus _parseOrderStatus(String raw) {
    return OrderStatus.values.firstWhere(
          (e) => e.name == raw,
      orElse: () => OrderStatus.pending,
    );
  }
}