import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../cart/domain/entities/cart_entity.dart';
import '../../../order_tracking/domain/entities/order_entity.dart';
import '../../../order_tracking/domain/usecases/order_usecases.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class SelectPaymentMethodEvent extends CheckoutEvent {
  final PaymentMethod method;
  const SelectPaymentMethodEvent(this.method);
  @override
  List<Object?> get props => [method];
}

class SetDeliveryAddressEvent extends CheckoutEvent {
  final DeliveryAddressEntity address;
  const SetDeliveryAddressEvent(this.address);
  @override
  List<Object?> get props => [address];
}

class SetPaymentPhoneEvent extends CheckoutEvent {
  final String phone;
  const SetPaymentPhoneEvent(this.phone);
  @override
  List<Object?> get props => [phone];
}

class SetNotesEvent extends CheckoutEvent {
  final String notes;
  const SetNotesEvent(this.notes);
  @override
  List<Object?> get props => [notes];
}

class PlaceOrderEvent extends CheckoutEvent {
  final CartEntity cart;
  const PlaceOrderEvent({required this.cart});
  @override
  List<Object?> get props => [cart];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object?> get props => [];
}

class CheckoutInitialState extends CheckoutState {}

class CheckoutReadyState extends CheckoutState {
  final PaymentMethod? selectedMethod;
  final DeliveryAddressEntity? address;
  final String paymentPhone;
  final String notes;
  final bool canPlaceOrder;

  const CheckoutReadyState({
    this.selectedMethod,
    this.address,
    this.paymentPhone = '',
    this.notes = '',
    this.canPlaceOrder = false,
  });

  CheckoutReadyState copyWith({
    PaymentMethod? selectedMethod,
    DeliveryAddressEntity? address,
    String? paymentPhone,
    String? notes,
  }) {
    final method = selectedMethod ?? this.selectedMethod;
    final addr = address ?? this.address;
    final phone = paymentPhone ?? this.paymentPhone;

    final can = addr != null &&
        method != null &&
        (method.isCOD ||
            method.isSelcom ||
            (method.requiresPhone && phone.length >= 9));

    return CheckoutReadyState(
      selectedMethod: method,
      address: addr,
      paymentPhone: phone,
      notes: notes ?? this.notes,
      canPlaceOrder: can,
    );
  }

  @override
  List<Object?> get props =>
      [selectedMethod, address, paymentPhone, notes, canPlaceOrder];
}

class CheckoutPlacingOrderState extends CheckoutState {}

class CheckoutOrderPlacedState extends CheckoutState {
  final OrderEntity order;
  const CheckoutOrderPlacedState({required this.order});
  @override
  List<Object?> get props => [order];
}

class CheckoutErrorState extends CheckoutState {
  final String message;
  const CheckoutErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

@injectable
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final PlaceOrderUseCase _placeOrder;

  static const _defaultAddress = DeliveryAddressEntity(
    label: 'Home',
    street: 'Kariakoo',
    area: 'Kariakoo',
    city: 'Dar es Salaam',
  );

  CheckoutBloc(this._placeOrder) : super(CheckoutInitialState()) {
    on<SelectPaymentMethodEvent>(_onSelectMethod);
    on<SetDeliveryAddressEvent>(_onSetAddress);
    on<SetPaymentPhoneEvent>(_onSetPhone);
    on<SetNotesEvent>(_onSetNotes);
    on<PlaceOrderEvent>(_onPlaceOrder);

    // Pre-load with default address
    emit(const CheckoutReadyState(address: _defaultAddress));
  }

  void _onSelectMethod(
      SelectPaymentMethodEvent event, Emitter<CheckoutState> emit) {
    final current = _currentReady;
    emit(current.copyWith(selectedMethod: event.method));
  }

  void _onSetAddress(
      SetDeliveryAddressEvent event, Emitter<CheckoutState> emit) {
    final current = _currentReady;
    emit(current.copyWith(address: event.address));
  }

  void _onSetPhone(SetPaymentPhoneEvent event, Emitter<CheckoutState> emit) {
    final current = _currentReady;
    emit(current.copyWith(paymentPhone: event.phone));
  }

  void _onSetNotes(SetNotesEvent event, Emitter<CheckoutState> emit) {
    final current = _currentReady;
    emit(current.copyWith(notes: event.notes));
  }

  Future<void> _onPlaceOrder(
      PlaceOrderEvent event,
      Emitter<CheckoutState> emit,
      ) async {
    final current = _currentReady;
    if (!current.canPlaceOrder) return;

    emit(CheckoutPlacingOrderState());

    final result = await _placeOrder(PlaceOrderParams(
      cart: event.cart,
      address: current.address!,
      paymentMethod: current.selectedMethod!,
      paymentPhone: current.paymentPhone.isNotEmpty
          ? '+255${current.paymentPhone}'
          : null,
      notes: current.notes.isNotEmpty ? current.notes : null,
    ));

    result.fold(
          (f) => emit(CheckoutErrorState(message: f.message)),
          (order) => emit(CheckoutOrderPlacedState(order: order)),
    );
  }

  CheckoutReadyState get _currentReady =>
      state is CheckoutReadyState
          ? state as CheckoutReadyState
          : const CheckoutReadyState(
        address: _defaultAddress,
      );
}