import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderTrackingDataSource {
  Stream<OrderTrackingUpdate> watchOrderTracking(String orderId);
  void disconnect();
}

@Injectable(as: OrderTrackingDataSource)
class OrderTrackingDataSourceImpl implements OrderTrackingDataSource {
  WebSocketChannel? _channel;

  @override
  Stream<OrderTrackingUpdate> watchOrderTracking(String orderId) {
    disconnect(); // close any existing connection

    final uri = Uri.parse('${AppConstants.wsBaseUrl}/orders/$orderId/tracking');
    _channel = WebSocketChannel.connect(uri);

    return _channel!.stream
        .where((data) => data is String)
        .map((data) => _parseUpdate(data as String, orderId))
        .where((update) => update != null)
        .cast<OrderTrackingUpdate>();
  }

  @override
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  OrderTrackingUpdate? _parseUpdate(String raw, String orderId) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return OrderTrackingUpdate(
        orderId: orderId,
        status: OrderStatus.values.firstWhere(
              (s) => s.name == (json['status'] as String),
          orElse: () => OrderStatus.pending,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        message: json['message'] as String?,
        riderLatitude: (json['rider_lat'] as num?)?.toDouble(),
        riderLongitude: (json['rider_lng'] as num?)?.toDouble(),
      );
    } catch (_) {
      return null;
    }
  }
}