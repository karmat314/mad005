import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helper/auth_service.dart';
import 'LoginScreen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  AuthService get authService => AuthService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
          appBar: AppBar(
            title: Text("Notes"),
          ),
          drawer: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text('Drawer Header'),
                ),
                ListTile(
                  title: const Text('Item 1'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                ),
                ListTile(
                  title: const Text('Item 2'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    authService.signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ));
                  },
                  child: Text("Log out"),
                )
              ],
            ),
          ),
          body: const TabBarView(
              children: [
                Icon(Icons.settings),
                // Add other tabs here
              ]
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: TabBar(
              tabs: [
                Icon(Icons.home, size: 30,),
                Icon(Icons.document_scanner, size: 30),
                Icon(Icons.portrait_rounded, size: 30),
                Icon(Icons.quiz_rounded, size: 30),
                Icon(Icons.settings, size: 30),
              ],
            ),
          )
      ),
    );
  }
}