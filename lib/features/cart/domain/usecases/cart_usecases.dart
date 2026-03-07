import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

@injectable
class GetCartUseCase extends NoParamsUseCase<CartEntity> {
  final CartRepository _repo;
  GetCartUseCase(this._repo);
  @override
  Future<Either<Failure, CartEntity>> call() => _repo.getCart();
}

@injectable
class AddToCartUseCase extends UseCase<CartEntity, AddToCartParams> {
  final CartRepository _repo;
  AddToCartUseCase(this._repo);
  @override
  Future<Either<Failure, CartEntity>> call(AddToCartParams p) =>
      _repo.addItem(
        menuItem: p.menuItem,
        quantity: p.quantity,
        variant: p.variant,
        extras: p.extras,
        note: p.note,
      );
}

class AddToCartParams extends Equatable {
  final MenuItemEntity menuItem;
  final int quantity;
  final MenuItemVariantEntity? variant;
  final List<MenuItemExtraEntity> extras;
  final String? note;

  const AddToCartParams({
    required this.menuItem,
    required this.quantity,
    this.variant,
    this.extras = const [],
    this.note,
  });

  @override
  List<Object?> get props => [menuItem, quantity, variant, extras];
}

@injectable
class RemoveFromCartUseCase extends UseCase<CartEntity, String> {
  final CartRepository _repo;
  RemoveFromCartUseCase(this._repo);
  @override
  Future<Either<Failure, CartEntity>> call(String cartItemId) =>
      _repo.removeItem(cartItemId);
}

@injectable
class UpdateCartItemQuantityUseCase extends UseCase<CartEntity, UpdateQtyParams> {
  final CartRepository _repo;
  UpdateCartItemQuantityUseCase(this._repo);
  @override
  Future<Either<Failure, CartEntity>> call(UpdateQtyParams p) =>
      _repo.updateItemQuantity(p.cartItemId, p.quantity);
}

class UpdateQtyParams extends Equatable {
  final String cartItemId;
  final int quantity;
  const UpdateQtyParams({required this.cartItemId, required this.quantity});
  @override
  List<Object?> get props => [cartItemId, quantity];
}

@injectable
class ClearCartUseCase extends NoParamsUseCase<CartEntity> {
  final CartRepository _repo;
  ClearCartUseCase(this._repo);
  @override
  Future<Either<Failure, CartEntity>> call() => _repo.clearCart();
}