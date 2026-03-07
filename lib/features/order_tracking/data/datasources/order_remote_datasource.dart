import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/network_client.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_models.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> placeOrder({
    required CartEntity cart,
    required DeliveryAddressEntity address,
    required PaymentMethod paymentMethod,
    String? paymentPhone,
    String? notes,
  });
  Future<OrderModel> getOrderById(String orderId);
  Future<List<OrderModel>> getMyOrders();
  Future<String> getSelcomControlNumber(String orderId);
}

@Injectable(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final NetworkClient _client;
  OrderRemoteDataSourceImpl(this._client);

  @override
  Future<OrderModel> placeOrder({
    required CartEntity cart,
    required DeliveryAddressEntity address,
    required PaymentMethod paymentMethod,
    String? paymentPhone,
    String? notes,
  }) async {
    try {
      final body = {
        'items': cart.items.map((i) => {
          'menu_item_id': i.menuItem.id,
          'quantity': i.quantity,
          'variant_id': i.selectedVariant?.id,
          'extras': i.selectedExtras.map((e) => e.id).toList(),
          'note': i.note,
        }).toList(),
        'delivery_address': {
          'label': address.label,
          'street': address.street,
          'area': address.area,
          'city': address.city,
          'latitude': address.latitude,
          'longitude': address.longitude,
          'instructions': address.instructions,
        },
        'payment_method': paymentMethod.name,
        if (paymentPhone != null) 'payment_phone': paymentPhone,
        if (notes != null) 'notes': notes,
      };
      final res = await _client.dio.post(ApiEndpoints.placeOrder, data: body);
      return OrderModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final res = await _client.dio.get(ApiEndpoints.orderById(orderId));
      return OrderModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final res = await _client.dio.get(ApiEndpoints.myOrders);
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<String> getSelcomControlNumber(String orderId) async {
    try {
      final res = await _client.dio.post(
        ApiEndpoints.controlNumber,
        data: {'order_id': orderId},
      );
      return res.data['data']['control_number'] as String;
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }
}