import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../document_scan_tab/DocumentScanScreen.dart';
import 'core_feature_widget.dart';

class HomeScreen extends StatefulWidget {
  final TabController tabController;

  const HomeScreen({super.key, required this.tabController});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text("Your points balance"),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text("Leaderboard"),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text("Grow our career"),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text("Stay Updated"),
              ),
            ),
          ),
          Text(
            "Core features",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // Two columns
              padding: const EdgeInsets.all(16.0),
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              children: <Widget>[
                FeatureWidget(
                  icon: Icons.document_scanner,
                  title: 'Document Scanner',
                  subtitle: 'Organize IDs & Certs',
                  onTap: () {
                    widget.tabController.animateTo(1); // Switch to Scan Docs tab
                  },
                ),
                FeatureWidget(
                  icon: Icons.portrait_rounded,
                  title: 'Portfolio',
                  subtitle: 'Manage your portfolio',
                  onTap: () {
                    widget.tabController.animateTo(2); // Switch to Scan Docs tab
                  },
                ),
                // Add more features here if needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}

