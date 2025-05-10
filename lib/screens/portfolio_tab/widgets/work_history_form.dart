import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddWorkHistoryForm extends StatefulWidget {
  final String? workHistoryId;

  const AddWorkHistoryForm({super.key, this.workHistoryId});

  @override
  State<AddWorkHistoryForm> createState() => _AddWorkHistoryFormState();
}

class _AddWorkHistoryFormState extends State<AddWorkHistoryForm> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  // Load data if editing an existing work history
  @override
  void initState() {
    super.initState();
    if (widget.workHistoryId != null) {
      _loadWorkHistory();
    }
  }

  void _loadWorkHistory() async {
    final workHistoryRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('work_history')
        .doc(widget.workHistoryId);

    final docSnapshot = await workHistoryRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _companyController.text = data['company'] ?? '';
      _timeController.text = data['time'] ?? '';
      _descriptionController.text = data['description'] ?? '';
    }
  }

  void _saveWorkHistory() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not signed in')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final workHistoryRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('work_history');

    final workHistoryData = {
      'title': _titleController.text.trim(),
      'company': _companyController.text.trim(),
      'time': _timeController.text.trim(),
      'description': _descriptionController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (widget.workHistoryId == null) {
      // Add new work history
      await workHistoryRef.add(workHistoryData);
    } else {
      // Update existing work history
      await workHistoryRef.doc(widget.workHistoryId).update(workHistoryData);
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop(); // Close form after saving
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.workHistoryId == null ? 'Add Work History' : 'Edit Work History'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
                validator: (value) => value!.isEmpty ? 'Enter job title' : null,
              ),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company'),
                validator: (value) => value!.isEmpty ? 'Enter company' : null,
              ),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time (e.g., 2020-2022)'),
                validator: (value) => value!.isEmpty ? 'Enter time period' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveWorkHistory,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.workHistoryId == null ? 'Save' : 'Update'),
        ),
      ],
    );
  }
}
