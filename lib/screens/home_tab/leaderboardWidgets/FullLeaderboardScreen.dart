import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'leaderboard_item.dart';

// LeaderboardUser model
class LeaderboardUser {
  final String userId;
  final String name;
  final int totalPoints;
  final String jobTitle;  // <-- jobTitle field

  LeaderboardUser({
    required this.userId,
    required this.name,
    required this.totalPoints,
    required this.jobTitle,
  });
}

class FullLeaderboardScreen extends StatefulWidget {
  const FullLeaderboardScreen({super.key});
  @override
  _FullLeaderboardScreenState createState() => _FullLeaderboardScreenState();
}

class _FullLeaderboardScreenState extends State<FullLeaderboardScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  List<LeaderboardUser> allUsers = [];

  String searchQuery = '';
  String selectedJobTitle = 'All';
  List<String> jobTitles = ['All'];

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  Future<void> getAllUsers() async {
    try {
      final usersSnapshot = await db.collection('users').get();

      List<LeaderboardUser> usersList = [];

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;

        final aboutDocRef = db
            .collection('users')
            .doc(userId)
            .collection('profile')
            .doc('about');

        final aboutDoc = await aboutDocRef.get();

        String userName = "Unknown";
        String userJobTitle = "Unknown";

        if (aboutDoc.exists && aboutDoc.data() != null) {
          userName = aboutDoc.data()!['name'] ?? "Unknown";
          userJobTitle = aboutDoc.data()!['jobTitle'] ?? "Unknown";
        }

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
          jobTitle: userJobTitle,
        ));
      }

      // Sort by points descending
      usersList.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

      // Extract unique jobTitles
      final jobTitleSet = {'All'};
      for (var user in usersList) {
        if (user.jobTitle.isNotEmpty) {
          jobTitleSet.add(user.jobTitle);
        }
      }

      setState(() {
        allUsers = usersList;
        jobTitles = jobTitleSet.toList();
      });
    } catch (e) {
      print("Error fetching all users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = allUsers.where((user) {
      final matchesName = user.name.toLowerCase().contains(searchQuery);
      final matchesJobTitle =
          selectedJobTitle == 'All' || user.jobTitle == selectedJobTitle;
      return matchesName && matchesJobTitle;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 12),

            // Filter dropdown
            DropdownButtonFormField<String>(
              value: selectedJobTitle,
              decoration: InputDecoration(
                labelText: 'Filter by job title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: jobTitles.map((title) {
                return DropdownMenuItem(
                  value: title,
                  child: Text(title),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedJobTitle = value!;
                });
              },
            ),
            const SizedBox(height: 12),

            // Leaderboard list
            if (allUsers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Loading leaderboard..."),
              )
            else if (filteredUsers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("No users found."),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isCurrentUser = user.userId == FirebaseAuth.instance.currentUser?.uid;

                    return Card(
                      child: LeaderBoardItem(
                        rank: index + 1,
                        name: user.name,
                        points: user.totalPoints,
                        isCurrentUser: isCurrentUser,
                        isFullLeaderboard: true,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
