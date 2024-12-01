import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_app/screens/register_screen.dart';

import '../controllers/auth_provider.dart';
import '../utils/snackbar.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isBiometricLogin =
      false; // Toggle between biometric and credentials login

  void _login() async {
    if (isBiometricLogin) {
      // Use biometric authentication
      bool isAuthenticated = await ref
          .read(authProvider.notifier)
          .authenticateWithBiometrics(context);
      if (isAuthenticated) {
        showSnackBar(context, 'Login successfully with Biometrics');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        showSnackBar(context, 'Biometric authentication failed');
      }
    } else {
      // Use username and password authentication
      String username = _usernameController.text;
      String password = _passwordController.text;

      // Validate credentials against secure storage
      bool credentialsValid = await ref
          .read(authProvider.notifier)
          .checkCredentials(context, username, password);

      _usernameController.text='';
      _passwordController.text='';

      if (credentialsValid) {
        showSnackBar(context, 'Login Successful with Credentials');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        showSnackBar(context, 'Invalid credentials');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Switch between login modes
            SwitchListTile(
              title: Text(
                  isBiometricLogin ? 'Biometric Login' : 'Credentials Login'),
              value: isBiometricLogin,
              onChanged: (value) {
                setState(() {
                  isBiometricLogin = value;
                });
              },
            ),
            // If the mode is credentials login, show the username and password fields
            if (!isBiometricLogin) ...[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
                ),
              ),
              child: const Text(
                'Dont\'t have an account? Register here',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text(isBiometricLogin
                  ? 'Authenticate with Biometrics'
                  : 'Login with Credentials'),
            ),
          ],
        ),
      ),
    );
  }
}
