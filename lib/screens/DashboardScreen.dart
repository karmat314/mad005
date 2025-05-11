import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mad005/screens/document_scan_tab/DocumentScanScreen.dart';
import 'package:mad005/screens/home_tab/HomeScreen.dart';
import 'package:mad005/screens/portfolio_tab/PortfolioScreen.dart';
import 'package:mad005/screens/quiz_tab/QuizzesScreen.dart';
import 'package:mad005/screens/settings_tab/SettingsScreen.dart';

import '../helper/auth_service.dart';
import 'LoginScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  AuthService get authService => AuthService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: AssetImage('assets/worldskill.png')),
                  title: Text('TVET Connect'),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, size: 30),
                title: const Text('Home'),
                onTap: () {
                  _tabController.animateTo(0); // Switch to Home tab
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.document_scanner, size: 30),
                title: const Text('Scan Docs'),
                onTap: () {
                  _tabController.animateTo(1); // Switch to Scan Docs tab
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.portrait_rounded, size: 30),
                title: const Text('Portfolio'),
                onTap: () {
                  _tabController.animateTo(2); // Switch to Portfolio tab
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.quiz_rounded, size: 30),
                title: const Text('Quizzes'),
                onTap: () {
                  _tabController.animateTo(3); // Switch to Quizzes tab
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, size: 30),
                title: const Text('Settings'),
                onTap: () {
                  _tabController.animateTo(4); // Switch to Settings tab
                  Navigator.pop(context);
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
          controller: _tabController, // Use the controller here
          children: [
            HomeScreen(tabController: _tabController), // Pass TabController here
            const DocumentScanScreen(),
            const PortfolioScreen(isViewer: false,),
            const QuizScreen(),
            const SettingsPage(),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: TabBar(
            controller: _tabController, // Use the controller here
            tabs: [
              Icon(Icons.home, size: 30),
              Icon(Icons.document_scanner, size: 30),
              Icon(Icons.portrait_rounded, size: 30),
              Icon(Icons.quiz_rounded, size: 30),
              Icon(Icons.settings, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}

