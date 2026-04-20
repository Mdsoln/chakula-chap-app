import 'package:equatable/equatable.dart';
import '../../../cart/domain/entities/cart_entity.dart';

// ── Payment Method ────────────────────────────────────────────────────────────

enum PaymentMethod {
  mpesa,
  mixxYas,
  airtelMoney,
  azamPesa,
  selcom,
  cashOnDelivery,
}

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.mpesa: return 'M-Pesa';
      case PaymentMethod.mixxYas: return 'Mix by Yas';
      case PaymentMethod.airtelMoney: return 'Airtel Money';
      case PaymentMethod.azamPesa: return 'AzamPesa';
      case PaymentMethod.selcom: return 'Selcom';
      case PaymentMethod.cashOnDelivery: return 'Cash on Delivery';
    }
  }

  String get emoji {
    switch (this) {
      case PaymentMethod.mpesa: return '📱';
      case PaymentMethod.mixxYas: return '💚';
      case PaymentMethod.airtelMoney: return '❤️';
      case PaymentMethod.azamPesa: return '🔵';
      case PaymentMethod.selcom: return '🧾';
      case PaymentMethod.cashOnDelivery: return '💵';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.mpesa: return 'Vodacom · STK Push';
      case PaymentMethod.mixxYas: return 'Mix by Yas · STK Push';
      case PaymentMethod.airtelMoney: return 'Airtel · STK Push';
      case PaymentMethod.azamPesa: return 'Azam · STK Push';
      case PaymentMethod.selcom: return 'Control Number / Bill Pay';
      case PaymentMethod.cashOnDelivery: return 'Pay when delivered';
    }
  }

  String get iconPath {
    const basePath = 'assets/images/payments';
    switch (this) {
      case PaymentMethod.mpesa: return '$basePath/mpesa.png';
      case PaymentMethod.mixxYas: return '$basePath/yas.png';
      case PaymentMethod.airtelMoney: return '$basePath/airtelmoney.png';
      case PaymentMethod.azamPesa: return '$basePath/azampesa.png';
      case PaymentMethod.selcom: return '$basePath/selcom.png';
      case PaymentMethod.cashOnDelivery: return '$basePath/cod.png';
    }
  }

  bool get requiresPhone =>
      this != PaymentMethod.cashOnDelivery && this != PaymentMethod.selcom;

  bool get isSelcom => this == PaymentMethod.selcom;
  bool get isCOD => this == PaymentMethod.cashOnDelivery;
}

// ── Order Status ──────────────────────────────────────────────────────────────

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  pickedUp,
  delivered,
  cancelled,
  failed,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending: return 'Order Placed';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.ready: return 'Ready for Pickup';
      case OrderStatus.pickedUp: return 'On the Way';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
      case OrderStatus.failed: return 'Failed';
    }
  }

  String get emoji {
    switch (this) {
      case OrderStatus.pending: return '📋';
      case OrderStatus.confirmed: return '✅';
      case OrderStatus.preparing: return '👨‍🍳';
      case OrderStatus.ready: return '📦';
      case OrderStatus.pickedUp: return '🛵';
      case OrderStatus.delivered: return '🏠';
      case OrderStatus.cancelled: return '❌';
      case OrderStatus.failed: return '⚠️';
    }
  }

  int get step {
    switch (this) {
      case OrderStatus.pending: return 0;
      case OrderStatus.confirmed: return 1;
      case OrderStatus.preparing: return 2;
      case OrderStatus.ready: return 3;
      case OrderStatus.pickedUp: return 4;
      case OrderStatus.delivered: return 5;
      default: return -1;
    }
  }

  bool get isTerminal =>
      this == OrderStatus.delivered ||
          this == OrderStatus.cancelled ||
          this == OrderStatus.failed;
}

// ── Delivery Address ──────────────────────────────────────────────────────────

class DeliveryAddressEntity extends Equatable {
  final String label; // "Home", "Work"
  final String street;
  final String area;
  final String city;
  final double? latitude;
  final double? longitude;
  final String? instructions;

  const DeliveryAddressEntity({
    required this.label,
    required this.street,
    required this.area,
    required this.city,
    this.latitude,
    this.longitude,
    this.instructions,
  });

  String get fullAddress => '$street, $area, $city';

  @override
  List<Object?> get props => [label, street, area, city, latitude, longitude];
}

// ── Order Entity ──────────────────────────────────────────────────────────────

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber; // e.g. CCHAP-20240001
  final List<CartItemEntity> items;
  final DeliveryAddressEntity deliveryAddress;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String? paymentReference;
  final String? controlNumber; // Selcom
  final String? notes;
  final DateTime placedAt;
  final DateTime? estimatedDeliveryAt;
  final RiderEntity? rider;

  const OrderEntity({
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

  @override
  List<Object?> get props => [id, orderNumber, status, paymentMethod];
}

class RiderEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final int totalDeliveries;
  final String? avatarUrl;

  const RiderEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.totalDeliveries,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, phone];
}

// ── Order Tracking Update ─────────────────────────────────────────────────────

class OrderTrackingUpdate extends Equatable {
  final String orderId;
  final OrderStatus status;
  final DateTime timestamp;
  final String? message;
  final double? riderLatitude;
  final double? riderLongitude;

  const OrderTrackingUpdate({
    required this.orderId,
    required this.status,
    required this.timestamp,
    this.message,
    this.riderLatitude,
    this.riderLongitude,
  });

  @override
  List<Object?> get props => [orderId, status, timestamp];
}