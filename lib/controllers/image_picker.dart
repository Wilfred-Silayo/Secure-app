import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart'; // For file path manipulation
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  // Pick a profile picture from the camera or gallery and save it locally
  Future<String?> pickProfilePicture(BuildContext context) async {
    // Request camera and storage permissions
    await _requestPermissions();

    final ImagePicker picker = ImagePicker();

    // Show a dialog for the user to choose between camera or gallery
    final XFile? pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pick a Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Camera"),
                onTap: () async {
                  Navigator.of(context)
                      .pop(await picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.of(context)
                      .pop(await picker.pickImage(source: ImageSource.gallery));
                },
              ),
            ],
          ),
        );
      },
    );

    // If the user selected an image
    if (pickedFile != null) {
      // Save the image locally
      String savedImagePath = await _saveImageLocally(pickedFile);
      return savedImagePath;
    }
    return null;
  }

  // Request camera and storage permissions at runtime
  Future<void> _requestPermissions() async {
    // Request permission for the camera and storage
    PermissionStatus cameraStatus = await Permission.camera.status;
    PermissionStatus storageStatus = await Permission.storage.status;

    // Request permission if not granted
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }

    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
  }

  // Save the image locally
  Future<String> _saveImageLocally(XFile pickedFile) async {
    // Get the app's documents directory
    final directory = await getApplicationDocumentsDirectory();
    final fileName = basename(pickedFile.path);
    final localPath = '${directory.path}/$fileName';
    
    final File localFile = File(localPath);
    await pickedFile.saveTo(localFile.path);
    
    return localFile.path; 
  }
}
