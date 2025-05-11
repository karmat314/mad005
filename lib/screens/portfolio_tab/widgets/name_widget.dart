import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NameWidget extends StatefulWidget {
  final String userId;
  final bool isViewer;
  const NameWidget({super.key, required this.userId, required this.isViewer});

  @override
  State<NameWidget> createState() => _NameWidgetState();
}

class _NameWidgetState extends State<NameWidget> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  void _showEditDialog(Map<String, dynamic> data) {
    final _nameController = TextEditingController(text: data['name']);
    final _jobTitleController = TextEditingController(text: data['jobTitle']);
    final _descriptionController = TextEditingController(text: data['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(labelText: 'Job Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final contactRef = db.collection('users').doc(widget.userId).collection('profile').doc('about');

                await contactRef.set({
                  'name': _nameController.text.trim(),
                  'jobTitle': _jobTitleController.text.trim(),
                  'description': _descriptionController.text.trim(),
                });

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactRef = db.collection('users').doc(widget.userId).collection('profile').doc('about');

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<DocumentSnapshot>(
          stream: contactRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading user details'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            final name = data['name'] ?? 'No name set';
            final jobTitle = data['jobTitle'] ?? 'No job title set';
            final description = data['description'] ?? 'No description set';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blueAccent,
                    child: const Icon(Icons.account_circle, size: 32, color: Colors.white),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(jobTitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  trailing: widget.isViewer? null : IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(data),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
