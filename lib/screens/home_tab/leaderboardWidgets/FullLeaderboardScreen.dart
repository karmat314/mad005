import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'leaderboard_highlights_widget.dart';
import 'leaderboard_item.dart';

class FullLeaderboardScreen extends StatefulWidget {
  const FullLeaderboardScreen({super.key});
  @override
  _FullLeaderboardScreenState createState() => _FullLeaderboardScreenState();
}

class _FullLeaderboardScreenState extends State<FullLeaderboardScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String totalPoints = "Loading...";
  List<LeaderboardUser> allUsers = []; // Holds top 3 users

  @override
  void initState() {
    super.initState();
    getAllUsers(); // Fetch top 3 users
  }
  Future<void> getAllUsers() async {
    try {
      final usersSnapshot = await db.collection('users').get();

      List<LeaderboardUser> usersList = [];

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;

        // Fetch profile/about document to get name
        final aboutDocRef = db
            .collection('users')
            .doc(userId)
            .collection('profile')
            .doc('about');

        final aboutDoc = await aboutDocRef.get();

        String userName = "Unknown";
        if (aboutDoc.exists && aboutDoc.data() != null) {
          userName = aboutDoc.data()!['name'] ?? "Unknown";
        }

        // Fetch attemptedQuizzes and sum totalPoints
        final attemptedQuizzesRef = db
            .collection('users')
            .doc(userId)
            .collection('attemptedQuizzes');

        final quizzesSnapshot = await attemptedQuizzesRef.get();

        int points = 0;
        for (var quizDoc in quizzesSnapshot.docs) {
          points += (quizDoc['totalPoints'] ?? 0) as int;
        }

        usersList.add(LeaderboardUser(
          userId: userId,
          name: userName,
          totalPoints: points,
        ));
      }

      // Sort by points descending and take top 3
      usersList.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
      setState(() {
        allUsers = usersList;
      });
    } catch (e) {
      print("Error fetching all users: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Padding(
          padding: EdgeInsets.all(20),
        child: Column(
          children: [
            if (allUsers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Loading leaderboard..."),
              )
            else
              ...allUsers.asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;
                final isCurrentUser =
                    user.userId == FirebaseAuth.instance.currentUser?.uid;

                return Card(
                  child: LeaderBoardItem(
                    rank: index + 1,
                    name: user.name,
                    points: user.totalPoints,
                    isCurrentUser: isCurrentUser,
                    isFullLeaderboard: true,
                  ),
                );
              }),

          ],
        ),
      )
    );
  }

}