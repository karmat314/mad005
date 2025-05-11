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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Quizzes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('quizzes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading quizzes'));
          }

          final quizDocs = snapshot.data?.docs ?? [];

          if (quizDocs.isEmpty) {
            return const Center(child: Text('No quizzes available'));
          }

          return ListView.builder(
            itemCount: quizDocs.length,
            itemBuilder: (context, index) {
              final quiz = quizDocs[index];
              final title = quiz['title'] ?? 'No title';
              final description = quiz['description'] ?? 'No description';
              final difficulty = quiz['difficulty'] ?? 'Unknown';

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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                        future:
                            db
                                .collection('quizzes')
                                .doc(quiz.id)
                                .collection('questions')
                                .get(),
                        builder: (context, questionSnapshot) {
                          if (questionSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Loading questions...');
                          }

                          if (questionSnapshot.hasError) {
                            return const Text('Error loading questions');
                          }

                          final questionCount =
                              questionSnapshot.data?.docs.length ?? 0;
                          final totalPoints = questionCount * 10;

                          return Text(
                            '$questionCount questions • $totalPoints points',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            final questionsSnapshot =
                                await db
                                    .collection('quizzes')
                                    .doc(quiz.id)
                                    .collection('questions')
                                    .get();

                            final questions =
                                questionsSnapshot.docs
                                    .map((doc) => doc.data())
                                    .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => TakeQuizScreen(
                                      quizTitle: quiz['title'],
                                      questions: questions,
                                    ),
                              ),
                            );
                          },
                          child: const Text('Take Quiz'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Optional: color the difficulty text
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
