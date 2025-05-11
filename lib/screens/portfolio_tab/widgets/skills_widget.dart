import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SkillsWidget extends StatefulWidget {
  final String userId;
  final bool isViewer;

  const SkillsWidget({super.key, required this.userId, required this.isViewer});

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
            decoration: const InputDecoration(
              hintText: 'Enter skill (e.g., Flutter)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add'),
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
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSkillDialog(DocumentReference skillDoc, String skillName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Skill'),
          content: Text('Are you sure you want to delete "$skillName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                await skillDoc.delete();
                Navigator.of(context).pop();
              },
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
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Skills',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if(!widget.isViewer)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddSkillDialog,
                  tooltip: 'Add Skill',
                ),
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
                  return const Center(child: CircularProgressIndicator());
                }

                final skillDocs = snapshot.data!.docs;

                if (skillDocs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No skills added yet.'),
                  );
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skillDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final skill = data['skill'] ?? '';

                    return widget.isViewer
                        ? InputChip(
                      label: Text(skill),
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[900]?.withOpacity(0.3)
                          : Colors.blue[50],
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[100]
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    )
                        : InputChip(
                      label: Text(skill),
                      onDeleted: () => _showDeleteSkillDialog(doc.reference, skill),
                      deleteIcon: const Icon(Icons.close),
                      deleteButtonTooltipMessage: 'Delete skill',
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[900]?.withOpacity(0.3)
                          : Colors.blue[50],
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[100]
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
