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
  @JsonKey(name: 'verified')
  final bool verified;
  @JsonKey(name: 'profileComplete')
  final bool isProfileComplete;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.avatarUrl,
    required this.verified,
    required this.isProfileComplete,
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
    verified: verified,
    isProfileComplete: isProfileComplete,
    createdAt: createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
  );
}

@JsonSerializable()
class AuthSessionModel {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  final UserModel user;
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresIn,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthSessionModelToJson(this);

  AuthSessionEntity toEntity() => AuthSessionEntity(
    accessToken: accessToken,
    refreshToken: refreshToken,
    user: user.toEntity(),
    expiresIn: expiresIn,
  );
}