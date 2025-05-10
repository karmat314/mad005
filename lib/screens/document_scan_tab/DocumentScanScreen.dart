import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:intl/intl.dart';
import '../../helper/database_helper.dart';
import '../../helper/uploadService.dart';
import 'document_list_widget.dart';

class DocumentScanScreen extends StatefulWidget {
  const DocumentScanScreen({super.key});

  @override
  State<DocumentScanScreen> createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends State<DocumentScanScreen> {
  final docScanner = FlutterDocScanner();

  late DatabaseHelper dbHelper;
  late UploadService uploadService;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    uploadService = UploadService(dbHelper);
  }

  final GlobalKey<DocumentsListWidgetState> documentsListKey = GlobalKey();

  Future<List<Map<String, dynamic>>> fetchDocuments() async {
    return await dbHelper.getAllDocuments();
  }

  Future<void> deleteDocument(int id) async {
    await dbHelper.deleteDocument(id);
    setState(() {});
  }

  String searchQuery = '';
  String dropdownvalue = 'All Categories';

  final _key = GlobalKey<ExpandableFabState>();

  // List of items in our dropdown menu
  var items = ['All Categories','Document', 'Id Card', 'Passport', 'Driving Licence', 'Audio'];

  void onChanged(String? newValue) {
    setState(() {
      dropdownvalue = newValue!;
    });
  }

  // Generated with ChatGPT
  Future<void> scanAndSave() async {
    final result = await docScanner.getScanDocuments();

    if (result != null) {
      final scannedFile = File(result.first);
      final String fileName = scannedFile.path.split('/').last;
      final String dateScanned = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final List<String> tagOptions = ['Document', 'ID Card', 'Passport', 'Driving Licence'];

      final String? tag = await showDialog<String>(
        context: context,
        builder: (context) {
          String? dropdownValue = tagOptions[0];  // Default value

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Select Tag for Document'),
                content: DropdownButtonFormField<String>(
                  value: dropdownValue,
                  onChanged: (newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                  items: tagOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(hintText: 'Choose a tag'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, dropdownValue),
                    child: Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (tag != null && tag.isNotEmpty) {
        await dbHelper.insertDocument({
          'title': fileName,
          'filePath': scannedFile.path,
          'tag': tag,
          'dateScanned': dateScanned,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document saved!'), duration: Duration(milliseconds: 300),));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tag is required'), duration: Duration(milliseconds: 300)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scan cancelled'), duration: Duration(milliseconds: 300)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Document Scan")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Scan Documents",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text("Manage and organize your important documents by category"),
              SizedBox(height: 20),
              SearchBar(
                leading: Icon(Icons.search),
                hintText: "Search Your Files...",
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),

              SizedBox(height: 20),
              DropdownButtonFormField(
                decoration: InputDecoration(prefixIcon: Icon(Icons.folder)),
                value: dropdownvalue,
                items: items.map((String item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    dropdownvalue = newValue!;
                  });
                },
              ),

              DocumentsListWidget(
                key: documentsListKey,
                searchQuery: searchQuery,
                selectedCategory: dropdownvalue,
              ),

            ],
          ),
        )
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        type: ExpandableFabType.up,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Colors.white.withOpacity(0.9),
        ),
        childrenAnimation: ExpandableFabAnimation.none,
        distance: 70,
        children: [
          Row(
            children: [
              const Text('Upload File'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () async {
                  await uploadService.uploadFileAndSave(context);
                  documentsListKey.currentState?.refreshDocuments();
                },
                child: const Icon(Icons.upload_file),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Upload Audio'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () async {
                  await uploadService.uploadAudio(context);
                  documentsListKey.currentState?.refreshDocuments();
                },
                child: const Icon(Icons.mic),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Scan with Camera'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  scanAndSave();
                  documentsListKey.currentState?.refreshDocuments();
                },
                child: const Icon(Icons.camera_alt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
