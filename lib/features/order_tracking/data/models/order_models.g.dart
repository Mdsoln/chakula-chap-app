// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_models.dart';

// ── OrderItemExtraModel ────────────────────────────────────────────────────────

OrderItemExtraModel _$OrderItemExtraModelFromJson(Map<String, dynamic> json) =>
    OrderItemExtraModel(
      extraId: json['extraId'] as String,
      extraName: json['extraName'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderItemExtraModelToJson(
    OrderItemExtraModel instance) =>
    <String, dynamic>{
      'extraId': instance.extraId,
      'extraName': instance.extraName,
      'price': instance.price,
    };

// ── RiderModel ────────────────────────────────────────────────────────────────

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

// ── DeliveryAddressModel ──────────────────────────────────────────────────────

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

// ── OrderItemModel ────────────────────────────────────────────────────────────

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      menuItemId: json['menuItemId'] as String,
      menuItemName: json['menuItemName'] as String,
      menuItemEmoji: json['menuItemEmoji'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
      lineTotal: (json['lineTotal'] as num).toDouble(),
      variantLabel: json['variantLabel'] as String?,
      note: json['note'] as String?,
      extras: (json['extras'] as List<dynamic>?)
          ?.map((e) =>
          OrderItemExtraModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'menuItemId': instance.menuItemId,
      'menuItemName': instance.menuItemName,
      'menuItemEmoji': instance.menuItemEmoji,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'lineTotal': instance.lineTotal,
      'variantLabel': instance.variantLabel,
      'note': instance.note,
      'extras': instance.extras.map((e) => e.toJson()).toList(),
    };

// ── OrderModel ────────────────────────────────────────────────────────────────

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String,
  orderNumber: json['orderNumber'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  deliveryAddress: DeliveryAddressModel.fromJson(
      json['deliveryAddress'] as Map<String, dynamic>),
  paymentMethod: json['paymentMethod'] as String,
  status: json['status'] as String,
  subtotal: (json['subtotal'] as num).toDouble(),
  deliveryFee: (json['deliveryFee'] as num).toDouble(),
  discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
  total: (json['total'] as num).toDouble(),
  paymentReference: json['paymentReference'] as String?,
  controlNumber: json['controlNumber'] as String?,
  notes: json['notes'] as String?,
  placedAt: DateTime.parse(json['placedAt'] as String),
  estimatedDeliveryAt: json['estimatedDeliveryAt'] == null
      ? null
      : DateTime.parse(json['estimatedDeliveryAt'] as String),
  rider: json['rider'] == null
      ? null
      : RiderModel.fromJson(json['rider'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'deliveryAddress': instance.deliveryAddress.toJson(),
      'paymentMethod': instance.paymentMethod,
      'status': instance.status,
      'subtotal': instance.subtotal,
      'deliveryFee': instance.deliveryFee,
      'discount': instance.discount,
      'total': instance.total,
      'paymentReference': instance.paymentReference,
      'controlNumber': instance.controlNumber,
      'notes': instance.notes,
      'placedAt': instance.placedAt.toIso8601String(),
      'estimatedDeliveryAt': instance.estimatedDeliveryAt?.toIso8601String(),
      'rider': instance.rider?.toJson(),
    };