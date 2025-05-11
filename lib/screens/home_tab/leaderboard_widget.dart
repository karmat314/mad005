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
            points += (doc['totalPoints'] ?? 0) as int;  // Add points from each quiz
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Your total points: $totalPoints",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
