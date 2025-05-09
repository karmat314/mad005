import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mad005/helper/auth_service.dart';
import 'DashboardScreen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 500);

  // AuthService instance
  AuthService get authService => AuthService();

  /// Login with Firebase
  Future<String?> _authUser(LoginData data) async {
    debugPrint('Login attempt: ${data.name}, Password: ${data.password}');
    final errorMessage = await authService.signInWithEmailPassword(
      data.name.trim(),
      data.password.trim(),
    );

    if (errorMessage == null) {
      // Login successful
      return null; // flutter_login treats `null` as success
    } else {
      // Login failed
      return "Failed to login";
    }
  }



  /// Signup with Firebase
  Future<String?> _signupUser(SignupData data) async {
    debugPrint('Signup attempt: ${data.name}, Password: ${data.password}');
    if (data.name == null || data.password == null) {
      return 'Email and password cannot be empty';
    }

    final result = await authService.registerWithEmailPassword(
      data.name!.trim(),
      data.password!.trim(),
    );

    if (result == true) {
      // Signup successful
      return null;
    } else {
      // Signup failed
      return result.toString();
    }
  }

  /// Dummy Recover password (optional: integrate Firebase reset later)
  Future<String?> _recoverPassword(String name) async {
    debugPrint('Recover password for: $name');

    // You can later integrate Firebase "sendPasswordResetEmail" here
    await Future.delayed(loginTime);
    return 'Password reset link sent (dummy)'; // For now just dummy
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Login Screen',
      theme: LoginTheme(
        primaryColor: Colors.white,
        buttonStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
        cardTheme: CardTheme(
          color: Colors.lightBlueAccent.shade100,
          elevation: 5,
          margin: const EdgeInsets.only(top: 15),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
      ),
      onLogin: _authUser,
      onSignup: _signupUser,
      onRecoverPassword: _recoverPassword,

      // Navigate to Dashboard if login/signup success
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      },

      // Optional: Social logins (not wired to Firebase here)
      loginProviders: <LoginProvider>[
        LoginProvider(
          icon: FontAwesomeIcons.google,
          label: 'Google',
          callback: () async {
            debugPrint('start google sign in');
            await Future.delayed(loginTime);
            debugPrint('stop google sign in');
            return null;
          },
        ),
        LoginProvider(
          icon: FontAwesomeIcons.facebook,
          label: 'Facebook',
          callback: () async {
            debugPrint('start facebook sign in');
            await Future.delayed(loginTime);
            debugPrint('stop facebook sign in');
            return null;
          },
        ),
        LoginProvider(
          icon: FontAwesomeIcons.battleNet,
          label: 'NDI',
          callback: () async {
            debugPrint('start NDI sign in');
            await Future.delayed(loginTime);
            debugPrint('stop NDI sign in');
            return null;
          },
        ),
      ],
    );
  }
}
