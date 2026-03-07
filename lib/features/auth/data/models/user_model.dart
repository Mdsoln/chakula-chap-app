import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// Data model = domain entity + JSON serialization.
/// Converts API responses → domain entities that the app logic uses.
@JsonSerializable()
class UserModel {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.avatarUrl,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convert data model → domain entity (the only direction allowed)
  UserEntity toEntity() => UserEntity(
    id: id,
    phone: phone,
    name: name,
    email: email,
    avatarUrl: avatarUrl,
    isVerified: isVerified,
    createdAt: createdAt,
  );
}

@JsonSerializable()
class AuthSessionModel {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  final UserModel user;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthSessionModelToJson(this);

  AuthSessionEntity toEntity() => AuthSessionEntity(
    accessToken: accessToken,
    refreshToken: refreshToken,
    user: user.toEntity(),
    expiresAt: expiresAt,
  );
}