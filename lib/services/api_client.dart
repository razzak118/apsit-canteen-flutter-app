import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'token_storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiClient {
  final http.Client _http;
  final TokenStorageService _tokenStorage;
  final Future<void> Function()? onUnauthorized;

  ApiClient({
    http.Client? httpClient,
    TokenStorageService? tokenStorage,
    this.onUnauthorized,
  })  : _http = httpClient ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  Future<dynamic> get(String path, {bool authRequired = true}) {
    return _send(
      method: 'GET',
      path: path,
      authRequired: authRequired,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool authRequired = true,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      authRequired: authRequired,
    );
  }

  Future<dynamic> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    required bool authRequired,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = await _buildHeaders(authRequired: authRequired);

    late http.Response response;
    if (method == 'GET') {
      response = await _http.get(uri, headers: headers);
    } else if (method == 'POST') {
      response = await _http.post(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
    } else {
      throw const ApiException('Unsupported HTTP method');
    }

    return await _decodeResponse(response);
  }

  Future<Map<String, String>> _buildHeaders({required bool authRequired}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authRequired) {
      final jwt = await _tokenStorage.getJwt();
      if (jwt == null || jwt.isEmpty) {
        throw const ApiException('JWT token not found. Please login again.');
      }
      headers['Authorization'] = 'Bearer $jwt';
    }

    return headers;
  }

  Future<dynamic> _decodeResponse(http.Response response) async {
    final status = response.statusCode;
    final body = response.body;

    if (status >= 200 && status < 300) {
      if (body.isEmpty) {
        return null;
      }
      return jsonDecode(body);
    }

    // Handle unauthorized (JWT expired or invalid)
    if (status == 401) {
      await onUnauthorized?.call();
      // Throw a gentle error that won't be shown to user since they'll be redirected
      throw const ApiException('Session expired. Please login again.', statusCode: 401);
    }

    String message = 'Request failed with status $status';
    if (body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          message = (decoded['message'] as String?) ??
              (decoded['error'] as String?) ??
              message;
        }
      } catch (_) {
        message = body;
      }
    }

    throw ApiException(message, statusCode: status);
  }
}
