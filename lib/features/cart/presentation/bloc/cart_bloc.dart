import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/usecases/cart_usecases.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class LoadCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final MenuItemEntity menuItem;
  final int quantity;
  final MenuItemVariantEntity? variant;
  final List<MenuItemExtraEntity> extras;
  final String? note;

  const AddToCartEvent({
    required this.menuItem,
    required this.quantity,
    this.variant,
    this.extras = const [],
    this.note,
  });

  @override
  List<Object?> get props => [menuItem, quantity, variant, extras];
}

class RemoveFromCartEvent extends CartEvent {
  final String cartItemId;
  const RemoveFromCartEvent({required this.cartItemId});
  @override
  List<Object?> get props => [cartItemId];
}

class UpdateCartQtyEvent extends CartEvent {
  final String cartItemId;
  final int quantity;
  const UpdateCartQtyEvent({required this.cartItemId, required this.quantity});
  @override
  List<Object?> get props => [cartItemId, quantity];
}

class ClearCartEvent extends CartEvent {}

class _CartUpdated extends CartEvent {
  final CartEntity cart;
  const _CartUpdated(this.cart);
  @override
  List<Object?> get props => [cart];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitialState extends CartState {}
class CartLoadingState extends CartState {}

class CartLoadedState extends CartState {
  final CartEntity cart;
  const CartLoadedState({required this.cart});
  @override
  List<Object?> get props => [cart];
}

class CartItemAddedState extends CartState {
  final CartEntity cart;
  final String itemName;
  const CartItemAddedState({required this.cart, required this.itemName});
  @override
  List<Object?> get props => [cart, itemName];
}

class CartErrorState extends CartState {
  final String message;
  const CartErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

@injectable
class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase _getCart;
  final AddToCartUseCase _addToCart;
  final RemoveFromCartUseCase _removeFromCart;
  final UpdateCartItemQuantityUseCase _updateQty;
  final ClearCartUseCase _clearCart;

  StreamSubscription<CartEntity>? _cartSubscription;

  CartBloc(
      this._getCart,
      this._addToCart,
      this._removeFromCart,
      this._updateQty,
      this._clearCart,
      ) : super(CartInitialState()) {
    on<LoadCartEvent>(_onLoad);
    on<AddToCartEvent>(_onAdd);
    on<RemoveFromCartEvent>(_onRemove);
    on<UpdateCartQtyEvent>(_onUpdateQty);
    on<ClearCartEvent>(_onClear);
    on<_CartUpdated>(_onCartUpdated);
  }

  Future<void> _onLoad(LoadCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoadingState());
    final result = await _getCart();
    result.fold(
          (f) => emit(CartErrorState(message: f.message)),
          (cart) => emit(CartLoadedState(cart: cart)),
    );
  }

  Future<void> _onAdd(AddToCartEvent event, Emitter<CartState> emit) async {
    final result = await _addToCart(AddToCartParams(
      menuItem: event.menuItem,
      quantity: event.quantity,
      variant: event.variant,
      extras: event.extras,
      note: event.note,
    ));
    result.fold(
          (f) => emit(CartErrorState(message: f.message)),
          (cart) => emit(CartItemAddedState(cart: cart, itemName: event.menuItem.name)),
    );
  }

  Future<void> _onRemove(RemoveFromCartEvent event, Emitter<CartState> emit) async {
    final result = await _removeFromCart(event.cartItemId);
    result.fold(
          (f) => emit(CartErrorState(message: f.message)),
          (cart) => emit(CartLoadedState(cart: cart)),
    );
  }

  Future<void> _onUpdateQty(UpdateCartQtyEvent event, Emitter<CartState> emit) async {
    final result = await _updateQty(UpdateQtyParams(
      cartItemId: event.cartItemId,
      quantity: event.quantity,
    ));
    result.fold(
          (f) => emit(CartErrorState(message: f.message)),
          (cart) => emit(CartLoadedState(cart: cart)),
    );
  }

  Future<void> _onClear(ClearCartEvent event, Emitter<CartState> emit) async {
    final result = await _clearCart();
    result.fold(
          (f) => emit(CartErrorState(message: f.message)),
          (cart) => emit(CartLoadedState(cart: cart)),
    );
  }

  void _onCartUpdated(_CartUpdated event, Emitter<CartState> emit) {
    emit(CartLoadedState(cart: event.cart));
  }

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }
}