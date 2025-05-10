import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mad005/screens/portfolio_tab/work_history_form.dart';

class WorkHistoryWidget extends StatefulWidget {
  final String userId; // Pass the user ID so we know whose work history to fetch

  const WorkHistoryWidget({
    super.key,
    required this.userId,
  });

  @override
  _WorkHistoryWidgetState createState() => _WorkHistoryWidgetState();
}

class _WorkHistoryWidgetState extends State<WorkHistoryWidget> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    CollectionReference workHistoryRef = db
        .collection('users')
        .doc(widget.userId)
        .collection('work_history'); // each entry is a document in this collection

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
                    final data = workHistoryDocs[index].data() as Map<String, dynamic>;
                    final title = data['title'] ?? '';
                    final company = data['company'] ?? '';
                    final time = data['time'] ?? '';
                    final description = data['description'] ?? '';

                    return ListTile(
                      title: Text(title),
                      subtitle: Text('$company\n$time\n$description'),
                      isThreeLine: true,
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
