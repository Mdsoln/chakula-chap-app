
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
  Future<bool> sendOtp(String phone) async {
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

    return true;
  }

  @override
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String otp,
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

  /// Call this after OTP verification when user provides profile details.
  Future<AuthSessionModel> completeProfile({
    required String phone,
    required String name,
    String? email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final existing = _users[phone];
    if (existing == null) {
      throw const ServerException(
        message: 'User session not found.',
        statusCode: 404,
      );
    }

    final updated = _RegisteredUser(
      id: existing.id,
      phone: phone,
      name: name,
      email: email,
    );
    _users[phone] = updated;
    return _buildSession(updated);
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
    return AuthSessionModel(
      accessToken: 'mock-access-${user.id}-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock-refresh-${user.id}',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      user: UserModel(
        id: user.id,
        phone: user.phone,
        name: user.name ?? 'ChakulaChap User',
        email: user.email,
        avatarUrl: null,
        isVerified: true,
        createdAt: DateTime.now(),
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