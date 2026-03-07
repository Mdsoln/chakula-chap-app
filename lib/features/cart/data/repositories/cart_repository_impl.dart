import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';

@Injectable(as: CartRepository)
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _local;
  CartRepositoryImpl(this._local);

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      return Right(await _local.getCart());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addItem({
    required MenuItemEntity menuItem,
    required int quantity,
    MenuItemVariantEntity? variant,
    List<MenuItemExtraEntity> extras = const [],
    String? note,
  }) async {
    try {
      return Right(await _local.addItem(
        menuItem: menuItem,
        quantity: quantity,
        variant: variant,
        extras: extras,
        note: note,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeItem(String cartItemId) async {
    try {
      return Right(await _local.removeItem(cartItemId));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateItemQuantity(
      String cartItemId,
      int quantity,
      ) async {
    try {
      return Right(await _local.updateQuantity(cartItemId, quantity));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, CartEntity>> clearCart() async {
    try {
      return Right(await _local.clearCart());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Stream<CartEntity> watchCart() => _local.watchCart();
}