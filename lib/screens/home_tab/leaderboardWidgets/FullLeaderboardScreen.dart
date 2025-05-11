import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullLeaderboardScreen extends StatefulWidget {
  const FullLeaderboardScreen({super.key});
  @override
  _FullLeaderboardScreenState createState() => _FullLeaderboardScreenState();
}

class _FullLeaderboardScreenState extends State<FullLeaderboardScreen> {




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Text("data")
    );
  }

}