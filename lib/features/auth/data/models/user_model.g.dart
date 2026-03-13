// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// ignore_for_file: type=lint

part of 'user_model.dart';

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  phone: json['phone'] as String,
  name: json['name'] as String?,
  email: json['email'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  isVerified: json['is_verified'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
      'email': instance.email,
      'avatar_url': instance.avatarUrl,
      'is_verified': instance.isVerified,
      'created_at': instance.createdAt.toIso8601String(),
    };

AuthSessionModel _$AuthSessionModelFromJson(Map<String, dynamic> json) =>
    AuthSessionModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$AuthSessionModelToJson(AuthSessionModel instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'user': instance.user.toJson(),
      'expires_at': instance.expiresAt.toIso8601String(),
    };