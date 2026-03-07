import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> placeOrder({
    required CartEntity cart,
    required DeliveryAddressEntity address,
    required PaymentMethod paymentMethod,
    String? paymentPhone,
    String? notes,
  });

  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);
  Future<Either<Failure, List<OrderEntity>>> getMyOrders();
  Future<Either<Failure, String>> getSelcomControlNumber(String orderId);
}

abstract class OrderTrackingRepository {
  Stream<Either<Failure, OrderTrackingUpdate>> watchOrderTracking(String orderId);
  Future<Either<Failure, OrderEntity>> getOrderWithTracking(String orderId);
}