import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfilePortfolioWidget extends StatefulWidget {
  final String userId;

  const ProfilePortfolioWidget({
    super.key,
    required this.userId,
  });

  @override
  _ProfilePortfolioWidgetState createState() => _ProfilePortfolioWidgetState();
}

class _ProfilePortfolioWidgetState extends State<ProfilePortfolioWidget> {
  final firestore = FirebaseFirestore.instance;

  File? _profileImage;
  File? _backgroundImage;
  bool _isUploading = false;
  String? _profileImagePath;
  String? _backgroundImagePath;

  @override
  void initState() {
    super.initState();
    _fetchExistingPaths();
  }

  Future<void> _fetchExistingPaths() async {
    final doc = await firestore.collection('users').doc(widget.userId).get();
    if (doc.exists) {
      setState(() {
        _profileImagePath = doc['profile_picture_path'];
        _backgroundImagePath = doc['background_picture_path'];

        if (_profileImagePath != null) _profileImage = File(_profileImagePath!);
        if (_backgroundImagePath != null) _backgroundImage = File(_backgroundImagePath!);
      });
    }
  }

  Future<File> _saveImageLocally(XFile image, bool isProfile) async {
    final directory = await getApplicationDocumentsDirectory();
    final folderName = isProfile ? 'profile_pictures' : 'background_pictures';

    final folderPath = path.join(directory.path, folderName);
    await Directory(folderPath).create(recursive: true);  // Create folder if not exists

    final fileName = '${widget.userId}.jpg';
    final newPath = path.join(folderPath, fileName);
    final newImage = await File(image.path).copy(newPath);

    return newImage;
  }

  Future<void> _pickImage(bool isProfile) async {
    final directory = await getApplicationDocumentsDirectory();
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        final savedImage = await _saveImageLocally(image, isProfile);

        final field = isProfile ? 'profile_picture_path' : 'background_picture_path';
        final filePath = savedImage.path;

        await firestore.collection('users').doc(widget.userId).set({
          field: filePath,
        }, SetOptions(merge: true));

        setState(() {
          if (isProfile) {
            _profileImage = savedImage;
            _profileImagePath = filePath;
          } else {
            _backgroundImage = savedImage;
            _backgroundImagePath = filePath;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isProfile ? 'Profile' : 'Background'} picture updated!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Background Image (Cover photo)
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _backgroundImage != null && _backgroundImage!.existsSync()
                      ? Image.file(_backgroundImage!, width: double.infinity, height: 150, fit: BoxFit.cover)
                      : Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 100),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _pickImage(false),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Profile Picture (Avatar)
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null && _profileImage!.existsSync()
                      ? FileImage(_profileImage!)
                      : null,
                  child: (_profileImage == null || !_profileImage!.existsSync())
                      ? Icon(Icons.account_circle, size: 100)
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _pickImage(true),
                ),
              ],
            ),
            SizedBox(height: 16),

            if (_isUploading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
