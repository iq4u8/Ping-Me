import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/crypto/key_manager.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final KeyManager _keyManager = KeyManager();

  AuthViewModel(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  Future<bool> login(String identifier) async {
    _setLoading(true);
    final success = await _repository.sendOtp(identifier, "phone");
    _setLoading(false);
    return success;
  }

  Future<bool> verify(String identifier, String otp) async {
    _setLoading(true);
    final token = await _repository.verifyOtp(identifier, otp);
    if (token != null) {
      // 5.1 Initialize E2EE Keys on successful login
      await _keyManager.initializeKeys();
    }
    _setLoading(false);
    return token != null;
  }

  Future<void> completeProfile(String username, String display) async {
    _setLoading(true);
    _currentUser = await _repository.register(username: username, displayName: display);
    _setLoading(false);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
