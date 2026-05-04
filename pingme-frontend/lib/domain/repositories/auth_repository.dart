import '../../domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<bool> sendOtp(String identifier, String method);
  Future<String?> verifyOtp(String identifier, String otp);
  Future<UserEntity?> register({
    required String username,
    required String displayName,
    String? bio,
  });
  Future<void> logout();
  Future<bool> isAuthenticated();
}
