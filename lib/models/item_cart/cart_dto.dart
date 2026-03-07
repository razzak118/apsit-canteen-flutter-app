import 'cart_item_dto.dart';

class CartDto {
  final int cartId;
  final List<CartItemDto> cartItems;
  final double totalCartPrice;

  const CartDto({
    required this.cartId,
    required this.cartItems,
    required this.totalCartPrice,
  });

  factory CartDto.fromJson(Map<String, dynamic> json) {
    final items = (json['cartItems'] as List<dynamic>)
        .map((item) => CartItemDto.fromJson(item as Map<String, dynamic>))
        .toList();

    return CartDto(
      cartId: json['cartId'] as int,
      cartItems: items,
      totalCartPrice: (json['totalCartPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
      'totalCartPrice': totalCartPrice,
    };
  }
}
