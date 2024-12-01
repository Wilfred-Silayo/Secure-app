import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';
import '../utils/snackbar.dart';
import './storage_services.dart';
import 'package:flutter/services.dart';

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> hasBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  // Function to authenticate using biometric
  Future<bool> authenticateWithBiometrics(BuildContext context) async {
    try {
      // Check if the user is registered
      final credentials = await SecureStorageService.getCredentials();

      if (credentials['username'] == null ||
          credentials['username']!.isEmpty ||
          credentials['password'] == null ||
          credentials['password']!.isEmpty) {
        showSnackBar(context, 'Please register first before using biometrics');

        return false;
      }
      final isAvailable = await hasBiometrics();
      if (!isAvailable) {
        return false;
      }
      bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      return isAuthenticated;
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

// Function to validate save user credentials
  Future<bool> saveCredentials(String username, String password) async {
    try {
      await SecureStorageService.saveCredentials(username, password);
      return true;
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  // Function to validate username and password
  Future<bool> checkCredentials(
      BuildContext context, String username, String password) async {
    try {
      // Check if the user is registered
      final credentials = await SecureStorageService.getCredentials();

      if (credentials['username'] == null ||
          credentials['username']!.isEmpty ||
          credentials['password'] == null ||
          credentials['password']!.isEmpty) {
        showSnackBar(context, 'Please register first before using biometrics');

        return false;
      }
      return username == credentials[username] &&
          password == credentials[password];
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }
}
