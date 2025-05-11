import 'package:flutter/material.dart';

class TakeQuizScreen extends StatefulWidget {
  final String quizTitle;
  final List<Map<String, dynamic>> questions;

  const TakeQuizScreen({
    super.key,
    required this.quizTitle,
    required this.questions,
  });

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  int currentIndex = 0;
  Map<int, String> selectedAnswers = {}; // Track selected answers by question index

  int correctAnswers = 0;
  int totalPoints = 0;

  // Navigate to the next question
  void nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void updateScore() {
    int correct = 0;
    int points = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final correctAnswer = widget.questions[i]['correctanswer'];
      final userAnswer = selectedAnswers[i];

      if (userAnswer == correctAnswer) {
        correct++;
        points += 10;
      }
    }

    setState(() {
      correctAnswers = correct;
      totalPoints = points;
    });
  }


  // Navigate to the previous question
  void previousQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentIndex];
    final questionText = question['text'];
    final options = List<String>.from(question['options']);
    final correctanswer = question['correctanswer'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentIndex + 1} of ${widget.questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(
              questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...options.map((option) {
              final isSelected = selectedAnswers[currentIndex] == option;

              return Card(
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(option),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : const Icon(Icons.circle_outlined),
                  onTap: () {
                    setState(() {
                      selectedAnswers[currentIndex] = option;
                    });
                  },
                ),
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentIndex > 0 ? previousQuestion : null,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateScore(); // update correctAnswers & totalPoints

                    if (currentIndex < widget.questions.length - 1) {
                      nextQuestion();
                    } else {
                      print(selectedAnswers);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Quiz Finished'),
                          content: Text(
                            'You correctly answered $correctAnswers out of ${widget.questions.length} questions.\n\n'
                                'Total Points: $totalPoints',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.popUntil(context, (route) => route.isFirst);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Text(currentIndex < widget.questions.length - 1 ? 'Next' : 'Finish'),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
