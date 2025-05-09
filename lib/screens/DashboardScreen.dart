import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helper/auth_service.dart';
import 'LoginScreen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  AuthService get authService => AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard"),),
      body: ElevatedButton(
          onPressed: () {
            authService.signOut();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ));
          },
          child: Text("Log out")
      ),
    );
  }
}