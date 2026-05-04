import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _storage = const FlutterSecureStorage();

  @override
  Future<bool> sendOtp(String identifier, String method) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<String?> verifyOtp(String identifier, String otp) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (otp == "000000") {
      const token = "mock_jwt_token";
      await _storage.write(key: 'access_token', value: token);
      return token;
    }
    return null;
  }

  @override
  Future<UserEntity?> register({
    required String username,
    required String displayName,
    String? bio,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return UserEntity(
      id: "uuid-123",
      username: username,
      displayName: displayName,
      bio: bio,
    );
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _storage.containsKey(key: 'access_token');
  }
}
