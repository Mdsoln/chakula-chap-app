import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final bool verified;
  final bool isProfileComplete;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.avatarUrl,
    required this.verified,
    required this.isProfileComplete,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, phone];
}

class AuthSessionEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;
  final int expiresIn;

  const AuthSessionEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresIn,
  });

  bool get isExpired {
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresIn * 1000);
    return DateTime.now().isAfter(expiryDate);
  }

  @override
  List<Object?> get props => [accessToken, user];
}

/// Returned by sendOtp — carries the server response details for the UI
class OtpSentEntity extends Equatable {
  final String phone;
  final String maskedPhone;
  final int expiresInSeconds;

  const OtpSentEntity({
    required this.phone,
    required this.maskedPhone,
    required this.expiresInSeconds,
  });

  @override
  List<Object?> get props => [phone, maskedPhone, expiresInSeconds];
}