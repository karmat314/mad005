// documents_list_widget.dart

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/database_helper.dart';

class DocumentsListWidget extends StatefulWidget {
  const DocumentsListWidget({super.key});

  @override
  DocumentsListWidgetState createState() => DocumentsListWidgetState();
}

// Rename State class to public so we can access it via GlobalKey
class DocumentsListWidgetState extends State<DocumentsListWidget> {
  final dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> fetchDocuments() async {
    return await dbHelper.getAllDocuments();
  }

  Future<void> deleteDocument(int id) async {
    await dbHelper.deleteDocument(id);
    setState(() {});
  }

  // ✨ Public refresh method to be called from outside
  void refreshDocuments() {
    setState(() {}); // Rebuild and refetch documents
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchDocuments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || (snapshot.data as List).isEmpty)
          return Center(child: Text('No documents found.'));

        final docs = snapshot.data as List<Map<String, dynamic>>;
        return ListView.builder(
          shrinkWrap: true, // So it works inside Column
          physics: NeverScrollableScrollPhysics(), // Disable scroll inside Column
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  // Your navigation here (optional)
                },
                onLongPress: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete Document?'),
                      content: Text('Are you sure you want to delete "${doc['title']}"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await deleteDocument(doc['id']);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document deleted')));
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.all(8),
                      child: Image.file(
                        File(doc['filePath']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc['title'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Chip(
                              label: Text(doc['tag'], style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.blueAccent,
                            ),
                            SizedBox(height: 6),
                            Text('Scanned: ${doc['dateScanned']}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
