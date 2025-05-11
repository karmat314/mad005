import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mad005/screens/portfolio_tab/widgets/work_history_form.dart';

class WorkHistoryWidget extends StatefulWidget {
  final String userId;
  final bool isViewer;

  const WorkHistoryWidget({
    super.key,
    required this.userId,
    required this.isViewer,
  });

  @override
  _WorkHistoryWidgetState createState() => _WorkHistoryWidgetState();
}

class _WorkHistoryWidgetState extends State<WorkHistoryWidget> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Delete work history item
  void _deleteWorkHistory(String workHistoryId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await db
        .collection('users')
        .doc(userId)
        .collection('work_history')
        .doc(workHistoryId)
        .delete();
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Work History'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference workHistoryRef = db
        .collection('users')
        .doc(widget.userId)
        .collection('work_history');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              'Work History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: workHistoryRef.orderBy('time', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final workHistoryDocs = snapshot.data!.docs;

                if (workHistoryDocs.isEmpty) {
                  return const Text('No work history added yet.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workHistoryDocs.length,
                  itemBuilder: (context, index) {
                    final doc = workHistoryDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'] ?? '';
                    final company = data['company'] ?? '';
                    final time = data['time'] ?? '';
                    final description = data['description'] ?? '';
                    final workHistoryId = doc.id;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Add an Icon to represent the job title (for example, a briefcase icon)
                            Icon(
                              Icons.work,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.titleLarge!.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    company,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).textTheme.bodyLarge!.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).textTheme.titleSmall!.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).textTheme.bodyMedium!.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Edit and Delete buttons
                            Column(
                              children: [
                                if(!widget.isViewer)
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AddWorkHistoryForm(workHistoryId: workHistoryId),
                                    );
                                  },
                                ),
                                if(!widget.isViewer)
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final shouldDelete = await _showDeleteConfirmationDialog(context);
                                    if (shouldDelete) {
                                      _deleteWorkHistory(workHistoryId);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddWorkHistoryForm(),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Work History'),
            )
          ],
        ),
      ),
    );
  }
}
