import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
class TrainingCertificationsWidget extends StatefulWidget {
  final String userId;

  const TrainingCertificationsWidget({super.key, required this.userId});

  @override
  State<TrainingCertificationsWidget> createState() => _TrainingCertificationsWidgetState();
}

class _TrainingCertificationsWidgetState extends State<TrainingCertificationsWidget> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  void _showTrainingDialog({DocumentSnapshot? doc}) {
    final _nameController = TextEditingController(text: doc != null ? doc['name'] : '');
    final _companyController = TextEditingController(text: doc != null ? doc['company'] : '');
    final _tagController = TextEditingController(text: doc != null ? doc['tag'] : '');
    String? documentPath = doc != null ? doc['documentPath'] : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(doc == null ? 'Add Training / Certification' : 'Edit Training / Certification'),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          documentPath != null
                              ? 'Document: ${documentPath?.split('/').last}'
                              : 'No document selected',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles();
                          if (result != null && result.files.single.path != null) {
                            setState(() {
                              documentPath = result.files.single.path!;
                            });
                          }
                        },
                      ),
                    ],
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

                    final data = {
                      'name': name,
                      'company': company,
                      'tag': tag,
                      'documentPath': documentPath ?? '',
                    };

                    if (doc == null) {
                      await trainingRef.add(data);
                    } else {
                      await doc.reference.update(data);
                    }

                    Navigator.of(context).pop();
                  }
                },
                child: Text(doc == null ? 'Add' : 'Update'),
              ),
            ],
          );
        });
      },
    );
  }

  void _confirmDelete(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await doc.reference.delete();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _viewDocument(String? path) async {
    if (path != null && path.isNotEmpty && await File(path).exists()) {
      await OpenFilex.open(path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document not found or invalid path')),
      );
    }
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
                  onPressed: () => _showTrainingDialog(),
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
                    final documentPath = data['documentPath'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(company),
                            const SizedBox(height: 4),
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
                            if (documentPath.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Doc: ${documentPath.split('/').last}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showTrainingDialog(doc: doc);
                            } else if (value == 'delete') {
                              _confirmDelete(doc);
                            } else if (value == 'view_doc') {
                              _viewDocument(documentPath);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                            if (documentPath.isNotEmpty)
                              const PopupMenuItem(value: 'view_doc', child: Text('View Document')),
                          ],
                        ),
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
