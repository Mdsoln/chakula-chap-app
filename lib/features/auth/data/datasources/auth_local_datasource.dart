import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheSession(AuthSessionModel session);
  Future<UserModel?> getCachedUser();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearSession();
  Future<bool> get isLoggedIn;
  Future<void> cacheUser(UserModel user);
}

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._secureStorage, this._prefs);

  @override
  Future<void> cacheSession(AuthSessionModel session) async {
    try {
      await Future.wait([
        _secureStorage.write(
          key: AppConstants.kAccessToken,
          value: session.accessToken,
        ),
        _secureStorage.write(
          key: AppConstants.kRefreshToken,
          value: session.refreshToken,
        ),
        _secureStorage.write(
          key: AppConstants.kUserId,
          value: session.user.id,
        ),
        _prefs.setString(
          'cached_user',
          jsonEncode(session.user.toJson()),
        ),
      ]);
    } catch (e) {
      throw StorageException(message: 'Failed to save session: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = _prefs.getString('cached_user');
      if (userJson == null) return null;
      return UserModel.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to load cached user: $e');
    }
  }

  @override
  Future<String?> getAccessToken() =>
      _secureStorage.read(key: AppConstants.kAccessToken);

  @override
  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: AppConstants.kRefreshToken);

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _secureStorage.deleteAll(),
      _prefs.remove('cached_user'),
    ]);
  }

  @override
  Future<bool> get isLoggedIn async {
    final token = await _secureStorage.read(key: AppConstants.kAccessToken);
    return token != null;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _prefs.setString(
        AppConstants.kCachedUser,
        jsonEncode(user.toJson()),
      );
    } catch (e) {
      throw StorageException(message: 'Failed to cache user: $e');
    }
  }

}