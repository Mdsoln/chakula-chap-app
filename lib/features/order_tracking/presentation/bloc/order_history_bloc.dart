import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/order_usecases.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class OrderHistoryEvent extends Equatable {
  const OrderHistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadOrderHistoryEvent extends OrderHistoryEvent {}

class RefreshOrderHistoryEvent extends OrderHistoryEvent {}

// ── States ────────────────────────────────────────────────────────────────────

abstract class OrderHistoryState extends Equatable {
  const OrderHistoryState();
  @override
  List<Object?> get props => [];
}

class OrderHistoryInitialState extends OrderHistoryState {}

class OrderHistoryLoadingState extends OrderHistoryState {}

class OrderHistoryLoadedState extends OrderHistoryState {
  final List<OrderEntity> orders;
  final bool isRefreshing;

  const OrderHistoryLoadedState({
    required this.orders,
    this.isRefreshing = false,
  });

  OrderHistoryLoadedState copyWith({
    List<OrderEntity>? orders,
    bool? isRefreshing,
  }) =>
      OrderHistoryLoadedState(
        orders: orders ?? this.orders,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );

  @override
  List<Object?> get props => [orders, isRefreshing];
}

class OrderHistoryErrorState extends OrderHistoryState {
  final String message;
  const OrderHistoryErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

@injectable
class OrderHistoryBloc extends Bloc<OrderHistoryEvent, OrderHistoryState> {
  final GetMyOrdersUseCase _getMyOrders;

  OrderHistoryBloc(this._getMyOrders) : super(OrderHistoryInitialState()) {
    on<LoadOrderHistoryEvent>(_onLoad);
    on<RefreshOrderHistoryEvent>(_onRefresh);
  }

  Future<void> _onLoad(
      LoadOrderHistoryEvent event,
      Emitter<OrderHistoryState> emit,
      ) async {
    emit(OrderHistoryLoadingState());
    final result = await _getMyOrders();
    result.fold(
          (failure) => emit(OrderHistoryErrorState(message: failure.message)),
          (orders) => emit(OrderHistoryLoadedState(orders: orders)),
    );
  }

  Future<void> _onRefresh(
      RefreshOrderHistoryEvent event,
      Emitter<OrderHistoryState> emit,
      ) async {
    if (state is OrderHistoryLoadedState) {
      emit((state as OrderHistoryLoadedState).copyWith(isRefreshing: true));
    }
    final result = await _getMyOrders();
    result.fold(
          (failure) => emit(OrderHistoryErrorState(message: failure.message)),
          (orders) => emit(OrderHistoryLoadedState(orders: orders)),
    );
  }
}