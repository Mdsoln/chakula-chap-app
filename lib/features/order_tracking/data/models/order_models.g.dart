
part of 'order_models.dart';

RiderModel _$RiderModelFromJson(Map<String, dynamic> json) => RiderModel(
  id: json['id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  totalDeliveries: json['total_deliveries'] as int? ?? 0,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$RiderModelToJson(RiderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'rating': instance.rating,
      'total_deliveries': instance.totalDeliveries,
      'avatar_url': instance.avatarUrl,
    };

DeliveryAddressModel _$DeliveryAddressModelFromJson(
    Map<String, dynamic> json) =>
    DeliveryAddressModel(
      label: json['label'] as String,
      street: json['street'] as String,
      area: json['area'] as String,
      city: json['city'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      instructions: json['instructions'] as String?,
    );

Map<String, dynamic> _$DeliveryAddressModelToJson(
    DeliveryAddressModel instance) =>
    <String, dynamic>{
      'label': instance.label,
      'street': instance.street,
      'area': instance.area,
      'city': instance.city,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'instructions': instance.instructions,
    };

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      menuItemId: json['menu_item_id'] as String,
      menuItemName: json['menu_item_name'] as String,
      menuItemEmoji: json['menu_item_emoji'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      lineTotal: (json['line_total'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'menu_item_id': instance.menuItemId,
      'menu_item_name': instance.menuItemName,
      'menu_item_emoji': instance.menuItemEmoji,
      'unit_price': instance.unitPrice,
      'quantity': instance.quantity,
      'line_total': instance.lineTotal,
    };

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String,
  orderNumber: json['order_number'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  deliveryAddress: DeliveryAddressModel.fromJson(
      json['delivery_address'] as Map<String, dynamic>),
  paymentMethod: json['payment_method'] as String,
  status: json['status'] as String,
  subtotal: (json['subtotal'] as num).toDouble(),
  deliveryFee: (json['delivery_fee'] as num).toDouble(),
  discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
  total: (json['total'] as num).toDouble(),
  paymentReference: json['payment_reference'] as String?,
  controlNumber: json['control_number'] as String?,
  notes: json['notes'] as String?,
  placedAt: DateTime.parse(json['placed_at'] as String),
  estimatedDeliveryAt: json['estimated_delivery_at'] == null
      ? null
      : DateTime.parse(json['estimated_delivery_at'] as String),
  rider: json['rider'] == null
      ? null
      : RiderModel.fromJson(json['rider'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'delivery_address': instance.deliveryAddress.toJson(),
      'payment_method': instance.paymentMethod,
      'status': instance.status,
      'subtotal': instance.subtotal,
      'delivery_fee': instance.deliveryFee,
      'discount': instance.discount,
      'total': instance.total,
      'payment_reference': instance.paymentReference,
      'control_number': instance.controlNumber,
      'notes': instance.notes,
      'placed_at': instance.placedAt.toIso8601String(),
      'estimated_delivery_at': instance.estimatedDeliveryAt?.toIso8601String(),
      'rider': instance.rider?.toJson(),
    };