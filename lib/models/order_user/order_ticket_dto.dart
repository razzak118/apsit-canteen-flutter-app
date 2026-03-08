import 'order_item_dto.dart';

class OrderTicketDto {
  final int? orderId;
  final String username;
  final List<OrderItemDto> orderItems;
  final double totalAmount;
  final String orderStatus;
  final String createdAt;
  final String? completedAt;
  final String? updatedAt;

  const OrderTicketDto({
    this.orderId,
    required this.username,
    required this.orderItems,
    required this.totalAmount,
    required this.orderStatus,
    required this.createdAt,
    this.completedAt,
    this.updatedAt,
  });

  factory OrderTicketDto.fromJson(Map<String, dynamic> json) {
    final items = (json['orderItems'] as List<dynamic>)
        .map((item) => OrderItemDto.fromJson(item as Map<String, dynamic>))
        .toList();

    return OrderTicketDto(
      orderId: (json['orderId'] ?? json['id']) == null
          ? null
          : int.tryParse((json['orderId'] ?? json['id']).toString()),
      username: json['username'] as String,
      orderItems: items,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      orderStatus: json['orderStatus'] as String,
      createdAt: json['createdAt'] as String,
      completedAt: json['completedAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'username': username,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'updatedAt': updatedAt,
    };
  }
}
