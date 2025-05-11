import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({super.key});

  @override
  _LeaderboardWidgetState createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String totalPoints = "Loading..."; // Initialize as loading state.

  // Fetch the user's total points by summing the points from each quiz in attemptedquizes
  Future<void> getTotalPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      try {
        final attemptedQuizzesRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('attemptedQuizzes');

        final querySnapshot = await attemptedQuizzesRef.get();

        if (querySnapshot.docs.isNotEmpty) {
          int points = 0;

          for (var doc in querySnapshot.docs) {
            // Assuming 'totalPoints' is a field in each quiz document
            points +=
                (doc['totalPoints'] ?? 0) as int; // Add points from each quiz
          }

          setState(() {
            totalPoints = points.toString(); // Update with the total sum
          });
        } else {
          setState(() {
            totalPoints = "No quizzes attempted yet";
          });
        }
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

  @override
  void initState() {
    super.initState();
    getTotalPoints(); // Fetch points when the widget is initialized.
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
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              ],
            ),
            const SizedBox(height: 16),

            // Top 3 Leaderboard with medals
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Leaderboard Highlights",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                _buildLeaderboardItem(
                  rank: 1,
                  name: "Alex Johnson",
                  points: 1245,
                ),
                _buildLeaderboardItem(
                  rank: 2,
                  name: "Sam Wilson",
                  points: 1120,
                ),
                _buildLeaderboardItem(rank: 3, name: "Karma", points: 980),
              ],
            ),

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
                color:
                    isCurrentUser ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ),
          Chip(
            backgroundColor:
                isCurrentUser
                    ? colorScheme.primary.withOpacity(0.1)
                    : colorScheme.surfaceContainerHighest,
            label: Text(
              "$points pts",
              style: TextStyle(
                color:
                    isCurrentUser
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
