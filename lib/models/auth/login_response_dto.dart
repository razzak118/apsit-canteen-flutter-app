class LoginResponseDto {
  final String jwt;
  final int userId;

  const LoginResponseDto({
    required this.jwt,
    required this.userId,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      jwt: json['jwt'] as String,
      userId: json['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jwt': jwt,
      'userId': userId,
    };
  }
}
