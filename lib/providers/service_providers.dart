import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/item_service.dart';
import '../services/order_service.dart';
import '../services/token_storage_service.dart';
import '../services/user_service.dart';

final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(tokenStorage: ref.read(tokenStorageServiceProvider));
});

final itemServiceProvider = Provider<ItemService>((ref) {
  return ItemService();
});

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService();
});

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});
