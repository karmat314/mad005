import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainingCertificationsWidget extends StatefulWidget {
  final String userId;

  const TrainingCertificationsWidget({super.key, required this.userId});

  @override
  State<TrainingCertificationsWidget> createState() => _TrainingCertificationsWidgetState();
}

class _TrainingCertificationsWidgetState extends State<TrainingCertificationsWidget> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  void _showAddTrainingDialog() {
    final _nameController = TextEditingController();
    final _companyController = TextEditingController();
    final _tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Training / Certification'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: 'Company'),
                ),
                TextField(
                  controller: _tagController,
                  decoration: const InputDecoration(labelText: 'Tag (e.g., Online, Workshop)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final company = _companyController.text.trim();
                final tag = _tagController.text.trim();

                if (name.isNotEmpty && company.isNotEmpty && tag.isNotEmpty) {
                  final trainingRef = db
                      .collection('users')
                      .doc(widget.userId)
                      .collection('training_certifications');

                  await trainingRef.add({
                    'name': name,
                    'company': company,
                    'tag': tag,
                  });

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
    final trainingRef = db
        .collection('users')
        .doc(widget.userId)
        .collection('training_certifications');

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
                  'Training & Certifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddTrainingDialog,
                )
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: trainingRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final trainingDocs = snapshot.data!.docs;

                if (trainingDocs.isEmpty) {
                  return const Text('No trainings or certifications added yet.');
                }

                return Column(
                  children: trainingDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? '';
                    final company = data['company'] ?? '';
                    final tag = data['tag'] ?? '';

                    return ListTile(
                      title: Text(name),
                      subtitle: Row(
                        children: [
                          Text(company),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

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
