
import 'dart:async';

import '../../../../core/mock/mock_data.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_models.dart';
import 'order_remote_datasource.dart';
import 'order_tracking_datasource.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Order status timeline — defined here to keep _StatusStep accessible
// ─────────────────────────────────────────────────────────────────────────────

class _TrackingStep {
  final OrderStatus status;
  final Duration delay;
  final double? riderLat;
  final double? riderLng;
  final String? message;

  const _TrackingStep(
      this.status,
      this.delay, {
        this.riderLat,
        this.riderLng,
        this.message,
      });
}

const List<_TrackingStep> _timeline = [
  _TrackingStep(OrderStatus.pending,   Duration(seconds: 0)),
  _TrackingStep(OrderStatus.confirmed, Duration(seconds: 15),
      message: '✅ Restaurant confirmed your order!'),
  _TrackingStep(OrderStatus.preparing, Duration(seconds: 30),
      message: '👨‍🍳 Kitchen is preparing your food'),
  _TrackingStep(OrderStatus.ready,     Duration(minutes: 2),
      riderLat: -6.7740, riderLng: 39.2501,
      message: '📦 Order packed — rider on the way!'),
  _TrackingStep(OrderStatus.pickedUp,  Duration(minutes: 2, seconds: 30),
      riderLat: -6.7820, riderLng: 39.2620,
      message: '🛵 Rider picked up your order!'),
  _TrackingStep(OrderStatus.delivered, Duration(minutes: 4),
      riderLat: -6.8000, riderLng: 39.2780,
      message: '🏠 Delivered! Enjoy your meal 🎉'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Shared in-memory order store — both datasources read/write this
// ─────────────────────────────────────────────────────────────────────────────

final _orderStore = <String, _LiveOrder>{
  for (final o in MockData.pastOrders)
    o.id: _LiveOrder(model: o, currentStatus: OrderStatus.delivered),
};

class _LiveOrder {
  OrderModel model;
  OrderStatus currentStatus;

  _LiveOrder({required this.model, required this.currentStatus});
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock Order Remote DataSource
// ─────────────────────────────────────────────────────────────────────────────

class MockOrderRemoteDataSource implements OrderRemoteDataSource {
  MockOrderRemoteDataSource._();
  static final MockOrderRemoteDataSource instance = MockOrderRemoteDataSource._();

  @override
  Future<OrderModel> placeOrder({
    required CartEntity cart,
    required DeliveryAddressEntity address,
    required PaymentMethod paymentMethod,
    String? paymentPhone,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final orderId = 'order-live-${DateTime.now().millisecondsSinceEpoch}';
    final orderNumber = 'ZTU-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}';

    final subtotal = cart.items.fold<double>(
      0,
          (sum, item) => sum + (item.menuItem.price * item.quantity),
    );
    const deliveryFee = 3000.0;

    final orderModel = OrderModel(
      id: orderId,
      orderNumber: orderNumber,
      items: cart.items
          .map((cartItem) => OrderItemModel(
        menuItemId: cartItem.menuItem.id,
        menuItemName: cartItem.menuItem.name,
        menuItemEmoji: cartItem.menuItem.emoji,
        unitPrice: cartItem.menuItem.price,
        quantity: cartItem.quantity,
        lineTotal: cartItem.menuItem.price * cartItem.quantity,
      ))
          .toList(),
      deliveryAddress: DeliveryAddressModel(
        label: address.label,
        street: address.street,
        area: address.area,
        city: address.city,
        latitude: address.latitude,
        longitude: address.longitude,
        instructions: address.instructions,
      ),
      paymentMethod: paymentMethod.name,
      status: OrderStatus.pending.name,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: 0,
      total: subtotal + deliveryFee,
      controlNumber: paymentMethod == PaymentMethod.selcom
          ? '290${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
          : null,
      notes: notes,
      placedAt: DateTime.now(),
      estimatedDeliveryAt: DateTime.now().add(const Duration(minutes: 45)),
      rider: null,
    );

    _orderStore[orderId] = _LiveOrder(
      model: orderModel,
      currentStatus: OrderStatus.pending,
    );

    // Kick off automated status progression
    MockOrderTrackingDataSource.instance.startProgression(orderId);

    return orderModel;
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final live = _orderStore[orderId];
    if (live == null) throw Exception('Order $orderId not found');
    return live.model;
  }

  @override
  Future<List<OrderModel>> getMyOrders() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final sorted = _orderStore.values.map((l) => l.model).toList()
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return sorted;
  }

  @override
  Future<String> getSelcomControlNumber(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _orderStore[orderId]?.model.controlNumber ??
        '290${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  // Called internally by tracking mock
  void updateStatus(String orderId, OrderStatus status, RiderModel? rider) {
    final live = _orderStore[orderId];
    if (live == null) return;

    live.currentStatus = status;
    live.model = OrderModel(
      id: live.model.id,
      orderNumber: live.model.orderNumber,
      items: live.model.items,
      deliveryAddress: live.model.deliveryAddress,
      paymentMethod: live.model.paymentMethod,
      status: status.name,
      subtotal: live.model.subtotal,
      deliveryFee: live.model.deliveryFee,
      discount: live.model.discount,
      total: live.model.total,
      controlNumber: live.model.controlNumber,
      notes: live.model.notes,
      placedAt: live.model.placedAt,
      estimatedDeliveryAt: live.model.estimatedDeliveryAt,
      rider: rider ?? live.model.rider,
      paymentReference: live.model.paymentReference,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock Order Tracking DataSource (replaces WebSocket)
// ─────────────────────────────────────────────────────────────────────────────

class MockOrderTrackingDataSource implements OrderTrackingDataSource {
  MockOrderTrackingDataSource._();
  static final MockOrderTrackingDataSource instance = MockOrderTrackingDataSource._();

  final Map<String, StreamController<OrderTrackingUpdate>> _controllers = {};
  final Map<String, List<Timer>> _activeTimers = {};

  @override
  Stream<OrderTrackingUpdate> watchOrderTracking(String orderId) {
    // Clean up previous subscription for this order if re-subscribing
    _controllers[orderId]?.close();

    final controller = StreamController<OrderTrackingUpdate>.broadcast();
    _controllers[orderId] = controller;

    // Immediately emit current status (prevents blank UI on navigation)
    _emitCurrentStatus(orderId, controller);

    return controller.stream;
  }

  @override
  void disconnect() {
    for (final ctrl in _controllers.values) {
      ctrl.close();
    }
    _controllers.clear();

    for (final timers in _activeTimers.values) {
      for (final t in timers) {
        t.cancel();
      }
    }
    _activeTimers.clear();
  }

  // Called by MockOrderRemoteDataSource after a new order is placed
  void startProgression(String orderId) {
    // Cancel any existing timers for this order (safety)
    _cancelTimers(orderId);

    final timers = <Timer>[];

    for (final step in _timeline) {
      final timer = Timer(step.delay, () {
        final rider = step.status.index >= OrderStatus.ready.index
            ? MockData.mockRider
            : null;

        // Update stored order model
        MockOrderRemoteDataSource.instance.updateStatus(orderId, step.status, rider);

        // Push update to any listening stream
        final controller = _controllers[orderId];
        if (controller != null && !controller.isClosed) {
          controller.add(OrderTrackingUpdate(
            orderId: orderId,
            status: step.status,
            timestamp: DateTime.now(),
            message: step.message,
            riderLatitude: step.riderLat,
            riderLongitude: step.riderLng,
          ));
        }

        // Auto-close stream after terminal status
        if (step.status.isTerminal) {
          Future.delayed(const Duration(seconds: 5), () {
            _controllers[orderId]?.close();
            _controllers.remove(orderId);
          });
        }
      });

      timers.add(timer);
    }

    _activeTimers[orderId] = timers;
  }

  void _emitCurrentStatus(
      String orderId,
      StreamController<OrderTrackingUpdate> controller,
      ) {
    final live = _orderStore[orderId];
    if (live == null) return;

    Future.microtask(() {
      if (!controller.isClosed) {
        controller.add(OrderTrackingUpdate(
          orderId: orderId,
          status: live.currentStatus,
          timestamp: DateTime.now(),
          riderLatitude: live.model.rider != null ? -6.800 : null,
          riderLongitude: live.model.rider != null ? 39.280 : null,
        ));
      }
    });
  }

  void _cancelTimers(String orderId) {
    final timers = _activeTimers.remove(orderId);
    if (timers != null) {
      for (final t in timers) {
        t.cancel();
      }
    }
  }
}