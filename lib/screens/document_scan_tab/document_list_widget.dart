// documents_list_widget.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../helper/database_helper.dart';

class DocumentsListWidget extends StatefulWidget {
  final String searchQuery;
  final String selectedCategory;

  const DocumentsListWidget({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
  });

  @override
  DocumentsListWidgetState createState() => DocumentsListWidgetState();
}

// Rename State class to public so we can access it via GlobalKey
class DocumentsListWidgetState extends State<DocumentsListWidget> {
  final dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> fetchDocuments() async {
    final allDocs = await dbHelper.getAllDocuments();

    // Apply filters
    return allDocs.where((doc) {
      final matchesSearch =
          widget.searchQuery.isEmpty ||
          doc['title'].toLowerCase().contains(widget.searchQuery.toLowerCase());

      final matchesCategory =
          widget.selectedCategory == 'All Categories' ||
          doc['tag'] == widget.selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Center(child: Text('No documents found.'));
        }

        final docs = snapshot.data as List<Map<String, dynamic>>;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "All Documents (${docs.length})",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Removed Expanded widget to avoid layout issues
            ListView.builder(
              shrinkWrap: true,
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final file = File(doc['filePath']);
                final fileExists = file.existsSync();

                // Handle file deletion if it doesn't exist
                if (!fileExists) {
                  Future.microtask(() => deleteDocument(doc['id']));
                }

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      final filePath = doc['filePath'];
                      final file = File(filePath);
                      final extension = file.path.split('.').last.toLowerCase();

                      if (file.existsSync()) {
                        OpenFilex.open(file.path);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('File does not exist')),
                        );
                      }
                    },
                    onLongPress: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Document?'),
                          content: Text(
                            'Are you sure you want to delete "${doc['title']}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await deleteDocument(doc['id']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Document deleted')),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.all(8),
                          child: fileExists
                              ? _getFilePreview(file) // Use your file preview method
                              : Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Chip(
                                  label: Text(
                                    doc['tag'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.blueAccent,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Scanned: ${doc['dateScanned']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getFilePreview(File file) {
    final fileExtension = file.path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
      // For image files
      return Image.file(file, fit: BoxFit.cover);
    } else if (fileExtension == 'pdf') {
      // For PDF files
      return Icon(
        Icons.picture_as_pdf,
        size: 50,
        color: Colors.red,
      ); // You could also use PDF viewer
    } else if (['doc', 'docx', 'txt', 'xls'].contains(fileExtension)) {
      // For Document files like Word, Text, or Excel
      return Icon(Icons.text_snippet, size: 50, color: Colors.blue);
    } else {
      // For unknown or unsupported file types
      return Icon(Icons.insert_drive_file, size: 50, color: Colors.grey);
    }
  }
}
