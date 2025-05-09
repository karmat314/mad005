import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class DocumentScanScreen extends StatefulWidget {
  const DocumentScanScreen({super.key});

  @override
  State<DocumentScanScreen> createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends State<DocumentScanScreen> {
  String dropdownvalue = 'Document';
  final _key = GlobalKey<ExpandableFabState>();

  // List of items in our dropdown menu
  var items = ['Document', 'Id Card', 'Passport', 'Driving Licence'];

  void onChanged(String? newValue) {
    setState(() {
      dropdownvalue = newValue!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Document Scan")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
            ),
            SizedBox(height: 20),
            DropdownButtonFormField(
              decoration: InputDecoration(prefixIcon: Icon(Icons.folder)),
              value: dropdownvalue,
              items:
                  items.map((String item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        distance: 70,
        children: const [
          Row(
            children: [
              Text('Upload File'),
              SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: null,
                child: Icon(Icons.upload_file),
              ),
            ],
          ),
          Row(
            children: [
              Text('Upload Audio'),
              SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: null,
                child: Icon(Icons.mic),
              ),
            ],
          ),
          Row(
            children: [
              Text('Scan with Camera'),
              SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: null,
                child: Icon(Icons.camera_alt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
