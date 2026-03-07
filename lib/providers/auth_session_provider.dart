import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth/login_request_dto.dart';
import '../models/auth/signup_request_dto.dart';
import 'service_providers.dart';

class AuthSessionNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final jwt = await ref.read(tokenStorageServiceProvider).getJwt();
    return jwt != null && jwt.isNotEmpty;
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).login(
            LoginRequestDto(username: username, password: password),
          );
      return true;
    });
  }

  Future<void> signup({
    required String username,
    required String password,
    required String mobileNumber,
    required String role,
  }) async {
    await ref.read(authServiceProvider).signup(
          SignupRequestDto(
            username: username,
            password: password,
            mobileNumber: mobileNumber,
            role: role,
          ),
        );
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AsyncData(false);
  }

  /// Called when JWT token expires or becomes invalid
  Future<void> handleTokenExpiration() async {
    await ref.read(tokenStorageServiceProvider).clearAuth();
    state = const AsyncData(false);
  }
}

final authSessionProvider = AsyncNotifierProvider<AuthSessionNotifier, bool>(
  AuthSessionNotifier.new,
);
