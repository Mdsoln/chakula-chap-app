
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  MockAuthRemoteDataSource._();
  static final MockAuthRemoteDataSource instance = MockAuthRemoteDataSource._();

  static const _mockOtp = '123456';
  static const _networkDelay = Duration(milliseconds: 1400);

  final Map<String, _RegisteredUser> _users = {
    // Pre-seeded demo account — always works without registering
    '+255700000001': const _RegisteredUser(
      id: 'mock-user-demo',
      phone: '+255700000001',
      name: 'Demo User',
      email: 'demo@chakulachap.co.tz',
    ),
  };

  @override
  Future<OtpSentModel> sendOtp(String phone) async {
    await Future.delayed(_networkDelay);

    // Simulate a blocked test number
    if (phone.endsWith('9999')) {
      throw const ServerException(
        message: 'This number cannot receive SMS. Try another.',
        statusCode: 422,
      );
    }

    // Accept any phone — auto-register unknown numbers on first OTP
    // (mirrors common OTP-first signup flows)
    if (!_users.containsKey(phone)) {
      _users[phone] = _RegisteredUser(
        id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        phone: phone,
        name: null,   // Will be set after profile completion
        email: null,
      );
    }

    return OtpSentModel(phone: phone, expiresInSeconds: 10, maskedPhone: phone);
  }

  @override
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String otp,
    String? deviceInfo,
  }) async {
    await Future.delayed(_networkDelay);

    if (otp != _mockOtp) {
      throw const UnauthorizedException(
        message: 'Incorrect OTP. Use 123456 for the demo.',
      );
    }

    final user = _users[phone];
    if (user == null) {
      throw const ServerException(
        message: 'Session expired. Please request a new OTP.',
        statusCode: 410,
      );
    }

    return _buildSession(user);
  }

  // ── Extended API used by registration flow ─────────────────────────────────

  @override
  Future<UserModel> completeProfile({
    required String phone,
    required String fullName,
    String? email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final entry = _users.entries.firstWhere(
          (e) => e.value.name == null,
      orElse: () => _users.entries.last,
    );

    final updated = _RegisteredUser(
      id: entry.value.id,
      phone: entry.value.phone,
      name: fullName,
      email: email,
    );
    _users[entry.key] = updated;

    return UserModel(
      id: updated.id,
      phone: updated.phone,
      name: updated.name!,
      email: updated.email,
      avatarUrl: null,
      verified: true,
      isProfileComplete: true,
      createdAt: "2026-03-21",
    );
  }

  @override
  Future<AuthSessionModel> refreshToken(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Find by refresh token prefix (simplified — real impl would use a map)
    final phone = _users.keys.firstOrNull ?? '+255700000001';
    final user = _users[phone]!;
    return _buildSession(user);
  }

  @override
  Future<bool> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  AuthSessionModel _buildSession(_RegisteredUser user) {
    const int sessionDurationSeconds = 86400;
    return AuthSessionModel(

      accessToken: 'mock-access-${user.id}-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock-refresh-${user.id}',
      expiresIn: sessionDurationSeconds,
      user: UserModel(
        id: user.id,
        phone: user.phone,
        name: user.name,
        email: user.email,
        avatarUrl: null,
        verified: true,
        isProfileComplete: true,
        createdAt: "2026-03-21",
      ),
    );
  }
}

class _RegisteredUser {
  final String id;
  final String phone;
  final String? name;
  final String? email;

  const _RegisteredUser({
    required this.id,
    required this.phone,
    this.name,
    this.email,
  });
}