import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';

class UploadService {
  final DatabaseHelper dbHelper;

  UploadService(this.dbHelper);


  // Generated with help of ChatGPT
  Future<void> uploadFileAndSave(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;
      final String dateScanned = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final List<String> tagOptions = ['Document', 'ID Card', 'Passport', 'Driving Licence'];

      final String? tag = await showDialog<String>(
        context: context,
        builder: (context) {
          String? dropdownValue = tagOptions[0];  // Default value

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Select Tag for File'),
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
                  decoration: const InputDecoration(hintText: 'Choose a tag'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, dropdownValue),
                    child: const Text('Save'),
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
          'filePath': filePath,
          'tag': tag,
          'dateScanned': dateScanned,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded and saved!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tag is required')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File selection cancelled')),
      );
    }
  }
}
