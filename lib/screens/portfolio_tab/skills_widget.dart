import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SkillsWidget extends StatefulWidget {
  final String userId;

  const SkillsWidget({super.key, required this.userId});

  @override
  State<SkillsWidget> createState() => _SkillsWidgetState();
}

class _SkillsWidgetState extends State<SkillsWidget> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  void _showAddSkillDialog() {
    final _skillController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Skill'),
          content: TextField(
            controller: _skillController,
            decoration: const InputDecoration(hintText: 'Enter skill (e.g., Flutter)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final skillText = _skillController.text.trim();
                if (skillText.isNotEmpty) {
                  final skillsRef = db
                      .collection('users')
                      .doc(widget.userId)
                      .collection('skills');

                  await skillsRef.add({'skill': skillText});

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final skillsRef = db
        .collection('users')
        .doc(widget.userId)
        .collection('skills');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Skills',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddSkillDialog,
                )
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: skillsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final skillDocs = snapshot.data!.docs;

                if (skillDocs.isEmpty) {
                  return const Text('No skills added yet.');
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: skillDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final skill = data['skill'] ?? '';

                    return Chip(
                      label: Text(skill),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
