import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mad005/screens/home_tab/leaderboardWidgets/FullLeaderboardScreen.dart';

import 'leaderboard_item.dart';

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({super.key});

  @override
  _LeaderboardWidgetState createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String totalPoints = "Loading...";
  List<LeaderboardUser> topUsers = [];
  List<LeaderboardUser> allUsers = [];// Holds top 3 users

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
            // Total points title
            Text(
              "Your Total Points",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Total points value
            Text(
              totalPoints,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Keep completing quizzes to earn more!",
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            // Leaderboard title
            Text(
              "Leaderboard Highlights",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Header row
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    "Rank",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Points",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, height: 16),

            // Leaderboard items
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

                final rank = index + 1;

                // Medal icon for top 3
                Widget rankWidget;
                if (rank == 1) {
                  rankWidget = Icon(Icons.emoji_events, color: Colors.amber, size: 24);
                } else if (rank == 2) {
                  rankWidget = Icon(Icons.emoji_events, color: Colors.grey, size: 24);
                } else if (rank == 3) {
                  rankWidget = Icon(Icons.emoji_events, color: Colors.brown, size: 24);
                } else {
                  rankWidget = Text(
                    '$rank',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Center(child: rankWidget)),
                      Expanded(
                        flex: 3,
                        child: Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentUser ? colorScheme.primary : null,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          user.totalPoints.toString(),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentUser ? colorScheme.primary : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullLeaderboardScreen(),
                    ),
                  );
                },
                child: Text(
                  "View Full Leaderboard",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
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
