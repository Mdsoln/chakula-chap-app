// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// ignore_for_file: type=lint

part of 'user_model.dart';

@JsonSerializable()
class OtpSentModel {
  final String phone;

  @JsonKey(name: 'expires_in_seconds')
  final int expiresInSeconds;

  @JsonKey(name: 'masked_phone')
  final String maskedPhone;

  const OtpSentModel({
    required this.phone,
    required this.expiresInSeconds,
    required this.maskedPhone,
  });

  factory OtpSentModel.fromJson(Map<String, dynamic> json) =>
      _$OtpSentModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtpSentModelToJson(this);

  OtpSentEntity toEntity() => OtpSentEntity(
    phone: phone,
    expiresInSeconds: expiresInSeconds,
    maskedPhone: maskedPhone,
  );
}

OtpSentModel _$OtpSentModelFromJson(Map<String, dynamic> json) => OtpSentModel(
  phone: json['phone'] as String,
  expiresInSeconds: json['expiresInSeconds'] as int,
  maskedPhone: json['maskedPhone'] as String,
);

Map<String, dynamic> _$OtpSentModelToJson(OtpSentModel instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'expiresInSeconds': instance.expiresInSeconds,
      'maskedPhone': instance.maskedPhone,
    };

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  phone: json['phone'] as String,
  name: json['name'] as String?,
  email: json['email'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  verified: json['verified'] as bool,
  createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']!) : DateTime.now(),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'verified': instance.verified,
      'createdAt': instance.createdAt,
    };

AuthSessionModel _$AuthSessionModelFromJson(Map<String, dynamic> json) =>
    AuthSessionModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthSessionModelToJson(AuthSessionModel instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn,
      'user': instance.user.toJson(),
    };