import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

@injectable
class PlaceOrderUseCase extends UseCase<OrderEntity, PlaceOrderParams> {
  final OrderRepository _repo;
  PlaceOrderUseCase(this._repo);

  @override
  Future<Either<Failure, OrderEntity>> call(PlaceOrderParams p) =>
      _repo.placeOrder(
        cart: p.cart,
        address: p.address,
        paymentMethod: p.paymentMethod,
        paymentPhone: p.paymentPhone,
        notes: p.notes,
      );
}

class PlaceOrderParams extends Equatable {
  final CartEntity cart;
  final DeliveryAddressEntity address;
  final PaymentMethod paymentMethod;
  final String? paymentPhone;
  final String? notes;

  const PlaceOrderParams({
    required this.cart,
    required this.address,
    required this.paymentMethod,
    this.paymentPhone,
    this.notes,
  });

  @override
  List<Object?> get props => [cart, address, paymentMethod];
}

@injectable
class GetOrderByIdUseCase extends UseCase<OrderEntity, String> {
  final OrderRepository _repo;
  GetOrderByIdUseCase(this._repo);

  @override
  Future<Either<Failure, OrderEntity>> call(String orderId) =>
      _repo.getOrderById(orderId);
}

@injectable
class GetMyOrdersUseCase extends NoParamsUseCase<List<OrderEntity>> {
  final OrderRepository _repo;
  GetMyOrdersUseCase(this._repo);

  @override
  Future<Either<Failure, List<OrderEntity>>> call() => _repo.getMyOrders();
}

@injectable
class WatchOrderTrackingUseCase
    extends StreamUseCase<OrderTrackingUpdate, String> {
  final OrderTrackingRepository _repo;
  WatchOrderTrackingUseCase(this._repo);

  @override
  Stream<Either<Failure, OrderTrackingUpdate>> call(String orderId) =>
      _repo.watchOrderTracking(orderId);
}