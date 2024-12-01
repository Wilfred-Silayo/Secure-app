import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SecureStorageService {
  
  static const _storage = FlutterSecureStorage();

  // Fetch keys from the .env file
  static final _usernameKey = dotenv.env['USERNAME_KEY']!;
  static final _passwordKey = dotenv.env['PASSWORD_KEY']!;

  /// Save username and password
  static Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _passwordKey, value: password);
  }

  /// Get username and password
  static Future<Map<String, String?>> getCredentials() async {
    String? username = await _storage.read(key: _usernameKey);
    String? password = await _storage.read(key: _passwordKey);
    return {'username': username, 'password': password};
  }

  /// Clear all credentials
  static Future<void> clearCredentials() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
  }
}
