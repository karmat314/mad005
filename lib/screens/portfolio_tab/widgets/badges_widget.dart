import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BadgesWidget extends StatefulWidget {
  final String userId;

  const BadgesWidget({super.key, required this.userId});
  @override
  _BadgesWidgetState createState() => _BadgesWidgetState();
}

class _BadgesWidgetState extends State<BadgesWidget> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> achievementQuizzes = [];

  @override
  void initState() {
    super.initState();
    getAllQuizzesWithAchievements();
  }

  Future<void> getAllQuizzesWithAchievements() async {
    try {
      final attemptedQuizzesRef = db
          .collection('users')
          .doc(widget.userId)
          .collection('attemptedQuizzes');

      final quizzesSnapshot = await attemptedQuizzesRef.get();

      List<Map<String, dynamic>> achievementList = [];

      for (var quizDoc in quizzesSnapshot.docs) {
        if (quizDoc['achievementAwarded'] == true) {
          achievementList.add({
            'userId': widget.userId,
            'quizTitle': quizDoc['quizTitle'],
            'timestamp': quizDoc['timestamp'],
          });
        }
      }

      setState(() {
        achievementQuizzes = achievementList;
      });
    } catch (e) {
      print("Error fetching achievements: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            achievementQuizzes.isEmpty
                ? const Center(child: Text('No achievements yet.'))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievementQuizzes.length,
              itemBuilder: (context, index) {
                final quiz = achievementQuizzes[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.emoji_events, color: Colors.amber),
                    title: Text(quiz['quizTitle']),
                    trailing: Text(
                      quiz['timestamp'] != null
                          ? (quiz['timestamp'] as Timestamp).toDate().toString().split(' ').first
                          : '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
