import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class TokenStorageService {
  Future<void> saveAuth({required String jwt, required int userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.jwtStorageKey, jwt);
    await prefs.setInt(ApiConfig.userIdStorageKey, userId);
  }

  Future<String?> getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.jwtStorageKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(ApiConfig.userIdStorageKey);
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.jwtStorageKey);
    await prefs.remove(ApiConfig.userIdStorageKey);
  }
}
