import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../entities/cart_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();

  Future<Either<Failure, CartEntity>> addItem({
    required MenuItemEntity menuItem,
    required int quantity,
    MenuItemVariantEntity? variant,
    List<MenuItemExtraEntity> extras,
    String? note,
  });

  Future<Either<Failure, CartEntity>> removeItem(String cartItemId);

  Future<Either<Failure, CartEntity>> updateItemQuantity(String cartItemId, int quantity);

  Future<Either<Failure, CartEntity>> clearCart();

  Stream<CartEntity> watchCart();
}