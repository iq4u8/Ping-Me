import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

class KeyManager {
  static final KeyManager _instance = KeyManager._internal();
  factory KeyManager() => _instance;
  KeyManager._internal();

  final _storage = const FlutterSecureStorage();

  Future<void> initializeKeys() async {
    final hasKeys = await _storage.containsKey(key: 'identity_key_public');
    if (!hasKeys) {
      await _generateAndStoreKeys();
    }
  }

  Future<void> _generateAndStoreKeys() async {
    // 5.1.4 Generate Identity Key Pair
    final identityKeyPair = generateIdentityKeyPair();
    final registrationId = generateRegistrationId(false);

    // 5.1.5 Generate Signed Pre-Key
    final signedPreKey = generateSignedPreKey(identityKeyPair, 0);

    // 5.1.6 Generate 100 One-Time Pre-Keys
    final preKeys = generatePreKeys(0, 100);

    // 5.1.7 Store in Secure Storage
    await _storage.write(key: 'registration_id', value: registrationId.toString());
    await _storage.write(
      key: 'identity_key_public',
      value: base64Encode(identityKeyPair.getPublicKey().serialize()),
    );
    await _storage.write(
      key: 'identity_key_private',
      value: base64Encode(identityKeyPair.getPrivateKey().serialize()),
    );
    
    await _storage.write(
      key: 'signed_pre_key_public',
      value: base64Encode(signedPreKey.getKeyPair().publicKey.serialize()),
    );
    
    // Store pre-keys as JSON blob (simplified for demo)
    final preKeysJson = preKeys.map((pk) => {
      'id': pk.id,
      'public': base64Encode(pk.getKeyPair().publicKey.serialize()),
    }).toList();
    
    await _storage.write(key: 'pre_keys', value: jsonEncode(preKeysJson));
  }

  Future<String?> getPublicKey() async => await _storage.read(key: 'identity_key_public');
}
