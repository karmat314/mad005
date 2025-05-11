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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    final isSmallScreen = screenWidth < 350;
    final isLargeScreen = screenWidth > 600;

    final cardRadius = isSmallScreen ? 8.0 : 12.0;
    final backgroundHeight = isSmallScreen ? 120.0 : (isLargeScreen ? 180.0 : 150.0);
    final avatarRadius = isSmallScreen ? 50.0 : (isLargeScreen ? 70.0 : 60.0);
    final avatarTopPosition = backgroundHeight - avatarRadius;
    final avatarHorizontalOffset = screenWidth / 2 - avatarRadius ;
    final iconSize = isSmallScreen ? 80.0 : (isLargeScreen ? 120.0 : 100.0);
    final editIconSize = isSmallScreen ? 18.0 : 24.0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Stack(
          clipBehavior: Clip.none, // Allow overflow for profile pic
          children: [
            // Background Image (Cover photo)
            ClipRRect(
              borderRadius: BorderRadius.circular(cardRadius - 4), // Slightly smaller than card radius
              child: _backgroundImage != null && _backgroundImage!.existsSync()
                  ? Image.file(
                _backgroundImage!,
                width: double.infinity,
                height: backgroundHeight,
                fit: BoxFit.cover,
              )
                  : Container(
                width: double.infinity,
                height: backgroundHeight,
                color: Colors.grey[300],
                child: Icon(Icons.image, size: iconSize),
              ),
            ),
            // Profile Picture (Avatar)
            Positioned(
              top: avatarTopPosition,
              left: 0,
              right: 0,
              child: Center(
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: _profileImage != null && _profileImage!.existsSync()
                      ? FileImage(_profileImage!)
                      : null,
                  child: (_profileImage == null || !_profileImage!.existsSync())
                      ? Icon(Icons.account_circle, size: iconSize)
                      : null,
                ),
              ),
            ),

            // Edit icon for background image
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.edit, color: Colors.white, size: editIconSize),
                onPressed: () => _pickImage(false),
              ),
            ),
            // Edit icon for profile image
            Positioned(
              bottom: 10,
              right: avatarHorizontalOffset + avatarRadius - editIconSize - 60,
              child: IconButton(
                icon: Icon(Icons.edit, size: editIconSize),
                onPressed: () => _pickImage(true),
              ),
            ),
            // Show progress indicator if uploading
            if (_isUploading)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: backgroundHeight / 2),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
