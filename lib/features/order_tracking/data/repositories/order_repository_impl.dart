import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../../../order_tracking/data/datasources/order_tracking_datasource.dart';

@Injectable(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remote;
  OrderRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, OrderEntity>> placeOrder({
    required CartEntity cart,
    required DeliveryAddressEntity address,
    required PaymentMethod paymentMethod,
    String? paymentPhone,
    String? notes,
  }) async {
    try {
      final order = await _remote.placeOrder(
        cart: cart,
        address: address,
        paymentMethod: paymentMethod,
        paymentPhone: paymentPhone,
        notes: notes,
      );
      return Right(order.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    try {
      final order = await _remote.getOrderById(orderId);
      return Right(order.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getMyOrders() async {
    try {
      final orders = await _remote.getMyOrders();
      return Right(orders.map((o) => o.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, String>> getSelcomControlNumber(String orderId) async {
    try {
      final cn = await _remote.getSelcomControlNumber(orderId);
      return Right(cn);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(PaymentFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}

@Injectable(as: OrderTrackingRepository)
class OrderTrackingRepositoryImpl implements OrderTrackingRepository {
  final OrderTrackingDataSource _ws;
  final OrderRemoteDataSource _remote;

  OrderTrackingRepositoryImpl(this._ws, this._remote);

  @override
  Stream<Either<Failure, OrderTrackingUpdate>> watchOrderTracking(
      String orderId,
      ) async* {
    try {
      await for (final update in _ws.watchOrderTracking(orderId)) {
        yield Right(update);
      }
    } catch (e) {
      yield const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderWithTracking(String orderId) async {
    try {
      final order = await _remote.getOrderById(orderId);
      return Right(order.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}