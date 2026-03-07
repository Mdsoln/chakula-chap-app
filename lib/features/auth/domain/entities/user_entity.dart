import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.avatarUrl,
    required this.isVerified,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, phone, name, email, avatarUrl, isVerified, createdAt];
}

class AuthSessionEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;
  final DateTime expiresAt;

  const AuthSessionEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [accessToken, refreshToken, user, expiresAt];
}