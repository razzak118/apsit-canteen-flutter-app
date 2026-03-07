import '../models/auth/change_password_request_dto.dart';
import '../models/auth/login_request_dto.dart';
import '../models/auth/login_response_dto.dart';
import '../models/auth/signup_request_dto.dart';
import '../models/auth/signup_response_dto.dart';
import 'api_client.dart';
import 'token_storage_service.dart';

class AuthService {
  final ApiClient _apiClient;
  final TokenStorageService _tokenStorage;

  AuthService({
    ApiClient? apiClient,
    TokenStorageService? tokenStorage,
    Future<void> Function()? onUnauthorized,
  })  : _apiClient = apiClient ?? ApiClient(onUnauthorized: onUnauthorized),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  Future<LoginResponseDto> login(LoginRequestDto request) async {
    final json = await _apiClient.post(
      '/auth/login',
      body: request.toJson(),
      authRequired: false,
    );

    final response = LoginResponseDto.fromJson(json as Map<String, dynamic>);
    await _tokenStorage.saveAuth(jwt: response.jwt, userId: response.userId);
    return response;
  }

  Future<SignupResponseDto> signup(SignupRequestDto request) async {
    final json = await _apiClient.post(
      '/auth/signup',
      body: request.toJson(),
      authRequired: false,
    );

    return SignupResponseDto.fromJson(json as Map<String, dynamic>);
  }

  Future<void> changePassword(ChangePasswordRequestDto request) async {
    await _apiClient.post(
      '/auth/change-password',
      body: request.toJson(),
      authRequired: true,
    );
  }

  Future<void> logout() {
    return _tokenStorage.clearAuth();
  }
}
