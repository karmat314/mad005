import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({super.key});

  @override
  _LeaderboardWidgetState createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String totalPoints = "Loading...";
  List<LeaderboardUser> topUsers = []; // Holds top 3 users

  @override
  void initState() {
    super.initState();
    getUserTotalPoints();
    getTopUsers(); // Fetch top 3 users
  }

  Future<void> getUserTotalPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      try {
        final attemptedQuizzesRef = db
            .collection('users')
            .doc(userId)
            .collection('attemptedQuizzes');

        final querySnapshot = await attemptedQuizzesRef.get();

        int points = 0;
        for (var doc in querySnapshot.docs) {
          points += (doc['totalPoints'] ?? 0) as int;
        }

        setState(() {
          totalPoints = points.toString();
        });
      } catch (e) {
        setState(() {
          totalPoints = "Error fetching points";
        });
        print("Error: $e");
      }
    } else {
      setState(() {
        totalPoints = "User not logged in";
      });
    }
  }

  Future<void> getTopUsers() async {
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
      final topThree = usersList.take(3).toList();

      setState(() {
        topUsers = topThree;
      });
    } catch (e) {
      print("Error fetching top users: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your total points",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              totalPoints,
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text("Keep completing quizzes to earn more!"),
            const SizedBox(height: 16),

            // Top 3 Leaderboard Highlights
            Text(
              "Leaderboard Highlights",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (topUsers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Loading leaderboard..."),
              )
            else
              ...topUsers.asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;
                final isCurrentUser =
                    user.userId == FirebaseAuth.instance.currentUser?.uid;

                return _buildLeaderboardItem(
                  rank: index + 1,
                  name: user.name,
                  points: user.totalPoints,
                  isCurrentUser: isCurrentUser,
                );
              }),

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to full leaderboard
                },
                child: Text(
                  "View Full Leaderboard",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required int points,
    bool isCurrentUser = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              "$rank",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                color: isCurrentUser
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
          ),
          Chip(
            backgroundColor: isCurrentUser
                ? colorScheme.primary.withOpacity(0.1)
                : colorScheme.surfaceContainerHighest,
            label: Text(
              "$points pts",
              style: TextStyle(
                color: isCurrentUser
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardUser {
  final String userId;
  final String name;
  final int totalPoints;

  LeaderboardUser({
    required this.userId,
    required this.name,
    required this.totalPoints,
  });
}
