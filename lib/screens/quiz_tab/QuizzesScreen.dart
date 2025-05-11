import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'TakeQuizScreen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  List<Map<String, dynamic>> attemptedQuizzes = [];
  List<String> attemptedQuizTitles = [];

  @override
  void initState() {
    super.initState();
    fetchAttemptedQuizzes();
  }

  Future<void> fetchAttemptedQuizzes() async {
    final snapshot = await db
        .collection('users')
        .doc(userId)
        .collection('attemptedQuizzes')
        .get();

    final attempts = snapshot.docs.map((doc) {
      return {
        'quizTitle': doc['quizTitle'],
        'totalPoints': doc['totalPoints'],
        'timestamp': doc['timestamp'],
      };
    }).toList();

    setState(() {
      attemptedQuizzes = attempts;
      attemptedQuizTitles = attempts.map((e) => e['quizTitle'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quizzes'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Available Quizzes'),
              Tab(text: 'My History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildQuizList(showAttempted: false),
            buildQuizList(showAttempted: true),
          ],
        ),
      ),
    );
  }

  Widget buildQuizList({required bool showAttempted}) {
    return StreamBuilder<QuerySnapshot>(
      stream: db.collection('quizzes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading quizzes'));
        }

        final quizDocs = snapshot.data?.docs ?? [];

        // Filter based on attempted / available
        final filteredQuizzes = quizDocs.where((quiz) {
          final title = quiz['title'] ?? '';
          return showAttempted
              ? attemptedQuizTitles.contains(title)
              : !attemptedQuizTitles.contains(title);
        }).toList();

        if (filteredQuizzes.isEmpty) {
          return Center(
            child: Text(showAttempted
                ? 'No quiz history yet'
                : 'No quizzes available'),
          );
        }

        return ListView.builder(
          itemCount: filteredQuizzes.length,
          itemBuilder: (context, index) {
            final quiz = filteredQuizzes[index];
            final title = quiz['title'] ?? '';
            final description = quiz['description'] ?? '';
            final difficulty = quiz['difficulty'] ?? 'Unknown';

            final attempt = attemptedQuizzes.firstWhere(
                  (a) => a['quizTitle'] == title,
              orElse: () => {},
            );

            final scoredPoints = attempt['totalPoints'] ?? 0;
            final attemptDate = attempt['timestamp'] != null
                ? (attempt['timestamp'] as Timestamp).toDate().toString().split(' ').first
                : '';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(description),
                    const SizedBox(height: 8),
                    Text(
                      'Difficulty: $difficulty',
                      style: TextStyle(
                        color: difficultyColor(difficulty),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<QuerySnapshot>(
                      future: db
                          .collection('quizzes')
                          .doc(quiz.id)
                          .collection('questions')
                          .get(),
                      builder: (context, questionSnapshot) {
                        if (questionSnapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Loading questions...');
                        }

                        if (questionSnapshot.hasError) {
                          return const Text('Error loading questions');
                        }

                        final questionCount = questionSnapshot.data?.docs.length ?? 0;
                        final totalPoints = questionCount * 10;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$questionCount questions • $totalPoints points',
                                style: const TextStyle(fontStyle: FontStyle.italic)),
                            if (showAttempted)
                              Text('You scored: $scoredPoints points on $attemptDate',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final questionsSnapshot = await db
                              .collection('quizzes')
                              .doc(quiz.id)
                              .collection('questions')
                              .get();

                          final questions = questionsSnapshot.docs.map((doc) => doc.data()).toList();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TakeQuizScreen(
                                quizTitle: quiz['title'],
                                questions: questions,
                              ),
                            ),
                          );
                        },
                        child: Text(showAttempted ? 'Retake Quiz' : 'Take Quiz'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
