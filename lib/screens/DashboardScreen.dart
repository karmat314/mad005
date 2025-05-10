import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mad005/screens/document_scan_tab/DocumentScanScreen.dart';
import 'package:mad005/screens/home_tab/HomeScreen.dart';
import 'package:mad005/screens/portfolio_tab/PortfolioScreen.dart';
import 'package:mad005/screens/settings_tab/SettingsScreen.dart';

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
          ),
          drawer: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage('assets/worldskill.png')),
                    title: Text('TVET Connect'),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home, size: 30,),
                  title: const Text('Home'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                ),
                ListTile(
                  leading: Icon(Icons.document_scanner, size: 30,),
                  title: const Text('Scan Docs'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                ),ListTile(
                  leading: Icon(Icons.portrait_rounded, size: 30,),
                  title: const Text('Portfolio'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                ),ListTile(
                  leading: Icon(Icons.quiz_rounded, size: 30,),
                  title: const Text('Quizzes'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                ),ListTile(
                  leading: Icon(Icons.settings, size: 30,),
                  title: const Text('Settings'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                ),


                ListTile(
                  leading: Icon(Icons.logout),
                  title: const Text('Log out'),
                  onTap: () {
                    authService.signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ));
                  },
                ),
              ],
            ),
          ),
          body: TabBarView(
              children: [
                HomeScreen(
                ),
                const DocumentScanScreen(),
                const PortfolioScreen(),
                const Icon(Icons.settings),
                const SettingsPage(),
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